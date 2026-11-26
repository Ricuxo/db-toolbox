# Desenho: cenário `rac_asm` (RAC 19c, 2 nós, ASM por udev)

Estado: **implementado** nas fases 00 a 70 (45 nova; 50, 60, 65 e 70 com ramo RAC; validado no
cluster orclrac do lab, RU 19.33).
Exemplos com os nomes do inventário modelo (`inventories/example`, cluster `rac_cluster01`); valores fictícios.

## 1. O que o cenário instala

Grid Infrastructure for a Cluster (Standalone Cluster) com ASM, banco RAC de 2 instâncias (CDB + PDB),
RU **19.30** (GIRU 38629535) nos dois homes, mais o one-off **38609069**. Dono único `oracle`.

| Fase | Em `rac_asm` | Onde roda |
|---|---|---|
| 00 gate | igual (sem mudança) | os dois nós |
| 10 host_prep | igual, mais os ramos novos (seção 4) | os dois nós |
| 15 rac_prep (nova) | regra udev por WWN e SSH equivalence do `oracle` | os dois nós |
| 20 stage | igual, só no nó de instalação | `srvrac01` |
| 30 asmlib | **não entra** (a regra udev da 15 substitui) | — |
| 40 grid | ramo `CRS_CONFIG` | instalador em `srvrac01`; `root.sh` em série, `srvrac01` e depois `srvrac02` |
| 45 diskgroups (nova) | `+FRA` e `+DATA` com `CREATE DISKGROUP` via `sqlplus / as sysasm` + `srvctl start` | `srvrac01` |
| 50 db_software | ramo RAC (`-applyRU <GIRU>`, `CLUSTER_NODES`) | instalador em `srvrac01`; `root.sh` em série |
| 60 dbca | ramo RAC (`databaseConfigType=RAC`, `nodelist`) | `srvrac01` |
| 65 db_service | `srvctl add service -preferred <inst1>,<inst2>` | `srvrac01` |
| 70 hugepages | por nó, um de cada vez (reinicia uma instância por vez) | os dois nós, em série |

O "nó de instalação" é o primeiro de `ora_rac_nodes` (variável do cluster), e as fases o recusam
se a mídia não estiver nele.

## 2. Inventário (`inventories/lab/`)

```yaml
# hosts.yml, dentro de oracle.children
        oracle_rac:                        # RAC: um subgrupo por cluster
          children:
            rac_cluster01:
              hosts:
                srvrac01:
                  ansible_host: 10.0.0.31
                srvrac02:
                  ansible_host: 10.0.0.32
```

`group_vars/rac_cluster01/main.yml` (valores do cluster, iguais para os dois nós; cada cluster é um subgrupo de `oracle_rac`, e o `group_vars/oracle_rac/` só tem o cenário e o Grid home):

```yaml
ora_install_type: rac_asm

# cwlin 19c, "About the Oracle Home Directory for Oracle Grid Infrastructure": num cluster o Grid
# home "must not be placed under one of the Oracle base directories" (exemplo do guia: /u01/app/19.0.0/grid).
# O nome <major>.<ru>.0.0 (ora_home_version) vem de group_vars/oracle; aqui o Grid home só sai do ORACLE_BASE.
ora_grid_home: "{{ ora_app_dir }}/{{ ora_home_version }}/grid"      # /u01/app/19.30.0.0/grid

ora_rac_cluster_name: cluster01
ora_rac_scan_name: cluster01-scan.example.com
ora_rac_scan_port: 1521
ora_rac_nodes:                             # gridsetup.rsp: clusterNodes = <público>:<vip>
  - {name: srvrac01, vip: srvrac01-vip}
  - {name: srvrac02, vip: srvrac02-vip}
ora_rac_interfaces:                        # gridsetup.rsp: networkInterfaceList, tipo 1=PUBLIC, 5=ASM & PRIVATE
  - {name: eth0, subnet: 10.0.0.0, type: 1}
  - {name: eth1, subnet: 10.10.10.0,   type: 5}

# Discos por WWN (by-id). A regra udev da fase 15 dá dono, grupo e modo.
ora_asm:
  disks:
    - {label: OCR1,  device: /dev/disk/by-id/wwn-0x6001405000000000000000000000b001}
    - {label: OCR2,  device: /dev/disk/by-id/wwn-0x6001405000000000000000000000b002}
    - {label: OCR3,  device: /dev/disk/by-id/wwn-0x6001405000000000000000000000b003}
    - {label: DATA1, device: /dev/disk/by-id/wwn-0x6001405000000000000000000000b004}
    - {label: FRA1,  device: /dev/disk/by-id/wwn-0x6001405000000000000000000000b005}
  diskgroups:                              # o 1º é o do OCR/voting, criado no gridSetup
    - {name: OCR,  redundancy: EXTERNAL, disks: [OCR1, OCR2, OCR3]}
    - {name: DATA, redundancy: EXTERNAL, disks: [DATA1]}
    - {name: FRA,  redundancy: EXTERNAL, disks: [FRA1]}
```

