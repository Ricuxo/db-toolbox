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

**Inventários reais não entram no repositório.** Só o `inventories/example/` é versionado (veja o
`inventories/.gitignore`). O inventário de cada ambiente ou cliente tem IPs, nomes, discos e senhas
(vault) e fica na máquina de quem opera, ou num repositório privado. Para começar, copie o modelo:
`cp -r inventories/example inventories/<amb>` e siga o `inventories/example/README.md`.

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
