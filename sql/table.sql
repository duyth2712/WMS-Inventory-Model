-- Defines the Star Schema (4 core tables) to model WMS inventory data.

-- 1. Create Product Dimension Table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'dim_Product' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.dim_Product;
CREATE TABLE dbo.dim_Product (
    SKU VARCHAR(50) PRIMARY KEY,
    ProductName NVARCHAR(255),
    Category VARCHAR(100),
    Brand VARCHAR(100),
    UnitCost DECIMAL(10, 2),        -- Cost of goods sold (COGS) / Purchase price
    OriginalPrice DECIMAL(10, 2)    -- Listed retail price
);

-- 2. Create Supplier Dimension Table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'dim_Supplier' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.dim_Supplier;
CREATE TABLE dbo.dim_Supplier (
    SupplierID VARCHAR(50) PRIMARY KEY,
    SupplierName NVARCHAR(255),
    ContactEmail VARCHAR(100),
    LeadTimeDays INT,               -- Number of days from order placement to delivery
    ReturnPolicyDays INT            -- Number of days allowed for Return To Vendor (RTV)
);


-- 3. Create Location Dimension Table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'dim_Location' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.dim_Location;
CREATE TABLE dbo.dim_Location (
    LocationID VARCHAR(50) PRIMARY KEY,
    ZoneType VARCHAR(50),           -- e.g., 'Picking', 'Bulk', 'Quarantine'
    Aisle VARCHAR(10),              -- Aisle identifier (e.g., A, B, C)
    Rack VARCHAR(10),               -- Rack identifier
    Bin VARCHAR(10)                 -- Specific storage bin
);

-- 4. Create Inventory Batch Fact Table (Center of the Star Schema)
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'fact_Inventory_Batch' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.fact_Inventory_Batch;
CREATE TABLE dbo.fact_Inventory_Batch (
    BatchID VARCHAR(50) PRIMARY KEY,
    SKU VARCHAR(50) FOREIGN KEY REFERENCES dim_Product(SKU),
    SupplierID VARCHAR(50) FOREIGN KEY REFERENCES dim_Supplier(SupplierID),
    LocationID VARCHAR(50) FOREIGN KEY REFERENCES dim_Location(LocationID),
    ReceiveDate DATE,               -- Date the batch was received in the warehouse
    ManufactureDate DATE,           -- Date of manufacture
    ExpirationDate DATE,            -- Expiration date (crucial for FMCG/Food)
    InitialQty INT,                 -- Original quantity received
    CurrentQty INT                  -- Current on-hand quantity available for sale
);