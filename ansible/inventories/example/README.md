# Inventário de exemplo

Modelo para um ambiente novo, com um servidor de cada cenário do `oracle-install`. Todos os nomes,
IPs e WWNs são fictícios. O inventário de verdade de cada ambiente (ou cliente) fica fora do
repositório público.

## Como usar

1. Copie o diretório para o nome do ambiente: `cp -r inventories/example inventories/<amb>`
   (`lab`, `dev`, `hml` ou `prod`).
2. Em `group_vars/all/main.yml`, troque `ora_env` pelo mesmo nome do diretório. Os playbooks recusam
   rodar se os dois forem diferentes, e é por isso que este exemplo não roda como está.
3. Crie o `group_vars/all/vault.yml` a partir do `vault.yml.example` e criptografe cada senha com
   `ansible-vault encrypt_string`.
4. Apague do `hosts.yml` os cenários que não vai usar e troque os nomes, IPs e discos pelos reais.

## Onde fica cada coisa

| Arquivo | O que tem |
|---|---|
| `hosts.yml` | quem: os servidores, o IP de cada um e em qual grupo (cenário) estão |
| `group_vars/all/` | o ambiente (`ora_env`) e as senhas (vault) |
| `group_vars/oracle/` | padrões de todo servidor Oracle (dono, OFA, homes, stage) |
| `group_vars/oracle_restart/`, `oracle_si/`, `oracle_rac/` | o cenário de cada grupo; não mexa |
| `host_vars/<host>.yml` | Restart e SI: discos e banco de **um** servidor |
| `group_vars/<cluster>/main.yml` | RAC: nós, SCAN, VIPs, interfaces, discos e banco de **um** cluster |

Restart e SI: o servidor entra direto no grupo do cenário. RAC: cada cluster é um subgrupo de
`oracle_rac`, com o nome do cluster, e os nós ficam dentro dele.

## Como rodar

Sempre com `--check` primeiro e com o alvo explícito:

```bash
cd ansible/projects/oracle/oracle-install
ansible-playbook -i ../../../inventories/<amb> playbooks/00_gate.yml -e ora_hosts=srvrestart01 --check
ansible-playbook -i ../../../inventories/<amb> playbooks/00_gate.yml -e ora_hosts=rac_cluster01 --check   # RAC: o cluster inteiro
```
