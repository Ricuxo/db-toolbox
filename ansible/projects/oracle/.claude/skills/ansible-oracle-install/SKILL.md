---
name: ansible-oracle-install
description: >-
  Pré-voo e orientação do projeto Ansible oracle-install (roles próprias, variáveis ora_; 19c,
  Oracle Restart, ASM com ASMLib v3, Oracle Linux 9, servidor novo). Revisa o inventário antes de
  rodar (ora_version, ora_ru, catálogo ora_media e one-offs exigidos pela página oficial da RU,
  discos by-id, vault, accept_warnings, allow_existing), descobre em que fase o servidor está,
  concilia o stage com o catálogo, diz qual fase vem com o comando pronto e interpreta falhas das
  fases 00 a 70. Use sempre que o DBA perguntar "o que rodar", "está pronto", "em que fase está",
  "faltou algum patch ou one-off", "o stage está correto", "revisa o host_vars", "por que a fase X
  falhou", ou for instalar um Oracle com este projeto. Só leitura e --check; nunca altera o
  inventário nem roda playbook real sem aprovação explícita do DBA.
---

# Pré-voo do oracle-install

Os playbooks do `oracle-install` **executam e se defendem**. A fase 00 aborta com Oracle ou outro
SGBD no servidor, a 20 confere a presença da mídia pelo nome e avisa sobre itens fora do catálogo, e as fases 30 a 70
recusam estado parcial. Esta skill é a **camada de julgamento em volta deles**: revisa o que o DBA
declarou, descobre onde o servidor está, aponta a próxima fase e explica falhas.

**Não repita checagens que os playbooks já fazem.** Para a presença da mídia, mande rodar a fase 20 em
`--check`. Para saber se o servidor está limpo, mande rodar a fase 00 em `--check`. A skill
acrescenta o que o YAML não sabe: se o catálogo bate com a doc oficial, se o inventário afrouxa
alguma regra, e em que ponto do fluxo o servidor está.

## Regras (do DBA; valem sobre qualquer costume)

- **Documentação oficial como fonte.** Requisito, patch exigido e combinação SO × RU vêm da doc da
  Oracle da versão alvo (docs.oracle.com, notas MOS) ou do `man` da ferramenta. Cite a fonte. Sem
  fonte lida nesta sessão, escreva **NÃO VERIFICADO**. Não preencha de memória.
- **Sem bypass.** Nunca proponha `-ignorePrereq`, `-ignorePrereqFailure`, `CV_ASSUME_DISTID`, aviso
  em `accept_warnings`, limite reduzido ou instalação sem a RU como saída. Requisito não atendido se
  corrige no servidor.
- **Mídia pelo nome do arquivo.** O catálogo não tem checksum (decisão do DBA, como a oravirt). Não sugira sha256.
- **Discos só por `/dev/disk/by-id/`.**
- **Senhas só no vault.** Nunca em claro, em `-e` ou em log.
- **Leitura e `--check` são livres. Mudança no servidor ou no inventário só com aprovação.** A
  skill sugere entradas; quem edita é o DBA, ou o Claude depois de um "sim" explícito.
- A oravirt (`ansible/ansible-oracle`) e o `ansible/old-ansible` são só referência de leitura.
  Nunca sugira roles ou variáveis deles.

## Passo 0 — ler a fonte da verdade

O projeto fica em `db-toolbox/ansible/projects/oracle/oracle-install/`. Antes de opinar, leia:

- `README.md`: fluxo, fases e tabela de variáveis. **É a lista oficial de variáveis**; a skill não
  copia essa lista.
- `CLAUDE.md`: regras do DBA e o roteiro de validação.
- `roles/*/defaults/main.yml` e `roles/*/meta/argument_specs.yml`: padrões e tipos.
- O inventário alvo, compartilhado entre projetos em `db-toolbox/ansible/inventories/<amb>/`:
  `hosts.yml`, `group_vars/all/main.yml` (`ora_env`), `group_vars/oracle/main.yml` (padrões e
  `ora_version`) e `host_vars/<host>.yml`. Da instalação, no projeto:
  `oracle-install/playbooks/group_vars/all/` (`media.yml`: RU alvo e catálogo). O `vault.yml` só para ver **se** os valores estão criptografados; nunca
  tente decifrar.

Se o código divergir do que está escrito aqui, o código e o README vencem. Avise a divergência.

## Passo 1 — revisar o inventário (no controller, antes de rodar)

Marque cada item como `[ok]`, `[FALTA]`, `[ATENÇÃO]` ou `[RISCO]`.

**Versão e RU**
- `ora_version` em 4 partes (`19.3.0.0`), que é a release da mídia base.
- `ora_ru` definido em 4 partes. Confira na doc oficial que a combinação SO/kernel × RU é suportada
  (ex.: o guia 19c exige RU ≥ 19.32 para OL9 com UEK 8). Sem a página lida: NÃO VERIFICADO.

**Catálogo `ora_media`**
- Chaves obrigatórias: `grid_base`, `db_base`, `opatch`, `ru_grid`, `ru_db`. Cada item com `file`.
  `patchid` nos RUs e em cada one-off. `asmlib` é obrigatório para a fase 30.
