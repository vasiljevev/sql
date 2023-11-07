set xact_abort on 
begin tran 
go
--	===============================================================================================
--	Author:			m-alekseeva
--	Alter date:
--		22.12.2021 10:05 a-shavgaev (\/) i_i (\/) Доработки под вызов в NE.
--		21.12.2021 18:57 a-shavgaev (\/) i_i (\/) Доработки под вызов в NE.
--		21.12.2021 18:57 a-shavgaev Доработки под вызов в NE.
--		25.03.2020 Корректировка теперь проходит путем инвертирования сумм
--		11.03.2020 разбивка объема по временным зонам
--		19.02.2020
--		13.02.2020 + исправления по код ревью
--	Description:	Отрицательный ОДН
-- ===============================================================================================
alter PROCEDURE EE.APP_Cons_Minus_ODN
	@Session 		INT,	--	Сессия.
	@Session_Period INT		--	Группа расчета.
AS 
	SET NOCOUNT, XACT_ABORT, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL ON
	SET NUMERIC_ROUNDABORT, CURSOR_CLOSE_ON_COMMIT OFF
BEGIN 	
	

	--	Параметры расчета и производные
	BEGIN

		DECLARE
			@F_Division			INT,			--	Отделение.
			@F_SubDivision		INT,			--	Участок.
			@D_Date1			SMALLDATETIME,	--	Дата начала расчетного интервала(включительно).
			@D_Date2			SMALLDATETIME,	--	Дата окончания расчетного интервала(включительно).
			@B_First_To_First	BIT,			--	Признак использования логики с первого по первое
			--
			@N_Period0			INT				--	Расчетный период

		SELECT
			@F_Division			= gv.F_Division,
			@F_SubDivision		= gv.F_SubDivision,
			@D_Date1			= gv.D_Date1,
			@D_Date2			= gv.D_Date2,
			@B_First_To_First	= gv.B_First_To_First,
			--
			@N_Period0			= YEAR(gv.D_Date0)*100+MONTH(gv.D_Date0)
		FROM #EE_ED_GenVars AS gv
		WHERE	gv.S_ID			= @Session
			AND gv.S_SP			= @Session_Period

	END


	

	--Условия досрочного выхода: 
	BEGIN 	 

		--	Прерывание если не включена настройка "Выставлять отрицательный ОДН"
		IF  0 = ISNULL(dbo.CFs_Get_Calc_Defaults (@F_Division, @F_SubDivision, 'B_Activate_Neg_ODN', NULL),0)
			RETURN 1

		-- перерасчет
		IF @N_Period0 <> @Session_Period
			RETURN 1

	END
		
		

	DECLARE
		--	Методы расчета.
		@ECM_Meter_ODN			TINYINT,	--	Общедомовой счетчик.
		@ECM_Area_Standard		TINYINT,	--	Норматив на площадь (ОДН).
		@ECM_Avg_Month_ODN		TINYINT,	--	Среднемесячное(ОДН).
		@ECM_NULL				TINYINT,
		--	Типы помещений.
		@CT_Porch				INT			--	Подъезд.

	SELECT @ECM_Meter_ODN		= ecm.LINK FROM dbo.ES_Calc_Methods AS ecm WHERE ecm.C_Const = 'ECM_Area_Standard'
	SELECT @ECM_Area_Standard	= ecm.LINK FROM dbo.ES_Calc_Methods AS ecm WHERE ecm.C_Const = 'ECM_Meter_ODN'
	SELECT @ECM_Avg_Month_ODN	= ecm.LINK FROM dbo.ES_Calc_Methods AS ecm WHERE ecm.C_Const = 'ECM_Avg_Month_ODN'	
	EXEC dbo.CP_NULL_Value 'dbo', 'ES_Calc_Methods', @ECM_NULL OUTPUT
	SELECT @CT_Porch			= cct.LINK FROM dbo.CS_Conn_Types AS cct	 WHERE cct.C_Const = 'CT_Porch'

	
	SELECT
		--	Если методов расчета нет
		@ECM_Meter_ODN					= ISNULL(@ECM_Meter_ODN, @ECM_NULL),
		@ECM_Area_Standard				= ISNULL(@ECM_Area_Standard, @ECM_NULL),
		@ECM_Avg_Month_ODN				= ISNULL(@ECM_Avg_Month_ODN, @ECM_NULL),
		--	Если нет типа помещения "подъезд"
		@CT_Porch						= ISNULL(@CT_Porch, -1)



	--Найти головы/УП, которые относятся к двум выбранным методам расчета и не являются детьми
	--и где нет помещения на точке поставки
	IF OBJECT_ID('tempdb.dbo.#EE_Registr_Pts') IS NOT NULL DROP TABLE #EE_Registr_Pts
	CREATE TABLE #EE_Registr_Pts
	(
		F_Registr_Pts			INT,
		PRIMARY KEY CLUSTERED  (F_Registr_Pts)
	)
		
		
	INSERT #EE_Registr_Pts(
		F_Registr_Pts)
	SELECT DISTINCT F_Registr_Pts 
	FROM #EE_ED_Cons EC
	INNER JOIN dbo.ED_Network_Pts AS enp
		ON	enp.LINK				= EC.F_Network_Pts
	--	Помещения
	LEFT JOIN dbo.SD_Conn_Points_Sub AS scps
		ON	scps.LINK				= enp.F_Conn_Points_Sub
	WHERE	EC.Session				= @Session
		AND EC.Session_Period		= @Session_Period
		--	Выбранные методы расчета
		AND EC.F_Calc_Methods		IN (@ECM_Meter_ODN, @ECM_Area_Standard, @ECM_Avg_Month_ODN)
		AND NOT EXISTS
			(
			--Не дети
			SELECT TOP 1
				1
			FROM #EE_ED_Cons AS ECx 
			WHERE	ECx.F_Registr_Pts_Child = EC.F_Registr_Pts
				AND ECx.Session				= EC.Session
				AND ECx.Session_Period		= EC.Session_Period 
			)
		AND
			( 
				scps.LINK			IS NULL			--	Помещения на ТоП либо нет
			OR	scps.F_Conn_Types	= @CT_Porch		--	Либо это помещение - подъезд
			)
	OPTION(RECOMPILE)
	
			

	--	Сначала проверим, подходит ли УП для формирования корректировки (учет временных зон будет ниже)
	IF OBJECT_ID('tempdb.dbo.#EE_ED_Cons_By_RP') IS NULL 
	BEGIN
		CREATE TABLE #EE_ED_Cons_By_RP (
			LINK						INT IDENTITY (1,1),
			F_Subscr					INT,
			F_Registr_Pts				INT,
			N_Cons						DECIMAL(19, 6),		--Этот столбец оставлен, чтобы легче было проверять сумму по УП во время отладки
			PRIMARY KEY NONCLUSTERED  (LINK)
		)
		CREATE  CLUSTERED INDEX IDX_EE_ED_Cons_RP_F_Subscr_F_Registr_Pts ON #EE_ED_Cons_By_RP (
			F_Subscr,
			F_Registr_Pts 
		);
		INSERT INTO #EE_ED_Cons_By_RP 
		SELECT 
			EC.F_Subscr,
			EC.F_Registr_Pts,						-- Точка учета		
			SUM(EC.N_Cons_Total)		AS N_Cons	
		FROM #EE_Registr_Pts RP_Heads	-- из EE_ED_Cons нужно достать УП, которые соответствуют выбранным методам расчета
			INNER JOIN #EE_ED_Cons EC
				ON RP_Heads.F_Registr_Pts = EC.F_Registr_Pts
		GROUP BY
			EC.F_Subscr,
			EC.F_Registr_Pts,
			EC.Session,
			EC.Session_Period
		HAVING SUM(EC.N_Cons_Total) < 0
			AND EC.Session			= @Session
			AND EC.Session_Period	= @Session_Period
		OPTION(RECOMPILE)				 	

	END

		
	
	--	Выход из процедуры если нет подходящих по условиям УП
	IF NOT EXISTS (SELECT TOP 1 1 FROM #EE_ED_Cons_By_RP)
		RETURN 1
	


	INSERT #EE_ED_Cons
	(
		[Session],				-- Сессия
		Session_Period,			-- группа расчета
		F_Division,				-- Отделение
		F_Subscr,				-- Абонент
		F_Areas,				-- Участок
		F_Registr_Pts,			-- Точка учета
		F_Sale_Items,			-- Номенклатура
		D_Date0,				-- Дата начала расчета
		D_Date1,				-- Дата конца расчета
		D_Date_Last,			-- Дата начала расчета
		D_Date_Curr,			-- Дата конца расчета
		F_Time_Zones,			-- Временная зона
		F_Calc_Methods,			-- Метод расчета
		
		N_Cons_Prim,			-- Потребление
		N_Cons_Total,
		F_Supplier,				-- Поставщик
		F_Network_Items,		-- Элемент сети
		F_Balance_Types,		-- Вид баланса
		F_Balance_Types_Details,-- Вид подтипа баланса
		F_Network_Pts,
		F_Pts_Main_Foreign,		-- значение из буфера ТУ

		bit4
	)
	SELECT DISTINCT
		EC.Session,
		EC.Session_Period,
		EC.F_Division,							--	Отделение
		EC.F_Subscr,							--	Абонент
		EC.F_Areas,								--	Участок
		EC.F_Registr_Pts,						--	Точка учета
		EC.F_Sale_Items,						--	Номенклатура
		@D_Date1				AS D_Date0,		--	Дата начала расчета
		@D_Date2				AS D_Date1,		--	Дата конца расчета
		@D_Date1				AS D_Date_Last,	--	Дата начала расчета
		@D_Date2				AS D_Date_Curr,	--	Дата конца расчета
		EC.F_Time_Zones,						--	Временная зона (всегда сутки)
		EC.F_Calc_Methods,						--	Метод расчета

		-EC.N_Cons_Total		AS N_Cons_Prim,
		-EC.N_Cons_Total		AS N_Cons_Total,
		EC.F_Supplier,							--	Поставщик
		EC.F_Network_Items,						--	Элемент сети
		EC.F_Balance_Types,						--	Вид баланса
		EC.F_Balance_Types_Details,				--	Вид подтипа баланса
		EC.F_Network_Pts,
		EC.F_Pts_Main_Foreign,					--	значение из буфера ТУ

		1						AS bit4			--	Данная строчка является корр. отриц. ОДН bit4
	FROM #EE_ED_Cons_By_RP AS RP
	INNER JOIN #EE_ED_Cons AS EC
		ON  RP.F_Subscr			= EC.F_Subscr
		AND RP.F_Registr_Pts	= EC.F_Registr_Pts
	WHERE	1=1
		AND EC.Session			= @Session
		AND EC.Session_Period	= @Session_Period
	OPTION (RECOMPILE)
	


	IF OBJECT_ID('tempdb.dbo.#EE_ED_Cons_By_RP')		 IS NOT NULL DROP TABLE #EE_ED_Cons_By_RP
	IF OBJECT_ID('tempdb.dbo.#EE_Registr_Pts')			 IS NOT NULL DROP TABLE #EE_Registr_Pts
	
	RETURN 1

END
go

declare @p3 tinyint
set @p3=1
declare @p7 tinyint
set @p7=3
declare @p9 int
set @p9=NULL
declare @p12 datetime
set @p12='20220131'
declare @p16 varchar(255)
set @p16=NULL
declare @p17 int
set @p17=-rand()*1000000000
exec EE.APP_Generate_Cons_Sheet_NE @subscr='<ROOT>
  <Subscr>
    <LINK>51198181</LINK>
  </Subscr>
</ROOT>',@arg=NULL,@alg=@p3 output,@book=NULL,@div=51,@SubDiv=106,@doc_mode=@p7 output,@reg_mode=0,@register_out=@p9 output,@year=2022,@month=1,@date0=@p12 output,@date1=NULL,@date2=NULL,@date_due=NULL,@status_msg=@p16 output,@id=@p17 output
select @p3, @p7, @p9, @p12, @p16, @p17
rollback tran 