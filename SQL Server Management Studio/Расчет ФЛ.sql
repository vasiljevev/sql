DECLARE 
	@F_Division		TINYINT,
	@F_SubDivision	TINYINT,
	@F_Subscr		NVARCHAR(max),
	@F_book			INT,
	@N_Period_Begin	INT,
	@N_Period_End	INT,
	@del			bit		---удалять РВ перед расчетом

--	ПАРАМЕТРЫ РАСЧЕТА ЗАДАЮТСЯ ТУТ
SET @F_Division		= 24--24		---	Отделение
SET @F_SubDivision	= 70--70		--	Участок
SET @F_book			= null--21		-- книга
SET	@F_Subscr		= null--null-- '20789921'--20789861	--	Идентификатор лицевого счета
SET	@N_Period_Begin	= 202204	--	Начальный период расчета
SET	@N_Period_End	= 202211	--	Конечный период расчета
set @del			= 1			--  удалять РВ перед расчетом

IF @del = 1 
	SELECT
		@F_Division		= ss.F_Division,
		@F_SubDivision	= ss.F_SubDivision
	FROM dbo.SD_Subscr AS ss
	WHERE	ss.LINK		= @F_Subscr
		AND ss.B_EE		= 0
	BEGIN
		DELETE FROM pe.FD_Charges	 WHERE N_Period = @N_Period_Begin AND F_Division = @F_Division AND (F_SubDivision = @F_SubDivision OR @F_SubDivision IS NULL OR @F_SubDivision = 0) and (F_Subscr= @F_Subscr or @F_Subscr is null)
END

IF @F_Subscr IS NOT NULL
	SELECT
		@F_Division		= ss.F_Division,
		@F_SubDivision	= ss.F_SubDivision
	FROM dbo.SD_Subscr AS ss
	WHERE	ss.LINK		= @F_Subscr
		AND ss.B_EE		= 0

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
	@p1				TINYINT = 2,
	@p2				TINYINT = 4,
	@p3				TINYINT = 1,
	@p13			INT = 4921,
	@p7				datetime,
	@p18			varchar(255)='В сообщениях есть замечания. См лог ошибок',
	@p19			int,
	@Status_Msg		VARCHAR(255),
	@subscr			NVARCHAR(max),
	@N_Session		INT,
	@Date0			DATETIME,
	@Date1			DATETIME,
	@N_Year			SMALLINT,
	@N_Month		TINYINT

BEGIN TRAN
	
	--	Расчет
WHILE @N_Period_Begin <= @N_Period_End
BEGIN

		SELECT
			@Date0			= cp.D_Date0_Fin,
			@Date1			= cp.D_Date1_Fin,
			@N_Year			= YEAR(cp.D_Date1_Fin),
			@N_Month		= MONTH(cp.D_Date1_Fin),
			@N_Period_Begin	= YEAR(DATEADD(day, 1, cp.D_Date1_Fin)) * 100 + MONTH(DATEADD(day, 1, cp.D_Date1_Fin))
		FROM dbo.CS_Periods AS cp   --select * from dbo.CS_Periods AS cp where N_year=2022
		WHERE	cp.N_Period	= @N_Period_Begin

		UPDATE sd
		SET N_Year		= @N_Year,
			N_Month		= @N_Month,
			N_Year_Last = YEAR(DATEADD(month, -1, @Date0)),
			N_Month_Last= MONTH(DATEADD(month, -1, @Date0))
		FROM dbo.SD_Divisions AS sd
		WHERE	sd.LINK		= @F_Division
		
		SET @B_Estim_Date = GETDATE()

declare @N_Main_Session int
EXEC cmn.APP_Get_Sequence_Values
                @Name    = 'Cons',
                @Number    = 1,
                @Value    = @N_Main_Session OUTPUT
--select @N_Main_Session
set @p7=@Date1
set @p19=@N_Main_Session

exec PE.APP_Generate_Documents 
	@alg=@p1 output,
	@doc_mode=@p2 output,
	@reg_mode=0,
	@reg_type=NULL,
	@date1=@Date0,
	@date2=@Date1,
	@date0=@p7 output,
	@year=NULL,
	@month=NULL,
	@date_due=NULL,
	@div=@F_Division,
	@SubDiv=@F_SubDivision,
	@register_out=@p13 output,
	@book=NULL,
	@subscr=@F_Subscr,
	@conn_point=NULL,
	@register_in=NULL,
	@status_msg=@p18 output,
	@id=@p19 output,
	@arg='<ROOT>
  <Main>
    <bit23>false</bit23>
  </Main>
</ROOT>',@n_rate=1.000000,@N_Amount=0.000000,@b_main_str=NULL,@b_info_str=NULL,@F_Recalc_Info=NULL,@N_Tariff=NULL
select  
@p7 as [дата выставления документов],
@Date0 as [дата начала расчетного интервала],
@Date1 as [дата окончания расчетного интервала],
@p18 as [код ошибки], @p19 as [Ид-р сессии],
@N_Year,
@N_Month,
@F_Subscr,
@F_Division,
@F_SubDivision

		IF @Status_Msg IS NOT NULL
		BEGIN
			
			SELECT 
			@p7 as [дата выставления документов],
			@Date0 as [дата начала расчетного интервала],
			@Date1 as [дата окончания расчетного интервала],
			@p18 as [код ошибки], @p19 as [Ид-р сессии],
			@N_Year,
			@N_Month,
			@F_Subscr,
			@F_Division,
			@F_SubDivision
			
			SELECT
				cel.C_Error_Text
			FROM dbo.CS_Error_Log AS cel
			WHERE	cel.C_User_Name	= SUSER_NAME()
				AND cel.D_Date		>=@B_Estim_Date
			ORDER BY cel.D_Date DESC
			 
		END

exec PE.UI_APP_Batch_Commit @Session=@p19

END

UPDATE sd 
SET	N_Year		= @N_Orig_Year,
	N_Month		= @N_Orig_Month,
	N_Year_Last	= @N_Orig_Year_Last,
	N_Month_Last= @N_Orig_Month_Last
FROM dbo.SD_Divisions AS sd
WHERE	sd.LINK		= @F_Division

COMMIT	
GO

--declare @N_Main_Session int
--EXEC cmn.APP_Get_Sequence_Values
--                @Name    = NULL,
--                @Number    = 1,
--                @Value    = @N_Main_Session OUTPUT
--select @N_Main_Session

/*
SELECT DISTINCT 'EXEC PE.UI_APP_Batch_Commit @Session=' + CAST(Session AS VARCHAR(50)) + ';
DELETE FROM Tmp.PE_Subscr_Active_Sessions WHERE [Session]=' + CAST(Session AS VARCHAR(50)) + ';'
, Session FROM Tmp.PE_Subscr_Active_Sessions WHERE C_User_Name = 'MR\Vasilev.EvV';


*/
--EXEC PE.UI_APP_Batch_Commit @Session=837719057;  DELETE FROM Tmp.PE_Subscr_Active_Sessions WHERE [Session]=837719057;