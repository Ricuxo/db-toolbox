# oracle-install

Instalação de Oracle com Ansible, com roles próprias (sem dependência da oravirt).
Escopo atual: **19c · Oracle Linux 9 · dono único `oracle`**, em dois cenários:

| Cenário | Grupo do inventário | O que instala | Fases |
|---|---|---|---|
| `restart_asm` | `oracle_restart` | Oracle Restart (Grid standalone) + ASM (ASMLib v3); banco em ASM; GIRU nos dois homes | 00 10 20 30 40 50 60 65 70 |
| `si_fs` | `oracle_si` | Só o banco (Single Instance, sem Grid) em filesystem; DB RU; listener do home; início no boot por `dbstart`/`dbora` | 00 10 20 50 55 60 62 65 70 |
| `rac_asm` | `oracle_rac` | RAC: Grid Infrastructure for a Cluster + ASM com discos por regra udev (WWN), sem ASMLib; RU do próprio grupo (`playbooks/group_vars/oracle_rac/media.yml`). **Em construção** (desenho em `DESENHO-RAC.md`) | prontas: 00 10 15 |

**O cenário vem do grupo do host no inventário** (`group_vars/<grupo>/main.yml` define
`ora_install_type`), do mesmo jeito que o ambiente vem do `-i`. As fases comuns miram no grupo
`oracle`; a 30 e a 40 só em `oracle_restart`; a 55 e a 62 só em `oracle_si`. Cada uma recusa o
cenário errado, mesmo forçada com `-e ora_hosts=`. A 15 só roda em `oracle_rac`. As fases que ainda não
tratam o `rac_asm` (20 a 70) deixam o `oracle_rac` fora do alvo padrão e recusam o host RAC na guarda
de ambiente (`ora_env_phase_types`).

## Princípios

- **Sem bypass.** Nunca `-ignorePrereq`/`-ignorePrereqFailure`. Requisito não atendido se
  corrige no servidor.
- **Documentação oficial** como fonte de todo requisito (links nos defaults das roles).
- **Gate antes de qualquer mudança:** aborta com Oracle existente, estado parcial, outro SGBD,
  ou SO fora do escopo. A mídia é verificada (presença, pelo nome do arquivo) na fase 20, antes de extrair.
- **Stage no servidor:** a fase 10 cria `ora_stage_dir` junto com os diretórios OFA; o DBA
  baixa a mídia do MOS e copia via `scp` para lá.
  Nada é copiado do controller. O stage nunca é apagado pelos playbooks. A fase 20 avisa (sem
  bloquear) sobre arquivos no stage que não estão no `ora_media`.
- **Recolhimento opcional:** com `ora_stage_collect_from`, a fase 20 move para o stage a mídia do
  catálogo deixada em outro diretório do servidor — só item do `ora_media` (pelo nome) que falta no
  stage, só no mesmo filesystem (rename; nunca cópia de GBs), sem sobrescrever.
- **Senhas só no Ansible Vault.** Response files com dono `oracle`, modo `0600`, `no_log` e
  apagados ao fim.
- Não altera SELinux, firewall, swap nem discos. No GRUB, só o THP: o RPM preinstall 19c
  grava `transparent_hugepage=never`, e a role troca para `madvise` como manda o guia 19c
  para UEK7 ou superior. No RHCK (ex.: RAC na 19.30, que não suporta UEK 8) a role só confere o `never`. O `numa=off` do preinstall é documentado e fica. **A role não
  reinicia o servidor**: o boot novo vale no próximo reinício, em janela.
- Depois de **atualizar o RPM preinstall**, rode a fase 10 de novo: o script do RPM pode
  regravar `transparent_hugepage=never`.

## Fluxo

