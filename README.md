# 📦 SmartStock: Inventory Aging & Operational Analytics

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/MS_SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Data Analytics](https://img.shields.io/badge/Data_Analytics-Operations-blue?style=for-the-badge)

## 📑 Table of Contents
- [Project Overview](#-project-overview)
- [Business Problem](#-business-problem)
- [Tech Stack](#-tech-stack)
- [Data Architecture & Backend Logic](#-data-architecture--backend-logic)
- [Dashboard & Frontend Design](#-dashboard--frontend-design)
- [Business Impact & Results](#-business-impact--results)
- [How to Run This Project](#-how-to-run-this-project)

---

## 🎯 Project Overview
**SmartStock** is an end-to-end data analytics project designed to optimize inventory working capital and support warehouse operations. By extracting raw data from a fictional Warehouse Management System (WMS) and translating complex business logic into automated SQL views, this project provides a real-time, actionable Power BI dashboard for PMO and Operations Managers to monitor aging stock, facilitate Return-to-Vendor (RTV) processes, and minimize expiry risks.

---

## 🚨 Business Problem
In fast-paced logistics and e-commerce environments, capital is often tied up in slow-moving or obsolete inventory (Bad Stock). Operations teams struggle with:
1. Identifying which specific batches are aging past 90 days.
2. Tracking items approaching their expiration date (FMCG).
3. Knowing exactly which items are eligible for immediate Return-to-Vendor (RTV) to recover capital.

**The Goal:** Shift from manual, reactive reporting to a proactive, data-driven execution model.

---

## 🛠 Tech Stack
* **Database / Backend:** MS SQL Server (T-SQL)
* **BI Tool / Frontend:** Power BI Desktop (DAX, Power Query / M Code)
* **Techniques:** Data Modeling (Star Schema), ETL Transformations, Conditional Formatting, Cross-filtering.

---

## ⚙️ Data Architecture & Backend Logic (SQL)
To ensure the Power BI dashboard runs smoothly, all heavy data transformations and business logic were pushed to the backend using an automated SQL View (`vw_Inventory_Aging_Analysis`).

**Key SQL Logic Implemented:**
* **Aging Calculation:** Used `DATEDIFF()` to calculate `DaysInInventory` based on receipt dates.
* **Aging Buckets:** Utilized `CASE WHEN` to categorize stock health:
  * `0-30 Days`: Healthy
  * `31-60 Days`: Slow
  * `61-90 Days`: Warning
  * `>90 Days`: Bad Stock
* **RTV Eligibility:** Automated logic to flag batches as *'Eligible for Return'* based on vendor SLAs.
* **Expiry Status:** Tracked shelf-life for FMCG items to flag *'Near Expiry (<30D)'*.

*(You can view the full SQL script in the `sql/` folder of this repository).*

---

## 📊 Dashboard & Frontend Design (Power BI)
The dashboard was designed following a **Top-Down Executive Layout** to guide the user from high-level KPIs down to granular execution tasks.

### 1. KPI Strip (The "What")
* **Total Inventory Value:** Tracking ~$5M+ in working capital.
* **Bad Stock Ratio (%):** Core metric to monitor inventory health.
* **RTV Potential Value:** Capital that can be recovered immediately.
* **Near Expiry Value:** Risk alert for perishable goods.

### 2. Analytical Core (The "Why & Where")
* **Donut Chart:** Value distribution across aging buckets.
* **Bar Chart:** Top product categories exposed to Bad Stock risk.
* **Treemap:** Space utilization mapping across warehouse zones (Picking, Bulk, Quarantine).

### 3. Execution Center (The "How")
* **Stock Action List:** A highly actionable Matrix table. Features **conditional formatting** (Gradient backgrounds & Alert Icons) to instantly highlight batches requiring priority clearance or RTV processing.

---

## 💡 Business Impact & Results
By deploying this analytical framework, the Operations and PMO teams can:
* **Reduce manual reporting time** by replacing Excel dumps with automated SQL-to-BI pipelines.
* **Accelerate bad stock clearance** by providing the warehouse floor with a prioritized, ready-to-use action list.
* **Improve capital liquidity** by actively monitoring and executing Returns (RTV) before policy deadlines expire.

---

## 🚀 How to Run This Project
1. **Database Setup:** * Open SSMS (SQL Server Management Studio).
   * Run the `01_Create_Mock_Data.sql` script to generate the WMS tables.
   * Run the `02_Create_Views.sql` script to deploy the backend logic.
2. **Dashboard Setup:**
   * Open the `SmartStock_Dashboard.pbix` file.
   * Go to *Transform Data > Data Source Settings* and update the server name to your local SQL Server instance.
   * Click *Refresh* to load the data.

---
*Created by **Bui Thanh Duy** - Data Analytics & Operations Specialist* *📧 [duyth1227@gmail.com] | 🔗 [https://github.com/duyth2712/WMS-Inventory-Model]*