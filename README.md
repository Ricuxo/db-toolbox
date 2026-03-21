# 📦 db-toolbox

![Status](https://img.shields.io/badge/status-active-success)
![Type](https://img.shields.io/badge/type-dba--toolbox-blue)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

> Database scripts and automation toolbox for daily DBA operations.

---

## 🎯 Purpose

This repository centralizes scripts and tools used in day-to-day database administration and automation tasks.

It is designed to:

* Organize scripts by technology and purpose
* Enable safe versioning and reuse
* Facilitate script transport across restricted environments
* Serve as a personal DBA toolbox

---

## 🧠 Repository Structure

```bash
db-toolbox/
│
├── db/
│   ├── oracle/
│   │   ├── dataguard/
│   │   ├── rman/
│   │   ├── performance/
│   │   ├── maintenance/
│   │   └── duplicate_database/
│   │
│   ├── mongo/
│   │   ├── scripts/
│   │   ├── monitoring/
│   │   └── admin/
│   │
│   └── sql/
│       ├── scripts/
│       └── reports/
│
├── ansible/
│   ├── ansible-oracle/
│   ├── playbooks/
│   └── roles/
│
├── automation/
│   ├── shell/
│   ├── python/
│   └── monitoring/
│
├── utils/
├── templates/
└── README.md
```

---

## 📂 Directory Overview

### 🔹 db/

Database-related scripts grouped by technology:

* **oracle/**: Oracle database operations (Data Guard, RMAN, performance, maintenance)
* **mongo/**: MongoDB administration, monitoring, and operational scripts
* **sql/**: Generic SQL scripts and reporting queries

---

### 🔹 ansible/

Infrastructure automation using Ansible:

* Playbooks
* Roles
* Oracle-related automation

---

### 🔹 automation/

General-purpose automation scripts:

* Shell scripts
* Python scripts
* Monitoring utilities

---

### 🔹 utils/

Reusable helper scripts and utilities.

---

### 🔹 templates/

Base templates to standardize new scripts.

---

## ⚙️ Usage Workflow

```bash
git pull
# edit or add scripts
git add .
git commit -m "feat: add new monitoring script"
git pull --rebase
git push
```

---

## 🧾 Best Practices

* Use descriptive and consistent naming
* Keep scripts organized by domain and purpose
* Avoid committing temporary or environment-specific files
* Document complex scripts when necessary

---

## 🔐 Security Guidelines

* Do NOT store credentials, passwords, or sensitive data
* Use `.gitignore` to exclude local or confidential files
* Sanitize scripts before sharing externally

---

## ☁️ Synchronization Note

This repository may be mirrored to cloud storage tools for file transfer purposes.

> ⚠️ Avoid using synchronized folders as your primary development workspace.

---

## 🚀 Future Improvements

* Environment-based organization (DEV / HML / PRD)
* Script standardization and naming conventions
* Integration with automation pipelines
* Expansion to DBRE practices

---

## 👤 Author

Henrique Soares da Silva
