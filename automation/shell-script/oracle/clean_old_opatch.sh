#!/usr/bin/env bash

# Ative -e/-o; -u só depois dos args
set -eo pipefail

# Uso:
#   bash run_remote_opatch_clean.sh <hosts.txt> --dry-run --target grid
#   bash run_remote_opatch_clean.sh <hosts.txt> --apply   --target grid
#   bash run_remote_opatch_clean.sh <hosts.txt> --dry-run --target dbhome
#   bash run_remote_opatch_clean.sh <hosts.txt> --apply   --target dbhome

if [ $# -lt 3 ] || [ $# -gt 3 ]; then
  echo "Uso: $0 <arquivo_de_hosts> <--dry-run|--apply> <--target grid|dbhome>"
  exit 1
fi

HOST_FILE=$1
MODE=$2
TARGET=$3

set -u

echo "[DEBUG] HOST_FILE='$HOST_FILE' MODE='$MODE' TARGET='$TARGET'"

if [ ! -f "$HOST_FILE" ]; then
  echo "Arquivo de hosts não encontrado: $HOST_FILE"
  exit 1
fi

case "$MODE" in
  --dry-run) DRYRUN=1 ;;
  --apply)   DRYRUN=0 ;;
  *) echo "Modo inválido: $MODE (use --dry-run ou --apply)"; exit 1 ;;
esac

case "$TARGET" in
  grid|dbhome) ;;
  *) echo "Target inválido: $TARGET (use grid ou dbhome)"; exit 1 ;;
esac

while IFS= read -r HOST; do
  [[ -z "$HOST" || "$HOST" =~ ^# ]] && continue

  echo "==============================================="
  echo "Conectando ao host: $HOST (modo: $( [ "$DRYRUN" -eq 1 ] && echo DRY-RUN || echo APPLY )) target: $TARGET"
  echo "-----------------------------------------------"

  if [ "$TARGET" = "grid" ]; then
    # >>> GRID com sudo
    if ! ssh "$HOST" "sudo -H env DRYRUN=$DRYRUN TARGET=$TARGET bash -s" <<'REMOTE_EOF'
set -euo pipefail
shopt -s nullglob extglob

BASE_GLOB="/u01/app/19.2[0-9]*.0.0/grid"

echo "Host: $(hostname)"
echo "Modo: $( [ "${DRYRUN:-1}" -eq 1 ] && echo DRY-RUN || echo APPLY )"
echo "Procurando em: ${BASE_GLOB}"
echo

found_any=0
for homedir in ${BASE_GLOB}; do
  [[ -d "$homedir" ]] || continue
  found_any=1

  echo "[GRID] $homedir"
  candidates=( "$homedir"/OPatch* )
  if [ ${#candidates[@]} -eq 0 ]; then
    echo "  - Nenhum OPatch* encontrado."
    continue
  fi

  for d in "${candidates[@]}"; do
    [[ -e "$d" ]] || continue
    base="$(basename -- "$d")"

    if [[ "$base" == "OPatch" ]]; then
      echo "  - Mantendo: $d"
      continue
    fi

    if [ "${DRYRUN:-1}" -eq 1 ]; then
      echo "  - [DRY-RUN] Removeria: $d"
    else
      echo "  - Removendo: $d"
      rm -rf -- "$d"
    fi
  done
done

if [ "$found_any" -eq 0 ]; then
  echo "Nenhum grid encontrado com padrão: ${BASE_GLOB}"
fi

echo "Concluído."
REMOTE_EOF
    then
      echo "Erro ao conectar ou executar o comando em: $HOST"
    fi

  else
    # >>> DBHOME sem sudo (ajuste para sudo se precisar)
    if ! ssh "$HOST" "DRYRUN=$DRYRUN TARGET=$TARGET bash -s" <<'REMOTE_EOF'
set -euo pipefail
shopt -s nullglob extglob

BASE_GLOB="/u01/app/oracle/product/19.2[0-9]*.0.0/dbhome_*"

echo "Host: $(hostname)"
echo "Modo: $( [ "${DRYRUN:-1}" -eq 1 ] && echo DRY-RUN || echo APPLY )"
echo "Procurando em: ${BASE_GLOB}"
echo

found_any=0
for homedir in ${BASE_GLOB}; do
  [[ -d "$homedir" ]] || continue
  found_any=1

  echo "[DBHOME] $homedir"
  candidates=( "$homedir"/OPatch* )
  if [ ${#candidates[@]} -eq 0 ]; then
    echo "  - Nenhum OPatch* encontrado."
    continue
  fi

  for d in "${candidates[@]}"; do
    [[ -e "$d" ]] || continue
    base="$(basename -- "$d")"

    if [[ "$base" == "OPatch" ]]; then
      echo "  - Mantendo: $d"
      continue
    fi

    if [ "${DRYRUN:-1}" -eq 1 ]; then
      echo "  - [DRY-RUN] Removeria: $d"
    else
      echo "  - Removendo: $d"
      rm -rf -- "$d"
    fi
  done
done

if [ "$found_any" -eq 0 ]; then
  echo "Nenhum dbhome encontrado com padrão: ${BASE_GLOB}"
fi

echo "Concluído."
REMOTE_EOF
    then
      echo "Erro ao conectar ou executar o comando em: $HOST"
    fi
  fi

  echo "==============================================="
done < "$HOST_FILE"
