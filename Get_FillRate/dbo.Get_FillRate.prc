
/****** Object:  StoredProcedure [dbo].[Get_FillRate]    Script Date: 19/05/2020******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON; 
GO

/******************************************************************************************************/
-- Created By : Arulmouzhi Ezhilarasan
-- Version    : 1.0
-- Created On : 19/05/2020
-- Description: -- To Fetch the List of all columns of a table with their Fill Rates in %.
-- 20/05/2020 - Version 2.0 -  Arulmouzhi Ezhilarasan - Made Changes by avoiding while loop.
/******************************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[Get_FillRate]  
(
    @p_TableName                  NVARCHAR(128),
    @p_Include_BlankAsNotFilled   BIT = 0 -- 0-OFF(Default); 1-ON(Blank As Not Filled Data)
)
AS
BEGIN
  
BEGIN TRY
   
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  
--Parameter Sniffing
DECLARE @TableName                  NVARCHAR(128),
        @Include_BlankAsNotFilled   BIT,
        @RESULT                     NVARCHAR(MAX);
  
SELECT  @TableName                  =   @p_TableName,
        @Include_BlankAsNotFilled   =   @p_Include_BlankAsNotFilled,
        @RESULT                     =   '';
          
--To Support some of the table formats that user typing.
SELECT @TableName   =REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TableName,'[',''),']',''),'dbo.',''),'...',''),'..',''),'.','');               
   
--validation
IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE [TYPE]='U' AND [NAME]=@TableName )   
    BEGIN
        SELECT Result = 1 , Reason ='Table not exists in this Database' ;
        RETURN 1;
    END;
  
--dropping temp table if exists - for debugging purpose
IF OBJECT_ID('TempDb..#Columns') IS NOT NULL
    DROP TABLE #Columns;
      
--temp table creations
CREATE TABLE #Columns
(
[ORDINAL_POSITION] INT NOT NULL,
[COLUMN_NAME] [sysname] NOT NULL,
[DataType_Field] BIT NOT NULL,
[TABLE_NAME] [sysname] NOT NULL
PRIMARY KEY CLUSTERED ([ORDINAL_POSITION],[COLUMN_NAME])
);
  
INSERT INTO #Columns ([ORDINAL_POSITION],[COLUMN_NAME],[DataType_Field],[TABLE_NAME])
SELECT
    [ORDINAL_POSITION],
    [COLUMN_NAME],
    CASE WHEN COLLATION_NAME IS NOT NULL THEN 1 ELSE 0 END,
    [TABLE_NAME]
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME =@tablename; --Using System_View
   
--Final Result Set
SELECT @RESULT = @RESULT+ N'SELECT '''+C.COLUMN_NAME+''' AS [Column Name],
                            CAST((100*(SUM(
                                    CASE WHEN ' +
                                        CASE
                                            WHEN @include_blankasnotfilled = 0
                                              THEN '[' + C.COLUMN_NAME + '] IS NOT NULL'
                                            WHEN C.[DataType_Field]=0
                                              THEN '[' + C.COLUMN_NAME + '] IS NOT NULL'
                                            ELSE 'ISNULL([' + C.COLUMN_NAME + '],'''')<>'''' ' END +
                                    ' THEN 1 ELSE 0 END)*1.0 / COUNT(*)))
                            AS DECIMAL(5,2)) AS [Fill Rate (%)]
                        FROM '+C.TABLE_NAME+' UNION ALL '
FROM #Columns C;
  
SET @RESULT=LEFT(@RESULT,LEN(@RESULT)-10); --To Omit 'Last UNION ALL '.
  
--PRINT(@RESULT); --for debug purpose
EXEC(@RESULT);
   
    RETURN 0;
  
END TRY
BEGIN CATCH  --error handling even it is fetching stored procedure
    SELECT
         ERROR_NUMBER()     AS ErrorNumber
        ,ERROR_SEVERITY()   AS ErrorSeverity
        ,ERROR_STATE()      AS ErrorState
        ,ERROR_PROCEDURE()  AS ErrorProcedure
        ,ERROR_LINE()       AS ErrorLine
        ,ERROR_MESSAGE()    AS ErrorMessage;
    RETURN 1;
END CATCH;
  
END;