| Passo | O quê |
|---|---|
| 1 | Validar pré-requisitos de SO — **triagem** (só bloqueios de infra) |
| 2 | `playbooks/00_gate.yml` — gate (só leitura) |
| 3 | `playbooks/10_host_prep.yml` — preinstall + pacotes + `kernel.panic` (exigido pelo gridSetup 19.32) + nome do servidor no `/etc/hosts` (com ou sem DNS) + grupos de ASM (se `ora_asm`) + diretórios OFA + stage + `/dev/shm` |
| 3a | `playbooks/15_rac_prep.yml` — **só `rac_asm`**, todos os nós de uma vez: regra udev dos discos do ASM por WWN (`oracle:asmdba 0660`, igual nos nós, regra nova só com disco vazio) e SSH sem senha do `oracle` entre os nós (`authorized_keys`, `known_hosts` com a chave de host lida do próprio nó, teste `ssh <nó> date`; cwlin 19c) |
| 4 | Validar pré-requisitos de SO — **confirmação** (todos os itens) |
| 5 | Copiar a mídia para `ora_stage_dir` com o nome que está no `ora_media` |
| 6 | `playbooks/20_stage.yml` — recolhe a mídia (se configurado), verifica (presença pelo nome) e descompacta RU e one-offs |
| 7 | `playbooks/30_asmlib.yml` — ASMLib v3 (`ol9_addons` + `oracleasmlib` do stage, `rpm -K`), partição GPT e `createdisk` (só disco vazio por `by-id`) |
| 8 | `playbooks/40_grid.yml` — Grid/Restart: Grid home, OPatch, `cvuqdisk` da mídia, `gridSetup.sh -silent -applyRU -applyOneOffs` (gate: pré-requisitos integrados, já com a RU; rc 6 só passa com avisos listados em `ora_grid_accept_warnings`), `root.sh`, `-executeConfigTools` |
| 9 | `playbooks/50_db_software.yml` — software do banco (só software) no `dbhome_1`: OPatch, `runInstaller -silent -applyRU <GIRU> -applyOneOffs` (banco em ASM com Restart usa a GIRU, página 19.32 das Release Notes; rc 6 só com avisos em `ora_db_accept_warnings`), `root.sh`; confere DB RU e one-offs no `opatch lspatches` | **Em `si_fs`**: `-applyRU <DBRU>` (página 19.32, "Single-instance Oracle Database"), sem exigir o Restart.
| 9a | `playbooks/55_listener.yml` — **só `si_fs`**: listener do DB home com `netca -silent -responsefile` e o template `assistants/netca/netca.rsp` do próprio home (LISTENER, TCP 1521; ladbi "Running Configuration Assistants Using Response Files"); recusa a 1521 ocupada por outro processo |
| 10 | `playbooks/60_dbca.yml` — `dbca -silent -createDatabase` (rsp do template oficial, senhas do vault, 0600, apagado no fim; archivelog, FRA e redo pela linha de comando): CDB + PDB em ASM, AL32UTF8, ASMM; confere registro no Restart, archivelog, PDB aberta, memória, FRA e redo; mostra o `dba_registry_sqlpatch` | **Em `si_fs`**: `storageType=FS`, `datafileDestination=ora_db_data_dir`, `recoveryAreaDestination=ora_db_fra_dir`; confere que todos os datafiles ficaram no diretório pedido.
| 10a | `playbooks/62_autostart.yml` — **só `si_fs`**: `Y` no `/etc/oratab` e `/etc/init.d/dbora` com o texto da doc (unxar 19c §2.2.1; `dbstart $ORACLE_HOME` também sobe o listener), `chgrp dba`, `0750` e links `rc0.d/K01dbora`, `rc3.d/S99dbora` e `rc5.d/S99dbora`. Não reinicia nada |
| 11 | `playbooks/65_db_service.yml` — serviço do Restart por PDB (`srvctl add service -pdb -policy AUTOMATIC`, só se não existir; nunca altera um existente) e garante o serviço rodando, o que abre a PDB em READ WRITE; idempotente | **Em `si_fs`** (sem Restart): `DBMS_SERVICE.CREATE_SERVICE`/`START_SERVICE` na PDB e `ALTER PLUGGABLE DATABASE ... SAVE STATE` (Multitenant Guide 19c). Se o serviço de usuário volta sozinho depois do reinício não está documentado: a fase 70 e o reboot do lab conferem.
| 12 | `playbooks/70_hugepages.yml` — depois do banco criado (doc 19c): `vm.nr_hugepages` = soma dos segmentos de memória compartilhada da instância (`sysresv` + `ipcs`, por segmento, arredondando para cima) + `ora_hugepages_extra` (2) em `/etc/sysctl.d/99-nr_hugepages.conf` (≤ 70% da RAM; confere memlock ≥ 90% e `vm.hugetlb_shm_group`); **reinicia o banco via srvctl** até o SGA estar em HugePages (com `TRUE`, prova pela tabela EXPECTED/ALLOCATED_PAGES da última partida no alert log, porque o segmento pequeno fica em 4K de propósito) e depois para valer `USE_LARGE_PAGES=ONLY`; confere serviços e PDBs abertos depois do reinício | **Em `si_fs`**: reinício por `shutdown immediate`/`startup` no SQL*Plus.

