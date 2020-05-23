--Execute this stored procedure - by passing the table name like below

--Case 1
--Execute like below if we need to consider NULL values alone as not filled
EXEC [Get_FillRate] @p_TableName='#TestEmp',@p_Include_BlankAsNotFilled=0;

--Case 2
--Execute like below if we need to consider both NULL values and empty/blank values as not filled
EXEC [Get_FillRate] @p_TableName='#TestEmp',@p_Include_BlankAsNotFilled=1;