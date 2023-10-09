USE NorthWind
GO

-- Preparando tabela
IF OBJECT_ID('EmployeesBig') IS NOT NULL
  DROP TABLE EmployeesBig
GO
SELECT IDENTITY(Int, 1,1) AS EmployeeID,
       a.LastName,
       a.FirstName + SUBSTRING(CONVERT(VarChar(200), NEWID()), 0, 5) AS FirstName,
       a.Title,
       a.TitleOfCourtesy,
       a.BirthDate,
       a.HireDate,
       a.Address,
       a.City,
       a.Region,
       a.PostalCode,
       a.Country,
       a.HomePhone,
       a.Extension,
       a.Notes,
       a.ReportsTo,
       a.PhotoPath
  INTO EmployeesBig
  FROM Employees AS a, Employees AS b, Employees AS c, Employees AS d, Employees AS e
GO
ALTER TABLE EmployeesBig ADD CONSTRAINT xpkEmployeeID PRIMARY KEY (EmployeeID)
GO


-- Sugest�es n�o s�o exibidas para planos triviais...
SELECT LastName,
       FirstName,
       Title,
       TitleOfCourtesy,
       BirthDate,
       HireDate,
       Address,
       City,
       Region,
       PostalCode,
       Country,
       HomePhone,
       Extension
  FROM EmployeesBig
 WHERE PostalCode = '98122'
OPTION (RECOMPILE)
GO


-- A recomenda��o � de um �ndice com TODAS as colunas no include cuidado com isso!
SELECT LastName,
       FirstName,
       Title,
       TitleOfCourtesy,
       BirthDate,
       HireDate,
       Address,
       City,
       Region,
       PostalCode,
       Country,
       HomePhone,
       Extension
  FROM EmployeesBig
 WHERE PostalCode = '98122'
OPTION (RECOMPILE, QueryTraceON 8757) -- TraceFlag 8758 para desabilitar planos trivial plans
GO

-- Recomenda��es s�o feitas com base no plano ESTIMADO,
-- Se a estimativa estiver errada, ele n�o vai recomendar nada, 
-- ou pode recomendar errado
-- Ou seja, recomenda��o � feita baseada no plano estimado, 
-- com base nos filtros utilizados...
-- Talvez n�o sirva para todos os casos...

-- Atualizando as estat�sticas para "enganar" o Otimizador
-- DBCC SHOW_STATISTICS (EmployeesBig) WITH STATS_STREAM
-- Stats_Stream	Rows	Data Pages
-- NULL	59049	1543
UPDATE STATISTICS EmployeesBig WITH ROWCOUNT = 1, PAGECOUNT = 1
GO
SELECT LastName, FirstName, Title
  FROM EmployeesBig
 WHERE PostalCode = '98122'
OPTION (RECOMPILE, QueryTraceOn 8757)
GO
UPDATE STATISTICS EmployeesBig WITH ROWCOUNT = 59049, PAGECOUNT = 1543
GO



-- �ndice sugerido n�o � a melhor op��o
SELECT OrderID, CustomerID, OrderDate, Value
  FROM OrdersBig
 WHERE OrderDate = '20080205'
 ORDER BY Value
OPTION (RECOMPILE, QueryTraceOn 8757)


-- Consegue ver o problema no �ndice sugerido?
CREATE NONCLUSTERED INDEX ix1 ON [dbo].[OrdersBig] ([OrderDate]) 
INCLUDE ([CustomerID],[Value])
GO

-- E agora o sort? ...
SELECT CustomerID, OrderDate, Value
  FROM OrdersBig
 WHERE OrderDate = '20080205'
 ORDER BY Value
OPTION (RECOMPILE, QueryTraceOn 8757)

-- O �ndice correto �: 
 -- DROP INDEX ix1 ON [dbo].[OrdersBig] 
CREATE NONCLUSTERED INDEX ix1 ON [dbo].[OrdersBig] ([OrderDate], [Value]) INCLUDE ([CustomerID])
WITH(DROP_EXISTING=ON)
GO