O banco (`ora_db_name`, `ora_pdb_name`, memória, FRA, redo, `ora_db_services`) fica no mesmo arquivo,
porque um banco RAC pertence ao cluster e não a um nó.

## 3. RU e catálogo da 19.30

`ora_media` é substituído inteiro, sem merge. Então o catálogo da 19.30 tem de ser completo e ter a sua
própria lista de `oneoffs`, sem o `_ora_oneoffs_common` da 19.32.

```yaml
ora_ru: 19.30.0.0
ora_media:
  grid_base: {file: LINUX.X64_193000_grid_home.zip}
  db_base:   {file: LINUX.X64_193000_db_home.zip}
  opatch:    {file: p6880880_190000_Linux-x86-64.zip}
  ru_grid:   {file: p38629535_190000_Linux-x86-64.zip, patchid: "38629535"}  # GI RELEASE UPDATE 19.30.0.0.0
  oneoffs:
    - {file: p38609069_1930000DBRU_Generic.zip, patchid: "38609069"}  # overlay 19.30, GI e DB home; teste de rollback
```

- Não há `ru_db`. Segundo a página da 19.32, o RAC usa a GIRU também no `runInstaller` do banco,
  como o `restart_asm`. Para a 19.30 isso fica **NÃO VERIFICADO** (não existe página da 19.30).
- Não há `asmlib`. As chaves obrigatórias da fase 20 passam a depender do cenário.
- A mídia é identificada só pelo nome do arquivo, sem checksum (decisão do DBA, como a oravirt).

**Onde fica o catálogo:** `playbooks/group_vars/all/media.yml` tem um catálogo por RU (`ora_media_catalog`);
o cluster escolhe a RU com `ora_ru` no `group_vars/<cluster>/main.yml` (ex.: 19.30), e o
`ora_media` é o catálogo dessa RU.

## 4. Mudanças nas fases existentes

**00 gate:** nenhuma.

**10 host_prep:**
- **THP:** hoje a role exige UEK e troca para `madvise`. Com a 19.30 os nós estão no RHCK, então essa
  checagem falharia. O ladbi 19c diz "Oracle recommends that you disable Transparent HugePages" e só
  manda `madvise` em "UEK7 and later". Não há regra própria para o RHCK no OL9. O desenho: com RHCK,
  manter `never` (o que o preinstall grava) e só conferir, sem trocar. Isso é decisão do DBA, porque a
  doc não fala do RHCK no OL9.
- **`/etc/hosts`:** a role grava a linha do próprio nó. No RAC as linhas dos nós, das VIPs, da
  interconexão e do SCAN já existem. A checagem de conflito precisa aceitar as linhas iguais nos dois nós.
- `kernel.panic`, `/dev/shm`, grupos do ASM, OFA e stage: iguais.
- **Diretórios dos homes:** Grid home `/u01/app/19.30.0.0/grid`, fora do `ORACLE_BASE`, e DB home `/u01/app/oracle/product/19.30.0.0/dbhome_1`, com dono `oracle:oinstall`.
  O caminho até ele precisa permitir o `root.sh`; a regra exata de dono no cluster fica para conferir no cwlin.

**15 rac_prep (nova):**
- **udev:** é a regra que já está nos nós, gerada a partir de `ora_asm.disks` (WWN → `OWNER=oracle`,
  `GROUP=asmdba`, `MODE=0660`). Antes de gravar, a fase confere que o disco está vazio e que o WWN
  aparece nos dois nós. Fonte: cwlin 19c, "Configuring Device Persistence Manually for Oracle ASM".
