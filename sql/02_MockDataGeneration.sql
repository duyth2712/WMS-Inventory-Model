-- Populates 1000+ rows simulating realistic scenarios (Aging stock, Expiry risks, and Warehouse zones).

-- 1. Populate dim_Product (Diverse categories and price points)
INSERT INTO dim_Product (SKU, ProductName, Category, Brand, UnitCost, OriginalPrice) VALUES
('SKU001', 'Smartphone X1', 'Electronics', 'TechBrand', 500.00, 750.00),
('SKU002', 'Wireless Earbuds', 'Electronics', 'SoundPro', 50.00, 99.00),
('SKU003', 'Organic Milk 1L', 'FMCG', 'EcoFarm', 1.50, 3.00),
('SKU004', 'Cotton T-Shirt L', 'Fashion', 'StyleCo', 10.00, 25.00),
('SKU005', 'Air Fryer 5L', 'Home & Kitchen', 'CookMaster', 80.00, 150.00),
('SKU006', 'Gaming Mouse', 'Electronics', 'TechBrand', 30.00, 60.00),
('SKU007', 'Running Shoes', 'Fashion', 'StyleCo', 45.00, 110.00),
('SKU008', 'Instant Noodles Box', 'FMCG', 'QuickFood', 12.00, 20.00);

-- 2. Populate dim_Supplier (Varying return policies)
INSERT INTO dim_Supplier (SupplierID, SupplierName, ContactEmail, LeadTimeDays, ReturnPolicyDays) VALUES
('SUP001', 'Global Tech Distro', 'sales@globaltech.com', 5, 30),
('SUP002', 'EcoFarm Logistics', 'orders@ecofarm.com', 2, 15),
('SUP003', 'Fast Fashion Wholesaler', 'contact@ffw.com', 7, 60),
('SUP004', 'Mega Kitchen Supplies', 'support@megakitchen.com', 10, 90);

-- 3. Populate dim_Location (Simulating warehouse zones)
INSERT INTO dim_Location (LocationID, ZoneType, Aisle, Rack, Bin) VALUES
('LOC-A01-01', 'Picking', 'A', '01', '01'),
('LOC-A01-02', 'Picking', 'A', '01', '02'),
('LOC-B05-10', 'Bulk', 'B', '05', '10'),
('LOC-B05-11', 'Bulk', 'B', '05', '11'),
('LOC-Q01-01', 'Quarantine', 'Q', '01', '01');

-- 4. Generate 1000 Rows for fact_Inventory_Batch
WITH RandomData AS (
    SELECT 1 as ID
    UNION ALL
    SELECT ID + 1 FROM RandomData WHERE ID < 1000
)
INSERT INTO fact_Inventory_Batch (BatchID, SKU, SupplierID, LocationID, ReceiveDate, ManufactureDate, ExpirationDate, InitialQty, CurrentQty)
SELECT 
    'BATCH-' + CAST(ID AS VARCHAR),
    -- Randomly pick a SKU
    CASE (ID % 8) 
        WHEN 0 THEN 'SKU001' WHEN 1 THEN 'SKU002' WHEN 2 THEN 'SKU003' WHEN 3 THEN 'SKU004'
        WHEN 4 THEN 'SKU005' WHEN 5 THEN 'SKU006' WHEN 6 THEN 'SKU007' ELSE 'SKU008' 
    END,
    -- Randomly pick a Supplier
    CASE (ID % 4) 
        WHEN 0 THEN 'SUP001' WHEN 1 THEN 'SUP002' WHEN 2 THEN 'SUP003' ELSE 'SUP004' 
    END,
    -- Randomly pick a Location
    CASE (ID % 5) 
        WHEN 0 THEN 'LOC-A01-01' WHEN 1 THEN 'LOC-A01-02' WHEN 2 THEN 'LOC-B05-10' 
        WHEN 3 THEN 'LOC-B05-11' ELSE 'LOC-Q01-01' 
    END,
    -- Randomly generate ReceiveDate (from 1 year ago to today)
    DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 365), GETDATE()),
    -- ManufactureDate is usually 30-60 days before ReceiveDate
    NULL, -- To be updated below
    NULL, -- To be updated below
    -- Initial Quantity (between 50 and 500)
    (ABS(CHECKSUM(NEWID())) % 450) + 50,
    -- Current Quantity (between 0 and InitialQty)
    0     -- To be updated below to ensure CurrentQty <= InitialQty
FROM RandomData
OPTION (MAXRECURSION 1000);

-- 5. Data Post-Processing (Ensure logical consistency)
UPDATE fact_Inventory_Batch
SET 
    CurrentQty = CAST(InitialQty * (RAND(CHECKSUM(NEWID())) * 0.8) AS INT), -- Set random current stock
    ManufactureDate = DATEADD(DAY, -60, ReceiveDate),
    ExpirationDate = CASE 
        WHEN SKU IN ('SKU003', 'SKU008') THEN DATEADD(DAY, 180, ReceiveDate) -- FMCG has expiration
        ELSE NULL -- Electronics/Fashion don't usually have expiration dates in this context
    END;