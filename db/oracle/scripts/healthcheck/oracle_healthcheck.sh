#!/bin/bash
# =============================================================================
# Oracle Health Check Script
#
# MODOS DE AUTENTICACAO (escolha um):
#
# 1) OS Authentication (/ as sysdba) — sem senha, usuario do SO no grupo dba:
#      ./oracle_healthcheck.sh <SID> --os [ORACLE_HOME]
#
# 2) Interativo — script solicita a senha sem echo (nao fica no history):
#      ./oracle_healthcheck.sh <SID> <USUARIO> [ORACLE_HOME]
#
# 3) Arquivo de credencial — para automacao/cron (chmod 600 obrigatorio):
#      echo 'SENHA' > ~/.oracle_hc_pass && chmod 600 ~/.oracle_hc_pass
#      ORACLE_HC_PASSFILE=~/.oracle_hc_pass ./oracle_healthcheck.sh <SID> <USER>
#
# 4) Oracle Wallet — mais seguro para automacao:
#      mkstore -wrl ~/.oracle/wallet -createCredential <SID> <USER> <PASS>
#      ./oracle_healthcheck.sh <SID> <USUARIO> [ORACLE_HOME] --wallet
#
# NUNCA passe a senha como argumento posicional — exposta em ps aux e audit logs.
# =============================================================================

set -uo pipefail

# ---------------------------------------------------------------------------
# ARGUMENTOS E MODO DE AUTENTICACAO
# ---------------------------------------------------------------------------
USE_OS=false
USE_WALLET=false
DB_PASS=""
DB_USER=""

print_usage() {
  echo ""
  echo "Uso:"
  echo "  $0 <SID> --os [ORACLE_HOME]                    # OS auth (/ as sysdba)"
  echo "  $0 <SID> <USUARIO> [ORACLE_HOME]               # senha interativa"
  echo "  $0 <SID> <USUARIO> [ORACLE_HOME] --wallet      # Oracle Wallet"
  echo "  ORACLE_HC_PASSFILE=<arq> $0 <SID> <USUARIO>   # arquivo seguro"
  echo ""
  echo "Exemplos:"
  echo "  $0 PROD --os"
  echo "  $0 PROD --os /u01/app/oracle/product/19.0.0/dbhome_1"
  echo "  $0 PROD sys"
  echo "  $0 PROD sys /u01/app/oracle/product/19.0.0/dbhome_1 --wallet"
  echo ""
}

