# oracle-install — regras para o Claude

Instalação de Oracle com Ansible, com roles próprias. Escopo, fases e variáveis estão no
`README.md`; leia-o antes de mudar qualquer coisa.

## Ordem de precedência
1. **Regras do DBA, abaixo.** Valem sobre qualquer skill ou costume.
2. **Skill `karpathy-guidelines`.** Carregue-a sempre que for escrever, revisar ou refatorar
   código Ansible deste projeto (roles, playbooks, templates, inventário).
3. Convenções já presentes no código.

Se a skill e uma regra do DBA entrarem em conflito, vale a regra do DBA. Se a dúvida persistir,
pergunte.

## Regras do DBA
- **Documentação oficial como fonte.** Todo requisito, comando, opção e valor vem da doc da
  Oracle da versão alvo, do template oficial que vem na mídia (ex.: `install/response/*.rsp`)
  ou do `man` da ferramenta oficial. Cite a fonte no comentário da task. Sem fonte, não afirme.
  Pergunte ou marque como NÃO VERIFICADO.
- **Sem bypass.** Nunca `-ignorePrereq`, `-ignorePrereqFailure`, `CV_ASSUME_DISTID` ou
  equivalentes. Nunca reduza limite nem aceite item como exceção. Requisito não atendido se
  corrige no servidor.
- **Mídia só com sha256 do MOS/edelivery.** Nunca use como referência o hash calculado do
  próprio arquivo.
- **Discos só por `/dev/disk/by-id/`.** Nunca `/dev/sdX`: os nomes mudam entre boots. Só
  particione ou marque disco vazio.
- **Senhas só do vault.** Nunca em claro, em `-e` ou em log. Tasks com senha usam
  `no_log: true`. Response files ficam com dono `oracle`, modo `0600`, e são apagados em `always`.
- **Mudança no servidor só com aprovação.** Leitura e `--check` são livres. Antes de alterar
  algo fora do que o DBA aprovou, pergunte.
- **Referências só de leitura.** `ansible/ansible-oracle` (oravirt) e `ansible/old-ansible`
  servem para consulta. Não execute nada a partir deles nem os use como dependência.

## Como validar uma mudança
1. `ansible-playbook -i ../../../inventories/lab playbooks/<fase>.yml --syntax-check`
2. `--check --diff` no laboratório.
3. Execução real, seguida de uma segunda execução com `changed=0`. Nas fases que só instalam
   em servidor limpo (40, 50 e 60), a segunda execução tem de recusar sem alterar nada
   (`failed=1`, `changed=0`).
4. Casos negativos: a fase tem de recusar entrada errada **sem alterar nada**. Confira no
   servidor depois.
5. Depois de mudar a preparação do host, rode a confirmação da skill `oracle-prereq-so`.

Relate o que foi testado e o que não foi. Não declare pronto o que não rodou.
