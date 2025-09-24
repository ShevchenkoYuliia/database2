# 🖱️ Database Project – Computer Mouse Store

This is a **student project** for practicing **SQL and database design** with **MS SQL Server**.  
The database models a store that sells **computer mice**.  
As the final stage, a **C# desktop application** (WinForms) was developed for interacting with the database.

### 📚 Database Structure

### Main Tables
- **Supplier** – stores supplier information (name, address, contacts).  
- **ComputerMouse** – product catalog (model, brand, type, price, stock).  
- **Customer** – customer data (name, email, phone, address).  
- **OrderTable** – customer orders.  
- **OrderDetails** – products inside each order.
- 
### ⚙️ Implemented Features
During the course, we practiced not only DDL (schema design), but also:

✅ Stored Procedures – inserting, updating, and deleting data.

✅ Functions – custom queries for reporting (e.g., total sales by customer).

✅ Cursors – iterating through orders to update stock quantities.

✅ Triggers – automatic actions on insert/update/delete (e.g., update stock after order).

✅ Views – simplified queries for sales reports and product availability.

### 🖥️ Final Stage – C# Application
Developed a WinForms application for managing the database.

### 🛠️ Technologies
MS SQL Server – database engine
SQL – schema, procedures, functions, triggers
C# (WinForms, .NET Framework) – desktop application

### 🚀 How to Run
Run SQL scripts in MS SQL Server Management Studio (SSMS).
Open and build the C# project in Visual Studio.
Adjust the App.config connection string to your SQL Server instance.

### 🎯 Purpose
This project was a training exercise in database design and application development, covering the full cycle:
Modeling entities and relationships.
Writing SQL queries, procedures, functions, triggers, and views.
Building a C# application for real interaction with the database
