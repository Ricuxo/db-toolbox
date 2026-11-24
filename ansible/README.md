# ansible

Automação de bancos de dados com Ansible: um inventário compartilhado e um diretório por projeto.

```
ansible/
├── inventories/<amb>/           # um por ambiente (lab, dev, hml, prod); o ambiente é o -i
│   ├── hosts.yml
│   ├── group_vars/
│   └── host_vars/
├── inventories/example/         # modelo com um servidor de cada cenário (valores fictícios)
└── projects/<banco>/
    ├── .claude/skills/          # skills dos projetos deste banco
    └── <projeto>/               # ex.: oracle-install (README, playbooks, roles)
```

Cada projeto tem o próprio `README.md` com escopo, fases e variáveis.

## Nome das skills de projeto

Skill que existe para operar **um projeto deste diretório** se chama
**`<ferramenta>-<projeto>`**, onde `<projeto>` é o nome do diretório do projeto:

| Skill | Projeto |
|---|---|
| `ansible-oracle-install` | `projects/oracle/oracle-install` |

Ela fica em `projects/<banco>/.claude/skills/` e só carrega quando se trabalha nesse projeto.

Não confunda com as skills genéricas de DBA, que seguem `<banco>-<domínio>-<objeto>` (ex.:
`oracle-install-os`) e valem para qualquer servidor, com ou sem Ansible. Começar pela ferramenta
mostra de cara que a skill é de um projeto, e não da biblioteca genérica.
