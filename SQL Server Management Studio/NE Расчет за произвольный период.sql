SET XACT_ABORT ON
SET NOCOUNT ON
GO
--select * from sd_divisions
/*select 
erp.F_Subscr,ss.*
from ED_Registr_Pts erp
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr

where erp.N_Code = '510069898'
*/
/*
DECLARE 
@Action_id UNIQUEIDENTIFIER
set @Action_id=newid()
exec EE.OP_ED_Network_Balance_Operate 
@Action_id=@Action_id,
@PK=NULL,
@F_Division=31,
@Status_Msg=null,

@Year=2021,@Month=12,@B_PE = 1 
@B_EE = 1
--,@B_PE = 1 
*/

/*
declare
@Action_id UNIQUEIDENTIFIER
set 
@Action_id=newid()
exec EE.OP_Generate_Data_Analizer 
@Action_id=@Action_id,
@PK=NULL,
@F_Division=31,
@Status_Msg=null,
@svsubdiv=2,
@N_Month=11,
@N_Year=2021
*/
/*
declare
@G_Session_ID UNIQUEIDENTIFIER
set @G_Session_ID='3DFABF10-F022-4601-A17B-F87BCBA254D3'
		EXEC IE.IMP_To_DMZ 
			@G_Session_ID	= @G_Session_ID, 
			@B_EE			= 1,
			@C_Note			= null

*/

DECLARE 
	@F_Division		TINYINT,
	@F_SubDivision	TINYINT,
	@F_Subscr		INT,
	@F_book			INT,
	@N_Period_Begin	INT,
	@N_Period_End	INT,
	@del			bit		---удалять РВ перед расчетом


--	ПАРАМЕТРЫ РАСЧЕТА ЗАДАЮТСЯ ТУТ
SET @F_Division		= 24		---	Отделение
SET @F_SubDivision	= 70		--	Участок
SET @F_book			= 21		-- книга
SET	@F_Subscr		= null--20789861	20789881--	Идентификатор лицевого счета
SET	@N_Period_Begin	= 202101	--	Начальный период расчета
SET	@N_Period_End	= 202211	--	Конечный период расчета
set @del			= 1			--  удалять РВ перед расчетом


	
BEGIN TRAN


IF @del = 1 
	BEGIN
		DELETE FROM EE.FD_Paysheets	 WHERE N_Period >= @N_Period_Begin AND F_Division = @F_Division AND (F_SubDivision = @F_SubDivision OR @F_SubDivision IS NULL OR @F_SubDivision = 0) and (F_Subscr= @F_Subscr or @F_Subscr is null)
	END
	--SELECT sd.LINK, sd.C_Name, sd.N_Year, sd.N_Month, sd.N_Year_Last, sd.N_Month_Last, * FROM dbo.SD_Divisions AS sd ORDER BY sd.LINK


IF @F_Subscr IS NOT NULL
	SELECT
		@F_Division		= ss.F_Division,
		@F_SubDivision	= ss.F_SubDivision
	FROM dbo.SD_Subscr AS ss
	WHERE	ss.LINK		= @F_Subscr
		AND ss.B_EE		= 1


----	Проверки
--BEGIN

--	IF @F_Division IS NULL AND @F_Subscr IS NOT NULL
--	BEGIN
--		PRINT 'ОШИБКА! Некорректный идентификатор лицевого счета'
--		RETURN
--	END
	
--	IF NOT EXISTS (SELECT 1 FROM dbo.SD_Divisions AS sd WHERE sd.LINK = @F_Division)
--	BEGIN
--		PRINT 'ОШИБКА! Некорректное отделение'
--		RETURN
--	END
	
--	--IF NOT EXISTS (SELECT 1 FROM dbo.SD_SubDivisions AS ssd WHERE ssd.LINK = @F_SubDivision) AND (@F_SubDivision <> 0  OR @F_SubDivision IS NOT NULL)
--	--BEGIN
--	--	PRINT 'ОШИБКА! Некорректный участок'
--	--	RETURN
--	--END

--	IF NOT EXISTS (SELECT 1 FROM dbo.CS_Periods AS cp WHERE	cp.N_Period	= @N_Period_Begin)
--	BEGIN
--		PRINT 'ОШИБКА! Некорректный период начала расчета'
--		RETURN
--	END

--	IF NOT EXISTS (SELECT 1 FROM dbo.CS_Periods AS cp WHERE	cp.N_Period	= @N_Period_End)
--	BEGIN
--		PRINT 'ОШИБКА! Некорректный период окончания расчета'
--		RETURN
--	END
	
