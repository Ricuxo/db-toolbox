# 📦 db-toolbox

![Status](https://img.shields.io/badge/status-active-success)
![Type](https://img.shields.io/badge/type-dba--toolbox-blue)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

> Database scripts and automation toolbox for daily DBA operations.

---

## 🎯 Purpose

This repository centralizes scripts and tools used in day-to-day database administration and automation tasks.

It is designed to:

* Organize scripts by database technology and domain
* Facilitate reuse and versioning
* Enable script transport across restricted environments
* Keep automation simple and maintainable

---

## 🧠 Repository Structure

```bash
db-toolbox/
│
├── db/
│   ├── oracle/
│   │   ├── sql/
│   │   │   ├── sessions/
│   │   │   ├── tablespaces/
│   │   │   ├── objects/
│   │   │   ├── performance/
│   │   │   ├── dataguard/
│   │   │   ├── asm/
│   │   │   ├── rman/
│   │   │   ├── parameters/
│   │   │   └── system/
│   │   │
│   │   └── scripts/
│   │
│   ├── mongo/
│   │   └── scripts/
│   │
│   └── sql/
│       ├── scripts/
│       └── reports/
│
├── automation/
│   └── shell/
│       ├── oracle/
│       └── mongo/
│
├── ansible/
│   └── projects/
│       └── ansible-oracle/
│           ├── playbooks/
│           └── roles/
│
├── templates/
└── README.md
```

---

## 📂 Directory Overview

### 🔹 db/

Database-specific scripts organized by technology and domain.

#### Oracle

* SQL scripts organized by domain:

  * `sessions/`
  * `tablespaces/`
  * `objects/`
  * `performance/`
  * `dataguard/`
  * `asm/`
  * `rman/`
  * `parameters/`
  * `system/`
* Shell scripts in `scripts/`

#### Mongo

* Administrative and diagnostic scripts in `scripts/`

#### SQL

* Generic SQL scripts and reports not tied to a specific database

---

### 🔹 automation/

Executable scripts responsible for orchestration.

* Shell scripts that call database scripts
* Entry points for operational workflows

---

### 🔹 ansible/

Infrastructure automation.

* `projects/`: isolated Ansible projects
* Example: `ansible-oracle`

---

### 🔹 templates/

Reusable templates for creating new scripts.

---

## ⚙️ Usage Workflow

```bash
git pull
git add .
git commit -m "feat: add new script"
git pull --rebase
git push
```

---

## 🧾 Best Practices

* Keep scripts simple and focused
* Organize SQL by domain (not by script type)
* Avoid unnecessary abstraction
* Prefer direct execution over complex dependencies
* Separate orchestration (shell) from execution (SQL/JS)

---

## 🔐 Security Guidelines

* Do NOT store credentials or sensitive data
* Use `.gitignore` to exclude local files
* Sanitize scripts before sharing externally

---

## ☁️ Synchronization Note

This repository may be mirrored to cloud storage for file transfer purposes.

> ⚠️ Avoid using synchronized folders as your primary development environment.

---

## 🚀 Publishing Strategy

This repository is intended for internal and personal usage.

For public sharing:

* Extract reusable components into separate repositories
* Clean and document before publishing
* Reference public repositories in blog posts

---

## 👤 Author

Henrique Soares da Silva
