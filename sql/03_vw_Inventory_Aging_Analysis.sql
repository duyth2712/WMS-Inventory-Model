--OBJECTIVE: Transform raw WMS data into actionable stock health insights.
--KEY METRICS: Inventory Value, Aging Buckets, Expiry Risk, and RTV Eligibility.

-- Create Inventory Aging Analysis View
CREATE OR ALTER VIEW vw_Inventory_Aging_Analysis AS
SELECT 
    f.BatchID,
    f.SKU,
    p.ProductName,
    p.Category,
    p.Brand,
    s.SupplierName,
    l.ZoneType,
    l.Aisle,
    f.ReceiveDate,
    f.ExpirationDate,
    f.CurrentQty,
    -- 1. Calculate Inventory Value (Capital tied up in stock)
    f.CurrentQty * p.UnitCost AS InventoryValue,
    
    -- 2. Calculate Days in Inventory
    DATEDIFF(DAY, f.ReceiveDate, GETDATE()) AS DaysInInventory,
    
    -- 3. Categorize Aging Buckets (Operational KPI)
    CASE 
        WHEN DATEDIFF(DAY, f.ReceiveDate, GETDATE()) <= 30 THEN '0-30 Days (Healthy)'
        WHEN DATEDIFF(DAY, f.ReceiveDate, GETDATE()) <= 60 THEN '31-60 Days (Slow)'
        WHEN DATEDIFF(DAY, f.ReceiveDate, GETDATE()) <= 90 THEN '61-90 Days (Warning)'
        ELSE '90+ Days (Bad Stock)'
    END AS AgingBucket,

    -- 4. Expiration Analysis (For FMCG)
    CASE 
        WHEN f.ExpirationDate IS NULL THEN 'No Expiry'
        WHEN f.ExpirationDate < GETDATE() THEN 'Expired'
        WHEN DATEDIFF(DAY, GETDATE(), f.ExpirationDate) <= 30 THEN 'Near Expiry (<30D)'
        ELSE 'Safe'
    END AS ExpiryStatus,

    -- 5. RTV Eligibility (Can we return this to the vendor?)
    CASE 
        WHEN DATEDIFF(DAY, f.ReceiveDate, GETDATE()) <= s.ReturnPolicyDays THEN 'Eligible for Return'
        ELSE 'Non-Returnable'
    END AS ReturnStatus

FROM fact_Inventory_Batch f
JOIN dim_Product p ON f.SKU = p.SKU
JOIN dim_Supplier s ON f.SupplierID = s.SupplierID
JOIN dim_Location l ON f.LocationID = l.LocationID
WHERE f.CurrentQty > 0; -- Only analyze items currently in stock
GO