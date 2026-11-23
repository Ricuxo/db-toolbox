# Falhas conhecidas do oracle-install

Falhas vistas no laboratório (19.32, OL 9.8, UEK 8), com causa e ação. "Observado no lab" quer
dizer comportamento visto e não regra documentada. **Nenhuma ação aqui é bypass.**

## Ansible e inventário

| Mensagem | Causa | Ação |
|---|---|---|
| `Attempt to use undecryptable variable: ... no vault secrets found` | Faltou `--ask-vault-pass`. Na fase 40 acontece **até em `--check`**: a validação do arg spec renderiza as senhas | Rodar de novo com `--ask-vault-pass` |
| `[FATAL] [DBT-06205] The 'SYS' password cannot be empty` (fase 60, rc 254) | O valor no vault era só `\n`: um Ctrl+D depois de um Enter no `encrypt_string`, e o template faz trim. Os asserts usam `trim \| length > 0` para pegar antes | Regerar o valor em pipe (gerar e criptografar sem digitar) e conferir o tamanho |
| `unsupported operand type(s)` numa conta da role | Valor passado com `-e` chega como texto | A role precisa de `\| int`; reportar como defeito da role |
| Fase N trava longe do previsto; relógio do servidor horas atrás | A VM do notebook foi suspensa (async pendurado; chrony confiando em amostras velhas) | Desligar a suspensão. `chronyc makestep` pode não bastar; `systemctl restart chronyd` saltou o relógio no lab (pedir aprovação) |

## Gate e recusas (comportamento correto, não erro)

| Mensagem | Leitura |
|---|---|
| Qualquer fase: `ora_env não definido` / `não está em [lab, dev, hml, prod]` | Inventário sem `ora_env` em `group_vars/all/main.yml`, ou com outro nome de ambiente. Conferir o `-i` e o arquivo; não contornar com `-e` |
| Qualquer fase: `ora_env=X, mas o inventário deste host é .../inventories/Y` | O ambiente tem de ser o nome do diretório do `-i`. Ou passaram `-e ora_env=...`, ou o inventário foi copiado de outro ambiente sem trocar o `ora_env`. Corrigir o inventário |
| Fase 70 em `prod`: `Para seguir, repita o ambiente ... -e ora_confirm_env=prod` | A fase reinicia o banco. O DBA confirma o ambiente na linha de comando, também em `--check` |
| Qualquer fase: `ora_install_type ... não está em` / `Cenário si_fs sem ora_db_data_mount...` | O cenário vem do grupo do host (`oracle_restart` ou `oracle_si`). Conferir o `hosts.yml`; não passar o cenário por `-e` |
| Fases 30/40 em `si_fs`, 55/62 em `restart_asm`: `Esta fase é do cenário ...` | Fase do outro cenário, forçada com `-e ora_hosts=`. Não é erro do servidor |
| Fase 10 em `si_fs`: `/u02 não é um ponto de montagem` | O disco dos datafiles não está montado. É infra: disco, filesystem e fstab por UUID; depois rodar a 10 de novo |
| Fase 50 em `si_fs`: `Há Grid/Restart neste servidor` | O host tem `olr.loc`, mas está no grupo `oracle_si`. Conferir o grupo no inventário |
| Fase 55: `A porta 1521 está em uso por outro processo` | Outro serviço na 1521. Conferir o alvo; a fase não para nada |
| Fase 00: `Servidor NÃO está limpo` | Esperado depois da fase 40, ou alvo errado no inventário. Conferir o IP/hostname antes de qualquer coisa |
| Fases 40 e 50: `Esta fase só instala em servidor limpo. Encontrado: olr.loc, inventory.xml, .patch_storage/<id>_*` | A fase já rodou (ou rodou pela metade). Com o Restart ok (`crsctl stat res -t`), siga para a próxima fase. Se for parcial, o DBA decide entre limpar e retomar; nunca forçar |
| Fase 60: lista com oratab, srvctl, `+DATA/<DB>`, `cfgtoollogs/dbca/<DB>` | O banco já existe |
| Fase 30: `já é disco ASM com outro label` / disco com assinatura | A fase não mexe em disco que não está vazio. Conferir o by-id do disco certo (WWN ou EUI contra o `ddb.uuid` do vmdk) |

## Grid (fase 40) e instalador

