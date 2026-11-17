# Sinais de cada fase (somente leitura)

Como saber até onde o servidor chegou. Os caminhos saem do inventário: `ora_grid_home`,
`ora_db_home`, `ora_stage_dir`, `ora_stage_patch_dir`, `ora_inventory_dir`, `ora_db_name`,
`ora_asm` e `ora_db_services`. Os valores abaixo são os padrões do projeto, e o inventário vence.

| Fase | Concluída quando | Sinal de PARCIAL |
|---|---|---|
| 10 | RPM `oracle-database-preinstall-19c` instalado; `/etc/sysctl.d/98-oracle-install.conf` existe; `ora_stage_dir` é diretório; o `nodename` está no `/etc/hosts` com o IP principal | — (é idempotente: rodar de novo é o conserto) |
| 20 | `<ora_stage_patch_dir>/<patchid>/<patchid>/` existe para `ru_grid`, `ru_db` e cada one-off | Diretório `<patchid>/` sem o `<patchid>/<patchid>/` dentro (extração interrompida); a fase recria com `creates` |
| 30 | `oracleasm listdisks` lista todos os labels de `ora_asm.disks`; `oracleasm status` ok | Disco com `-part1` sem label ASM; label diferente do declarado (a fase recusa) |
| 40 | `/etc/oracle/olr.loc` existe; `inventory.xml` tem um `HOME` com `LOC="<ora_grid_home>"` e `CRS="true"`; `crsctl stat res -t` mostra `ora.asm` ONLINE | Grid home com sub-patch da GIRU ou one-off em `.patch_storage/<id>_*` **sem** `olr.loc`; processo `gridSetup`/`OPatch` rodando; `/tmp/ora_grid_*` (rsp com senha de execução interrompida: a fase apaga) |
| 50 | `inventory.xml` tem um `HOME` com `LOC="<ora_db_home>"`; `opatch lspatches` do DB home lista a DB RU e os one-offs | DB home com arquivos e fora do `inventory.xml`; `/tmp/ora_db_sw_*` |
| 60 | `srvctl config database -db <DB>` responde; o `<DB>` está no `/etc/oratab`; `+<DG>/<DB>` existe no ASM | `cfgtoollogs/dbca/<DB>` existe sem banco registrado; `pmon` sem registro no Restart (`pgrep -f "^ora_pmon_<SID>"` com o SID do oratab, `ora_pmon_ORCL` no lab; o `comm` do processo fica em minúsculas) |
| 65 | `srvctl config service -db <DB>` lista cada `ora_db_services[].name` com a PDB certa | Serviço com outra PDB (a fase recusa e não altera) |
| 70 | `/etc/sysctl.d/99-nr_hugepages.conf` existe; `use_large_pages=ONLY` em memória; HugePages comprometidas ≥ as páginas dos segmentos da instância | `nr_hugepages` gravado com o banco ainda em `TRUE` (a fase continua de onde parou); banco parado com `ONLY` no spfile (`ORA-27106`, ver falhas-conhecidas) |

A fase 00 não deixa sinal (é só leitura). Depois da 40 ela **aborta de propósito**.

## Coleta num comando só

Rodar do diretório do projeto. Substitua os valores entre `<>` pelos do inventário. É só leitura e
roda como root via `-b`.

```bash
ansible -i ../../../inventories/<amb> <host> -b -m shell -a '
G=<ora_grid_home>; D=<ora_db_home>; S=<ora_stage_dir>; P=<ora_stage_patch_dir>; I=<ora_inventory_dir>; DB=<ora_db_name>
echo "== 10"; rpm -q oracle-database-preinstall-19c; ls -l /etc/sysctl.d/98-oracle-install.conf; ls -ld $S; grep -w "$(uname -n)" /etc/hosts
echo "== 20"; ls -d $P/*/* 2>&1
echo "== 30"; oracleasm listdisks 2>&1; oracleasm status 2>&1 | tail -2
echo "== 40"; ls -l /etc/oracle/olr.loc 2>&1; grep -o "<HOME [^>]*>" $I/ContentsXML/inventory.xml 2>&1
              ls -d $G/.patch_storage/[0-9]*_* 2>/dev/null; ls -d /tmp/ora_grid_* /tmp/ora_db_sw_* 2>/dev/null
              pgrep -u oracle -fa "gridSetup|runInstaller|opatchauto|OPatch/jre|dbca" || echo "sem instalador rodando"
              su - oracle -c "$G/bin/crsctl stat res -t" 2>&1 | head -40
echo "== 50"; su - oracle -c "ORACLE_HOME=$D $D/OPatch/opatch lspatches" 2>&1 | tail -8
echo "== 60"; grep -vE "^(#|$)" /etc/oratab; su - oracle -c "ORACLE_HOME=$D $D/bin/srvctl config database -db $DB" 2>&1 | head -12
echo "== 65"; su - oracle -c "ORACLE_HOME=$D $D/bin/srvctl config service -db $DB" 2>&1 | grep -E "^(Service name|Pluggable database name):"
echo "== 70"; cat /etc/sysctl.d/99-nr_hugepages.conf 2>&1; grep -E "^HugePages_(Total|Free|Rsvd)" /proc/meminfo
              echo "show parameter use_large_pages" | su - oracle -c "ORACLE_SID=$DB ORACLE_HOME=$D $D/bin/sqlplus -s / as sysdba" 2>&1 | grep -i use_large_pages
echo "== stage"; ls -la $S
echo "== SO"; getenforce; systemctl is-active firewalld || true
'
```

O `use_large_pages` em memória sai da linha `show parameter` da seção 70 (o SID é o do oratab;
no Restart é o `ora_db_name`). **A fase 70 em `--check` não mostra esse valor:** ela termina antes
do resumo. A consulta vai por pipe, sem aspas na SQL, para não precisar de arquivo no servidor.
**Nunca gravar script em `/tmp` nem em outro lugar do servidor para coletar:** a coleta é só
leitura. Se faltar algo, acrescente ao comando acima.
