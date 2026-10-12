#!/bin/bash
# ---------------------------------------------------------------- #
# Nome do Script:   switchover_database.sh
#
# Descricao:        Realiza o switchover de banco de dados oracle,
#                   utilizando Data Guard Broker
#
# Escrito por:      Henrique Soares da Silva
#
# ---------------------------------------------------------------- #
# Como usar:
#       $ ./switchover_database.sh
# ---------------------------------------------------------------- #
# Historico:        v1.0 23/08/2024, Henrique:
#                    - Inicio do programa
#
# -----------------------------------------------------------------#


export data=$(date +%d/%m/%Y" - "%H:%M:%S)

borda() {
titulo="| $1 |"
borda=$(echo "$titulo" | sed 's/./-/g')
echo "$borda"
echo "$titulo"
echo "$borda"
}

SIDs=$(ps -ef | grep pmon | awk -F \_ '{print $3}' | egrep -v '^$|\+')

# Valida se foi encontrado algum SID
if [ -z "$SIDs" ]; then
echo "Nenhum SID ativo encontrado"
exit 1
fi

# Cria um array com os SIDs encontrados
IFS=$'\n' read -r -d '' -a sid_array <<< "$SIDs"


# Exibe o menu com os banco de dados encontrados
echo ""
borda "Selecione o banco de dados desejado"
echo ""
PS3="Escolha uma opção: "
select sid in "${sid_array[@]}" Sair;
do
if [[ $sid == "Sair" ]]; then
echo -e "Tchau"
exit 0
elif [[ -n "$sid" ]]; then
echo "Você selecionou o SID: $sid"
break;
else
echo "Opção inválida. Tente novamente."
fi
done


# Configurando variaveis de ambiente
export ORAENV_ASK=NO
ORACLE_SID=$sid
. oraenv <<EOF
$ORACLE_SID
EOF
export ORAENV_ASK=YES

# Solicitar as credenciais de conexao
read -p "Digite o usuario para conectar ao Broker (sysdg): " oracle_user
read -sp "Digite a senha do usuario: " oracle_pass
echo ""
echo ""

# Obter nome do banco primary
prmy_db=$(dgmgrl / "show configuration" | grep "Primary" | awk '{print $1}')
stby_db=$(dgmgrl / "show configuration" | grep "Physical" | awk '{print $1}')

# Obter o nome do dg connect identifier
prmy_db_service_name=$(dgmgrl / "show database verbose $prmy_db" | grep DGConnectIdentifier | awk '{print $3}' | sed "s/'//g")
stby_db_service_name=$(dgmgrl / "show database verbose $stby_db" | grep DGConnectIdentifier | awk '{print $3}' | sed "s/'//g")

# Validar status do ambiente
borda "Validar status do Dataguard Broker... - $data"
echo ""
dgmgrl / "show configuration" | grep -A20 "Configuration"
echo ""

# Validar status do switchover, o script vai se conectar no banco de dados primary e validar o banco de dados primary e standby
borda "Validar status do Switchover banco de dados Primary... - $data"
echo ""
dgmgrl -silent "$oracle_user/$oracle_pass@$prmy_db_service_name as sysdg" "validate database $prmy_db"
echo ""
borda "Validar status do Switchover banco de dados Standby... - $data"
echo ""
dgmgrl -silent "$oracle_user/$oracle_pass@$prmy_db_service_name as sysdg" "validate database $stby_db"
echo ""
borda "INICIO DO SWITCHOVER - $data"
echo ""
status_switchover_p=$(dgmgrl /  "validate database $prmy_db" | grep "Ready for Switchover" | awk '{print $4}')
status_switchover_s=$(dgmgrl /  "validate database $stby_db" | grep "Ready for Switchover" | awk '{print $4}')
if [ "$status_switchover_p" = "Yes" ] && [ "$status_switchover_s" = "Yes" ]; then
echo "Banco de dados apto para realizar switchover"
read -r -p "${1:-Deseja fazer o switchover? [y/N]} " resposta_switchover
case "$resposta_switchover" in
[yY][sS]|[yY])
echo "Realizando o switchover ..."
dgmgrl "$oracle_user/$oracle_pass@$prmy_db_service_name as sysdg" "switchover to $stby_db"
;;
*)
echo "Saindo do programa"
exit 0
;;
esac
else
echo "Banco de dados com problemas para realizar o Switchover. ACIONAR O DBA"
echo "Status do switchover no banco de dados Primary: $status_switchover_p"
echo "Status do switchover no banco de dados Standby: $status_switchover_s"
echo ""
exit 1
fi


# Validar status do ambiente
echo ""
borda "Validar status do Dataguard Broker..."
dgmgrl / "show configuration" | grep -A20 "Configuration"
echo ""

borda "TERMINO DO SWITCHOVER - $data   "
echo ""