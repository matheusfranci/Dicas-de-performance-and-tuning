USE Northwind
GO

IF OBJECT_ID('ProductsBig') IS NOT NULL
  DROP TABLE ProductsBig
GO
SELECT TOP 10000 IDENTITY(Int, 1,1) AS ProductID, 
       dbo.fn_ReturnProductName() + ' ' + SubString(CONVERT(VarChar(250),NEWID()),1,8) AS ProductName, 
       CONVERT(VarChar(250), NEWID()) AS Col1
  INTO ProductsBig
  FROM Products A
 CROSS JOIN Products B
 CROSS JOIN Products C
 CROSS JOIN Products D
GO
INSERT INTO ProductsBig (ProductName, Col1)
VALUES  ('Produto TV 50 com nome Fabiano e c�digo - 98872167', 'Alguma coisa'), 
        ('SAMSUNG UN50JS7200GXZD LED 50" UHD SMART 4X HDMI', 'TVs SAMSUNG'), 
        ('SAMSUNG UN32J4300AGXZD TV LED 32" HD SMART 2HDMI 1USB', 'TVs SAMSUNG')
GO
ALTER TABLE ProductsBig ADD CONSTRAINT xpk_ProductsBig PRIMARY KEY(ProductID)
GO
CREATE INDEX ixProductName ON ProductsBig (ProductName) 
WITH(FILLFACTOR = 20)
GO


-- E agora, usa qual �ndice para fazer o scan?... 
-- o n�o cluster que � menor, certo?
SET STATISTICS IO ON
SELECT COUNT(*)
  FROM ProductsBig
SET STATISTICS IO OFF
GO






-- Corrigindo o fillfactor...
ALTER INDEX ixProductName ON ProductsBig REBUILD WITH(FILLFACTOR=80)
GO


-- E agora?
SET STATISTICS IO ON
SELECT COUNT(*)
  FROM ProductsBig
SET STATISTICS IO OFF
GO
