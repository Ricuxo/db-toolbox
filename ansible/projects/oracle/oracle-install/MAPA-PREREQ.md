# Mapa: item de pré-requisito → fase do Ansible

Lido pela skill `oracle-install-os` quando ela recebe `ansible=<este diretório>`. Para cada item
que o relatório de pré-requisitos marca como CORRIGIR, diz qual fase resolve, em quais cenários e
o que a fase **não** cobre. Ao mudar uma role, atualize esta tabela.

## Como montar o comando

Sempre de dentro deste diretório, primeiro em `--check --diff` (não muda nada) e depois de verdade:

```bash
cd <este diretório>
ansible-playbook -i ../../../inventories/<amb> playbooks/<fase>.yml -e ora_hosts=<host ou grupo> --check --diff
ansible-playbook -i ../../../inventories/<amb> playbooks/<fase>.yml -e ora_hosts=<host ou grupo>
```

- `<amb>`: o diretório de `../../../inventories/` onde o servidor está (`lab`, `dev`, `hml`, `prod`).
- `<host ou grupo>`: o nome do host no inventário (procure pelo `ansible_host` com o IP do
  servidor). Servidor fora do inventário: a fase não roda; entregue o trecho para incluir no
  `hosts.yml` e o comando manual.
- Fases 40 e 60 pedem `--ask-vault-pass`. Fase 70 em `prod` pede `-e ora_confirm_env=prod`.
- Rode a fase 00 (gate) antes de qualquer outra: ela recusa cenário, SO ou estado fora do escopo.

## Cenários cobertos

| Cenário | Grupo do inventário | Fases |
|---|---|---|
| `restart_asm` | `oracle_restart` | 00 10 20 30 40 50 60 65 70 |
| `si_fs` | `oracle_si` | 00 10 20 50 55 60 62 65 70 |
| `rac_asm` | `oracle_rac` | **em construção**: 00 10 15 20 prontas, 40 escrita; 50 a 70 ainda recusam o cenário (use o comando manual) |

## Itens

| Item do relatório | Fase | Role | O que a fase faz | Não cobre |
|---|---|---|---|---|
| RPM preinstall | 10_host_prep | ora_host_prep | instala `ora_host_prep_preinstall_rpm` da versão | — |
| Pacotes exigidos | 10_host_prep | ora_host_prep | instala a lista `ora_host_prep_packages` do release e do major do SO (guia 19c) | versão mínima de pacote (ex.: `make-4.4.1-3`): instala a do repositório |
| Grupos do ASM | 10_host_prep | ora_host_prep | cria `asmadmin` 54329, `asmdba` 54327, `asmoper` 54328 e põe o dono nos três (só com `ora_asm`) | — |
| Dono do software e `oinstall` primário | 10_host_prep | ora_host_prep | confere; o dono vem do preinstall | criar o usuário |
| Diretórios OFA e oraInventory | 10_host_prep | ora_host_prep | cria os diretórios e o oraInventory, se ausente | montar filesystem |
| Parâmetros de kernel extras do gridSetup | 10_host_prep | ora_host_prep | grava `ora_host_prep_sysctl_extra` em `/etc/sysctl.d/98-oracle-install.conf` | parâmetros da tabela de mínimos: vêm do preinstall |
| Nome do servidor no `/etc/hosts` | 10_host_prep | ora_host_prep | confere e grava a entrada (linha com o mesmo IP e os mesmos nomes, em qualquer ordem, já vale) | DNS, SCAN, VIPs |
| `/dev/shm` com `nosuid` ou `noexec` | 10_host_prep | ora_host_prep | corrige as opções de montagem | tamanho do `/dev/shm` |
| THP | 10_host_prep | ora_host_prep | UEK7 ou mais novo: `transparent_hugepage=madvise` no GRUB e em tempo de execução. RHCK: só confere o `never` do preinstall | o reboot: a fase não reinicia; no RHCK não altera |
| cvuqdisk (Restart) | 40_grid | ora_grid | instala o `cvuqdisk-*.rpm` do diretório `cv/rpm` da mídia do Grid, antes do gridSetup | instalar antes da fase 40: não há fase própria |
| Discos do ASM (persistência, dono, permissão) | 30_asmlib | ora_asmlib | `restart_asm`: ASMLib v3, partição GPT e `createdisk` por `by-id`, só em disco vazio | regras udev; discos compartilhados de RAC |
| Discos do ASM compartilhados (RAC) | 15_rac_prep | ora_rac_prep | `rac_asm`: regra udev por WWN (`/dev/disk/by-id/wwn-*`) com `oracle:asmadmin 0660`, igual nos nós; regra nova só com disco vazio | apresentar o LUN aos nós (infra); com o ASM já em uso, qualquer mudança na regra é recusada (incluir LUN depois da instalação é manual) |
| SSH sem senha do dono entre os nós (RAC) | 15_rac_prep | ora_rac_prep | chave RSA do `oracle` (só se ausente), `authorized_keys` e `known_hosts` com todos os nós; testa `ssh <nó> date` | — |
| HugePages | 70_hugepages | ora_hugepages | `vm.nr_hugepages` pela SGA real, depois do banco criado | antes do banco existir |
| Kernel e versão do SO | — | — | nada: a fase 00 só recusa o que está fora da matriz `ora_supported_os` (distribuição, release, kernel e RU mínimos) | trocar kernel |
| RAM, swap, `/tmp`, espaço em disco | — | — | nada | infra |
| SCAN, VIPs, rede privada, DNS | — | — | nada | infra |
| SELinux, firewall, swap, discos | — | — | nada, de propósito (README, Princípios) | — |