| Mensagem | Causa | Ação |
|---|---|---|
| `runcluvfy.sh` da mídia 19.3 pendurado; `NullPointerException` em `XmlTaskFactory.getTasks` | Observado no lab: o CVU da mídia 19.3 quebra no OL9 | A fase não usa o `runcluvfy`: o gate é a checagem integrada do `gridSetup` já com a RU. Não usar `CV_ASSUME_DISTID` |
| CVU avulso (p30839369) reprova `compat-libcap1` (PRVF-7532) | Sem dados de referência de 19c para OL9; usa os do OL7 | Não usar o CVU avulso na 19c em OL9 (decisão do DBA) |
| rc 6 com `PRVG-1205` `kernel.panic` | O gridSetup 19.32 exige `kernel.panic=1` | A fase 10 grava em `98-oracle-install.conf`: rodar a 10 de novo |
| rc 6 com `PRVG-11550` cvuqdisk | Pacote ausente | A fase 40 instala da mídia (`rpm -iv`, como manda a doc) |
| rc 6 com `INS-30011` | Senha fraca para os critérios da Oracle | Gerar senha forte no vault; **não** pôr em `accept_warnings` |
| rc 6 com outro INS-/PRV- | Requisito não atendido | Ler o log do instalador, achar o item na doc e corrigir no servidor |
| Listener `INTERMEDIATE`, "Not All Endpoints Registered" | Hostname resolvido só pelo `myhostname` do nss, que devolve primeiro o fe80 link-local | A fase 10 grava `IP nodename` no `/etc/hosts` (doc 19c "Confirming Host Name Resolution"). Depois, restart do listener |
| Controller morreu no meio da fase 40 | O gridSetup async segue órfão; o rsp com senha fica em `/tmp/ora_grid_*` | Esperar terminar ou parar com o DBA. A próxima execução apaga o rsp e recusa o estado parcial |

## HugePages (fase 70)

| Mensagem | Causa | Ação |
|---|---|---|
| `ORA-27106` ao subir com `USE_LARGE_PAGES=ONLY` | HugePages insuficientes. Com `ONLY`, a instância pede 1 página a mais que no modo `TRUE` (o segmento pequeno também vai para HugePages) | Banco parado: subir `vm.nr_hugepages` em `99-nr_hugepages.conf` (com aprovação) e `srvctl start`. A role atual soma os segmentos (`sysresv` + `ipcs`) + `ora_hugepages_extra` |
| Fase 70: "SGA fora de HugePages" com `TRUE` | Ver o alert log: tabela `PAGESIZE / EXPECTED_PAGES / ALLOCATED_PAGES / ERROR(s)` da última partida. Em `TRUE`, o segmento pequeno fica em 4K de propósito (observado no lab) | Se o 2048K tiver `ALLOCATED < EXPECTED`, faltam páginas ou a memória está fragmentada (a doc manda reiniciar o servidor) |
| `O kernel alocou X de Y HugePages` | Memória fragmentada (doc 19c). Visto na 5ª VM (2973 de 3076) e na 6ª (550 de 3076: cache de 12 GB da mídia copiada e extraída no mesmo boot). Depois do reboot, 3076 no boot e o banco já sobe em HugePages | O valor já está gravado: reiniciar o servidor em janela e rodar a fase de novo. **Não** repetir a fase para "ver se pega": no lab uma nova tentativa sem reboot conseguiu as páginas, mas isso não é documentado e o DBA decidiu (2026-11-16) seguir a doc |
| PDB fechada depois de reiniciar o banco | Serviço da fase 65 ausente ou parado | Rodar a fase 65 (é o serviço AUTOMATIC que reabre a PDB) |

## Mídia (fase 20)

| Mensagem | Causa | Ação |
|---|---|---|
| `sha256 DIVERGE` | Download corrompido, ou o digest no catálogo está errado | Baixar de novo e reconferir no MOS. Se o MOS entregar um arquivo que diverge do digest publicado (caso 39932578), abrir SR. **Nunca** trocar o catálogo pelo hash do arquivo sem decisão do DBA (a única exceção registrada é o 39932578 no si_fs, em `media.yml`) |
| AVISO "fora do catálogo" | Arquivo no stage que nenhuma fase usa | Ver o Passo 3 da skill (patch órfão) |
| `/u01` é um **arquivo**, não um diretório | `scp` feito antes de o diretório existir | Não apagar: mover para fora e pedir ao DBA para copiar de novo para dentro do stage |
| Fase 50 (si_fs): `INS-08101` em `supportedOSCheck`, `NullPointerException` em `StorageUtil` | Home sem o CVU novo: a DB RU não traz CVU, quem traz é o 39932578 (no Restart, a GIRU) | Conferir se o 39932578 está no catálogo do si_fs e extraído. O home fica com a RU aplicada e sem registro: limpar `dbhome_1` e o conteúdo do `oraInventory` com aprovação do DBA |