## Como rodar

```bash
ansible-galaxy collection install -r requirements.yml -p collections
ansible-playbook -i ../../../inventories/lab playbooks/00_gate.yml --check            # nada muda
ansible-playbook -i ../../../inventories/lab playbooks/10_host_prep.yml --check --diff
ansible-playbook -i ../../../inventories/lab playbooks/10_host_prep.yml
```

**Inventário e ambiente.** O inventário é compartilhado por todos os projetos e fica fora deste,
em `db-toolbox/ansible/inventories/<amb>/` (daqui: `../../../inventories/<amb>`). Cada ambiente
(`lab`, `dev`, `hml`, `prod`) tem o seu diretório, e **o ambiente é o `-i` do comando**: com
`-i .../inventories/dev`, os servidores de produção não existem para o Ansible. Não há inventário
padrão no `ansible.cfg`, de propósito: sem `-i`, nenhum host casa e nada roda.

Todo playbook começa pela role `ora_env`, que mostra o ambiente e recusa rodar se o `ora_env`
(`inventories/<amb>/group_vars/all/main.yml`) faltar ou não estiver em `lab`, `dev`, `hml` ou
`prod`. A fase 70 reinicia o banco: em `prod` ela exige repetir o ambiente na linha de comando,
`-e ora_confirm_env=prod`.

Alvo padrão: grupo `oracle_restart`. Outro alvo: `-e ora_hosts=<grupo|host>`.

### Instalação completa (`playbooks/site.yml`)

O `site.yml` importa as fases 00 a 70 em ordem. Roteiro para servidor novo:

```bash
cd /projetos/DESENVOLVIMENTO/desenvolvimento/db-toolbox/ansible/projects/oracle/oracle-install
ansible-playbook -i ../../../inventories/lab playbooks/00_gate.yml
ansible-playbook -i ../../../inventories/lab playbooks/10_host_prep.yml
# reiniciar o servidor (GRUB da fase 10) e copiar a mídia para /u01/stage
time ansible-playbook -i ../../../inventories/lab playbooks/site.yml --ask-vault-pass
```

- **Rodar de dentro do `oracle-install`:** o `ansible.cfg` daqui aponta roles, collections e `become`.
- **`--ask-vault-pass` é obrigatório:** as fases 40 e 60 usam as senhas (pedida uma vez, no início).
- **Mídia antes da fase 20:** o stage só existe depois da fase 10, por isso a 10 roda antes,
  sozinha. Alternativa: deixar a mídia em um diretório de `ora_stage_collect_from` (no lab, `/u01`).
  As fases 00 e 10 rodam de novo dentro do `site.yml` sem mudar nada.
- **Reboot depois da fase 10:** o GRUB (THP `madvise`, `numa=off`) só vale no próximo boot e o
  `site.yml` não reinicia o servidor. Todas as instalações testadas tiveram esse reboot; sem ele,
  não testado.
- **Falha no meio:** o `site.yml` não retoma. As fases 40, 50 e 60 recusam o que já foi feito;
  depois de corrigir, rode uma a uma a partir da que falhou. Na fase 70, "O kernel alocou X de Y
  HugePages" pede reboot do servidor e a fase de novo (não repetir sem o reboot).
- **Produção:** o `site.yml` inclui a fase 70 (reinicia o banco) e exige `-e ora_confirm_env=prod`.
- **Cenário `si_fs`:** o mesmo `site.yml` serve; as fases 30 e 40 não casam host e as 55 e 62 entram.
  A mídia é só a do banco: `db_base`, OPatch, DB RU e os one-offs. O disco dos datafiles tem de estar
  montado em `/u02` antes da fase 10. Um reboot depois da instalação prova o `dbora`.

## Variáveis