--	IF  @N_Period_Begin > @N_Period_End
--	BEGIN
--		PRINT 'ОШИБКА! Период начала расчета больше периода окончания'
--		RETURN
--	END
	
--END


DECLARE 
	@N_Orig_Year		INT,
	@N_Orig_Month		INT,
	@N_Orig_Year_Last	INT,
	@N_Orig_Month_Last	INT,
	@B_Estim_Date		DATETIME,
	@N_Count_PS			INT
	
SELECT 
	@N_Orig_Year		= sd.N_Year,
	@N_Orig_Month		= sd.N_Month,
	@N_Orig_Year_Last	= sd.N_Year_Last,
	@N_Orig_Month_Last	= sd.N_Month_Last
FROM dbo.SD_Divisions AS sd
WHERE	sd.LINK			= @F_Division
	

DECLARE
	@p3				TINYINT = 1,
	@p7				TINYINT = 4,
	@Status_Msg		VARCHAR(255),
	@subscr			NVARCHAR(max),
	@N_Session		INT,
	@Date0			DATETIME,
	@N_Year			SMALLINT,
	@N_Month		TINYINT
	
	
IF @F_Subscr IS NOT NULL
	SET @subscr = 
	'<ROOT>
		<Subscr>
			<LINK>' + CAST(@F_Subscr AS NVARCHAR(50)) + '</LINK>
		</Subscr>
	</ROOT>'
	






	
	--	Расчет
	WHILE @N_Period_Begin <= @N_Period_End
	BEGIN
	
		SELECT
			@Date0			= cp.D_Date1_Fin,
			@N_Year			= YEAR(cp.D_Date1_Fin),
			@N_Month		= MONTH(cp.D_Date1_Fin),
			@N_Period_Begin	= YEAR(DATEADD(day, 1, cp.D_Date1_Fin)) * 100 + MONTH(DATEADD(day, 1, cp.D_Date1_Fin))
		FROM dbo.CS_Periods AS cp
		WHERE	cp.N_Period	= @N_Period_Begin

		--	Генерация сесии расчета
		EXEC cmn.APP_Get_Sequence_Values
			@Name	= NULL,
			@Number	= NULL,
			@Value	= @N_Session OUTPUT

		--	Определение периода расчета
		UPDATE sd
		SET N_Year		= @N_Year,
			N_Month		= @N_Month,
			N_Year_Last = YEAR(DATEADD(month, -1, @Date0)),
			N_Month_Last= MONTH(DATEADD(month, -1, @Date0))
		FROM dbo.SD_Divisions AS sd
		WHERE	sd.LINK		= @F_Division
		
		SET @B_Estim_Date = GETDATE()
		
		EXEC EE.APP_Generate_Cons_Sheet_NE 
			@subscr			= @subscr,
			@arg			= NULL,
			@alg			= @p3			OUTPUT,
			@book			= @F_book,
			@div			= @F_Division,
			@SubDiv			= @F_SubDivision,
			@doc_mode		= @p7			OUTPUT,
			@reg_mode		= 0,
			@register_out	= NULL,
			@year			= @N_Year,
			@month			= @N_Month,
			@date0			= @Date0		OUTPUT,
			@date1			= NULL,
			@date2			= NULL,
			@date_due		= NULL,
			@status_msg		= @Status_Msg	OUTPUT,
			@id				= @N_Session	OUTPUT

		--	Вывод ошибок расчета
		IF @Status_Msg IS NOT NULL
		BEGIN
			
			SELECT @p3, @p7, @Date0, @Status_Msg, @N_Session
			
			SELECT
				cel.C_Error_Text
			FROM dbo.CS_Error_Log AS cel
			WHERE	cel.C_User_Name	= SUSER_NAME()
				AND cel.D_Date		>=@B_Estim_Date
			ORDER BY cel.D_Date DESC
			 
		END

		SELECT @N_Count_PS = COUNT(1) FROM EE.FD_Paysheets AS fp WHERE fp.S_SequenceID = @N_Session
		PRINT 'За РП ' + CAST(@N_Year AS VARCHAR(4)) + '.' + CAST(@N_Month AS VARCHAR(4)) + ' рассчитанно ' + CAST(@N_Count_PS AS VARCHAR(50)) + ' РВ'
		
	END

--	Восстановление РП
UPDATE sd 
SET	N_Year		= @N_Orig_Year,
	N_Month		= @N_Orig_Month,
	N_Year_Last	= @N_Orig_Year_Last,
	N_Month_Last= @N_Orig_Month_Last
FROM dbo.SD_Divisions AS sd
WHERE	sd.LINK		= @F_Division

	
--COMMIT	
GO






