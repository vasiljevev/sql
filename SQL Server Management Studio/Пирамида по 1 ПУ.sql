--2	     1	2	NULL	1	NULL	5AE88A85-50A2-445F-8A89-A2D545B560ED	Владимирэнерго (ф)
--21	20	2	NULL	1	NULL	88EC6364-151F-4174-ABB2-222BC52C015A	Ивэнерго (ф)
--31	30	2	NULL	1	NULL	A3A68627-5801-41AA-9DC6-40559E7C53E7	Калугаэнерго (ф)
--41	40	2	NULL	1	NULL	0E1C8E1C-3C7A-47C4-86C1-649D61F47472	Кировэнерго (ф)
--51	50	2	NULL	1	NULL	D6677B99-8415-40E3-A9C4-FCB641BB0564	Мариэнерго (ф)
--61	60	2	NULL	1	NULL	49B1D2E2-F28A-417A-ADC9-D6B7B6F63809	Нижновэнерго (ф)
--71	70	2	NULL	1	NULL	2C82B81C-7CA8-452A-9D24-D003A1DE0FBC	РязаньЭнерго (ф)
--81	80	2	NULL	1	NULL	9B84E969-CF94-4776-A5AB-BB3F596E7FFD	ТулЭнерго (ф)
--91	90	2	NULL	1	NULL	46D4B1B2-090A-4AFA-A5E1-AEE2258CB404	Удмуртэнерго (ф)
/*
EXEC IE.IMP_Readings_Complete
@C_Start_Date = '20220720',
@C_End_Date = '20220726',
@F_Division = 71,
@B_Run_SSIS = 1,
@B_Run_Service = 1,
@B_Remote = 1,
--@B_Load_Integral=0,
@C_Device_ID = '4a8786bf-7f0e-45a0-bda4-13565a461f3c'

*/


DECLARE	@D_Date			SMALLDATETIME = GETDATE(),
		@N_Day			INT,
		@N_Hour			INT,
		@N_Month		INT,
		@N_Year			INT,
		@N_Date			INT,
		@N_Start_Date	INT,
		@N_End_Date		INT,
		@N_Hour_Date	INT,
		@F_Division 	INT = 71,
		@B_Load_Integral int,
		@B_Load_Interval int

SELECT	@N_Day		= DAY(@D_Date),
		@N_Hour		= DATEPART(HOUR, @D_Date),
		@N_Month	= MONTH(@D_Date),
		@N_Year		= YEAR(@D_Date),
		@N_Start_Date = DAY(@D_Date),
		@N_End_Date = DAY(@D_Date)

		
		
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

	( @N_Day,		@N_Start_Date,			@N_End_Date,			@N_Hour, 1, 1 )

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
			
		END
		IF @N_Hour = @N_Hour_Date
		BEGIN
			

			EXEC IE.IMP_Readings_Complete @C_Start_Date = @C_Start_Date, @C_End_Date = @C_End_Date, @F_Division = @F_Division, @B_Run_SSIS = 1, @B_Run_Service = 1, @B_Remote = 1, @B_Load_Integral=@B_Load_Integral, @B_Load_Interval=@B_Load_Interval, @B_Report = 1, @B_Mail = 1,@C_Device_ID='2f7e458f-2354-4ea3-aa50-368972fc1a51'  ;
		END
	END
	FETCH NEXT FROM Schedule_Cursor 
	INTO @N_Date, @N_Start_Date, @N_End_Date, @N_Hour_Date,@B_Load_Integral,@B_Load_Interval
END

CLOSE Schedule_Cursor
DEALLOCATE Schedule_Cursor
IF OBJECT_ID('tempdb..#T_Schedule') IS NOT NULL DROP TABLE #T_Schedule

GO
