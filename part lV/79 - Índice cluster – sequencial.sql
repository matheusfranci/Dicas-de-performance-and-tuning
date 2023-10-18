USE NorthWind
GO

-- Sequencial --
/*
  Nota: Evitar page splits
  
  Page splits n�o s� causam fragmenta��o, mas geram muito mais LOG
*/

IF OBJECT_ID('BigTable') IS NOT NULL
  DROP TABLE BigTable
GO
CREATE TABLE BigTable (Col1 Integer, 
                       Col2 Char(1100));
GO
CREATE CLUSTERED INDEX Cluster_BigTable_Col1 ON BigTable(Col1);
GO

INSERT INTO BigTable VALUES (1, 'a');
INSERT INTO BigTable VALUES (2, 'a');
INSERT INTO BigTable VALUES (3, 'a');
INSERT INTO BigTable VALUES (4, 'a');
INSERT INTO BigTable VALUES (6, 'a');
INSERT INTO BigTable VALUES (7, 'a');
GO

/* 
  Visualiznado quantas p�ginas de dados foram alocadas 
  para a tabela.
  Apenas uma p�gina de dados foi alocada
*/
DBCC IND (NorthWind, BigTable, 1)
GO

/*
  Quanto espa�o livre tem na p�gina?
  Olhar a m_freeCnt no cabe�alho da p�gina.
  
  m_freeCnt = 1334
*/
DBCC TRACEON (3604)
DBCC PAGE (NorthWind, 1, 251600, 3)
/*
  S� temos mais 1418 bytes livres na p�gina, ou seja
  s� cabe mais uma linha.
*/

/*
  For�a o CheckPoint
  Como o banco esta em recovery model simple
  limpamos o LOG, para poder analisar com a ::fn_dblog
*/ 
CHECKPOINT
GO

/*
  Quando espa�o um simples INSERT ocupa no Log
  de transa��es?
*/
BEGIN TRAN

-- Inserir um registro sequencial
INSERT INTO BigTable VALUES (8, 'a');
GO

-- Consulta a quantidade de logs utilizados
SELECT database_transaction_log_bytes_used
  FROM sys.dm_tran_database_transactions
 WHERE database_id = DB_ID('NorthWind');
GO

-- Consulta quais eventos foram gerados no Log
SELECT * FROM ::fn_dblog(null, null)

COMMIT TRAN
GO

/*
  Quando espa�o um PageSplit ocupa no Log
  de transa��es?
*/
BEGIN TRAN
-- Inserir o registro 5 que esta faltando na tabela
-- para manter a ordem dos dados, o SQL precisa fazer o 
-- Split
INSERT INTO BigTable VALUES (5, 'a');
GO

-- Consulta a quantidade de logs utilizados
SELECT database_transaction_log_bytes_used
  FROM sys.dm_tran_database_transactions
 WHERE database_id = DB_ID('NorthWind');
GO

-- Consulta quais eventos foram gerados no Log
SELECT * FROM ::fn_dblog(null, null)

COMMIT TRAN
GO

/*
  PageSplit gerou praticamente 6 vezes mais log que um simples insert
*/