No inventário compartilhado (`db-toolbox/ansible/inventories/<amb>/`): o ambiente em
`group_vars/all/main.yml` (`ora_env`) e as senhas em `group_vars/all/vault.yml`; os padrões dos
servidores Oracle em `group_vars/oracle/main.yml`; o que é de um servidor só em
`host_vars/<host>.yml`. Só da instalação, neste projeto: `playbooks/group_vars/all/main.yml` e
`playbooks/group_vars/all/media.yml` (RU alvo e catálogo da mídia). Um `group_vars/<grupo>` ou
`host_vars` do inventário vence os do projeto.

| Variável | Onde | Descrição |
|---|---|---|
| `ora_env` | inventário (`group_vars/all`) | nome do ambiente (`lab`, `dev`, `hml`, `prod`); obrigatório, conferido pela role `ora_env` |
| `ora_confirm_env` | linha de comando | repetir o ambiente para a fase 70 em `prod` (`-e ora_confirm_env=prod`) |
| `ora_owner` / `ora_install_group` | inventário (`group_vars/oracle`) | dono único (`oracle`) e grupo primário (`oinstall`) |
| `ora_app_dir`, `ora_base`, `ora_inventory_dir` | inventário (`group_vars/oracle`) | layout OFA |
| `ora_stage_dir` | inventário (`group_vars/oracle`) | onde o DBA deixa a mídia |
| `ora_stage_collect_from` | host_vars | diretórios de onde a fase 20 pode mover a mídia para o stage (padrão `[]`) |
| `ora_supported_os` | projeto (`playbooks/group_vars/all`) | escopo de SO aceito pelo gate |
| `ora_version` | inventário (`group_vars/oracle`) | release base da mídia, 4 partes (`19.3.0.0`) |
| `ora_ru` | projeto (`media.yml`) | RU alvo, aplicado na instalação (`19.32.0.0`) |
| `ora_media` | projeto (`media.yml`) | catálogo da mídia: `file` (+ `patchid` nos RUs e one-offs); sem checksum |
| `ora_install_type` | inventário (`group_vars/oracle_restart` ou `oracle_si`) | cenário: `restart_asm` ou `si_fs` |
| `ora_db_data_mount`, `ora_db_data_dir`, `ora_db_fra_dir` | inventário (`group_vars/oracle_si`) | `si_fs`: `/u02` (tem de ser ponto de montagem), `/u02/app/oracle/oradata`, `<ORACLE_BASE>/fast_recovery_area` (OFA) |
| `ora_asm` | host_vars | discos (`label` + `device` por `/dev/disk/by-id/`) e diskgroups; o 1º diskgroup é criado no gridSetup |
| `ora_media.asmlib` | projeto (`media.yml`) | RPM `oracleasmlib` (file), baixado pelo DBA; a fase 30 confere a assinatura (`rpm -K`) |
| `ora_media.cvu` | projeto (`media.yml`) | CVU avulso do MOS (patch 30839369): **não** usado na 19c em OL9 (sem dados de referência); mapeado para 26ai |
| `ora_home_version` | inventário (`group_vars/oracle`) | `<major>.<ru>.0.0` tirado do `ora_ru`; nome dos homes |
| `ora_grid_home` | inventário (`group_vars/oracle`) | `{{ ora_base }}/product/<major>.<ru>.0.0/grid`, ex.: `19.32.0.0` (OFA, standalone, dono único; nomenclatura da casa) |
| `ora_db_home` | inventário (`group_vars/oracle`) | `{{ ora_base }}/product/<major>.<ru>.0.0/dbhome_1` (OFA; nomenclatura da casa) |
| `ora_db_edition` | defaults `ora_db_software` | `EE` (padrão da casa) |
| `ora_db_name`, `ora_pdb_name`, `ora_db_total_memory_mb`, `ora_db_fra_size_mb`, `ora_db_redo_size_mb` | host_vars | banco da fase 60 |
| `ora_db_services` | host_vars | serviços da fase 65: lista de `{name, pdb}` |
| `vault_ora_sys_password`, `vault_ora_system_password`, `vault_ora_pdbadmin_password` | vault.yml | senhas do banco (fase 60) |
| `vault_ora_sysasm_password`, `vault_ora_asmsnmp_password` | vault.yml | senhas do ASM (fase 40) |
| `ora_gate_allow_existing` | linha de comando | prosseguir com Oracle/outro SGBD — só com decisão explícita |

Senhas: `group_vars/all/vault.yml` (modelo em `vault.yml.example`), sempre criptografado.
