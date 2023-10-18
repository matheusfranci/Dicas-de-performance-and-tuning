USE Northwind
GO
IF OBJECT_ID('vw_Test') IS NOT NULL
  DROP VIEW vw_Test
GO
IF OBJECT_ID('OrdersBig') IS NOT NULL
  DROP TABLE OrdersBig
GO
CREATE TABLE [dbo].[OrdersBig](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[Value] [numeric](18, 2) NOT NULL
) ON [PRIMARY]
GO
INSERT INTO [OrdersBig] WITH (TABLOCK) ([CustomerID], OrderDate, Value) 
SELECT TOP 1000000
       ABS(CHECKSUM(NEWID())) / 1000000 AS CustomerID,
       ISNULL(CONVERT(Date, GETDATE() - (CheckSUM(NEWID()) / 1000000)), GetDate()) AS OrderDate,
       ISNULL(ABS(CONVERT(Numeric(18,2), (CheckSUM(NEWID()) / 1000000.5))),0) AS Value
  FROM Orders A
 CROSS JOIN Orders B
 CROSS JOIN Orders C
 CROSS JOIN Orders D
GO
ALTER TABLE OrdersBig ADD CONSTRAINT xpk_OrdersBig PRIMARY KEY(OrderID)
GO


/*
  Consulta abaixo faz um Scan no �ndice cluster
*/
SET STATISTICS IO ON
SELECT CustomerID, SUM(Value)
  FROM OrdersBig
 GROUP BY CustomerID
 ORDER BY CustomerID
SET STATISTICS IO OFF
GO

IF OBJECT_ID('vw_Test') IS NOT NULL
  DROP VIEW vw_Test
GO
CREATE VIEW vw_Test
WITH SCHEMABINDING AS 
SELECT CustomerID, SUM(Value) AS Value, Count_Big(*) AS CountBig
  FROM dbo.OrdersBig
 GROUP BY CustomerID
GO
CREATE UNIQUE CLUSTERED INDEX ix_View ON vw_Test(CustomerID) WITH(DATA_COMPRESSION=PAGE)
GO


-- E agora, quantas p�ginas?... 
SET STATISTICS IO ON
SELECT CustomerID, SUM(Value)
  FROM OrdersBig
 GROUP BY CustomerID
 ORDER BY CustomerID
SET STATISTICS IO OFF
GO