if [[ $# -lt 1 ]]; then
  print_usage; exit 1
fi

ORACLE_SID="$1"
shift  # remove SID da lista de args — o que resta sao opcoes/usuario/home

# Detectar modo --os
for arg in "$@"; do
  [[ "$arg" == "--os" ]] && USE_OS=true
  [[ "$arg" == "--wallet" ]] && USE_WALLET=true
done

if [[ "$USE_OS" == "true" && "$USE_WALLET" == "true" ]]; then
  echo "ERRO: --os e --wallet sao mutuamente exclusivos."
  exit 1
fi

# Extrair ORACLE_HOME e USUARIO da lista de argumentos restantes
# Argumentos validos apos SID: <USUARIO> [ORACLE_HOME] [--os|--wallet]
ORACLE_HOME="${ORACLE_HOME:-}"
for arg in "$@"; do
  [[ "$arg" == "--os" || "$arg" == "--wallet" ]] && continue
  if [[ -z "$DB_USER" && "$USE_OS" == "false" ]]; then
    DB_USER="$arg"
  elif [[ -d "$arg" || "$arg" == /* ]]; then
    ORACLE_HOME="$arg"
  elif [[ -z "$DB_USER" && "$USE_OS" == "true" ]]; then
    # No modo --os o segundo argumento pode ser o ORACLE_HOME
    [[ -z "$ORACLE_HOME" ]] && ORACLE_HOME="$arg"
  fi
done

# Validar argumentos minimos
if [[ "$USE_OS" == "false" && -z "$DB_USER" ]]; then
  echo "ERRO: usuario obrigatorio quando nao usar --os."
  print_usage; exit 1
fi

# ---------------------------------------------------------------------------
# LEITURA DA CREDENCIAL CONFORME MODO
# ---------------------------------------------------------------------------
if [[ "$USE_OS" == "true" ]]; then
  echo "[AUTH] Modo: OS Authentication (/ as sysdba)"
  echo "       Usuario do SO '$(id -un)' deve estar no grupo dba/oinstall."

elif [[ "$USE_WALLET" == "true" ]]; then
  echo "[AUTH] Modo: Oracle Wallet"
  echo "       Certifique-se que sqlnet.ora aponta para o wallet correto."

elif [[ -n "${ORACLE_HC_PASSFILE:-}" ]]; then
  if [[ ! -f "$ORACLE_HC_PASSFILE" ]]; then
    echo "ERRO: ORACLE_HC_PASSFILE='$ORACLE_HC_PASSFILE' nao encontrado."
    exit 1
  fi
  PERM=$(stat -c '%a' "$ORACLE_HC_PASSFILE" 2>/dev/null || stat -f '%OLp' "$ORACLE_HC_PASSFILE" 2>/dev/null)
  if [[ "$PERM" != "600" && "$PERM" != "400" ]]; then
    echo "ERRO: $ORACLE_HC_PASSFILE com permissao $PERM — exigido 600 ou 400."
    echo "      Correcao: chmod 600 $ORACLE_HC_PASSFILE"
    exit 1
  fi
  DB_PASS=$(< "$ORACLE_HC_PASSFILE")
  [[ -z "$DB_PASS" ]] && { echo "ERRO: $ORACLE_HC_PASSFILE esta vazio."; exit 1; }
  echo "[AUTH] Modo: arquivo seguro ($ORACLE_HC_PASSFILE)"

else
  # Modo interativo: read -s nao exibe a senha no terminal
  echo ""
  printf "[AUTH] Senha para %s@%s: " "$DB_USER" "$ORACLE_SID"
  read -r -s DB_PASS
  echo ""
  [[ -z "$DB_PASS" ]] && { echo "ERRO: senha nao pode ser vazia."; exit 1; }
fi

export ORACLE_SID

# ---------------------------------------------------------------------------
# RESOLUCAO DO ORACLE_HOME
# ---------------------------------------------------------------------------
if [[ -z "$ORACLE_HOME" ]]; then
  if [[ -f /etc/oratab ]]; then
    ORACLE_HOME=$(awk -F: -v sid="$ORACLE_SID" '$1==sid{print $2}' /etc/oratab | head -1)
  fi
  if [[ -z "$ORACLE_HOME" ]]; then
    echo "ERRO: ORACLE_HOME nao encontrado para SID=$ORACLE_SID. Passe como 4 argumento."
    exit 1
  fi
fi

export ORACLE_HOME
export PATH="$ORACLE_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$ORACLE_HOME/lib:${LD_LIBRARY_PATH:-}"

SQLPLUS="$ORACLE_HOME/bin/sqlplus"
if [[ ! -x "$SQLPLUS" ]]; then
  echo "ERRO: sqlplus nao encontrado em $ORACLE_HOME/bin"
  exit 1
fi

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
HOSTNAME=$(hostname -s)
OUTPUT_HTML="oracle_hc_${ORACLE_SID}_${TIMESTAMP}.html"
TMP_SQL="/tmp/oracle_hc_$$.sql"
TMP_OUT="/tmp/oracle_hc_out_$$.txt"

# ---------------------------------------------------------------------------
# CLEANUP
# ---------------------------------------------------------------------------
cleanup() { rm -f "$TMP_SQL" "$TMP_OUT"; }
trap cleanup EXIT

echo "======================================================"
echo "  Oracle Health Check --- SID: $ORACLE_SID"
echo "======================================================"
echo "  Host      : $HOSTNAME"
echo "  ORACLE_HOME: $ORACLE_HOME"
echo "  Relatorio  : $OUTPUT_HTML"
echo ""

# ---------------------------------------------------------------------------
# COLETA OS
# ---------------------------------------------------------------------------
# Mapa de permissoes necessarias (sem sudo):
#   cat /sys/kernel/mm/...   -> leitura publica, qualquer usuario
#   cat /proc/meminfo        -> leitura publica, qualquer usuario
#   sysctl -n <param>        -> leitura publica, qualquer usuario
#   uname, hostname          -> leitura publica, qualquer usuario
#   timedatectl status       -> leitura publica, qualquer usuario
#   ip link show             -> leitura publica, qualquer usuario
#   lsblk                    -> leitura publica, qualquer usuario
#   cat /sys/block/*/queue/scheduler -> leitura publica, qualquer usuario
#   tuned-adm active         -> leitura publica, qualquer usuario
#   dmesg                    -> REQUER root ou CAP_SYSLOG (kernel >= 3.7)
#                               alternativa: /var/log/messages ou journalctl
#   su - oracle -c ulimit    -> REQUER root (para mudar de usuario)
#                               alternativa: ler /etc/security/limits.d/ diretamente
# ---------------------------------------------------------------------------
collect_os() {
  # -- tuned: leitura publica
  TUNED_ACTIVE=$(tuned-adm active 2>/dev/null | awk '/Current active profile/{print $NF}' || echo "N/A")

  # -- THP e HugePages: /sys e /proc sao publicos
  THP_ENABLED=$(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || echo "N/A")
  THP_DEFRAG=$(cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || echo "N/A")
  HP_TOTAL=$(grep -i HugePages_Total /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
  HP_FREE=$(grep  -i HugePages_Free  /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
  HP_SIZE=$(grep  -i Hugepagesize    /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "2048")

  # -- ulimits do usuario oracle
  # Preferencia 1: se o script ja roda como oracle, pegar direto
  # Preferencia 2: ler /etc/security/limits.d/ (sem root)
  # Fallback:      tentar su - oracle (requer root)
  OPEN_FILES="N/A"
  if [[ "$(id -un)" == "oracle" ]]; then
    OPEN_FILES=$(ulimit -n 2>/dev/null || echo "N/A")
  elif [[ -d /etc/security/limits.d ]]; then
    # Ler limite de nofile dos arquivos de configuracao (sem root)
    OPEN_FILES=$(grep -h "oracle.*nofile\|oracle.*open" /etc/security/limits.d/*.conf /etc/security/limits.conf 2>/dev/null       | awk '/hard/{print $NF}' | tail -1 || echo "N/A (ver /etc/security/limits.d/)")
    [[ -z "$OPEN_FILES" ]] && OPEN_FILES="N/A (ver /etc/security/limits.d/)"
  fi
  # Ultimo recurso com su (so funciona como root)
  if [[ "$OPEN_FILES" == "N/A"* && $EUID -eq 0 ]]; then
    OPEN_FILES=$(su - oracle -c "ulimit -n" 2>/dev/null || echo "N/A")
  fi

  # -- sysctl: leitura publica (escrita requer root, mas -n para leitura nao)
  SWAPPINESS=$(sysctl -n vm.swappiness 2>/dev/null || echo "N/A")
  DIRTY_RATIO=$(sysctl -n vm.dirty_ratio 2>/dev/null || echo "N/A")
  DIRTY_BG=$(sysctl -n vm.dirty_background_ratio 2>/dev/null || echo "N/A")
  NUMA_BAL=$(sysctl -n kernel.numa_balancing 2>/dev/null || echo "N/A")

  # -- uname, timedatectl, ip, lsblk: publicos
  KERNEL_VER=$(uname -r)
  NTP_SYNC=$(timedatectl status 2>/dev/null | grep "NTP synchronized" | awk '{print $NF}' || echo "N/A")

  # -- dmesg: requer CAP_SYSLOG (root ou sysctl kernel.dmesg_restrict=0)
  # Tentar dmesg; fallback para journalctl (nao requer root no systemd)
  OOM_COUNT="0"
  if dmesg 2>/dev/null | head -1 >/dev/null 2>&1; then
    OOM_COUNT=$(dmesg 2>/dev/null | grep -ci "oom\|killed process" || echo "0")
  elif journalctl -k --no-pager -q 2>/dev/null | head -1 >/dev/null 2>&1; then
    OOM_COUNT=$(journalctl -k --no-pager -q 2>/dev/null | grep -ci "oom\|killed process" || echo "0")
    OOM_COUNT="${OOM_COUNT} (via journalctl)"
  else
    OOM_COUNT="N/A (requer root ou kernel.dmesg_restrict=0)"
  fi

  # -- I/O scheduler: /sys/block publico
  IO_SCHEDULERS=""
  for disk in $(lsblk -d -o NAME 2>/dev/null | grep -v NAME); do
    sched=$(cat /sys/block/$disk/queue/scheduler 2>/dev/null | grep -oP '\[\K[^\]]+' || echo "?")
    IO_SCHEDULERS="${IO_SCHEDULERS}${disk}:${sched} "
  done
  [[ -z "$IO_SCHEDULERS" ]] && IO_SCHEDULERS="N/A"
}

# ---------------------------------------------------------------------------
# COLETA MTU
# ---------------------------------------------------------------------------
collect_net() {
  NET_IFACES=""
  while IFS= read -r line; do
    iface=$(echo "$line" | awk '{print $2}' | tr -d ':')
    mtu=$(ip link show "$iface" 2>/dev/null | awk '/mtu/{for(i=1;i<=NF;i++) if($i=="mtu") print $(i+1)}')
    NET_IFACES="${NET_IFACES}${iface}(MTU=${mtu}) "
  done < <(ip link show 2>/dev/null | grep "^[0-9]" || true)
  [[ -z "$NET_IFACES" ]] && NET_IFACES="N/A"
}

# ---------------------------------------------------------------------------
# COLETA DO BANCO
# ---------------------------------------------------------------------------
collect_db() {
  cat > "$TMP_SQL" <<'ENDSQL'
SET PAGESIZE 0
SET LINESIZE 500
SET FEEDBACK OFF
SET HEADING OFF
SET TRIMSPOOL ON
SET ECHO OFF
SET VERIFY OFF
SET WRAP OFF
WHENEVER SQLERROR CONTINUE

PROMPT ##DB_DETECT_START##
SELECT 'CDB='||cdb||'|ROLE='||database_role||'|LOG_MODE='||log_mode||'|FLASH='||flashback_on||'|NAME='||name FROM v$database;
PROMPT ##DB_DETECT_END##

PROMPT ##INSTANCES_START##
SELECT inst_id||'|'||instance_name||'|'||version||'|'||status||'|'||database_status FROM gv$instance ORDER BY 1;
PROMPT ##INSTANCES_END##

PROMPT ##PATCHES_START##
SELECT TO_CHAR(action_time,'DD/MM/YYYY HH24:MI')||'|'||patch_id||'|'||SUBSTR(description,1,70)||'|'||action FROM dba_registry_sqlpatch ORDER BY action_time DESC FETCH FIRST 10 ROWS ONLY;
PROMPT ##PATCHES_END##

PROMPT ##REGISTRY_START##
SELECT comp_name||'|'||version||'|'||status FROM dba_registry ORDER BY status, comp_name;
PROMPT ##REGISTRY_END##

PROMPT ##INVALID_START##
SELECT owner||'|'||object_type||'|'||COUNT(*) FROM dba_objects WHERE status='INVALID' GROUP BY owner, object_type ORDER BY 3 DESC;
PROMPT ##INVALID_END##

PROMPT ##MEM_PARAMS_START##
SELECT name||'='||value FROM v$parameter WHERE name IN ('memory_target','memory_max_target','sga_target','pga_aggregate_target','use_large_pages','sga_max_size') ORDER BY name;
PROMPT ##MEM_PARAMS_END##

PROMPT ##FRA_START##
SELECT name||'|'||ROUND(space_limit/1024/1024/1024,2)||'|'||ROUND(space_used/1024/1024/1024,2)||'|'||ROUND(space_used/NULLIF(space_limit,0)*100,2) FROM v$recovery_file_dest;
PROMPT ##FRA_END##

PROMPT ##FRA_USAGE_START##
SELECT file_type||'|'||ROUND(percent_space_used,2)||'|'||number_of_files FROM v$recovery_area_usage ORDER BY percent_space_used DESC;
PROMPT ##FRA_USAGE_END##

PROMPT ##REDO_START##
SELECT l.group#||'|'||l.members||'|'||ROUND(l.bytes/1024/1024)||'|'||l.status FROM v$log l ORDER BY l.group#;
PROMPT ##REDO_END##

PROMPT ##REDO_SWITCHES_START##
SELECT TO_CHAR(first_time,'DD/MM/YYYY HH24')||'|'||COUNT(*) FROM v$archived_log WHERE first_time > SYSDATE-1 GROUP BY TO_CHAR(first_time,'DD/MM/YYYY HH24') ORDER BY 1 DESC FETCH FIRST 10 ROWS ONLY;
PROMPT ##REDO_SWITCHES_END##

PROMPT ##UNDO_START##
SELECT name||'='||value FROM v$parameter WHERE name IN ('undo_management','undo_tablespace','undo_retention') ORDER BY name;
PROMPT ##UNDO_END##

PROMPT ##TS_START##
SELECT tablespace_name||'|'||ROUND(used_space*8192/1024/1024)||'|'||ROUND(tablespace_size*8192/1024/1024)||'|'||ROUND((1-used_space/NULLIF(tablespace_size,0))*100,2) FROM dba_tablespace_usage_metrics ORDER BY 4;
PROMPT ##TS_END##

PROMPT ##FLASHLOG_START##
SELECT NVL(TO_CHAR(oldest_flashback_time,'DD/MM/YYYY HH24:MI'),'N/A')||'|'||NVL(TO_CHAR(retention_target),'N/A')||'|'||NVL(TO_CHAR(ROUND(flashback_size/1024/1024/1024,2)),'N/A') FROM v$flashback_database_log;
PROMPT ##FLASHLOG_END##

PROMPT ##RMAN_START##
SELECT TO_CHAR(start_time,'DD/MM/YYYY HH24:MI')||'|'||input_type||'|'||status||'|'||ROUND(elapsed_seconds/60)||'|'||ROUND(output_bytes/1024/1024/1024,2) FROM v$rman_backup_job_details ORDER BY start_time DESC FETCH FIRST 5 ROWS ONLY;
PROMPT ##RMAN_END##

PROMPT ##RECYCLE_START##
SELECT COUNT(*)||'|'||NVL(TO_CHAR(ROUND(SUM(space)*8192/1024/1024,2)),'0') FROM dba_recyclebin;
PROMPT ##RECYCLE_END##

PROMPT ##AUDIT_START##
SELECT COUNT(*)||'|'||NVL(TO_CHAR(MIN(ntimestamp#),'DD/MM/YYYY'),'N/A')||'|'||NVL(TO_CHAR(MAX(ntimestamp#),'DD/MM/YYYY'),'N/A') FROM sys.aud$;
PROMPT ##AUDIT_END##

PROMPT ##NLS_START##
SELECT parameter||'='||value FROM nls_database_parameters WHERE parameter IN ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET','NLS_LANGUAGE','NLS_TERRITORY') ORDER BY parameter;
PROMPT ##NLS_END##

PROMPT ##TZ_START##
SELECT version FROM v$timezone_file;
PROMPT ##TZ_END##

PROMPT ##BLOCKSIZE_START##
SELECT tablespace_name||'|'||block_size||'|'||contents FROM dba_tablespaces ORDER BY block_size, tablespace_name;
PROMPT ##BLOCKSIZE_END##

PROMPT ##WAITS_START##
SELECT event||'|'||total_waits||'|'||time_waited||'|'||ROUND(average_wait,2) FROM v$system_event WHERE event NOT LIKE 'SQL*Net%' AND event NOT IN ('rdbms ipc message','pmon timer','smon timer','dispatcher timer','virtual circuit status','pipe get','wakeup time manager','Streams AQ: waiting for messages in the queue','class slave wait') ORDER BY time_waited DESC FETCH FIRST 15 ROWS ONLY;
PROMPT ##WAITS_END##

PROMPT ##ASH_START##
SELECT event||'|'||COUNT(*) FROM v$active_session_history WHERE sample_time > SYSDATE-5/1440 AND session_state='WAITING' GROUP BY event ORDER BY 2 DESC FETCH FIRST 10 ROWS ONLY;
PROMPT ##ASH_END##

PROMPT ##BCHIT_START##
SELECT ROUND((1-(phy.value/NULLIF(cur.value+con.value,0)))*100,2) FROM v$sysstat phy, v$sysstat cur, v$sysstat con WHERE phy.name='physical reads' AND cur.name='db block gets' AND con.name='consistent gets';
PROMPT ##BCHIT_END##

PROMPT ##DBAPRIV_START##
SELECT grantee||'|'||admin_option FROM dba_role_privs WHERE granted_role='DBA' AND grantee NOT IN ('SYS','SYSTEM','SYSDG','SYSBACKUP','SYSKM','DBA') ORDER BY grantee;
PROMPT ##DBAPRIV_END##

PROMPT ##DEFUSERS_START##
SELECT username||'|'||account_status||'|'||NVL(TO_CHAR(expiry_date,'DD/MM/YYYY'),'N/A') FROM dba_users WHERE username IN ('SCOTT','HR','OE','SH','OUTLN','DBSNMP','ANONYMOUS','XDB','APEX_PUBLIC_USER') AND account_status NOT IN ('LOCKED','EXPIRED & LOCKED');
PROMPT ##DEFUSERS_END##

PROMPT ##DBLINKS_START##
SELECT owner||'|'||db_link||'|'||NVL(username,'(current_user)')||'|'||host FROM dba_db_links ORDER BY owner;
PROMPT ##DBLINKS_END##

PROMPT ##AUDITPARAM_START##
SELECT name||'='||value FROM v$parameter WHERE name IN ('audit_trail','unified_auditing') ORDER BY name;
PROMPT ##AUDITPARAM_END##

PROMPT ##DG_START##
SELECT name||'='||value FROM v$parameter WHERE name IN ('log_archive_dest_1','log_archive_dest_2','dg_broker_start','standby_file_management','fal_server') ORDER BY name;
PROMPT ##DG_END##

PROMPT ##DGSTATS_START##
SELECT name||'|'||value||'|'||NVL(TO_CHAR(datum_time,'DD/MM/YYYY HH24:MI'),'N/A') FROM v$dataguard_stats WHERE name IN ('transport lag','apply lag','apply finish time');
PROMPT ##DGSTATS_END##

PROMPT ##DGPROCESS_START##
SELECT process||'|'||status||'|'||sequence# FROM v$managed_standby ORDER BY process;
PROMPT ##DGPROCESS_END##

PROMPT ##DGARCH_GAP_START##
SELECT thread#||'|'||low_sequence#||'|'||high_sequence# FROM v$archive_gap;
PROMPT ##DGARCH_GAP_END##

PROMPT ##STATS_START##
SELECT TO_CHAR(MAX(last_analyzed),'DD/MM/YYYY HH24:MI') FROM dba_tables WHERE owner='SYS' AND last_analyzed IS NOT NULL;
PROMPT ##STATS_END##

PROMPT ##ASM_START##
SELECT name||'|'||type||'|'||total_mb||'|'||free_mb||'|'||ROUND((1-free_mb/NULLIF(total_mb,0))*100,1) FROM v$asm_diskgroup ORDER BY name;
PROMPT ##ASM_END##

EXIT;
ENDSQL

  # Credenciais NUNCA vao como argumento de linha de comando (expostas em ps aux/audit logs).
  if [[ "$USE_OS" == "true" ]]; then
    # OS Authentication: / as sysdba — sem usuario/senha, usa grupo dba do SO
    "$SQLPLUS" -S -L "/ as sysdba" @"$TMP_SQL" > "$TMP_OUT" 2>&1

  elif [[ "$USE_WALLET" == "true" ]]; then
    # Oracle Wallet: credencial armazenada no wallet, sem senha em disco ou memoria
    "$SQLPLUS" -S -L "/@${ORACLE_SID} as sysdba" @"$TMP_SQL" > "$TMP_OUT" 2>&1

  else
    # Interativo / arquivo: CONNECT enviado via pipe para stdin — invisivel ao ps
    {
      printf 'CONNECT %s/"%s"@%s AS SYSDBA\n' "$DB_USER" "$DB_PASS" "$ORACLE_SID"
      cat "$TMP_SQL"
    } | "$SQLPLUS" -S -L /nolog > "$TMP_OUT" 2>&1
  fi
}

# ---------------------------------------------------------------------------
# PARSE HELPERS
# ---------------------------------------------------------------------------
extract_section() {
  local tag="$1"
  sed -n "/##${tag}_START##/,/##${tag}_END##/p" "$TMP_OUT" \
    | grep -v "##${tag}_" \
    | grep -v "^[[:space:]]*$" || true
}

get_param() {
  local section="$1" key="$2"
  extract_section "$section" | grep "^${key}=" | cut -d= -f2- | head -1 || echo ""
}

# ---------------------------------------------------------------------------
# HTML HELPERS
# ---------------------------------------------------------------------------
badge() {
  case "$1" in
    OK)      echo '<span class="badge ok">&#10003; OK</span>' ;;
    ATENCAO) echo '<span class="badge warn">&#9888; ATENCAO</span>' ;;
    CRITICO) echo '<span class="badge crit">&#128308; CRITICO</span>' ;;
    INFO)    echo '<span class="badge info">&#8505; INFO</span>' ;;
    *)       echo "<span class=\"badge info\">$1</span>" ;;
  esac
}

item_row() {
  local item="$1" found="$2" expected="$3" reason="$4" status="$5" fix="${6:-}"
  local fix_html=""
  if [[ -n "$fix" ]]; then
    fix_html="<tr class=\"fix-row\"><td colspan=\"5\"><div class=\"fix-block\"><div class=\"fix-label\">CORRECAO:</div><pre class=\"fix-code\">${fix}</pre></div></td></tr>"
  fi
  echo "<tr class=\"item-row s-${status,,}\"><td class=\"iname\">${item}</td><td>${found}</td><td>${expected}</td><td class=\"reason\">${reason}</td><td>$(badge "$status")</td></tr>${fix_html}"
}

tbl_header() {
  echo "<tr class=\"col-hdr\"><th>Item</th><th>Valor Encontrado</th><th>Valor Esperado</th><th>Motivo / Impacto</th><th>Status</th></tr>"
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
echo "-> Coletando dados do SO..."
collect_os

echo "-> Coletando dados de rede..."
collect_net

echo "-> Conectando ao banco $ORACLE_SID..."
collect_db

echo "-> Processando resultados..."

# ---------------------------------------------------------------------------
# PARSE BANCO
# ---------------------------------------------------------------------------
DB_LINE=$(extract_section "DB_DETECT" | head -1)
IS_CDB=$(echo "$DB_LINE"   | grep -oP 'CDB=\K[^|]+' || echo "N/A")
DB_ROLE=$(echo "$DB_LINE"  | grep -oP 'ROLE=\K[^|]+' || echo "N/A")
LOG_MODE=$(echo "$DB_LINE" | grep -oP 'LOG_MODE=\K[^|]+' || echo "N/A")
FLASH_ON=$(echo "$DB_LINE" | grep -oP 'FLASH=\K[^|]+' || echo "N/A")
DB_NAME=$(echo "$DB_LINE"  | grep -oP 'NAME=\K[^|]+' || echo "$ORACLE_SID")

MEM_TARGET=$(get_param "MEM_PARAMS" "memory_target")
MEM_MAX=$(get_param "MEM_PARAMS" "memory_max_target")
SGA_TARGET=$(get_param "MEM_PARAMS" "sga_target")
PGA_TARGET=$(get_param "MEM_PARAMS" "pga_aggregate_target")
USE_LARGE=$(get_param "MEM_PARAMS" "use_large_pages")
SGA_MAX=$(get_param "MEM_PARAMS" "sga_max_size")

FRA_LINE=$(extract_section "FRA" | head -1)
FRA_NAME=$(echo "$FRA_LINE"   | cut -d'|' -f1)
FRA_LIMIT=$(echo "$FRA_LINE"  | cut -d'|' -f2)
FRA_USED=$(echo "$FRA_LINE"   | cut -d'|' -f3)
FRA_PCT=$(echo "$FRA_LINE"    | cut -d'|' -f4)

RECYCLE_LINE=$(extract_section "RECYCLE" | head -1)
RECYCLE_CNT=$(echo "$RECYCLE_LINE" | cut -d'|' -f1 | tr -d ' ')
RECYCLE_MB=$(echo "$RECYCLE_LINE"  | cut -d'|' -f2 | tr -d ' ')

AUDIT_LINE=$(extract_section "AUDIT" | head -1)
AUDIT_CNT=$(echo "$AUDIT_LINE"  | cut -d'|' -f1 | tr -d ' ')
AUDIT_MIN=$(echo "$AUDIT_LINE"  | cut -d'|' -f2)
AUDIT_MAX=$(echo "$AUDIT_LINE"  | cut -d'|' -f3)

BCHIT=$(extract_section "BCHIT" | head -1 | tr -d ' ')
TZ_VER=$(extract_section "TZ" | head -1 | tr -d ' ')
STATS_DATE=$(extract_section "STATS" | head -1 | tr -d ' ')

UNDO_MGT=$(get_param "UNDO" "undo_management")
UNDO_RETENTION=$(get_param "UNDO" "undo_retention")
AUDIT_TRAIL=$(get_param "AUDITPARAM" "audit_trail")
UNIFIED_AUD=$(get_param "AUDITPARAM" "unified_auditing")
DG_BROKER=$(get_param "DG" "dg_broker_start")

NLS_CHARSET=$(get_param "NLS" "NLS_CHARACTERSET")

# ---------------------------------------------------------------------------
# ANALISES - STATUS
# ---------------------------------------------------------------------------
# Tuned
if echo "$TUNED_ACTIVE" | grep -qiE "oracle|throughput-performance"; then
  TUNED_STATUS="OK"; TUNED_FIX=""
else
  TUNED_STATUS="ATENCAO"
  TUNED_FIX="tuned-adm profile oracle
# ou: tuned-adm profile throughput-performance"
fi

# THP Enabled
if echo "$THP_ENABLED" | grep -q "\[never\]"; then
  THP_EN_STATUS="OK"; THP_EN_FIX=""
else
  THP_EN_STATUS="CRITICO"
  THP_EN_FIX='echo never > /sys/kernel/mm/transparent_hugepage/enabled
# Persistir - adicionar ao /etc/rc.d/rc.local ou via grubby:
# grubby --update-kernel=ALL --args="transparent_hugepage=never"'
fi

# THP Defrag
if echo "$THP_DEFRAG" | grep -q "\[never\]"; then
  THP_DF_STATUS="OK"; THP_DF_FIX=""
else
  THP_DF_STATUS="CRITICO"
  THP_DF_FIX='echo never > /sys/kernel/mm/transparent_hugepage/defrag
# Persistir em /etc/rc.d/rc.local'
fi

# HugePages
HP_MB=$(( HP_TOTAL * HP_SIZE / 1024 ))
if [[ "$HP_TOTAL" -gt 0 && "$HP_FREE" -gt 0 ]]; then
  HP_STATUS="OK"; HP_FIX=""
elif [[ "$HP_TOTAL" -gt 0 ]]; then
  HP_STATUS="ATENCAO"
  HP_FIX="# HugePages_Free = 0 — SGA pode nao caber integralmente
# Calcular novo valor: (SGA_MB / hugepage_size_MB) * 1.10
sysctl -w vm.nr_hugepages=<NOVO_VALOR>
echo 'vm.nr_hugepages = <NOVO_VALOR>' > /etc/sysctl.d/99-oracle-hugepages.conf"
else
  HP_STATUS="ATENCAO"
  HP_FIX="# Calcular: (SGA_MB / 2) * 1.10 = nr_hugepages
sysctl -w vm.nr_hugepages=<VALOR>
echo 'vm.nr_hugepages = <VALOR>' > /etc/sysctl.d/99-oracle-hugepages.conf
sysctl -p /etc/sysctl.d/99-oracle-hugepages.conf"
fi

# AMM
if [[ "${MEM_TARGET:-0}" == "0" || -z "${MEM_TARGET:-}" ]]; then
  AMM_STATUS="OK"; AMM_FIX=""
else
  AMM_STATUS="CRITICO"
  AMM_FIX="ALTER SYSTEM SET memory_target=0 SCOPE=SPFILE SID='*';
ALTER SYSTEM SET memory_max_target=0 SCOPE=SPFILE SID='*';
ALTER SYSTEM SET sga_target=<VALOR>M SCOPE=SPFILE SID='*';
ALTER SYSTEM SET pga_aggregate_target=<VALOR>M SCOPE=SPFILE SID='*';
ALTER SYSTEM SET use_large_pages=TRUE SCOPE=SPFILE SID='*';
-- Reiniciar todas as instancias apos alteracao"
fi

# use_large_pages
if echo "${USE_LARGE:-}" | grep -qi "TRUE\|ONLY"; then
  ULP_STATUS="OK"; ULP_FIX=""
else
  ULP_STATUS="ATENCAO"
  ULP_FIX="ALTER SYSTEM SET use_large_pages=TRUE SCOPE=SPFILE SID='*';
-- Requer restart da instancia para ativar"
fi

# Swappiness
SWAP_INT="${SWAPPINESS:-99}"
if [[ "$SWAP_INT" =~ ^[0-9]+$ && "$SWAP_INT" -le 10 ]]; then
  SWAP_STATUS="OK"; SWAP_FIX=""
else
  SWAP_STATUS="ATENCAO"
  SWAP_FIX="sysctl -w vm.swappiness=10
echo 'vm.swappiness = 10' >> /etc/sysctl.d/99-oracle.conf
sysctl -p /etc/sysctl.d/99-oracle.conf"
fi

# NUMA
if [[ "${NUMA_BAL:-1}" == "0" ]]; then
  NUMA_STATUS="OK"; NUMA_FIX=""
else
  NUMA_STATUS="ATENCAO"
  NUMA_FIX="sysctl -w kernel.numa_balancing=0
echo 'kernel.numa_balancing = 0' >> /etc/sysctl.d/99-oracle.conf"
fi

# Open Files
OFILES_INT="${OPEN_FILES:-0}"
if [[ "$OFILES_INT" == "unlimited" || ( "$OFILES_INT" =~ ^[0-9]+$ && "$OFILES_INT" -ge 65536 ) ]]; then
  OFILES_STATUS="OK"; OFILES_FIX=""
else
  OFILES_STATUS="ATENCAO"
  OFILES_FIX="cat > /etc/security/limits.d/99-oracle.conf <<'EOF'
oracle soft nofile 65536
oracle hard nofile 65536
oracle soft nproc  16384
oracle hard nproc  16384
oracle soft stack  10240
oracle hard stack  32768
EOF
# Requer novo login do usuario oracle para ativar"
fi

# NTP
if echo "${NTP_SYNC:-no}" | grep -qi "yes"; then
  NTP_STATUS="OK"; NTP_FIX=""
else
  NTP_STATUS="CRITICO"
  NTP_FIX="systemctl enable --now chronyd
timedatectl set-ntp true
chronyc makestep"
fi

# OOM
OOM_INT="${OOM_COUNT:-0}"
if [[ "$OOM_INT" =~ ^[0-9]+$ && "$OOM_INT" -eq 0 ]]; then
  OOM_STATUS="OK"; OOM_FIX=""
else
  OOM_STATUS="CRITICO"
  OOM_FIX="# Investigar causa raiz primeiro (memory leak ou RAM subdimensionada)
# Protecao temporaria:
for pid in \$(pgrep -u oracle); do
  echo -1000 > /proc/\$pid/oom_score_adj 2>/dev/null
done
# Ver detalhes: dmesg | grep -A 10 'oom-killer'"
fi

# Archivelog
if [[ "$LOG_MODE" == "ARCHIVELOG" ]]; then
  ARCH_STATUS="OK"; ARCH_FIX=""
else
  ARCH_STATUS="CRITICO"
  ARCH_FIX="-- ATENCAO: Requer parada do banco
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER SYSTEM ARCHIVE LOG CURRENT;"
fi

# Flashback
if [[ "$FLASH_ON" == "YES" ]]; then
  FLASH_STATUS="OK"; FLASH_FIX=""
else
  FLASH_STATUS="ATENCAO"
  FLASH_FIX="-- Verificar FRA configurada antes de habilitar:
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE=<TAMANHO>G SCOPE=BOTH;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST='<FRA_PATH>' SCOPE=BOTH;
ALTER DATABASE FLASHBACK ON;"
fi

# FRA PCT
FRA_PCT_INT=$(echo "${FRA_PCT:-0}" | cut -d. -f1 | tr -d ' ')
if [[ ! "$FRA_PCT_INT" =~ ^[0-9]+$ ]]; then
  FRA_STATUS="INFO"; FRA_FIX=""
elif [[ "$FRA_PCT_INT" -ge 90 ]]; then
  FRA_STATUS="CRITICO"
  FRA_FIX="-- Ampliar FRA imediatamente:
ALTER SYSTEM SET db_recovery_file_dest_size=<NOVO_GB>G SCOPE=BOTH;
-- ou liberar via RMAN:
RMAN> DELETE OBSOLETE;
RMAN> DELETE EXPIRED BACKUP;"
elif [[ "$FRA_PCT_INT" -ge 80 ]]; then
  FRA_STATUS="ATENCAO"
  FRA_FIX="ALTER SYSTEM SET db_recovery_file_dest_size=<NOVO_GB>G SCOPE=BOTH;
-- ou via RMAN: DELETE OBSOLETE;"
else
  FRA_STATUS="OK"; FRA_FIX=""
fi

# Recyclebin
RC_INT=$(echo "${RECYCLE_CNT:-0}" | tr -d ' \n')
if [[ "$RC_INT" =~ ^[0-9]+$ && "$RC_INT" -eq 0 ]]; then
  RECYCLE_STATUS="OK"; RECYCLE_FIX=""
else
  RECYCLE_STATUS="ATENCAO"
  RECYCLE_FIX="PURGE DBA_RECYCLEBIN;
-- Verificar resultado:
SELECT count(*) FROM dba_recyclebin;"
fi

# Audit$
AC_INT=$(echo "${AUDIT_CNT:-0}" | tr -d ' \n')
if [[ "$AC_INT" =~ ^[0-9]+$ && "$AC_INT" -gt 1000000 ]]; then
  AUDIT_STATUS="ATENCAO"
  AUDIT_FIX="DELETE FROM sys.aud\$ WHERE ntimestamp# < SYSTIMESTAMP - INTERVAL '30' DAY;
COMMIT;
-- Agendar purge regular:
EXEC DBMS_AUDIT_MGMT.INIT_CLEANUP(
  audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
  default_cleanup_interval => 24);
EXEC DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
  audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
  audit_trail_purge_interval => 24,
  audit_trail_purge_name => 'DAILY_AUD_PURGE',
  use_last_arch_timestamp => TRUE);"
else
  AUDIT_STATUS="OK"; AUDIT_FIX=""
fi

# Buffer Cache Hit
BCHIT_INT=$(echo "${BCHIT:-0}" | cut -d. -f1 | tr -d ' ')
if [[ "$BCHIT_INT" =~ ^[0-9]+$ && "$BCHIT_INT" -ge 95 ]]; then
  BCHIT_STATUS="OK"; BCHIT_FIX=""
else
  BCHIT_STATUS="ATENCAO"
  BCHIT_FIX="-- Verificar dimensionamento do Buffer Cache:
SELECT round(size_for_estimate/1024/1024) mb_estimate,
       estd_physical_reads,
       estd_physical_read_factor
FROM v\$db_cache_advice
WHERE name='DEFAULT' AND block_size=8192
ORDER BY 1;
-- Se factor < 1 para tamanho maior, aumentar sga_target:
ALTER SYSTEM SET sga_target=<NOVO_VALOR>M SCOPE=BOTH;"
fi

# Undo Management
if [[ "${UNDO_MGT:-}" == "AUTO" ]]; then
  UNDO_STATUS="OK"; UNDO_FIX=""
else
  UNDO_STATUS="ATENCAO"
  UNDO_FIX="ALTER SYSTEM SET undo_management=AUTO SCOPE=SPFILE;
-- Requer restart do banco"
fi

# Auditoria
if echo "${AUDIT_TRAIL:-} ${UNIFIED_AUD:-}" | grep -qiE "DB|UNIFIED|TRUE"; then
  AUDPARAM_STATUS="OK"; AUDPARAM_FIX=""
else
  AUDPARAM_STATUS="ATENCAO"
  AUDPARAM_FIX="ALTER SYSTEM SET audit_trail=DB SCOPE=SPFILE;
-- Requer restart do banco para ativar"
fi

# DG Broker
if [[ "$DB_ROLE" == "PRIMARY" ]]; then
  if [[ "${DG_BROKER:-}" == "TRUE" ]]; then
    DGB_STATUS="OK"; DGB_FIX=""
  else
    DGB_STATUS="ATENCAO"
    DGB_FIX="ALTER SYSTEM SET dg_broker_start=TRUE SCOPE=BOTH;"
  fi
else
  DGB_STATUS="INFO"; DGB_FIX=""
fi

# SGA_MAX vs SGA_TARGET
SGA_MAX_INT=$(echo "${SGA_MAX:-0}" | tr -d ' ')
SGA_TGT_INT=$(echo "${SGA_TARGET:-0}" | tr -d ' ')
if [[ "$SGA_MAX_INT" =~ ^[0-9]+$ && "$SGA_TGT_INT" =~ ^[0-9]+$ && "$SGA_MAX_INT" -ge "$SGA_TGT_INT" && "$SGA_TGT_INT" -gt 0 ]]; then
  SGAMAX_STATUS="OK"; SGAMAX_FIX=""
else
  SGAMAX_STATUS="ATENCAO"
  SGAMAX_FIX="ALTER SYSTEM SET sga_max_size=<VALOR>M SCOPE=SPFILE SID='*';
-- sga_max_size deve ser >= sga_target
-- Requer restart"
fi

# ---------------------------------------------------------------------------
# CONTADORES
# ---------------------------------------------------------------------------
COUNT_CRITICO=0
COUNT_ATENCAO=0
COUNT_OK=0

for s in $TUNED_STATUS $THP_EN_STATUS $THP_DF_STATUS $HP_STATUS $AMM_STATUS $ULP_STATUS \
         $SWAP_STATUS $NUMA_STATUS $OFILES_STATUS $NTP_STATUS $OOM_STATUS \
         $ARCH_STATUS $FRA_STATUS $FLASH_STATUS $RECYCLE_STATUS $AUDIT_STATUS \
         $BCHIT_STATUS $UNDO_STATUS $AUDPARAM_STATUS $DGB_STATUS $SGAMAX_STATUS; do
  case $s in
    CRITICO) COUNT_CRITICO=$((COUNT_CRITICO+1)) ;;
    ATENCAO) COUNT_ATENCAO=$((COUNT_ATENCAO+1)) ;;
    OK)      COUNT_OK=$((COUNT_OK+1)) ;;
  esac
done

# ---------------------------------------------------------------------------
# GERAR HTML
# ---------------------------------------------------------------------------
echo "-> Gerando HTML: $OUTPUT_HTML"

cat > "$OUTPUT_HTML" << 'HTMLSTART'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
HTMLSTART

echo "<title>Oracle HC — ${DB_NAME} — ${TIMESTAMP}</title>" >> "$OUTPUT_HTML"

cat >> "$OUTPUT_HTML" << 'HTMLCSS'
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Inter:wght@400;500;600;700;800&display=swap');
:root{
  /* Fundo branco com superficies levemente cinzas — maximo contraste */
  --bg:#f1f5f9;
  --surf:#ffffff;
  --surf2:#f8fafc;
  --surf3:#f1f5f9;
  --bord:#e2e8f0;
  --bord2:#cbd5e1;

  /* Texto com hierarquia clara */
  --txt:#1e293b;        /* texto principal — quase preto */
  --txt-m:#475569;      /* texto secundario — cinza medio escuro */
  --txt-s:#64748b;      /* texto terciario — cinza */
  --txt-b:#0f172a;      /* titulo — preto total */

  /* Acento azul Oracle */
  --acc:#1d4ed8;
  --acc-l:#3b82f6;
  --acc2:#4f46e5;

  /* Status com fundo pastel legivel */
  --ok:#15803d;   --ok-b:#dcfce7;   --ok-bd:#86efac;
  --wn:#b45309;   --wn-b:#fef3c7;   --wn-bd:#fcd34d;
  --cr:#b91c1c;   --cr-b:#fee2e2;   --cr-bd:#fca5a5;
  --inf:#475569;  --inf-b:#f1f5f9;  --inf-bd:#cbd5e1;

  --mono:'JetBrains Mono',monospace;
  --sans:'Inter',sans-serif;
  --radius:8px;
  --shadow:0 1px 3px rgba(0,0,0,.08),0 1px 2px rgba(0,0,0,.06);
  --shadow-md:0 4px 6px rgba(0,0,0,.07),0 2px 4px rgba(0,0,0,.06);
}
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth}
body{background:var(--bg);color:var(--txt);font-family:var(--sans);font-size:13px;line-height:1.6}

/* HEADER */
.ph{
  background:linear-gradient(135deg,#1e3a5f 0%,#1d4ed8 60%,#1e40af 100%);
  border-bottom:3px solid #1e40af;
  padding:28px 36px 24px;
  position:relative;overflow:hidden;
}
.ph::after{
  content:'';position:absolute;top:-40px;right:-40px;
  width:220px;height:220px;border-radius:50%;
  background:rgba(255,255,255,.05);pointer-events:none;
}
.ph-eye{font-family:var(--mono);font-size:10px;letter-spacing:.2em;text-transform:uppercase;color:rgba(255,255,255,.65);margin-bottom:6px}
.ph-title{font-size:26px;font-weight:800;color:#fff;letter-spacing:-.3px}
.ph-title span{color:#93c5fd}
.ph-meta{display:flex;gap:20px;margin-top:16px;flex-wrap:wrap}
.mi{display:flex;flex-direction:column;gap:2px}
.ml{font-family:var(--mono);font-size:10px;text-transform:uppercase;letter-spacing:.1em;color:rgba(255,255,255,.5)}
.mv{font-family:var(--mono);font-size:12px;color:rgba(255,255,255,.92);font-weight:500}

/* COUNTERS */
.sb{display:flex;gap:14px;padding:16px 36px;background:#fff;border-bottom:1px solid var(--bord);flex-wrap:wrap;box-shadow:var(--shadow)}
.sc{display:flex;align-items:center;gap:12px;padding:12px 20px;border-radius:var(--radius);border:1px solid;flex:1;min-width:150px}
.sc.cr{background:var(--cr-b);border-color:var(--cr-bd)}
.sc.wn{background:var(--wn-b);border-color:var(--wn-bd)}
.sc.ok{background:var(--ok-b);border-color:var(--ok-bd)}
.sn{font-size:32px;font-weight:800;font-family:var(--mono);line-height:1}
.sn.cr{color:var(--cr)}.sn.wn{color:var(--wn)}.sn.ok{color:var(--ok)}
.sl{font-size:12px;font-weight:600;line-height:1.3}
.sl.cr{color:var(--cr)}.sl.wn{color:var(--wn)}.sl.ok{color:var(--ok)}

/* NAV */
.toc{background:#fff;border-bottom:1px solid var(--bord);padding:10px 36px;display:flex;gap:6px;flex-wrap:wrap;position:sticky;top:0;z-index:10;box-shadow:var(--shadow)}
.toc a{font-family:var(--mono);font-size:10px;color:var(--txt-s);text-decoration:none;padding:4px 10px;border-radius:20px;border:1px solid var(--bord2);transition:all .15s;font-weight:500}
.toc a:hover{color:var(--acc);border-color:var(--acc);background:#eff6ff}

/* CONTENT */
.cnt{padding:28px 36px;max-width:1600px;margin:0 auto}

/* SECTION */
.sb2{margin-bottom:28px;border:1px solid var(--bord);border-radius:var(--radius);overflow:hidden;background:var(--surf);box-shadow:var(--shadow)}
.st{
  background:linear-gradient(90deg,#1e3a5f,#1d4ed8);
  padding:11px 18px;font-size:11px;font-weight:700;
  letter-spacing:.08em;text-transform:uppercase;
  color:#fff;
  border-bottom:1px solid var(--bord);
  display:flex;align-items:center;gap:8px;
}
.st::before{content:'';width:3px;height:14px;background:rgba(255,255,255,.6);border-radius:2px;flex-shrink:0}

/* MAIN TABLE */
table{width:100%;border-collapse:collapse}
.col-hdr th{
  background:var(--surf2);
  font-family:var(--mono);font-size:10px;text-transform:uppercase;
  letter-spacing:.08em;color:var(--txt-s);
  padding:8px 14px;text-align:left;
  border-bottom:2px solid var(--bord2);
  font-weight:600;
}
.item-row td{padding:10px 14px;border-bottom:1px solid var(--bord);vertical-align:top;font-size:12px;color:var(--txt)}
.item-row:last-child td{border-bottom:none}
.item-row:hover td{background:#f8fafc}

/* Status row highlight — fundo pastel suave */
.s-critico td{border-left:4px solid var(--cr);background:#fff8f8}
.s-critico:hover td{background:#fee2e2}
.s-atencao td{border-left:4px solid var(--wn);background:#fffdf0}
.s-atencao:hover td{background:#fef3c7}
.s-ok td{border-left:4px solid var(--ok)}
.s-info td{border-left:4px solid var(--bord2)}

.iname{font-family:var(--mono);font-size:11px;color:var(--txt-b);font-weight:700;white-space:nowrap;min-width:200px}
.reason{color:var(--txt-m);font-size:12px}

/* BADGES */
.badge{display:inline-flex;align-items:center;padding:3px 10px;border-radius:20px;font-family:var(--mono);font-size:10px;font-weight:700;white-space:nowrap;border:1px solid}
.badge.ok  {background:var(--ok-b);color:var(--ok);border-color:var(--ok-bd)}
.badge.warn{background:var(--wn-b);color:var(--wn);border-color:var(--wn-bd)}
.badge.crit{background:var(--cr-b);color:var(--cr);border-color:var(--cr-bd)}
.badge.info{background:var(--inf-b);color:var(--inf);border-color:var(--inf-bd)}

/* FIX BLOCK */
.fix-row{background:#fafbff}
.fix-block{padding:10px 14px 14px}
.fix-label{
  font-family:var(--mono);font-size:10px;text-transform:uppercase;
  letter-spacing:.12em;color:var(--cr);margin-bottom:6px;font-weight:700;
  display:flex;align-items:center;gap:6px;
}
.fix-label::before{content:'';display:inline-block;width:6px;height:6px;background:var(--cr);border-radius:50%}
.fix-code{
  background:#1e293b;
  border:1px solid #334155;
  border-left:3px solid var(--acc-l);
  border-radius:6px;
  padding:12px 16px;
  font-family:var(--mono);font-size:11px;
  color:#e2e8f0;
  overflow-x:auto;white-space:pre;line-height:1.8;
}

/* DATA TABLES */
.dt{width:100%;border-collapse:collapse;font-family:var(--mono);font-size:11px}
.dt th{
  background:var(--surf2);color:var(--txt-s);font-size:10px;
  text-transform:uppercase;letter-spacing:.07em;
  padding:7px 12px;text-align:left;
  border-bottom:2px solid var(--bord2);font-weight:600;
}
.dt td{padding:7px 12px;border-bottom:1px solid var(--bord);color:var(--txt)}
.dt tr:hover td{background:#f8fafc}
.dt tr:last-child td{border-bottom:none}
.g{color:var(--ok);font-weight:600}
.w{color:var(--wn);font-weight:600}
.r{color:var(--cr);font-weight:600}
.m{color:var(--txt-s)}

/* INNER TABLE WRAPPER */
.itw{padding:14px 16px}
.itl{
  font-family:var(--mono);font-size:10px;text-transform:uppercase;
  letter-spacing:.08em;color:var(--txt-s);
  margin-bottom:8px;margin-top:14px;font-weight:600;
  padding-bottom:4px;border-bottom:1px solid var(--bord);
}
.itl:first-child{margin-top:0}

/* EXEC SUMMARY */
.es{background:#fff;border:1px solid var(--bord);border-radius:var(--radius);padding:24px 28px;margin-bottom:32px;box-shadow:var(--shadow-md)}
.es-title{font-size:15px;font-weight:800;color:var(--txt-b);margin-bottom:16px;padding-bottom:12px;border-bottom:2px solid var(--bord2);display:flex;align-items:center;gap:8px}
.es-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px}
.es-col{padding:16px;border-radius:6px;border:1px solid}
.es-col.cr{background:var(--cr-b);border-color:var(--cr-bd)}
.es-col.wn{background:var(--wn-b);border-color:var(--wn-bd)}
.es-col.ok{background:var(--ok-b);border-color:var(--ok-bd)}
.es-col-t{font-family:var(--mono);font-size:10px;text-transform:uppercase;letter-spacing:.1em;margin-bottom:10px;font-weight:700}
.es-col-t.cr{color:var(--cr)}.es-col-t.wn{color:var(--wn)}.es-col-t.ok{color:var(--ok)}
.ei{font-size:12px;padding:3px 0;color:var(--txt-m);display:flex;align-items:flex-start;gap:6px}
.ei::before{content:'›';flex-shrink:0;font-weight:700}

/* FOOTER */
.ft{text-align:center;padding:20px;font-family:var(--mono);font-size:10px;color:var(--txt-s);border-top:1px solid var(--bord);margin-top:32px;background:#fff}

@media(max-width:900px){
  .ph,.sb,.toc,.cnt{padding-left:14px;padding-right:14px}
  .es-grid{grid-template-columns:1fr}
}
</style>
</head>
<body>
HTMLCSS

# HEADER
cat >> "$OUTPUT_HTML" << HEOF
<div class="ph">
  <div class="ph-eye">Oracle Health Check Report</div>
  <div class="ph-title">Banco: <span>${DB_NAME}</span></div>
  <div class="ph-meta">
    <div class="mi"><span class="ml">SID</span><span class="mv">${ORACLE_SID}</span></div>
    <div class="mi"><span class="ml">Host</span><span class="mv">${HOSTNAME}</span></div>
    <div class="mi"><span class="ml">Role</span><span class="mv">${DB_ROLE}</span></div>
    <div class="mi"><span class="ml">Log Mode</span><span class="mv">${LOG_MODE}</span></div>
    <div class="mi"><span class="ml">CDB</span><span class="mv">${IS_CDB}</span></div>
    <div class="mi"><span class="ml">Flashback</span><span class="mv">${FLASH_ON}</span></div>
    <div class="mi"><span class="ml">Gerado em</span><span class="mv">$(date '+%d/%m/%Y %H:%M:%S')</span></div>
    <div class="mi"><span class="ml">Oracle Home</span><span class="mv">${ORACLE_HOME}</span></div>
  </div>
</div>

<div class="sb">
  <div class="sc cr"><div class="sn cr">${COUNT_CRITICO}</div><div class="sl">Itens Criticos</div></div>
  <div class="sc wn"><div class="sn wn">${COUNT_ATENCAO}</div><div class="sl">Itens Atencao</div></div>
  <div class="sc ok"><div class="sn ok">${COUNT_OK}</div><div class="sl">Itens OK</div></div>
</div>

<div class="toc">
  <a href="#so">SO</a>
  <a href="#rede">Rede</a>
  <a href="#dbdet">DB / Instancias</a>
  <a href="#mem">Memoria</a>
  <a href="#fra">FRA / Archive</a>
  <a href="#redo">Redo Logs</a>
  <a href="#ts">Tablespaces</a>
  <a href="#undo">Undo</a>
  <a href="#rman">RMAN</a>
  <a href="#obj">Objetos</a>
  <a href="#perf">Performance</a>
  <a href="#seg">Seguranca</a>
  <a href="#dg">Data Guard</a>
  <a href="#patches">Patches</a>
  <a href="#sumario">Sumario</a>
</div>

<div class="cnt">
HEOF

# ============================================================
# BLOCO 1 - SO
# ============================================================
cat >> "$OUTPUT_HTML" << BEOF
<div id="so" class="sb2">
<div class="st">BLOCO 1 — Sistema Operacional</div>
<table>
$(tbl_header)
$(item_row "1.1 Tuned Profile" "$TUNED_ACTIVE" "oracle | throughput-performance" "Gerencia THP, I/O scheduler, CPU latency e buffers de rede para Oracle" "$TUNED_STATUS" "$TUNED_FIX")
$(item_row "1.2 THP Enabled" "$THP_ENABLED" "[never]" "THP causa latencia imprevisivel e conflito com HugePages — incompativel com Oracle (Ref: MOS 1557478.1)" "$THP_EN_STATUS" "$THP_EN_FIX")
$(item_row "1.3 THP Defrag" "$THP_DEFRAG" "[never]" "THP defrag causa latencia e fragmentacao de memoria sob pressao (Ref: MOS 1557478.1)" "$THP_DF_STATUS" "$THP_DF_FIX")
$(item_row "1.4 HugePages" "Total=${HP_TOTAL} | Free=${HP_FREE} | Size=${HP_SIZE}KB | ~${HP_MB}MB" "Total > CEIL(SGA/hugepage_size)*1.10 | Free > 0" "SGA deve residir em HugePages para eliminar overhead de TLB e paginacao (Ref: MOS 361323.1)" "$HP_STATUS" "$HP_FIX")
$(item_row "1.5 vm.swappiness" "$SWAPPINESS" "<= 10" "Evita que o OS faca swap da SGA para disco sob pressao de memoria" "$SWAP_STATUS" "$SWAP_FIX")
$(item_row "1.6 kernel.numa_balancing" "$NUMA_BAL" "0 (desabilitado)" "Oracle gerencia NUMA internamente — balanceamento automatico causa latencia adicional" "$NUMA_STATUS" "$NUMA_FIX")
$(item_row "1.7 Oracle Open Files (ulimit)" "$OPEN_FILES" ">= 65536" "Limites baixos causam ORA-27123 e falhas de spawn de processos background" "$OFILES_STATUS" "$OFILES_FIX")
$(item_row "1.8 vm.dirty_ratio / dirty_bg" "${DIRTY_RATIO}/${DIRTY_BG}" "15/3 (OLTP) | 60/20 (OLAP)" "Controla flush de dirty pages — impacta I/O do redo e datafiles em bulk" "INFO" "")
$(item_row "1.9 I/O Schedulers" "$IO_SCHEDULERS" "deadline | mq-deadline | noop" "cfq prioriza fairness, nao latencia minima — inadequado para Oracle (Ref: MOS 1595273.1)" "INFO" "")
$(item_row "1.10 NTP Sincronizado" "$NTP_SYNC" "yes" "Em RAC, divergencia de clock entre nos pode causar eviction pelo Clusterware (Ref: MOS 1063274.1)" "$NTP_STATUS" "$NTP_FIX")
$(item_row "1.11 OOM Killer (dmesg)" "${OOM_COUNT} evento(s)" "0" "OOM killer matando processos Oracle causa crash sem entrada clara no alert.log" "$OOM_STATUS" "$OOM_FIX")
$(item_row "1.12 Kernel" "$KERNEL_VER" "Certificado para Oracle 19c" "Versao determina compatibilidade com patches Oracle e suporte a Jumbo Frames e HugePages" "INFO" "")
</table>
</div>
BEOF

# ============================================================
# BLOCO 2 - REDE
# ============================================================
cat >> "$OUTPUT_HTML" << BEOF
<div id="rede" class="sb2">
<div class="st">BLOCO 2 — Rede</div>
<table>
$(tbl_header)
$(item_row "2.1 Interfaces / MTU" "$NET_IFACES" "Publica: MTU 1500 | Interconnect RAC: MTU 9000" "MTU 1500 no interconnect causa fragmentacao de pacotes GCS/GES — impacta Cache Fusion em RAC (Ref: MOS 341788.1)" "INFO" "")
</table>
</div>
BEOF

# ============================================================
# BLOCO 3 - DB DETECT
# ============================================================
# Build instances table
INST_HTML=""
while IFS='|' read -r iid iname iver istat idbs; do
  [[ -z "$iid" ]] && continue
  sc=""
  [[ "$istat" == "OPEN" ]] && sc=" class=\"g\""
  INST_HTML="${INST_HTML}<tr><td>${iid}</td><td>${iname}</td><td>${iver}</td><td${sc}>${istat}</td><td>${idbs}</td></tr>"
done < <(extract_section "INSTANCES")

cat >> "$OUTPUT_HTML" << BEOF
<div id="dbdet" class="sb2">
<div class="st">BLOCO 3 — Deteccao e Status do Banco</div>
<table>
$(tbl_header)
$(item_row "3.1 Multitenant (CDB)" "$IS_CDB" "YES/NO (conforme arquitetura)" "CDB=YES requer gerenciamento via PDB — verificar container correto para operacoes" "INFO" "")
$(item_row "3.2 Database Role" "$DB_ROLE" "PRIMARY | PHYSICAL STANDBY" "Define comportamento esperado do banco no contexto HA/DR" "INFO" "")
$(item_row "3.3 Log Mode" "$LOG_MODE" "ARCHIVELOG" "NOARCHIVELOG impede backup online e recuperacao PITR — inaceitavel em producao" "$ARCH_STATUS" "$ARCH_FIX")
$(item_row "3.4 Flashback Database" "$FLASH_ON" "YES" "Permite rollback rapido pos-mudanca sem restore completo via RMAN (Ref: MOS 565535.1)" "$FLASH_STATUS" "$FLASH_FIX")
</table>
<div class="itw">
<div class="itl">Instancias (gv\$instance)</div>
<table class="dt">
<tr><th>INST_ID</th><th>Instance Name</th><th>Versao</th><th>Status</th><th>DB Status</th></tr>
${INST_HTML:-<tr><td colspan="5" class="m">Sem dados</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# BLOCO 4 - MEMORIA
# ============================================================
MEM_MAX_ST=$( [[ "${MEM_MAX:-0}" == "0" || -z "${MEM_MAX:-}" ]] && echo "OK" || echo "ATENCAO" )
SGA_TGT_ST=$( [[ -n "${SGA_TARGET:-}" && "${SGA_TARGET:-0}" != "0" ]] && echo "OK" || echo "ATENCAO" )
PGA_TGT_ST=$( [[ -n "${PGA_TARGET:-}" && "${PGA_TARGET:-0}" != "0" ]] && echo "OK" || echo "ATENCAO" )

cat >> "$OUTPUT_HTML" << BEOF
<div id="mem" class="sb2">
<div class="st">BLOCO 4 — Memoria e SGA</div>
<table>
$(tbl_header)
$(item_row "4.1 memory_target (AMM)" "${MEM_TARGET:-0}" "0 (desabilitado)" "AMM usa /dev/shm e e incompativel com HugePages — impede alocacao dedicada de SGA (Ref: MOS 749851.1)" "$AMM_STATUS" "$AMM_FIX")
$(item_row "4.2 memory_max_target" "${MEM_MAX:-0}" "0" "Deve estar zerado quando AMM esta desabilitado" "$MEM_MAX_ST" "")
$(item_row "4.3 sga_target (ASMM)" "${SGA_TARGET:-N/A}" "> 0" "ASMM ajusta Buffer Cache, Shared Pool, etc. automaticamente sem conflito com HugePages" "$SGA_TGT_ST" "")
$(item_row "4.4 pga_aggregate_target" "${PGA_TARGET:-N/A}" "> 0" "Controla memoria para sort, hash join e bitmap operations — subdimensionado causa disk spill" "$PGA_TGT_ST" "")
$(item_row "4.5 use_large_pages" "${USE_LARGE:-N/A}" "TRUE ou ONLY" "SGA deve usar HugePages para eliminar overhead de TLB miss e instabilidade de memoria (Ref: MOS 361323.1)" "$ULP_STATUS" "$ULP_FIX")
$(item_row "4.6 sga_max_size vs sga_target" "max=${SGA_MAX:-N/A} | target=${SGA_TARGET:-N/A}" "sga_max_size >= sga_target" "sga_max_size menor que sga_target impede crescimento da SGA e causa erros na inicializacao" "$SGAMAX_STATUS" "$SGAMAX_FIX")
</table>
</div>
BEOF

# ============================================================
# BLOCO 5 - FRA
# ============================================================
FRA_USAGE_HTML=""
while IFS='|' read -r ftype fpct ffiles; do
  [[ -z "$ftype" ]] && continue
  fp_int=$(echo "$fpct" | cut -d. -f1 | tr -d ' ')
  fc=""
  [[ "$fp_int" =~ ^[0-9]+$ && "$fp_int" -ge 90 ]] && fc=" class=\"r\""
  [[ "$fp_int" =~ ^[0-9]+$ && "$fp_int" -ge 70 && "$fp_int" -lt 90 ]] && fc=" class=\"w\""
  FRA_USAGE_HTML="${FRA_USAGE_HTML}<tr><td>${ftype}</td><td${fc}>${fpct}%</td><td>${ffiles}</td></tr>"
done < <(extract_section "FRA_USAGE")

cat >> "$OUTPUT_HTML" << BEOF
<div id="fra" class="sb2">
<div class="st">BLOCO 5 — Archivelog e Fast Recovery Area</div>
<table>
$(tbl_header)
$(item_row "5.1 FRA Path" "${FRA_NAME:-N/A}" "Configurada e acessivel" "Repositorio central de archives, backups RMAN e redo multiplexado" "INFO" "")
$(item_row "5.2 FRA Uso" "${FRA_USED:-N/A} GB / ${FRA_LIMIT:-N/A} GB (${FRA_PCT:-N/A}%)" "< 80%" "FRA cheia bloqueia geracao de archives — banco suspende com ORA-19809, ORA-16014 (Ref: MOS 368590.1)" "$FRA_STATUS" "$FRA_FIX")
</table>
<div class="itw">
<div class="itl">FRA por tipo de arquivo</div>
<table class="dt">
<tr><th>Tipo</th><th>% Usado</th><th>Arquivos</th></tr>
${FRA_USAGE_HTML:-<tr><td colspan="3" class="m">Sem dados (FRA pode nao estar configurada)</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# BLOCO 6 - REDO LOGS
# ============================================================
REDO_HTML=""
while IFS='|' read -r grp members mb status; do
  [[ -z "$grp" ]] && continue
  mb_int=$(echo "$mb" | tr -d ' ')
  rc=" class=\"g\""; rmsg="OK"
  if [[ "$mb_int" =~ ^[0-9]+$ && "$mb_int" -lt 200 ]]; then
    rc=" class=\"r\""; rmsg="CRITICO: muito pequeno (recomendado >= 500MB)"
  elif [[ "$mb_int" =~ ^[0-9]+$ && "$mb_int" -lt 500 ]]; then
    rc=" class=\"w\""; rmsg="ATENCAO: considerar >= 500MB para producao"
  fi
  REDO_HTML="${REDO_HTML}<tr><td>${grp}</td><td>${members}</td><td${rc}>${mb} MB</td><td>${status}</td><td${rc}>${rmsg}</td></tr>"
done < <(extract_section "REDO")

SWITCH_HTML=""
while IFS='|' read -r hora cnt; do
  [[ -z "$hora" ]] && continue
  cnt_int=$(echo "$cnt" | tr -d ' ')
  sc=" class=\"g\""; smsg="OK"
  if [[ "$cnt_int" =~ ^[0-9]+$ && "$cnt_int" -gt 6 ]]; then
    sc=" class=\"r\""; smsg="CRITICO: excessivo — aumentar redo logs"
  elif [[ "$cnt_int" =~ ^[0-9]+$ && "$cnt_int" -gt 4 ]]; then
    sc=" class=\"w\""; smsg="ATENCAO: acima do recomendado (<= 4/hora)"
  fi
  SWITCH_HTML="${SWITCH_HTML}<tr><td>${hora}</td><td${sc}>${cnt_int}</td><td${sc}>${smsg}</td></tr>"
done < <(extract_section "REDO_SWITCHES")

cat >> "$OUTPUT_HTML" << BEOF
<div id="redo" class="sb2">
<div class="st">BLOCO 6 — Redo Logs</div>
<div class="itw">
<div class="itl">Grupos de Redo Log</div>
<table class="dt">
<tr><th>Group#</th><th>Members</th><th>Tamanho</th><th>Status</th><th>Avaliacao</th></tr>
${REDO_HTML:-<tr><td colspan="5" class="m">Sem dados</td></tr>}
</table>
<div class="itl">Switches por hora (ultimas 24h) — Esperado: &lt;= 4/hora</div>
<table class="dt">
<tr><th>Hora</th><th>Switches</th><th>Avaliacao</th></tr>
${SWITCH_HTML:-<tr><td colspan="3" class="m">Sem dados (modo NOARCHIVELOG ou sem archives recentes)</td></tr>}
</table>
<div style="font-size:11px;color:var(--txt-m);margin-top:10px;font-family:var(--mono)">
Correcao para redo logs pequenos:<br>
<pre class="fix-code">-- Adicionar novo grupo maior:
ALTER DATABASE ADD LOGFILE GROUP &lt;N&gt; SIZE 500M;
-- Forcar switch e dropar grupo antigo (somente se INACTIVE/UNUSED):
ALTER SYSTEM SWITCH LOGFILE;
ALTER DATABASE DROP LOGFILE GROUP &lt;N_ANTIGO&gt;;</pre>
</div>
</div>
</div>
BEOF

# ============================================================
# BLOCO 7 - TABLESPACES
# ============================================================
TS_HTML=""
while IFS='|' read -r ts used total pfree; do
  [[ -z "$ts" ]] && continue
  pf_int=$(echo "$pfree" | cut -d. -f1 | tr -d ' ')
  tc=" class=\"g\""; tstatus="OK"
  if [[ "$pf_int" =~ ^[0-9]+$ && "$pf_int" -le 5 ]]; then
    tc=" class=\"r\""; tstatus="CRITICO"
  elif [[ "$pf_int" =~ ^[0-9]+$ && "$pf_int" -le 15 ]]; then
    tc=" class=\"w\""; tstatus="ATENCAO"
  fi
  TS_HTML="${TS_HTML}<tr><td>${ts}</td><td>${used} MB</td><td>${total} MB</td><td${tc}>${pfree}%</td><td${tc}>${tstatus}</td></tr>"
done < <(extract_section "TS")

cat >> "$OUTPUT_HTML" << BEOF
<div id="ts" class="sb2">
<div class="st">BLOCO 7 — Tablespaces (dba_tablespace_usage_metrics)</div>
<div class="itw">
<table class="dt">
<tr><th>Tablespace</th><th>Usado</th><th>Total</th><th>% Livre</th><th>Status</th></tr>
${TS_HTML:-<tr><td colspan="5" class="m">Sem dados</td></tr>}
</table>
<div style="font-size:11px;color:var(--txt-m);margin-top:10px;font-family:var(--mono)">
Minimo para upgrade: SYSTEM >= 1GB livre | SYSAUX >= 2GB | TEMP >= 2GB | UNDO >= 2GB (Ref: MOS 2361040.1)</div>
</div>
</div>
BEOF

# ============================================================
# BLOCO 8 - UNDO
# ============================================================
cat >> "$OUTPUT_HTML" << BEOF
<div id="undo" class="sb2">
<div class="st">BLOCO 8 — Undo</div>
<table>
$(tbl_header)
$(item_row "8.1 undo_management" "${UNDO_MGT:-N/A}" "AUTO" "Gestao automatica de undo elimina conflitos de alocacao manual (Ref: Oracle DB Admin Guide)" "$UNDO_STATUS" "$UNDO_FIX")
$(item_row "8.2 undo_retention" "${UNDO_RETENTION:-N/A} segundos" ">= 900 (ajustar conforme SLA)" "Retencao baixa causa ORA-01555 em queries longas — agravado durante catupgrd.sql" "INFO" "")
</table>
</div>
BEOF

# ============================================================
# BLOCO 9 - RMAN
# ============================================================
RMAN_HTML=""
while IFS='|' read -r dt tipo status dur gb; do
  [[ -z "$dt" ]] && continue
  sc=" class=\"g\""
  [[ "$status" != "COMPLETED" ]] && sc=" class=\"r\""
  RMAN_HTML="${RMAN_HTML}<tr><td>${dt}</td><td>${tipo}</td><td${sc}>${status}</td><td>${dur} min</td><td>${gb} GB</td></tr>"
done < <(extract_section "RMAN")

cat >> "$OUTPUT_HTML" << BEOF
<div id="rman" class="sb2">
<div class="st">BLOCO 9 — RMAN / Backup</div>
<div class="itw">
<table class="dt">
<tr><th>Data Inicio</th><th>Tipo</th><th>Status</th><th>Duracao</th><th>Output</th></tr>
${RMAN_HTML:-<tr><td colspan="5" class="r">Nenhum backup RMAN encontrado — verificar politica de backup</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# BLOCO 10 - OBJETOS / DICIONARIO
# ============================================================
REGISTRY_HTML=""
while IFS='|' read -r comp ver status; do
  [[ -z "$comp" ]] && continue
  sc=""
  [[ "$status" != "VALID" ]] && sc=" class=\"r\""
  REGISTRY_HTML="${REGISTRY_HTML}<tr><td>${comp}</td><td>${ver}</td><td${sc}>${status}</td></tr>"
done < <(extract_section "REGISTRY")

INVALID_HTML=""
while IFS='|' read -r owner otype cnt; do
  [[ -z "$owner" ]] && continue
  sc=" class=\"w\""
  [[ "$owner" == "SYS" || "$owner" == "SYSTEM" ]] && sc=" class=\"r\""
  INVALID_HTML="${INVALID_HTML}<tr><td${sc}>${owner}</td><td>${otype}</td><td${sc}>${cnt}</td></tr>"
done < <(extract_section "INVALID")

BLOCKSIZE_HTML=""
while IFS='|' read -r ts bs contents; do
  [[ -z "$ts" ]] && continue
  BLOCKSIZE_HTML="${BLOCKSIZE_HTML}<tr><td>${ts}</td><td>${bs}</td><td>${contents}</td></tr>"
done < <(extract_section "BLOCKSIZE")

NLS_HTML=""
while IFS='=' read -r param val; do
  [[ -z "$param" ]] && continue
  NLSC=""
  if [[ "$param" == "NLS_CHARACTERSET" && "$val" != "AL32UTF8" ]]; then
    NLSC=" class=\"w\""
  fi
  NLS_HTML="${NLS_HTML}<tr><td>${param}</td><td${NLSC}>${val}</td></tr>"
done < <(extract_section "NLS")

cat >> "$OUTPUT_HTML" << BEOF
<div id="obj" class="sb2">
<div class="st">BLOCO 10 — Objetos, Dicionario, NLS e Charset</div>
<table>
$(tbl_header)
$(item_row "10.1 Recyclebin" "${RECYCLE_CNT:-0} objetos | ${RECYCLE_MB:-0} MB" "Vazio (0 objetos)" "Cada objeto no recyclebin e processado durante upgrade — aumenta janela de manutencao" "$RECYCLE_STATUS" "$RECYCLE_FIX")
$(item_row "10.2 sys.aud\$ volume" "${AUDIT_CNT:-0} linhas (${AUDIT_MIN} a ${AUDIT_MAX})" "<= 1.000.000 linhas + purge job ativo" "AUD\$ com volume alto consome espaco em SYSTEM e aumenta tempo de upgrade" "$AUDIT_STATUS" "$AUDIT_FIX")
$(item_row "10.3 Estatisticas SYS (DBMS_STATS)" "${STATS_DATE:-N/A}" "Coletada ha menos de 7 dias" "Stats desatualizadas causam planos ruins no catupgrd.sql — aumenta tempo de upgrade (Ref: MOS 465787.1)" "INFO" "EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;")
$(item_row "10.4 NLS_CHARACTERSET" "${NLS_CHARSET:-N/A}" "AL32UTF8 (recomendado 19c)" "Bancos em WE8ISO8859P1 podem ter problemas com dados multibyte apos upgrade para 19c" "INFO" "")
$(item_row "10.5 Timezone File Version" "${TZ_VER:-N/A}" "Compativel com versao target" "Diferenca de versao adiciona etapa DST upgrade a janela — considerar fazer separadamente" "INFO" "")
</table>
<div class="itw">
<div class="itl">dba_registry — Componentes do Dicionario</div>
<table class="dt">
<tr><th>Componente</th><th>Versao</th><th>Status</th></tr>
${REGISTRY_HTML:-<tr><td colspan="3" class="m">Sem dados</td></tr>}
</table>

<div class="itl">Objetos Invalidos (dba_objects WHERE status = 'INVALID')</div>
<table class="dt">
<tr><th>Owner</th><th>Object Type</th><th>Qtde</th></tr>
${INVALID_HTML:-<tr><td colspan="3" class="g">Nenhum objeto invalido encontrado</td></tr>}
</table>
<div style="font-size:11px;color:var(--txt-m);margin-top:8px;font-family:var(--mono)">
Correcao: @?/rdbms/admin/utlrp.sql  (executar como sysdba)</div>

<div class="itl">Block Size por Tablespace</div>
<table class="dt">
<tr><th>Tablespace</th><th>Block Size</th><th>Contents</th></tr>
${BLOCKSIZE_HTML:-<tr><td colspan="3" class="m">Sem dados</td></tr>}
</table>

<div class="itl">NLS Parameters</div>
<table class="dt">
<tr><th>Parametro</th><th>Valor</th></tr>
${NLS_HTML:-<tr><td colspan="2" class="m">Sem dados</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# BLOCO 11 - PERFORMANCE
# ============================================================
WAITS_HTML=""
while IFS='|' read -r event twait twtd avgw; do
  [[ -z "$event" ]] && continue
  WAITS_HTML="${WAITS_HTML}<tr><td>${event}</td><td>${twait}</td><td>${twtd}</td><td>${avgw}</td></tr>"
done < <(extract_section "WAITS")

ASH_HTML=""
while IFS='|' read -r event cnt; do
  [[ -z "$event" ]] && continue
  ASH_HTML="${ASH_HTML}<tr><td>${event}</td><td>${cnt}</td></tr>"
done < <(extract_section "ASH")

BCHIT_CLASS="g"
[[ "$BCHIT_INT" =~ ^[0-9]+$ && "$BCHIT_INT" -lt 95 ]] && BCHIT_CLASS="w"
[[ "$BCHIT_INT" =~ ^[0-9]+$ && "$BCHIT_INT" -lt 80 ]] && BCHIT_CLASS="r"

cat >> "$OUTPUT_HTML" << BEOF
<div id="perf" class="sb2">
<div class="st">BLOCO 11 — Performance (Snapshot Atual)</div>
<table>
$(tbl_header)
$(item_row "11.1 Buffer Cache Hit Ratio" "<span class=\"${BCHIT_CLASS}\">${BCHIT:-N/A}%</span>" ">= 95% (OLTP)" "Hit ratio baixo indica Buffer Cache subdimensionado ou workload intenso em full table scans" "$BCHIT_STATUS" "$BCHIT_FIX")
</table>
<div class="itw">
<div class="itl">Top 15 Wait Events (v\$system_event — historico acumulado desde startup)</div>
<table class="dt">
<tr><th>Event</th><th>Total Waits</th><th>Time Waited (cs)</th><th>Avg Wait (cs)</th></tr>
${WAITS_HTML:-<tr><td colspan="4" class="m">Sem dados</td></tr>}
</table>

<div class="itl">ASH — Sessoes em Wait (ultimos 5 minutos)</div>
<table class="dt">
<tr><th>Event</th><th>Sessoes</th></tr>
${ASH_HTML:-<tr><td colspan="2" class="g">Sem sessoes em wait significativo no momento</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# BLOCO 12 - SEGURANCA
# ============================================================
DBAPRIV_HTML=""
while IFS='|' read -r grantee admin; do
  [[ -z "$grantee" ]] && continue
  DBAPRIV_HTML="${DBAPRIV_HTML}<tr><td class=\"w\">${grantee}</td><td>${admin}</td></tr>"
done < <(extract_section "DBAPRIV")

DEFUSER_HTML=""
while IFS='|' read -r uname ustatus uexp; do
  [[ -z "$uname" ]] && continue
  DEFUSER_HTML="${DEFUSER_HTML}<tr><td class=\"r\">${uname}</td><td class=\"r\">${ustatus}</td><td>${uexp}</td></tr>"
done < <(extract_section "DEFUSERS")

DBLINK_HTML=""
while IFS='|' read -r owner link user host; do
  [[ -z "$owner" ]] && continue
  DBLINK_HTML="${DBLINK_HTML}<tr><td>${owner}</td><td>${link}</td><td>${user}</td><td>${host}</td></tr>"
done < <(extract_section "DBLINKS")

cat >> "$OUTPUT_HTML" << BEOF
<div id="seg" class="sb2">
<div class="st">BLOCO 12 — Seguranca</div>
<table>
$(tbl_header)
$(item_row "12.1 Auditoria" "audit_trail=${AUDIT_TRAIL:-N/A} | unified=${UNIFIED_AUD:-N/A}" "DB ou UNIFIED ativo" "Sem auditoria nao ha rastreabilidade de acoes privilegiadas (Ref: CIS Oracle Benchmark)" "$AUDPARAM_STATUS" "$AUDPARAM_FIX")
</table>
<div class="itw">
<div class="itl">Usuarios com Role DBA (exceto SYS/SYSTEM/DBA)</div>
<table class="dt">
<tr><th>Grantee</th><th>Admin Option</th></tr>
${DBAPRIV_HTML:-<tr><td colspan="2" class="g">Nenhum usuario adicional com role DBA — conforme</td></tr>}
</table>

<div class="itl">Usuarios Default Oracle com status OPEN (devem estar LOCKED)</div>
<table class="dt">
<tr><th>Username</th><th>Status</th><th>Expiry</th></tr>
${DEFUSER_HTML:-<tr><td colspan="3" class="g">Nenhum usuario default Oracle esta OPEN — conforme</td></tr>}
</table>
<div style="font-size:11px;color:var(--txt-m);margin-top:6px;font-family:var(--mono)">
Correcao: ALTER USER &lt;username&gt; ACCOUNT LOCK;</div>

<div class="itl">DB Links (dependencias externas)</div>
<table class="dt">
<tr><th>Owner</th><th>DB Link</th><th>Username</th><th>Host</th></tr>
${DBLINK_HTML:-<tr><td colspan="4" class="m">Nenhum DB Link encontrado</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# BLOCO 13 - DATA GUARD
# ============================================================
DG_PARAMS_HTML=""
while IFS='=' read -r pname pval; do
  [[ -z "$pname" ]] && continue
  DG_PARAMS_HTML="${DG_PARAMS_HTML}<tr><td>${pname}</td><td style=\"word-break:break-all\">${pval}</td></tr>"
done < <(extract_section "DG")

DGSTATS_HTML=""
while IFS='|' read -r name val dt; do
  [[ -z "$name" ]] && continue
  DGSTATS_HTML="${DGSTATS_HTML}<tr><td>${name}</td><td>${val}</td><td>${dt}</td></tr>"
done < <(extract_section "DGSTATS")

DGPROC_HTML=""
while IFS='|' read -r proc status seq; do
  [[ -z "$proc" ]] && continue
  sc=""
  echo "$status" | grep -qiE "ERROR|WAIT_FOR" && sc=" class=\"r\""
  DGPROC_HTML="${DGPROC_HTML}<tr><td>${proc}</td><td${sc}>${status}</td><td>${seq}</td></tr>"
done < <(extract_section "DGPROCESS")

DGARCH_GAP=$(extract_section "DGARCH_GAP" | grep -v "^$" | head -5 || echo "")

cat >> "$OUTPUT_HTML" << BEOF
<div id="dg" class="sb2">
<div class="st">BLOCO 13 — Data Guard</div>
<table>
$(tbl_header)
$(item_row "13.1 dg_broker_start" "${DG_BROKER:-N/A}" "TRUE (em ambientes com DG ativo)" "Broker e necessario para gerenciar failover/switchover de forma controlada (Ref: MOS 1305019.1)" "$DGB_STATUS" "$DGB_FIX")
</table>
<div class="itw">
<div class="itl">Parametros de Data Guard</div>
<table class="dt">
<tr><th>Parametro</th><th>Valor</th></tr>
${DG_PARAMS_HTML:-<tr><td colspan="2" class="m">Sem parametros DG configurados</td></tr>}
</table>

<div class="itl">v\$dataguard_stats — Lag (esperado: transport lag &lt; 30s, apply lag &lt; 60s)</div>
<table class="dt">
<tr><th>Metric</th><th>Valor</th><th>Datum Time</th></tr>
${DGSTATS_HTML:-<tr><td colspan="3" class="m">Sem dados — banco nao e standby ou DG nao configurado</td></tr>}
</table>

<div class="itl">Processos MRP / RFS (v\$managed_standby)</div>
<table class="dt">
<tr><th>Process</th><th>Status</th><th>Sequence#</th></tr>
${DGPROC_HTML:-<tr><td colspan="3" class="m">Sem processos MRP/RFS — banco pode ser PRIMARY ou DG nao configurado</td></tr>}
</table>

<div class="itl">Archive Gap (v\$archive_gap — deve estar vazio)</div>
<div style="font-family:var(--mono);font-size:11px;color:var(--txt-m);padding:4px 0">
${DGARCH_GAP:-Nenhum gap detectado}
</div>
</div>
</div>
BEOF

# ============================================================
# BLOCO 14 - PATCHES
# ============================================================
PATCHES_HTML=""
while IFS='|' read -r dt pid desc action; do
  [[ -z "$dt" ]] && continue
  PATCHES_HTML="${PATCHES_HTML}<tr><td>${dt}</td><td style=\"font-family:var(--mono)\">${pid}</td><td>${desc}</td><td>${action}</td></tr>"
done < <(extract_section "PATCHES")

cat >> "$OUTPUT_HTML" << BEOF
<div id="patches" class="sb2">
<div class="st">BLOCO 14 — Patches Aplicados (dba_registry_sqlpatch)</div>
<div class="itw">
<table class="dt">
<tr><th>Data/Hora</th><th>Patch ID</th><th>Descricao</th><th>Acao</th></tr>
${PATCHES_HTML:-<tr><td colspan="4" class="m">Nenhum patch registrado em dba_registry_sqlpatch</td></tr>}
</table>
</div>
</div>
BEOF

# ============================================================
# ASM DISKGROUPS (se houver dados)
# ============================================================
ASM_ROWS=$(extract_section "ASM" | grep -v "^$" | wc -l)
if [[ "$ASM_ROWS" -gt 0 ]]; then
  ASM_HTML=""
  while IFS='|' read -r name type total free pct; do
    [[ -z "$name" ]] && continue
    pct_int=$(echo "$pct" | cut -d. -f1 | tr -d ' ')
    pc=""
    [[ "$pct_int" =~ ^[0-9]+$ && "$pct_int" -ge 85 ]] && pc=" class=\"r\""
    [[ "$pct_int" =~ ^[0-9]+$ && "$pct_int" -ge 75 && "$pct_int" -lt 85 ]] && pc=" class=\"w\""
    ASM_HTML="${ASM_HTML}<tr><td>${name}</td><td>${type}</td><td>${total} MB</td><td>${free} MB</td><td${pc}>${pct}%</td></tr>"
  done < <(extract_section "ASM")

  cat >> "$OUTPUT_HTML" << BEOF
<div class="sb2">
<div class="st">BLOCO 15 — ASM Diskgroups</div>
<div class="itw">
<table class="dt">
<tr><th>Diskgroup</th><th>Redundancia</th><th>Total (MB)</th><th>Free (MB)</th><th>% Usado</th></tr>
${ASM_HTML}
</table>
<div style="font-size:11px;color:var(--txt-m);margin-top:8px;font-family:var(--mono)">
Esperado: uso &lt; 80% | Redundancia: NORMAL (minimo) ou HIGH (producao recomendado)</div>
</div>
</div>
BEOF
fi

# ============================================================
# SUMARIO EXECUTIVO
# ============================================================
CRITICOS_LIST=""
ATENCAO_LIST=""
OK_LIST=""

add_to_summary() {
  local item="$1" status="$2"
  case "$status" in
    CRITICO) CRITICOS_LIST="${CRITICOS_LIST}<div class=\"ei\">${item}</div>" ;;
    ATENCAO) ATENCAO_LIST="${ATENCAO_LIST}<div class=\"ei\">${item}</div>" ;;
    OK)      OK_LIST="${OK_LIST}<div class=\"ei\">${item}</div>" ;;
  esac
}

add_to_summary "1.1 Tuned Profile" "$TUNED_STATUS"
add_to_summary "1.2 THP Enabled" "$THP_EN_STATUS"
add_to_summary "1.3 THP Defrag" "$THP_DF_STATUS"
add_to_summary "1.4 HugePages" "$HP_STATUS"
add_to_summary "1.5 vm.swappiness" "$SWAP_STATUS"
add_to_summary "1.6 kernel.numa_balancing" "$NUMA_STATUS"
add_to_summary "1.7 Oracle Open Files" "$OFILES_STATUS"
add_to_summary "1.10 NTP Sincronizado" "$NTP_STATUS"
add_to_summary "1.11 OOM Killer" "$OOM_STATUS"
add_to_summary "3.3 Log Mode (ARCHIVELOG)" "$ARCH_STATUS"
add_to_summary "3.4 Flashback Database" "$FLASH_STATUS"
add_to_summary "4.1 AMM (memory_target)" "$AMM_STATUS"
add_to_summary "4.5 use_large_pages" "$ULP_STATUS"
add_to_summary "4.6 sga_max_size vs sga_target" "$SGAMAX_STATUS"
add_to_summary "5.2 FRA Uso" "$FRA_STATUS"
add_to_summary "10.1 Recyclebin" "$RECYCLE_STATUS"
add_to_summary "10.2 sys.aud$ Volume" "$AUDIT_STATUS"
add_to_summary "11.1 Buffer Cache Hit" "$BCHIT_STATUS"
add_to_summary "8.1 Undo Management" "$UNDO_STATUS"
add_to_summary "12.1 Auditoria" "$AUDPARAM_STATUS"
add_to_summary "13.1 DG Broker" "$DGB_STATUS"

cat >> "$OUTPUT_HTML" << BEOF
<div id="sumario" class="es">
  <div class="es-title">&#128203; Sumario Executivo — Proximos Passos por Prioridade</div>
  <div class="es-grid">
    <div class="es-col cr">
      <div class="es-col-t cr">&#128308; Criticos — Acao Imediata</div>
      ${CRITICOS_LIST:-<div class="ei" style="color:var(--ok)">Nenhum item critico</div>}
    </div>
    <div class="es-col wn">
      <div class="es-col-t wn">&#9888; Atencao — Corrigir em Janela</div>
      ${ATENCAO_LIST:-<div class="ei">Nenhum item de atencao</div>}
    </div>
    <div class="es-col ok">
      <div class="es-col-t ok">&#10003; Conformes</div>
      ${OK_LIST:-<div class="ei">—</div>}
    </div>
  </div>
</div>

</div><!-- .cnt -->

<div class="ft">
  Oracle Health Check Report &mdash; SID: ${ORACLE_SID} &mdash; Host: ${HOSTNAME} &mdash; ${TIMESTAMP}<br>
  Baseado em: Oracle Database 19c Documentation, MOS Best Practices, CIS Oracle Benchmark<br>
  Este relatorio e informativo — validar comandos de correcao em ambiente de homologacao antes de aplicar em producao
</div>

</body>
</html>
BEOF

echo ""
echo "======================================================"
echo "  Health Check concluido!"
echo "------------------------------------------------------"
printf "  Criticos : %d\n" "$COUNT_CRITICO"
printf "  Atencao  : %d\n" "$COUNT_ATENCAO"
printf "  OK       : %d\n" "$COUNT_OK"
echo "------------------------------------------------------"
printf "  Relatorio: %s\n" "$OUTPUT_HTML"
echo "======================================================"
