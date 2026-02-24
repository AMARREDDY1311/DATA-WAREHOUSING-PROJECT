# 📐 Data Warehouse — Naming Conventions

> A reference guide for all naming standards applied across schemas, tables, views, columns, and stored procedures in the data warehouse.

---

## 📋 Table of Contents

1. [General Principles](#1-general-principles)
2. [Table Naming Conventions](#2-table-naming-conventions)
   - [Bronze Rules](#-bronze)
   - [Silver Rules](#-silver)
   - [Gold Rules](#-gold)
   - [Glossary of Category Patterns](#glossary-of-category-patterns)
3. [Column Naming Conventions](#3-column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
4. [Stored Procedures](#4-stored-procedures)

---

## 1. General Principles

All object names across schemas, tables, views, columns, and stored procedures must follow these baseline rules:

| Rule | Description |
|------|-------------|
| **Case style** | `snake_case` — lowercase letters with underscores as word separators |
| **Language** | English for all object names without exception |
| **Reserved words** | Never use SQL reserved words as object names |

---

## 2. Table Naming Conventions

| Layer | Pattern | Example | Notes |
|-------|---------|---------|-------|
| 🥉 Bronze | `<sourcesystem>_<entity>` | `crm_customer_info` | Exact source name preserved |
| 🥈 Silver | `<sourcesystem>_<entity>` | `crm_customer_info` | Same pattern as Bronze, no renaming |
| 🥇 Gold | `<category>_<entity>` | `dim_customers` | Business-aligned, category-prefixed |

---

### 🥉 Bronze

Tables in the Bronze layer must mirror their source system exactly — no renaming, no reformatting.

**Pattern:** `<sourcesystem>_<entity>`

| Token | Description |
|-------|-------------|
| `<sourcesystem>` | Name of the originating system, e.g. `crm`, `erp` |
| `<entity>` | Exact table name from the source system — unchanged |

**Example:**
```
crm_customer_info   →   Customer information from the CRM system
```

---

### 🥈 Silver

Silver tables inherit the same naming pattern as Bronze. Source system name and entity name are preserved — transformations happen in the data, not the name.

**Pattern:** `<sourcesystem>_<entity>`

| Token | Description |
|-------|-------------|
| `<sourcesystem>` | Name of the originating system, e.g. `crm`, `erp` |
| `<entity>` | Exact table name from the source system — unchanged |

**Example:**
```
crm_customer_info   →   Cleansed customer information from the CRM system
```

---

### 🥇 Gold

Gold layer objects use business-aligned names that describe what the data represents, not where it came from. Each name starts with a category prefix.

**Pattern:** `<category>_<entity>`

| Token | Description |
|-------|-------------|
| `<category>` | Role of the object — see the Glossary of Category Patterns below |
| `<entity>` | Descriptive, domain-aligned name such as `customers`, `products`, or `sales` |

**Examples:**
```
dim_customers   →   Dimension table for customer data
fact_sales      →   Fact table containing sales transactions
```

---

### Glossary of Category Patterns

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `dim_` | Dimension table | `dim_customer`, `dim_product` |
| `fact_` | Fact table | `fact_sales` |
| `report_` | Aggregated report table | `report_customers`, `report_sales_monthly` |

---

## 3. Column Naming Conventions

### Surrogate Keys

Every primary key in a dimension table must use the suffix `_key`. The full column name is formed by combining the entity name with this suffix.

**Pattern:** `<table_name>_key`

| Token | Description |
|-------|-------------|
| `<table_name>` | Name of the dimension table or entity the key belongs to |
| `_key` | Mandatory suffix identifying the column as a surrogate key |

**Example:**
```
customer_key   →   Surrogate key in the dim_customers table
```

---

### Technical Columns

System-generated metadata columns must be prefixed with `dwh_` to distinguish them from business data. They must never be used in business logic.

**Pattern:** `dwh_<column_name>`

| Token | Description |
|-------|-------------|
| `dwh_` | Mandatory prefix, reserved exclusively for data warehouse metadata |
| `<column_name>` | Descriptive name indicating the purpose of the metadata field |

**Example:**
```
dwh_load_date   →   System-generated column storing the date the record was loaded
```

**Common technical columns:**

| Column | Purpose |
|--------|---------|
| `dwh_load_date` | Timestamp of when the record was loaded into the warehouse |
| `dwh_create_date` | Timestamp automatically populated on row insertion via `DEFAULT GETDATE()` |

---

## 4. Stored Procedures

All stored procedures responsible for loading data into a warehouse layer must follow the pattern below. The layer name in the procedure name must exactly match the schema it populates.

**Pattern:** `load_<layer>`

| Token | Description |
|-------|-------------|
| `<layer>` | The target schema being loaded: `bronze`, `silver`, or `gold` |

| Procedure | Purpose | Target Schema |
|-----------|---------|---------------|
| `load_bronze` | Bulk-loads raw CSV data into the Bronze layer | `bronze` |
| `load_silver` | ETL — transforms Bronze data into the Silver layer | `silver` |
| `load_gold` | Builds Gold views from Silver conformed tables | `gold` |

**Usage examples:**
```sql
EXEC bronze.load_bronze;
EXEC silver.load_silver;
EXEC gold.load_gold;
```
