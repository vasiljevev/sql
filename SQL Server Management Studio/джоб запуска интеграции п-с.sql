DECLARE	@D_Date			SMALLDATETIME = '20220605',
		@N_Day			INT,
		@N_Hour			INT,
		@N_Month		INT,
		@N_Year			INT,
		@N_Date			INT,
		@N_Start_Date	INT,
		@N_End_Date		INT,
		@N_Hour_Date	INT,
		@F_Division 	INT = 51,
		@C_Device_ID varchar(512),
		@B_Load_Integral int,
		@B_Load_Interval int

SELECT	@N_Day		= DAY(@D_Date),
		@N_Hour		= 22,
		@N_Month	= MONTH(@D_Date),
		@N_Year		= YEAR(@D_Date),
		@C_Device_ID = 'a15d262c-4d88-4631-9d7b-45a6876b2a43'
		
IF OBJECT_ID('tempdb..#T_Schedule') IS NOT NULL DROP TABLE #T_Schedule
	
CREATE TABLE #T_Schedule
(
	N_Date			INT,
	N_Start_Date	INT,
	N_End_Date		INT,
	N_Hour_Date		INT,
	B_Load_Integral int,
	B_Load_Interval int
)
INSERT #T_Schedule (N_Date, N_Start_Date, N_End_Date, N_Hour_Date, B_Load_Integral, B_Load_Interval) 
VALUES
	( 05,		26,			01,			22, 1, 1),
	( 10,		01,			10,			22, 0, 1 ),
	( 20,		10,			20,			22, 0, 1 ),
	( 23,		20,			23,			22, 1, 1 ),
	( 26,		20,			26,			22, 0, 1 )
	
DECLARE Schedule_Cursor CURSOR FOR 
	SELECT N_Date, N_Start_Date, N_End_Date, N_Hour_Date,B_Load_Integral,B_Load_Interval
	FROM #T_Schedule AS ts
	
OPEN Schedule_Cursor  
  
FETCH NEXT FROM Schedule_Cursor 
INTO @N_Date, @N_Start_Date, @N_End_Date, @N_Hour_Date,@B_Load_Integral,@B_Load_Interval

WHILE @@FETCH_STATUS = 0  
BEGIN
	IF @N_Day = @N_Date
	BEGIN
		DECLARE @C_Start_Date SMALLDATETIME, @C_End_Date SMALLDATETIME
		SET @C_Start_Date	= CAST(@N_Year AS VARCHAR(MAX))  + FORMAT(@N_Month,'0#') + FORMAT(@N_Start_Date,'0#')
		SET @C_End_Date		= CAST(@N_Year AS VARCHAR(MAX)) + FORMAT(@N_Month,'0#') + FORMAT(@N_End_Date,'0#')
		IF @N_End_Date < @N_Start_Date
			SET @C_End_Date = DATEADD(MONTH, 1, @C_End_Date)
		IF @N_Date < @N_Start_Date
		BEGIN
			SET @C_Start_Date = DATEADD(MONTH, -1, @C_Start_Date)
			SET @C_End_Date = DATEADD(MONTH, -1, @C_End_Date)
			set @B_Load_Integral=@B_Load_Integral
			set @B_Load_Interval=@B_Load_Interval
			--set @C_Device_ID=cast (@C_Device_ID as varchar(512))
		END
		IF @N_Hour = @N_Hour_Date
		BEGIN
			--select @C_Start_Date,@C_End_Date,@F_Division,@C_Device_ID,@B_Load_Integral,@B_Load_Interval

			EXEC IE.IMP_Readings_Complete @C_Start_Date = @C_Start_Date, @C_End_Date = @C_End_Date, @F_Division = @F_Division, @B_Run_SSIS = 1, @B_Run_Service = 1, @B_Remote = 1, @B_Load_Integral=@B_Load_Integral, @B_Load_Interval=@B_Load_Interval,@C_Device_ID = @C_Device_ID;
		END
	END
	FETCH NEXT FROM Schedule_Cursor 
	INTO @N_Date, @N_Start_Date, @N_End_Date, @N_Hour_Date,@B_Load_Integral,@B_Load_Interval
END

CLOSE Schedule_Cursor
DEALLOCATE Schedule_Cursor
IF OBJECT_ID('tempdb..#T_Schedule') IS NOT NULL DROP TABLE #T_Schedule
--select @C_Start_Date,@C_End_Date,@F_Division,@C_Device_ID
GO