- **One-offs exigidos pela RU:** leia a página oficial "Installing Oracle Database 19c (19.xx) on
  Oracle Linux 9 and RHEL 9" da RU alvo e compare com `ora_media.oneoffs`. Um one-off exigido que
  falta vira `[FALTA]`. Um one-off que está no catálogo e não aparece na página vira `[ATENÇÃO]`,
  para o DBA confirmar.
- O one-off tem de ser a variante da RU alvo. O nome leva a RU em 5 partes sem pontos (ex.: `p39544247_1932000DBRU_…`
  para a 19.32), e uma variante de outra RU vira `[RISCO]`. Os RUs e o OPatch se chamam
  `p<id>_190000_…` (versão base), e a RU deles se confere pela descrição no MOS e pelo `patchid`.
- Item comentado, ou anotado "não vai para produção", num inventário de produção vira `[RISCO]`.
  No lab, vira `[ATENÇÃO]` com a pendência registrada.

**ASM**
- Todo `ora_asm.disks[].device` começa com `/dev/disk/by-id/`. `/dev/sdX` ou `/dev/nvmeXnY` vira
  `[RISCO]`. No VMware com NVMe, `nvme-eui.*` (o `nvme-VMware_…` repete o serial).
- Labels únicos, e todo `diskgroups[].disks` cita um label que existe. O 1º diskgroup é o que o
  gridSetup cria.

**Senhas**
- `vault_ora_sysasm_password`, `vault_ora_asmsnmp_password`, `vault_ora_sys_password`,
  `vault_ora_system_password` e `vault_ora_pdbadmin_password` estão no `vault.yml` como `!vault`.
- Procure senha em claro em todo o inventário, com `grep -riE 'pass(word)?\s*:'` e ignorando
  `!vault`. Senha em claro vira `[RISCO]`; mostre só o caminho e a chave, nunca o valor.

**Afrouxamentos (regra "sem bypass")**
- `ora_grid_accept_warnings`, `ora_db_accept_warnings` ou `ora_dbca_accept_warnings` diferente de
  `[]` vira `[ATENÇÃO]`. Em produção vira `[RISCO]`. O padrão da casa, inclusive no lab, é `[]`.
- `ora_gate_allow_existing` gravado no inventário vira `[RISCO]`, porque só vale como decisão
  pontual na linha de comando.
- `ora_hugepages_max_pct` acima de 70, o teto da doc 19c, vira `[RISCO]`.
- Qualquer variável ou `extra-args` com `ignorePrereq` ou `CV_ASSUME_DISTID` vira `[RISCO]`.

**Banco (fase 60)**
- `ora_db_name`, `ora_pdb_name`, `ora_db_total_memory_mb`, `ora_db_fra_size_mb`,
  `ora_db_redo_size_mb` e `ora_db_services` (`{name, pdb}`, com o `pdb` igual a `ora_pdb_name`)
  estão definidos.

## Passo 2 — em que fase o servidor está (somente leitura)

Use os sinais de `references/sinais-por-fase.md`. Colete tudo com **um** `ansible -m shell` só de
leitura e classifique:

- **VAZIO:** nenhum sinal. O caminho é triagem → 00 → 10.
- **Fase N concluída:** todos os sinais até N e nenhum de N+1. A próxima é N+1.
- **PARCIAL:** sinais de uma fase pela metade. Exemplos: Grid home com sub-patch da RU no
  `.patch_storage` sem `olr.loc`; processo do instalador rodando; DB home sem registro no
  inventário. **Pare**, mostre a evidência e peça a decisão do DBA (limpar ou retomar). Não sugira
  rodar a fase de novo: a role vai recusar, e isso é correto.

Lembre que a fase 00 **aborta de propósito** depois da 40, porque passa a haver Oracle no servidor.
Isso não é erro; o gate é só para servidor novo.

## Passo 3 — conciliar o stage

Liste `ora_stage_dir` no servidor, sem recursão (`patches/` é o destino da extração).

O catálogo são as entradas **não comentadas** de `ora_media` com `file` (as chaves e cada item de
`oneoffs`). Linhas comentadas não contam. Ao dar um total, conte arquivo a arquivo e cite os nomes.

- **Arquivo do catálogo ausente** vira `[FALTA]`. Diga ao DBA qual arquivo copiar via `scp` para o
  stage. A skill não copia nem baixa nada.
- **Patch órfão** (`p*.zip` no stage que não está no `ora_media`): tire o `patchid` do nome
  (`p<patchid>_<versão>_<plataforma>.zip`). Se puder, confirme o patch pelo README de dentro do ZIP
  (`unzip -l`/`unzip -p`, só leitura). Sugira a entrada para o DBA revisar e colar:
  ```yaml
  - {file: p<patchid>_<versão>_Linux-x86-64.zip, patchid: "<patchid>"}  # <descrição do MOS>
  ```
  Diga se ele é exigido pela página da RU (então vai em `oneoffs`) ou se fica fora do fluxo de
  instalação, como a OJVM, que depende de decisão do DBA.
- A presença da mídia é da fase 20: recomende `20_stage.yml --check`.

