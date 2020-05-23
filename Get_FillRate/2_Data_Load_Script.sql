--Sample Table Creation with Data Loading Script

--dropping temp table if exists
IF OBJECT_ID('TempDb..#TestEmp') IS NOT NULL
    DROP TABLE #TestEmp;
  
CREATE TABLE #TestEmp
(
    [TestEmp_Key] INT IDENTITY(1,1) NOT NULL,
    [EmpName] VARCHAR(100) NOT NULL,
    [Age] INT NULL,
    [Address] VARCHAR(100) NULL,
    [PhoneNo] VARCHAR(11) NULL,
    [Inserted_dte] DATETIME NOT NULL,
    [Updated_dte] DATETIME NULL,
 CONSTRAINT [PK_TestEmp] PRIMARY KEY CLUSTERED
 (
    TestEmp_Key ASC
 )
);
GO
   
INSERT INTO #TestEmp
(EmpName,Age,[Address],PhoneNo,Inserted_dte)
VALUES
('Arul',24,'xxxyyy','1234567890',GETDATE()),
('Gokul',22,'zzzyyy',NULL,GETDATE()),
('Krishna',24,'aaa','',GETDATE()),
('Adarsh',25,'bbb','1234567890',GETDATE()),
('Mani',21,'',NULL,GETDATE()),
('Alveena',20,'ddd',NULL,GETDATE()),
('Janani',30,'eee','',GETDATE()),
('Vino',26,NULL,'1234567890',GETDATE()),
('Madhi',25,'ggg',NULL,GETDATE()),
('Ronen',25,'ooo',NULL,GETDATE()),
('Visakh',25,'www',NULL,GETDATE()),
('Jayendran',NULL,NULL,NULL,GETDATE());
GO
   
SELECT [TestEmp_Key],[EmpName],[Age],[Address],[PhoneNo],[Inserted_dte],[Updated_dte] FROM #TestEmp;
GO