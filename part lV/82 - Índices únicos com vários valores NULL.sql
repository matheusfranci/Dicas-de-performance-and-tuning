
/*
  Outro cen�rio complicado era � cria��o de �ndices �nicos
  mas que aceitavam NULL.
  Vamos ver o problema.
*/

IF OBJECT_ID('TMP_Unique') IS NOT NULL
  DROP TABLE TMP_Unique
GO
CREATE TABLE TMP_Unique (ID Int)
GO

/*
  Como n�o posso permitir que os Valuees dupliquem, ent�o crio um �ndice
  �nico com base na coluna ID
*/

CREATE UNIQUE INDEX ix_Unique ON TMP_Unique(ID)
GO

-- Vamos tentar inserir um o Value "1" duas vezes
INSERT INTO TMP_Unique (ID) VALUES(1) --  OK
INSERT INTO TMP_Unique (ID) VALUES(1) -- ERRO

INSERT INTO TMP_Unique (ID) VALUES(NULL) --  OK
INSERT INTO TMP_Unique (ID) VALUES(NULL) -- ERRO

/*
  At� ai ok, mas e se eu quiser aceitar Valuees NULL duplicados?
  A solu��o existente seria criar uma view indexada com o 
  WHERE IS NOT NULL
  Com o �ndice filtered ficou bem mais f�cil
*/
TRUNCATE TABLE TMP_Unique
GO
DROP INDEX ix_Unique ON TMP_Unique
GO
CREATE UNIQUE INDEX ix_Unique ON TMP_Unique(ID)
WHERE ID IS NOT NULL

INSERT INTO TMP_Unique (ID) VALUES(NULL) -- OK
INSERT INTO TMP_Unique (ID) VALUES(NULL) -- OK

INSERT INTO TMP_Unique (ID) VALUES(1) -- OK
INSERT INTO TMP_Unique (ID) VALUES(1) -- ERRO