## Passo 4 — próxima fase, com o comando pronto

Sempre com `cd` absoluto e `--check` antes da execução real:

```
cd /projetos/DESENVOLVIMENTO/desenvolvimento/db-toolbox/ansible/projects/oracle/oracle-install && ansible-playbook -i ../../../inventories/<amb> playbooks/<fase>.yml --check
```

| Momento | O que rodar | Avisos |
|---|---|---|
| Antes de tudo | skill `oracle-install-os`, **triagem** | Devolve à infra o que o playbook não resolve (RAM, swap, `/u01`, discos) |
| 00 | `00_gate.yml --check` | Só leitura |
| 10 | `10_host_prep.yml --check --diff`, depois a execução real | O GRUB (THP `madvise`) só vale no próximo boot: reiniciar em janela |
| Depois da 10 | `oracle-install-os`, **confirmação** | Obrigatória antes do software |
| 20 | DBA copia a mídia para o stage, depois `20_stage.yml` | nome do arquivo igual ao do `ora_media` |
| 30 | `30_asmlib.yml` | Só disco vazio por by-id |
| 40 | `40_grid.yml --ask-vault-pass` | Pede o vault **até em `--check`** (o arg spec renderiza as senhas); cerca de 15 a 30 min |
| 50 | `50_db_software.yml` | Cerca de 15 min |
| 60 | `60_dbca.yml --ask-vault-pass` | Cerca de 30 min |
| 65 | `65_db_service.yml` | Idempotente |
| 70 | `70_hugepages.yml` | **Reinicia o banco** (até 2 vezes): em servidor em uso, só em janela. Em `prod` exige `-e ora_confirm_env=prod`, **também no `--check`** (a guarda roda antes de tudo) |

Antes de execução longa em VM de notebook, lembre: suspensão desligada (atrasa o relógio e
pendura o async).

Depois de cada fase real, o roteiro do `CLAUDE.md`: 2ª execução com `changed=0` e, quando couber,
um teste negativo.

## Passo 5 — interpretar falhas

Leia `references/falhas-conhecidas.md` quando o DBA colar um erro ou um log. Para cada falha:
causa, evidência a coletar (só leitura) e ação. **A ação nunca é bypass.** Se a falha não estiver no
arquivo, investigue no log do instalador ou no alert log e na doc oficial antes de propor qualquer
coisa. Se o achado for novo e confirmado, sugira acrescentá-lo ao arquivo.

## Fora do escopo (diga isso; não improvise)

- Patch ou RU num ambiente já instalado (o antigo "Fluxo B"). O caminho é um projeto próprio,
  ainda inexistente.
- Segundo Oracle home ao lado de banco existente: projeto separado, por decisão do DBA.
- RAC além das fases prontas: o cenário `rac_asm` (grupo `oracle_rac`) está em construção. Prontas
  para `rac_asm`: 00, 10, 15, 20 e 40. Ainda não implementadas: 50, 60, 65 e 70 — o `hosts` padrão
  dessas fases exclui `oracle_rac` e as roles não têm ramo RAC; ao passá-las com
  `-e ora_hosts=<cluster RAC>`, o `ora_hosts` sobrepõe o padrão e a fase aborta (ex.: a 50 afirma
  `olr.loc` ausente, que após a 40 passa a existir). Não se aplicam ao RAC: 30 (ASMLib — disco por
  udev na 15), 55 e 62 (`si_fs`). Desenho em `oracle-install/DESENHO-RAC.md`.
- Banco em filesystem sem ASM, versões além da 19c, separação de papéis (usuário `grid`).

Para essas situações, não sugira roles da oravirt nem adapte as fases de instalação.

## Relatório (sempre neste formato)

```
# Pré-voo oracle-install — <host> (<ambiente>)

## Inventário
[ok|FALTA|ATENÇÃO|RISCO] <item> — <evidência: arquivo:chave> — <fonte oficial, se houver>

## Estado do servidor
[VAZIO | Fase N concluída | PARCIAL] — <sinais encontrados>

## Stage
[ok|FALTA|ATENÇÃO] <arquivo> — <no catálogo? presente? órfão?>
<entrada sugerida para ora_media, se houver órfão>

## Próxima fase
<fase e comando com cd absoluto; --check primeiro; avisos de janela, vault e tempo>

## Pendências antes de executar
<o que o DBA precisa resolver>

## Fora do escopo / NÃO VERIFICADO
<o que não foi conferido e por quê>
```

## Nunca

- Editar o inventário, as roles ou o vault sem um "sim" explícito do DBA.
- Rodar `ansible-playbook` sem `--check` sem aprovação.
- Baixar ou copiar mídia.
- Gravar arquivo no servidor, nem temporário (script SQL em `/tmp`, por exemplo). A coleta é por comando e pipe.
- Propor bypass, aviso aceito ou limite reduzido.
- Decifrar o vault, mostrar senha ou passar senha por `-e`.
- Formatar, particionar ou marcar disco à mão. Isso é da fase 30, só com disco vazio.
- Alterar SELinux ou firewall (só reportar `getenforce` e `systemctl is-active firewalld`).
