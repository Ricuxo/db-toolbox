# 📦 db-toolbox

![Status](https://img.shields.io/badge/status-active-success)
![Type](https://img.shields.io/badge/type-dba--toolbox-blue)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

> Database scripts and automation toolbox for daily DBA operations.

---

## 🎯 Purpose

This repository centralizes scripts and tools used in day-to-day database administration and automation tasks.

It is designed to:

* Organize scripts by database technology
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
│   │   └── scripts/
│   │       ├── dataguard/
│   │       ├── rman/
│   │       ├── performance/
│   │       ├── maintenance/
│   │       └── duplicate_database/
│   │
│   ├── mongo/
│   │   └── scripts/
│   │       ├── collect_users.js
│   │       ├── collect_roles.js
│   │       └── check_replica.js
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
├── templates/
└── README.md
```

---

## 📂 Directory Overview

### 🔹 db/

Database-specific scripts organized by technology.

* **oracle/**: Oracle operations (Data Guard, RMAN, performance, maintenance)
* **mongo/**: MongoDB scripts for administration and diagnostics
* **sql/**: Generic SQL scripts and reports

---

### 🔹 automation/

Executable scripts responsible for orchestration.

* Shell scripts that call database scripts
* Entry points for operational workflows

---

### 🔹 templates/

Reusable templates for creating new scripts.

* Shell script templates
* SQL templates
* Standardized script structure

---

## ⚙️ Usage Workflow

```bash
git pull
# edit or add scripts
git add .
git commit -m "feat: add new script"
git pull --rebase
git push
```

---

## 🧾 Best Practices

* Keep scripts simple and focused
* Organize by database and purpose
* Avoid unnecessary abstraction
* Use consistent naming conventions
* Prefer direct execution over complex dependencies

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

## 🚀 Future Improvements

* Script naming standardization
* Advanced automation workflows
* Expansion toward DBRE practices

---

## 👤 Author

Henrique Soares da Silva