- **SSH equivalence do `oracle`:** cwlin 19c diz "Passwordless SSH configuration is a mandatory
  installation requirement". O procedimento manual é chave em cada nó, `authorized_keys` com todas as
  chaves, `~/.ssh` em 700 e `ssh <nó> date` de cada nó para cada nó, inclusive para si mesmo, para
  popular o `known_hosts`. O guia mostra DSA; o desenho usa RSA, que o guia aceita ("RSA or DSA keys").

**20 stage:** roda só no nó de instalação. A lista de chaves obrigatórias passa a depender do cenário
(sem `asmlib` nem `ru_db` em `rac_asm`).

**40 grid (ramo `CRS_CONFIG`):** as chaves saem do template oficial `install/response/gridsetup.rsp`
da mídia 19.3:
- `oracle.install.option=CRS_CONFIG`, `ClusterConfiguration=STANDALONE`, `scanType=LOCAL_SCAN`;
- `gpnp.scanName`, `gpnp.scanPort`, `clusterName`;
- `clusterNodes=srvrac01:srvrac01-vip,srvrac02:srvrac02-vip` e `networkInterfaceList=eth0:10.0.0.0:1,eth1:10.10.10.0:5`;
- `storageOption=FLEX_ASM_STORAGE`;
- `configureGIMR=false` (sem GIMR, decisão 5);
- `diskGroup.disks` com o caminho by-id (sem o prefixo `ORCL:` do ASMLib) e
  `diskDiscoveryString` com os caminhos by-id exatos de `ora_asm` (decisão 2);
- `executeRootScript=false`: o `root.sh` roda pelo Ansible, `srvrac01` e depois `srvrac02`;
- `-executeConfigTools` no fim, só no `srvrac01`.

Os campos do template são todos documentados nos comentários dele. A ordem do `root.sh` (primeiro nó
antes dos demais, em série) fica **NÃO VERIFICADO** na doc lida até agora.

**50 db_software:** `oracle.install.option=INSTALL_DB_SWONLY` com `CLUSTER_NODES=srvrac01,srvrac02`. As
chaves vêm do template `db_install.rsp`, a ler antes do código. Depois, `root.sh` em série.

**60 dbca:** `databaseConfigType=RAC` e `nodelist=srvrac01,srvrac02`, com datafiles em `+DATA` e a
FRA em `+FRA`. As chaves vêm do template `dbca.rsp`, a ler antes do código.

**65 e 70:** os serviços com as duas instâncias preferidas. As HugePages são calculadas por nó, e o
reinício é de uma instância por vez, com `srvctl stop/start instance`.

## 5. Decisões do DBA (2026-11-24)

1. **Catálogo da 19.30:** entrada `19.30.0.0` do `ora_media_catalog` (projeto); a RU é escolhida no inventário, por cluster.
2. **Disk string:** os caminhos by-id exatos dos discos de `ora_asm` (lista separada por vírgula, sem glob).
   A fase 15 não cria links `/dev/oracleasm/*`.
3. **THP no RHCK:** `never`, só conferido pela fase 10.
4. **Patches no stage:** recolhidos pela fase 20 via `ora_stage_collect_from` (host_vars do `srvrac01`);
   tirar a entrada depois da fase 20.
5. **GIMR:** não configurar. O LUN do GIMR fica fora do `ora_asm` e da regra udev.

## 6. Pendências antes da fase 40 (MOS)

- **Variantes 19.30 dos one-offs 39544247 e 39932578.** A página da 19.32 exige o 39544247 ("REMOTE
  ROOT.SH POSTPATCH FAILS … ORA-00600 [KFNSBACKGROUND11]"), e é justamente o `root.sh` do 2º nó num RAC.
  A falta de página da 19.30 não prova que a 19.30 está livre do bug. Procure no MOS se há
  variante `_1930000…`.
- Certificação do OL 9.9 com RHCK 5.14.0-741 para o 19c.
- OPatch 12.2.0.1.56 e a GIRU baixada de novo no stage do `srvrac01`.
- Ler os templates `db_install.rsp` e `dbca.rsp` da mídia e a página do cwlin sobre o `root.sh` em cluster.

## 7. Documentação

A cada fase pronta: `README.md` (cenário, fluxo, variáveis), `MAPA-PREREQ.md`, a skill `ansible-oracle-install`
e o `site.yml`. Já atualizados para as fases 00, 10 e 15.
