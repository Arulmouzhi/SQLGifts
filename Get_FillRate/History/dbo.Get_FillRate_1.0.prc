
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
        @ColumnName                 NVARCHAR(128),
        @R_NO                       INT,
        @DataType_Field             BIT,
        @i                          INT, --Iteration
        @RESULT                     NVARCHAR(MAX);
  
SELECT  @TableName                  =   @p_TableName,
        @Include_BlankAsNotFilled   =   @p_Include_BlankAsNotFilled,
        @i                          =   1;
          
--To Support some of the table formats that user typing.
SELECT @TableName   =REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TableName,'[',''),']',''),'dbo.',''),'...',''),'..',''),'.','');       
   
--validation
IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE [TYPE]='U' AND [NAME]=@TableName )   
    BEGIN
        SELECT Result = 1 , Reason ='Table not exists in this Database' ;
        RETURN 1;
    END;
   
--dropping temp table if exists - for debugging purpose
IF OBJECT_ID('TempDb..#Temp') IS NOT NULL
    DROP TABLE #Temp;
IF OBJECT_ID('TempDb..#Columns') IS NOT NULL
    DROP TABLE #Columns;
  
--temp table creations
CREATE TABLE #Temp
(
[R_NO] INT NOT NULL,
[ColumnName] NVARCHAR(128) NOT NULL,
[FillRate] DECIMAL(5,2) NOT NULL
PRIMARY KEY CLUSTERED (ColumnName)
);
  
CREATE TABLE #Columns
(
[R_NO] INT NOT NULL,
[Name] [sysname] NOT NULL,
[DataType_Field] BIT NOT NULL
PRIMARY KEY CLUSTERED ([Name])
);
   
INSERT INTO #Columns ([R_NO],[Name],[DataType_Field])
SELECT
    COLUMN_ID,
    [Name],
    IIF(collation_name IS NULL,0,1)
FROM SYS.COLUMNS WHERE OBJECT_ID = OBJECT_ID(@TableName);
   
WHILE @i <= ( SELECT MAX(R_NO) FROM #Columns) --Checking of Iteration till total number of columns
    BEGIN
        SELECT @DataType_Field=DataType_Field,@ColumnName=[Name],@R_NO=[R_NO] FROM #Columns WHERE R_NO = @i;
   
          SET @RESULT =
            'INSERT INTO #Temp ([R_NO],[ColumnName], [FillRate]) ' +
            'SELECT ' + QUOTENAME(@R_NO,CHAR(39)) + ',
                ''' + @ColumnName + ''',
                CAST((100*(SUM(
                    CASE WHEN ' +
                        CASE
                            WHEN @Include_BlankAsNotFilled = 0
                              THEN '[' + @ColumnName + '] IS NOT NULL'
                            WHEN @DataType_Field = 0
                              THEN '[' + @ColumnName + '] IS NOT NULL'
                            ELSE 'ISNULL([' + @ColumnName + '],'''')<>'''' ' END +
                    ' THEN 1 ELSE 0 END)*1.0 / COUNT(*)))
                AS DECIMAL(5,2))
            FROM ' + @TableName;
   
        --PRINT(@RESULT); --for debug purpose
        EXEC(@RESULT);
   
        SET @i += 1; -- Incrementing Iteration Count
    END;
   
 --Final Result Set
    SELECT
      ColumnName AS [Column Name],
      FillRate AS [Fill Rate (%)]
    FROM #TEMP
    ORDER BY [R_NO];
   
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