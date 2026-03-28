# 📦 db-toolbox

![Status](https://img.shields.io/badge/status-active-success)
![Type](https://img.shields.io/badge/type-dba--toolbox-blue)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

> Toolbox pessoal para administração de bancos de dados, automação e troubleshooting no dia a dia.

---

## 🎯 Objetivo

Centralizar scripts e automações utilizados no dia a dia como DBA, permitindo:

* Organização por tecnologia e domínio
* Reutilização de scripts
* Versionamento via Git
* Facilidade de transporte entre ambientes restritos

---

## 🧠 Estrutura do Repositório

```bash
db-toolbox/
│
├── ansible/
│   └── projects/
│       └── ansible-oracle/
│           └── playbook/
│
├── automation/
│   └── shell-script/
│       ├── oracle/
│       └── mongo/
│
├── db/
│   ├── oracle/
│   │   ├── scripts/
│   │   └── sql/
│   │       ├── acl/
│   │       ├── archives-redos/
│   │       ├── asm/
│   │       ├── audit/
│   │       ├── awr/
│   │       ├── blocks/
│   │       ├── controlfile/
│   │       ├── database/
│   │       ├── datafiles/
│   │       ├── dataguard/
│   │       ├── datapump/
│   │       ├── enterprise-manager/
│   │       ├── environment/
│   │       ├── exadata/
│   │       ├── goldengate/
│   │       ├── indexes/
│   │       ├── initfile/
│   │       ├── inventory/
│   │       ├── jobs/
│   │       ├── licensing/
│   │       ├── locks/
│   │       ├── memory/
│   │       ├── miscellaneous/
│   │       ├── objects/
│   │       ├── profile/
│   │       ├── rman/
│   │       ├── sessions/
│   │       ├── tables/
│   │       ├── tablespace/
│   │       ├── traces/
│   │       ├── tunning/
│   │       ├── undo/
│   │       └── users/
│   │
│   ├── mongo/
│   │   ├── js/
│   │   └── scripts/
│   │
│   ├── postgresql/
│   │   ├── scripts/
│   │   └── sql/
│   │
│   └── sqlserver/
│       ├── scripts/
│       └── sql/
│
├── templates/
└── README.md
```

---

## 📂 Organização por Camadas

### 🔹 `db/`

Scripts organizados por tecnologia de banco:

* **oracle/** → estrutura completa por domínio técnico (alta granularidade)
* **mongo/** → scripts JS e operacionais
* **postgresql/** → scripts SQL e automações
* **sqlserver/** → scripts SQL e utilitários

---

### 🔹 `automation/`

Scripts de orquestração:

* Shell scripts que executam validações e rotinas
* Integração com scripts SQL/JS

---

### 🔹 `ansible/`

Projetos de automação de infraestrutura:

* Contém projetos independentes (ex: instalação Oracle)
* Uso interno e laboratório

---

### 🔹 `templates/`

Modelos reutilizáveis para criação de novos scripts.

---

## 🧠 Padrão Oracle (decisão importante)

A estrutura Oracle foi organizada por **domínio técnico detalhado**, permitindo alta especialização:

Exemplos:

* `sessions/` → sessões e locks
* `tablespace/`, `datafiles/`, `asm/` → armazenamento
* `dataguard/` → replicação
* `rman/`, `datapump/` → backup e migração
* `awr/`, `tunning/`, `memory/` → performance
* `objects/`, `users/`, `profile/` → administração lógica

> ⚠️ Estrutura intencionalmente granular para refletir operações reais de DBA.

---

## ⚡ Execução rápida com SQL*Plus

Para uso no dia a dia, os scripts não são chamados diretamente pelo path completo.

É utilizada uma pasta local fora do repositório:

```bash
~/sqlplus
```

Com configuração:

```bash
export SQLPATH=$HOME/sqlplus
```

E uso de symlinks:

```bash
ln -s <repo>/db/oracle/sql/tablespace/tablespace_usage.sql ~/sqlplus/tablespace.sql
```

Execução:

```sql
@tablespace
@sessions
@users
```

---

## ⚙️ Workflow Git

```bash
git pull
git add .
git commit -m "feat: new script"
git pull --rebase
git push
```

---

## 🧾 Boas práticas

* Scripts pequenos e objetivos
* Separação clara entre SQL e shell
* Evitar duplicação
* Nomeação simples e direta
* Não over-engineering

---

## 🔐 Segurança

* Não armazenar senhas ou dados sensíveis
* Sanitizar scripts antes de compartilhar
* Utilizar `.gitignore` quando necessário

---

## 🚀 Estratégia de publicação

Este repositório é voltado para uso interno.

Para compartilhar conteúdo:

1. Desenvolver aqui
2. Extrair versão limpa
3. Criar novo repositório público
4. Documentar
5. Publicar

---

## 👤 Autor

Henrique Soares da Silva
