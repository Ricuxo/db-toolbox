#!/bin/bash
# Verifica se ambos os argumentos (arquivo de hosts e comando) foram fornecidos

if [ $# -ne 2 ]; then
  echo "Uso: $0 <arquivo_de_hosts> <comando>"
  exit 1
fi

HOST_FILE=$1
SSH_COMMAND=$2

# Verifica se o arquivo de hosts existe
if [ ! -f "$HOST_FILE" ]; then
  echo "Arquivo de hosts não encontrado: $HOST_FILE"
  exit 1
fi

# Loop para ler cada host do arquivo
while read -r HOST; do
  # Verifica se a variável HOST não está vazia
  if [ -n "$HOST" ]; then
    echo "Conectando ao host: $HOST"
    # Executa o comando no host remoto
    ssh "$HOST" bash <<EOF
      echo '==============================================='
      echo "$HOST"
      $SSH_COMMAND
      echo '==============================================='
EOF
    # Verifica se o comando SSH foi executado com sucesso
    if [ $? -ne 0 ]; then
      echo "Erro ao conectar ou executar o comando em: $HOST"
    fi
  fi
done < "$HOST_FILE"