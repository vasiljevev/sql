
--	=========================================================================================================================
--	Author		a-shavgaev
--	Create date	03.07.2014 16:50
--	Alter date
--		16.01.2022 a-shavgaev Сохранеине информации о периоде с которого происходит замещение по АППГ.
--		15.07.2022 a-shavgaev Корректировка проблемных мест.
--		18.01.2022 a-shavgaev (\/) i_i (\/) исправление опечатки.
--		18.11.2021 S-Setkov: ДЭК Якутия
--      03.11.2021 10:19 m-tersenidis
--		07.11.2019 11:30 a-shavgaev Добавлена проверка значений на NULL
--      28.10.2019 a-gusarchuk проверка на изменение после последнего запуска
--		26.07.2019 11:37 a-shavgaev Заккоментирован выход из процедуры при отсутствии профилей в АППГ. Это прерывало замещение профиля по граничным значениям.
--		30.05.2018 10:18 a-shavgaev Доработки для расчетов с учетом часов и логики 1-1.
--		11.10.2017 15:53 a-shavgaev Разгон
--		17.01.2017 10:57 a-shavgaev Переделка со скаларной функции на табличную
--		27.12.2016 14:56 a-shavgaev Скрытие отладочных выводов
--	Description:
--		 Операция "Замещение отсутствующих данных в профиле".
--	cmn.UIR_unIncomplite_Profiles
--	=========================================================================================================================
ALTER PROCEDURE [EE].[OP_unIncomplite_Profiles]
	@Action_id			UNIQUEIDENTIFIER = NULL,	-- Ид-р операции
	@F_Division			INT=NULL,
	@PK					INT=NULL,					-- ПУ
	@Status_Msg			VARCHAR(250) OUTPUT,
	
	@Session			INT = NULL,					--	Для запуска при расчете
	@C_SubDivisions		VARCHAR(MAX) = NULL,		--	Отделения/Участки
	@C_Subscrs			VARCHAR(MAX) = NULL,
	@N_Year				INT,
	@N_Month			INT
AS 			
	SET NOCOUNT, XACT_ABORT, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL ON
	SET NUMERIC_ROUNDABORT, CURSOR_CLOSE_ON_COMMIT OFF
BEGIN 
	------------------------------------------------------------------------------------------------------------------------------
	DECLARE 
		@B_tmp		BIT
	SET	@B_tmp = 0
	------------------------------------------------------------------------------------------------------------------------------

	
	DECLARE 
		@PID INT = @@PROCID
	EXEC cmn.APP_Add_Msg_Log @F_Division, @PID


	--	Переменные и декларации.
	BEGIN
		
		DECLARE 
			@D_Date0		SMALLDATETIME,
			@D_Date1		SMALLDATETIME,
			@N_Period		INT,
			@N_Hours		INT,			--	Количество часов в периоде
		
			@ERS_Replace	TINYINT,		--	Статус показания "замещен".
			@N_Rowcount		INT
		
		
		SELECT 
			@D_Date0		= cp.D_Date0,
			@D_Date1		= cp.D_Date1,
			@N_Period		= cp.N_Year * 100 + cp.N_Month,
			@N_Hours		= DATEDIFF(hour, cp.D_Date0, cp.D_Date1 + 1 )
		FROM dbo.CS_Periods AS cp
		WHERE	cp.N_Year	= @N_Year
			AND cp.N_Month	= @N_Month

			
		SELECT @ERS_Replace	= ers.LINK FROM dbo.ES_Readings_Status AS ers WHERE ers.C_Const	= 'ERS_Replace'
		
		DECLARE
			@SIT_Active_Energy	SMALLINT
		SELECT @SIT_Active_Energy	= fsi.LINK FROM dbo.FS_Sale_Items AS fsi WHERE fsi.C_Const = 'SIT_Active_Energy'
			
	END

	
	
	IF @ERS_Replace IS NULL
		RETURN 1



	--	Переданные в параметрах отделения и участки.
	BEGIN

		IF OBJECT_ID ('tempdb.dbo.#T_Divisions') IS NOT NULL DROP TABLE #T_Divisions
		CREATE TABLE #T_Divisions
		(
			LINK			BIGINT,
			F_Division		TINYINT,
			C_Division		VARCHAR(250),
			B_SubDivision	BIT,			--	Ведется учет по участкам
			F_SubDivision	TINYINT,
			C_SubDivision	VARCHAR(250),
			--	Настройки
			N_MAX_Replace	INT,			--	MAX кол-во отсутствующих часов для замещения
			N_Round			INT				--	Точность почасовых показаний
		)
		CREATE CLUSTERED INDEX IDX_RPT_Divisions ON #T_Divisions (
			F_Division	)
		
		
		INSERT #T_Divisions (LINK, F_Division, C_Division, B_SubDivision, F_SubDivision, C_SubDivision, N_MAX_Replace, N_Round)
		SELECT f.LINK, 
			f.F_Division, SUBSTRING(f.C_Name, 0, ISNULL(NULLIF(CHARINDEX('/', f.C_Name), 0), 256)),
			f.B_SubDivision, f.F_SubDivision, SUBSTRING (f.C_Name, NULLIF (CHARINDEX ('/', f.C_Name), 0) + 1, 256),
			cd_r.N_Value,
			cd_p.N_Value
		FROM dbo.SF_Text_To_Table(@C_SubDivisions) t
		INNER JOIN dbo.ORL_Subdivisions_Full_List f
			ON  f.LINK			= t.LINK
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, 'N_MAX_Replace', NULL, NULL) AS cd_r
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, '442_Precision_Profile', NULL, NULL) AS cd_p


		-- при выборе управления запишем все подразделения
		INSERT #T_Divisions (LINK, F_Division, C_Division, B_SubDivision, F_SubDivision, C_SubDivision, N_MAX_Replace, N_Round)
		SELECT f.LINK,
			f.F_Division, SUBSTRING (f.C_Name, 0, ISNULL (NULLIF (CHARINDEX('/', f.C_Name), 0), 256)),
			f.B_SubDivision, f.F_SubDivision, SUBSTRING (f.C_Name, NULLIF (CHARINDEX ('/', f.C_Name), 0) + 1, 256),
			cd_r.N_Value,
			cd_p.N_Value
		FROM dbo.ORL_Subdivisions_Full_List f
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, 'N_MAX_Replace', NULL, NULL) AS cd_r
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, '442_Precision_Profile', NULL, NULL) AS cd_p
		WHERE	EXISTS (SELECT TOP 1 1 FROM #T_Divisions d WHERE d.F_Division IS NULL AND d.F_SubDivision IS NULL)  --  если есть центральный аппарат
			AND NOT EXISTS (SELECT TOP 1 1 FROM #T_Divisions d WHERE d.LINK = f.LINK) -- если подразделенеи уже записали то не дублируем
		
		
		-- если было выбрано отделение, то выберем все участки в него входящие
		INSERT #T_Divisions (LINK, F_Division, C_Division, B_SubDivision, F_SubDivision, C_SubDivision, N_MAX_Replace, N_Round)
		SELECT f.LINK, 
			f.F_Division, SUBSTRING(f.C_Name, 0, ISNULL(NULLIF(CHARINDEX('/', f.C_Name), 0), 256)),
		 	f.B_SubDivision, f.F_SubDivision, SUBSTRING (f.C_Name, NULLIF (CHARINDEX ('/', f.C_Name), 0) + 1, 256),
			cd_r.N_Value,
			cd_p.N_Value
		FROM #T_Divisions d
		INNER JOIN dbo.ORL_Subdivisions_Full_List f
			ON  f.F_Division		= d.F_Division
			AND f.F_SubDivision		IS NOT NULL		-- соберем все участки выбранного отделения
			AND NOT EXISTS (SELECT TOP 1 1 FROM #T_Divisions ld WHERE ld.LINK = f.LINK) -- если подразделение уже записали то не дублируем	
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, 'N_MAX_Replace', NULL, NULL) AS cd_r
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, '442_Precision_Profile', NULL, NULL) AS cd_p
		WHERE	d.F_Division IS NOT NULL AND d.F_SubDivision IS NULL
		OPTION (RECOMPILE)


		--	При запуске с прибора загрузим его отделение
		INSERT #T_Divisions (LINK, F_Division, C_Division, B_SubDivision, F_SubDivision, C_SubDivision, N_MAX_Replace, N_Round)
		SELECT f.LINK, 
			f.F_Division, SUBSTRING(f.C_Name, 0, ISNULL(NULLIF(CHARINDEX('/', f.C_Name), 0), 256)),
			f.B_SubDivision, f.F_SubDivision, SUBSTRING (f.C_Name, NULLIF (CHARINDEX ('/', f.C_Name), 0) + 1, 256),
			cd_r.N_Value,
			cd_p.N_Value
		FROM dbo.ED_Devices AS ed
		INNER JOIN dbo.ORL_Subdivisions_Full_List AS f
			ON	f.F_Division	= ed.F_Division
			AND	(	f.F_SubDivision = ed.F_SubDivision
				OR	f.B_SubDivision	= 0)
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, 'N_MAX_Replace', NULL, NULL) AS cd_r
		CROSS APPLY dbo.CF_Get_Calc_Defaults (f.F_Division, f.F_SubDivision, '442_Precision_Profile', NULL, NULL) AS cd_p
		WHERE	ed.F_Division	= @F_Division
			AND ed.LINK			= @PK
		
		
		--	Не ведется учёт по участкам, пометим их как общие
		UPDATE d 
		SET F_SubDivision	= 0
		FROM #T_Divisions AS d
		WHERE	d.B_SubDivision	= 0
			AND d.F_SubDivision	IS NULL
			AND d.F_Division	<>0
		OPTION (RECOMPILE)

			
		DELETE FROM #T_Divisions WHERE F_SubDivision IS NULL AND B_SubDivision = 1
		OPTION (RECOMPILE)

		
		IF @B_tmp = 1
			SELECT '#T_Divisions' AS [#T_Divisions], * FROM #T_Divisions
			
		
		--	SELECT * FROM #T_Divisions
	
	END
	


	--	соберем переданные в параметрах ЛС
	BEGIN

		IF OBJECT_ID ('tempdb.dbo.#T_Subscrs') IS NOT NULL DROP TABLE #T_Subscrs
		CREATE TABLE #T_Subscrs
		(
			F_Division		TINYINT,	--	Отделение ЛС
			F_Subscr		INT			--	ЛС
		)
		CREATE CLUSTERED INDEX IDX_T_Subscrs ON #T_Subscrs (
			F_Division, F_Subscr )
		
		
		--	Запуск с ПУ
		INSERT #T_Subscrs (
			F_Division, F_Subscr)
		SELECT DISTINCT
			erp.F_Division, erp.F_Subscr
		FROM dbo.ED_Devices_Pts AS edp
		INNER JOIN dbo.ED_Registr_Pts AS erp
			ON	erp.LINK			= edp.F_Registr_Pts
		WHERE	edp.F_Devices		= @PK

		--	Запуск по ЛС
		INSERT #T_Subscrs (
			F_Division, F_Subscr)
		SELECT
			ss.F_Division, ss.LINK 
		FROM dbo.SF_Text_To_Table (@C_Subscrs) t
		INNER JOIN dbo.SD_Subscr AS ss
			ON  ss.LINK				= t.LINK
			
		--	Запуск по отделениям	
		INSERT #T_Subscrs (F_Division, F_Subscr)
		SELECT ss.F_Division, ss.LINK
		FROM dbo.SD_Subscr AS ss
		INNER JOIN #T_Divisions AS sd
			ON	sd.F_Division		= ss.F_Division
			AND sd.F_SubDivision	= ss.F_SubDivision
		WHERE	@Session			IS NULL
			AND @PK					IS NULL
			AND (	@C_Subscrs			= '0' 
				OR	@C_Subscrs			IS NULL	)
		OPTION (RECOMPILE)
	
		--	Запуск с расчета
		IF @Session IS NOT NULL AND OBJECT_ID('tempdb.dbo.#EEE_SD_Subscr') IS NOT NULL 
		
			INSERT #T_Subscrs (
				F_Division, F_Subscr)
			SELECT
				ss.F_Division, ss.F_Subscr
			FROM #EEE_SD_Subscr AS ss
			WHERE	ss.Session	= @Session
			OPTION (RECOMPILE)

			
		IF @B_tmp = 1
			SELECT '#T_Subscrs' AS [#T_Subscrs], * FROM #T_Subscrs AS rs
		
	END
	
	

	--	пользователь может запустить операцию только по своему участку (SubDiv), но если пользователь общего участка, то по любому участку или по всем участкам сразу.
	--	Так же и по филиалам (Division),  пользователь может запустить операцию только по своему филиалу.
	--	Но если пользователь управления (0 Division), то по любому филиалу или по всем участкам сразу
	IF @Session IS NULL
	BEGIN 
		
		SELECT @Status_Msg = 'Операця отменена!'+ CHAR(13) + CHAR(10) + ' Пользователь не иммет прав на выполнение данной операции по следующим отделениям:' + CHAR(13) + CHAR(10)
	
		SELECT  @Status_Msg = @Status_Msg +  d.C_Division + ' ' + d.C_SubDivision + ';' + CHAR(13) + CHAR(10)
		FROM #T_Divisions AS d
		WHERE	NOT EXISTS 
			(
				SELECT 1
				FROM #T_Divisions AS ld
				WHERE	dbo.SF_Division()		= 0
					AND dbo.SF_SubDivision()	= 0
					AND ld.F_Division			= d.F_Division
					AND ld.F_SubDivision		= d.F_SubDivision
				UNION ALL 
				SELECT 1
				FROM #T_Divisions AS ld
				WHERE	dbo.SF_Division()		= ld.F_Division
					AND dbo.SF_SubDivision()	= 0
					AND ld.F_Division			= d.F_Division
					AND ld.F_SubDivision		= d.F_SubDivision
				UNION ALL 
				SELECT 1
				FROM #T_Divisions AS ld
				WHERE	dbo.SF_Division()		= ld.F_Division
					AND dbo.SF_SubDivision()	= ld.F_SubDivision		
					AND ld.F_Division			= d.F_Division
					AND ld.F_SubDivision		= d.F_SubDivision
			)
		OPTION (RECOMPILE)

		SELECT @N_Rowcount = @@ROWCOUNT
		
		IF @N_Rowcount = 0
			SET @Status_Msg = NULL 
		ELSE 
		BEGIN
			EXEC cmn.APP_Add_Msg_Log @F_Division, @PID, 0
			RETURN 0
		END
	
	END
	
	
		
	--	Проверка чтобы заданный период был больше ПЗП по всем выбранным отделениям
	IF @Session IS NULL
	BEGIN 
	
		SELECT @Status_Msg = 'Операця отменена!'+ CHAR(13) + CHAR(10) + 'Заданный период меньше или равен ПЗП по следующим отделениям:' + CHAR(13) + CHAR(10)
		
		SELECT @Status_Msg = @Status_Msg +  d.C_Name + CHAR(13) + CHAR(10)
		FROM
		(
			SELECT DISTINCT
				sd.C_Name
			FROM #T_Divisions AS d
			INNER JOIN dbo.SD_Divisions AS sd
				ON	sd.LINK			= d.F_Division
				AND sd.N_Year_Last * 100 + sd.N_Month_Last 
									>=@N_Period
		) AS d
		OPTION (RECOMPILE)
		SELECT @N_Rowcount = @@ROWCOUNT
		
		IF @N_Rowcount = 0
			SET @Status_Msg = NULL 
		ELSE
		BEGIN 
			EXEC cmn.APP_Add_Msg_Log @F_Division, @PID, 0
			RETURN 0
		END
	
	END
	
	
	
	--	Загрузка неполных профилей
	BEGIN

		IF OBJECT_ID ('tempdb.dbo.#T_Heads_Profile') IS NOT NULL DROP TABLE #T_Heads_Profile
		CREATE TABLE #T_Heads_Profile
		(
			F_Head			INT IDENTITY (1,1),
			F_Division		TINYINT,			--	Отделение
			F_SubDivision	TINYINT,			--	Участок. Нужен только обрабатываемым профилям для анализа настройки в разерезе участков.
			F_Calendar		INT,				--	Календарь ЛС/Отделения/По умолчанию
			F_Devices		INT,				--	Прибор учета
			F_Energy_Types	TINYINT,			--	Измеряемый показатель
			F_Energy_Types_Main	TINYINT,			--	Измеряемый показатель
			F_Profile		BIGINT,				--	LINK ED_Meter_Profiles
			N_Period		INT,				--	Период профиля
			N_Period_Last	INT,				--	Период АППГ / ПП
			V_Cons			VARBINARY(max),		--	Запакованные почасовые расходы
			V_Status		VARBINARY(max),		--	Запакованные статусы расходов
			X_Cons			XML,				--	Замещенный профиль, промежуточный XML
			X_Status		XML,
			X_Date_Last		XML					--	Для замещения по АППГ/ПП - дата с которой взят профильных расход
		)
		CREATE CLUSTERED INDEX IDX_T_Heads_Profile ON #T_Heads_Profile(
			F_Division,	F_Devices)
		CREATE NONCLUSTERED INDEX IDX_T_Heads_Profile_F_Profile ON #T_Heads_Profile(
			F_Profile	)
		CREATE NONCLUSTERED INDEX IDX_T_Heads_Profile_F_Head ON #T_Heads_Profile(
			F_Head	)
		

		--	Выборка неполных профилей.
		INSERT #T_Heads_Profile
		(
			F_Division,
			F_SubDivision,
			F_Devices,
			F_Energy_Types,
			F_Energy_Types_Main,
			F_Profile,
			N_Period,
			V_Cons,
			V_Status 
		)
		SELECT DISTINCT
			emp.F_Division, 
			emp.F_SubDivision,
			emp.F_Devices, 
			emp.F_Energy_Types,
			emp.F_Energy_Types,
			emp.LINK			AS F_Profile,
			emp.N_Period,
			emp.N_Cons			AS V_Cons,
			emp.N_Param15		AS V_Status
		FROM #T_Subscrs AS rs
		INNER JOIN dbo.ED_Registr_Pts AS erp
			ON	erp.F_Division			= rs.F_Division
			AND erp.F_Subscr			= rs.F_Subscr
			AND	erp.F_Sale_Items		= @SIT_Active_Energy
		INNER JOIN dbo.ED_Devices_Pts AS edp
			ON  edp.F_Registr_Pts		= erp.LINK
			AND	(	
					@PK						IS NOT NULL
				AND	edp.F_Devices			= @PK
				OR	@PK						IS NULL
				)
		inner JOIN dbo.ED_Meter_Profiles AS emp
			ON	emp.F_Division			= edp.F_Division
			AND emp.F_Devices			= edp.F_Devices
			AND emp.N_Period			= @N_Period
			AND emp.F_Energy_Types		= edp.F_Energy_Types
			AND ISNULL(emp.N_Count, 0)	< @N_Hours					--	Имеются "пустые" профильные значения
			AND (
					@Session			IS NULL
				OR	@Session			IS NOT NULL
				--	Дата последнего запуска операции меньше чем дата изменения профилей.
				AND	ISNULL(emp.D_Date_Replace_Cons,'19900101')
										 < ISNULL(emp.S_Modif_Date, '20790606')
				)
		OPTION (RECOMPILE)

		--select * from #T_Heads_Profile

		--	Выборка неполных профилей.
		INSERT #T_Heads_Profile
		(
			F_Division,
			F_SubDivision,
			F_Devices,
			F_Energy_Types,
			F_Energy_Types_Main,
			F_Profile,
			N_Period,
			V_Cons,
			V_Status 
		)
		SELECT DISTINCT
			erp.F_Division ,
			erp.F_SubDivision,
			ed.LINK, 
			emm.F_Energy_Types,
			edp.F_Energy_Types,
			emp.LINK			AS F_Profile,
			@N_Period,
			emp.N_Cons			AS V_Cons,
			emp.N_Param15		AS V_Status
		FROM #T_Subscrs AS rs
		INNER JOIN dbo.ED_Registr_Pts AS erp
			ON	erp.F_Division			= rs.F_Division
			AND erp.F_Subscr			= rs.F_Subscr
			AND	erp.F_Sale_Items		= @SIT_Active_Energy
		INNER JOIN dbo.ED_Devices_Pts AS edp
			ON  edp.F_Registr_Pts		= erp.LINK
			AND	(	
					@PK						IS NOT NULL
				AND	edp.F_Devices			= @PK
				OR	@PK						IS NULL
				)
				and B_Main	= 1
		inner join dbo.ED_Devices as ed
			on	ed.LINK					= edp.F_Devices
		inner join dbo.ED_Meter_Measures as emm
			on emm.F_Devices			= ed.LINK
			and	emm.F_Energy_Types		<> edp.F_Energy_Types
		--	если профиля нет по тому же виду энергии что и на уп 
		LEFT JOIN dbo.ED_Meter_Profiles AS emp
			ON	emp.F_Division			= emm.F_Division
			AND emp.F_Devices			= emm.F_Devices
			AND emp.N_Period			= @N_Period
			AND emp.F_Energy_Types		= emm.F_Energy_Types
			AND ISNULL(emp.N_Count, 0)	< @N_Hours					--	Имеются "пустые" профильные значения
			AND (
					@Session			IS NULL
				OR	@Session			IS NOT NULL
				--	Дата последнего запуска операции меньше чем дата изменения профилей.
				AND	ISNULL(emp.D_Date_Replace_Cons,'19900101')
										 < ISNULL(emp.S_Modif_Date, '20790606')
				)
		left join #T_Heads_Profile as t
			on	t.F_Profile			= emp.LINK
		where t.F_Devices is null 
		OPTION (RECOMPILE)



		--	Период с которого подтянутся замещаемые значения (АППГ или ПП)
		UPDATE hp
		SET N_Period_Last	= pp.N_Period
		FROM #T_Heads_Profile AS hp
		OUTER APPLY
		(
			SELECT TOP 1
				emp.N_Period
			FROM dbo.ED_Meter_Profiles AS emp
			WHERE	emp.F_Division		= hp.F_Division
				AND emp.F_Devices		= hp.F_Devices
				AND emp.F_Energy_Types	= hp.F_Energy_Types
				AND emp.N_Period		< hp.N_Period
			ORDER BY 
				CASE WHEN emp.N_Period		= YEAR (DATEADD(YEAR, -1, @D_Date0)) * 100 + MONTH (DATEADD(YEAR, -1, @D_Date0)) THEN 0 ELSE 1 END ASC,
				emp.N_Period DESC 
		) AS pp
		OPTION (RECOMPILE)

		

		IF @B_tmp = 1
			SELECT '#T_Heads_Profile' AS [#T_Heads_Profile], * FROM #T_Heads_Profile
			
	END
	


	--	Соответствие недель АППГ и ПП, не по числам, а по номеру недель и дню недели.
	BEGIN

		IF OBJECT_ID ('tempdb.dbo.#UIP_Weeks') IS NOT NULL DROP TABLE #UIP_Weeks
		CREATE TABLE #UIP_Weeks
		(
			N_Period		INT,
			N_Period_Last	INT,
			D_Date			SMALLDATETIME,	-- & N_id
			D_Date_Last		SMALLDATETIME,	-- & N_id
			N_Week			TINYINT,		--	Номер недели
			N_Day			TINYINT			--	Номер дня недели
		)
		CREATE CLUSTERED INDEX IDX_UIP_Weeks ON #UIP_Weeks (
			N_Day	)
				
	
		--	Уникальные сочетания интервалов для которых и определим соответствие по дат по номеру и дням недели

		SET LANGUAGE Russian	-- выставим настройку в РУ, чтобы вск принимался за конец недели, а не начало (для функции DATEPART(weekday,<>,<>))

		IF OBJECT_ID ('tempdb.dbp.#UIP_Days') IS NOT NULL DROP TABLE #UIP_Days
		CREATE TABLE #UIP_Days 
		(
			B_Period			BIT,			--	0 - текущий, 1 - АППГ/ПП
			N_Period			INT, 
			N_Period_Last		INT,
			D_Date				SMALLDATETIME,
			N_Monday			TINYINT,
			N_Day				TINYINT
		)
			
		INSERT INTO #UIP_Days
		(
			B_Period,
			N_Period,
			N_Period_Last,
			D_Date,
			N_Monday,
			N_Day
		)
		SELECT 
			0						AS B_Period,
			i.N_Period, 
			i.N_Period_Last,
			cd.D_Date,
			CAST(cd.B_Monday AS TINYINT)
									AS N_Monday,
			DATEPART(weekday, cd.D_Date)
									AS N_Day
		FROM (
			SELECT DISTINCT hp.N_Period, hp.N_Period_Last
			FROM #T_Heads_Profile AS hp
			WHERE	hp.N_Period_Last	IS NOT NULL	
		)		AS i
		-- текущий РП
		INNER JOIN dbo.CS_Days AS cd
			ON	cd.N_Year * 100 + cd.N_Month	= i.N_Period
		OPTION (RECOMPILE)
		
				
			
		INSERT INTO #UIP_Days
		(
			B_Period,
			N_Period,
			N_Period_Last,
			D_Date,
			N_Monday,
			N_Day
		)
		SELECT 
			1						AS B_Period,
			i.N_Period, 
			i.N_Period_Last,
			cdL.D_Date,
			CAST(cdL.B_Monday AS TINYINT)
									AS N_Monday,
			DATEPART(weekday, cdL.D_Date)
									AS N_Day
		FROM
		(
			SELECT DISTINCT hp.N_Period, hp.N_Period_Last
			FROM #T_Heads_Profile AS hp
			WHERE	hp.N_Period_Last	IS NOT NULL
		)		AS i
		INNER JOIN DBO.CS_Days AS cdL
			ON	cdL.N_Year * 100 + cdL.N_Month	= i.N_Period_Last
		OPTION (RECOMPILE)

		
		UPDATE d
		SET d.N_Monday = 0
		FROM #UIP_Days AS d
		WHERE	d.N_Monday = 1
			AND d.D_Date   = 
				(
				SELECT TOP 1 ld.D_Date
				FROM #UIP_Days AS ld
				WHERE ld.B_Period			= d.B_Period
					AND ld.N_Period			= d.N_Period
					AND ld.N_Period_Last	= d.N_Period_Last
				ORDER BY ld.D_Date ASC
				)
		OPTION (RECOMPILE)


		INSERT #UIP_Weeks
		(
			N_Period,
			N_Period_Last,
			D_Date,
			D_Date_Last,
			N_Week,
			N_Day
		)
		SELECT 
			n.N_Period, 
			n.N_Period_Last,
			n.D_Date,
			l.D_Date		AS D_Date_Last,
			n.N_Week,
			n.N_Day
		FROM 
		(
			SELECT 
				d.N_Period, 
				d.N_Period_Last,
				d.D_Date,
				(SELECT SUM(ld.N_Monday)
				 FROM #UIP_Days AS ld
				 WHERE  ld.B_Period			= d.B_Period
					AND ld.N_Period			= d.N_Period
					AND ld.N_Period_Last	= d.N_Period_Last
					AND ld.D_Date			<=d.D_Date
				)					AS N_Week,
				d.N_Day
			FROM #UIP_Days AS d 
			WHERE d.B_Period = 0
		)		AS n 
		-- для замещения берутся данные интервала АППГ/ПП за соответствующий час соответствующего дня недели соответствующего порядкого номера недели в месяце.
		LEFT JOIN
		(
			SELECT 
				d.N_Period, 
				d.N_Period_Last,
				d.D_Date,
				(SELECT SUM(ld.N_Monday)
				 FROM #UIP_Days AS ld
				 WHERE  ld.B_Period			= d.B_Period
					AND ld.N_Period			= d.N_Period
					AND ld.N_Period_Last	= d.N_Period_Last
					AND ld.D_Date			<=d.D_Date
				)					AS N_Week,
				d.N_Day
			FROM #UIP_Days AS d 
			WHERE d.B_Period = 1
		)		AS l
			ON	l.N_Period		= n.N_Period 
			AND l.N_Period_Last	= n.N_Period_Last
			AND l.N_Week		= n.N_Week
			AND l.N_Day			= n.N_Day	
		OPTION (RECOMPILE)
								
		SET LANGUAGE us_English	--	вернем назад
	
	
		--	SELECT * FROM #UIP_Weeks AS w ORDER BY w.D_Date 
	
		--	Выберем незаполненные окончания интервалов (последняя неделя предыдущего месяца оказалась короче текущей)
		--	В этом случае необходимо заполнить недостающие даты с предпоследней недели АППГ/ПП
		UPDATE w
		SET D_Date_Last = wP.D_Date_Last 
		FROM #UIP_Weeks AS w 
		INNER JOIN #UIP_Weeks AS wP
			ON	wP.N_Period			= w.N_Period
			AND wP.N_Period_Last	= w.N_Period_Last
			AND wP.N_Week			= w.N_Week - 1
			AND wP.N_Day			= w.N_Day 
		WHERE	w.N_Week		> 0
			AND w.D_Date_Last	IS NULL 
		OPTION (RECOMPILE)
	
		
		--	А если не нашлось соответствия для первой недели притянем даты с предыдущего месяца от АППГ/ПП (первая неделя предыдущего месяца короче текущей)
		UPDATE w
		SET D_Date_Last		= DATEADD(dd,-(p.N_Day-w.N_Day), p.D_Date_Last)
		FROM #UIP_Weeks AS w 
		INNER JOIN
		(
			SELECT
				w.N_Period, w.N_Period_Last, w.D_Date_Last, w.N_Day
			FROM #UIP_Weeks AS w
			WHERE	w.N_Week		= 0
				AND w.D_Date_Last	= 
					(
					SELECT TOP 1 lw.D_Date_Last
					FROM #UIP_Weeks AS lw
					WHERE	lw.N_Period			= w.N_Period
						AND lw.N_Period_Last	= w.N_Period_Last
						AND lw.N_Week			= w.N_Week
						AND lw.D_Date_Last		IS NOT NULL
					ORDER BY lw.D_Date_Last ASC  	
					)
		) AS p
			ON	p.N_Period		= w.N_Period
			AND p.N_Period_Last	= w.N_Period_Last
		WHERE	w.N_Week		= 0
			AND w.D_Date_Last	IS NULL 
		OPTION (RECOMPILE)

		
		IF @B_tmp = 1	
			SELECT '#UIP_Weeks' AS [#UIP_Weeks], * FROM #UIP_Weeks AS w ORDER BY w.D_Date 

	END
	
	
	
		-- соберем эталонные профиля (им не указываем LINK профиля)
		INSERT #T_Heads_Profile
		(
			F_Division,
			F_Devices,
			F_Energy_Types,
			F_Energy_Types_Main,
			N_Period,
			V_Cons,
			V_Status
		) 
		SELECT 
			hp.F_Division, 
			hp.F_Devices, 
			hp.F_Energy_Types,
			hp.F_Energy_Types_Main,
			emp.N_Period, 
			emp.N_Cons			AS V_Cons,
			emp.N_Param15		AS V_Status
		FROM #T_Heads_Profile AS hp
		INNER JOIN
		(	-- определим за какие периоды надо распаковать эталонные профиля
			SELECT DISTINCT
				w.N_Period, w.N_Period_Last, YEAR(w.D_Date_Last) * 100 + MONTH(w.D_Date_Last) AS N_Period_Profile
			FROM #UIP_Weeks AS w
		) AS p
			ON	hp.N_Period			= p.N_Period
			AND hp.N_Period_Last	= p.N_Period_Last
		LEFT JOIN DBO.ED_Meter_Profiles AS emp
			ON	emp.F_Division		= hp.F_Division
			AND emp.F_Devices		= hp.F_Devices
			AND emp.F_Energy_Types	= hp.F_Energy_Types
			AND emp.N_Period		= p.N_Period_Profile
		WHERE hp.F_Energy_Types		= hp.F_Energy_Types_Main
		OPTION (RECOMPILE)

	 
		--	SELECT * FROM #T_Heads_Profile
	
	
	
		--	Для обработки распакуем профиля в временную проиндексированную табличку
		IF OBJECT_ID ('tempdb.dbo.#UIP_Profiles') IS NOT NULL DROP TABLE #UIP_Profiles
		CREATE TABLE #UIP_Profiles
		(
			F_Head			INT,				--	Ссылка на #T_Heads_Profile
			D_Date			SMALLDATETIME,		--	Дата (без часов)
			D_Date_Last		SMALLDATETIME,		--	Дата с которой подтянулся расход АППГ/ПП
			N_id			SMALLINT,			--	Номер часа в месяце
			N_Value			DECIMAL(19,6),		--	Почасовой расход
			F_Status		TINYINT				--	Статус расхода
		)
		CREATE CLUSTERED INDEX IDX_UIP_Profiles ON #UIP_Profiles(
			F_Head)
		CREATE NONCLUSTERED INDEX IDX_UIP_Profiles_N_id ON #UIP_Profiles(
			N_id)
			
		
		INSERT #UIP_Profiles (F_Head, D_Date, N_id, N_Value, F_Status)
		SELECT hp.F_Head, DATEADD(dd, cuv.Id/24, @D_Date0), cuv.Id, cuv.Value1, cuv.Value17
		FROM #T_Heads_Profile AS hp
		CROSS APPLY dbo.EF_UnpackValues(hp.V_Cons, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, hp.V_Status) AS cuv
		where hp.F_Energy_Types	= hp.F_Energy_Types_Main

		OPTION (RECOMPILE)

		INSERT #UIP_Profiles (F_Head, D_Date, N_id, N_Value, F_Status)
		SELECT hp.F_Head,DATEADD(dd, cuv.Id/24, @D_Date0), cuv.Id, cuv.Value1, cuv.Value17
		FROM #T_Heads_Profile AS hp 
		--INNER JOIN #UIP_Profiles AS p
		--	ON	p.F_Head			= hp.F_Head
		outer APPLY dbo.EF_UnpackValues(hp.V_Cons, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, hp.V_Status) AS cuv
		where hp.F_Energy_Types	<> hp.F_Energy_Types_Main
		
		--select * from #UIP_Profiles
		------------------------------------------------------------------------------------------------------------------------------		
		--	заместим пустоты с АППГ/ПП
		UPDATE p
		SET N_Value		= pP.N_Value,
			F_Status	= @ERS_Replace,
			D_Date_Last	= DATEADD(hour, pP.N_id % 24, w.D_Date_Last)
		FROM #T_Heads_Profile AS hp 
		INNER JOIN #UIP_Profiles AS p
			ON	p.F_Head			= hp.F_Head
		LEFT JOIN ES_Readings_Status AS ers
			ON	ers.LINK			= p.F_Status
		INNER JOIN #UIP_Weeks AS w
			ON	w.N_Period			= hp.N_Period
			AND w.D_Date			= DATEADD (dd, p.N_id / 24, @D_Date0)
		-- эталончики	
		INNER JOIN #T_Heads_Profile AS hpP
			ON	hpP.F_Division		= hp.F_Division
			AND hpP.F_Devices		= hp.F_Devices
			AND hpP.F_Energy_Types	= hp.F_Energy_Types
			AND hpP.N_Period		= YEAR(w.D_Date_Last) * 100 + MONTH(w.D_Date_Last)
		INNER JOIN dbo.CS_Periods AS cpP
			ON	cpP.N_Year * 100 + cpP.N_Month = hpP.N_Period
		INNER JOIN #UIP_Profiles AS pP
			ON	pP.F_Head			= hpP.F_Head
			AND DATEADD (dd, pP.N_id / 24, cpP.D_Date0)
									= w.D_Date_Last
			AND pP.N_id % 24		= p.N_id % 24
		LEFT JOIN dbo.ES_Readings_Status AS ersP
			ON	ersP.LINK			= pP.F_Status
		WHERE	hp.F_Profile		IS NOT NULL
			AND hp.N_Period_Last	IS NOT NULL
			and	hp.F_Energy_Types	= hp.F_Energy_Types_Main
			--	Замешаем только недостоверные или пустые значения, а так же значения сформированные в предыдущих запусках данной операции
			AND (	p.N_Value		IS NULL 
				OR	p.F_Status		= @ERS_Replace 
				OR	ers.B_InfoOnly	= 1	)
			--	Замещаем толкьо если показание есть и действительно
			AND (
					pp.N_Value		IS NOT NULL
				AND ISNULL(ersP.B_InfoOnly, 0) = 0
				)
		OPTION (RECOMPILE)

		update p
		SET 
			N_Value		= isnull(N_Value, 0),
			F_Status	= @ERS_Replace,
			D_Date_Last	= DATEADD(hour, p.N_id % 24, p.D_Date)
		from #T_Heads_Profile as hp
			INNER JOIN #UIP_Profiles AS p
				ON	p.F_Head			= hp.F_Head
		where hp.F_Energy_Types <>hp.F_Energy_Types_Main
		AND p.N_Value IS NULL

	------------------------------------------------------------------------------------------------------------------------------		
	--	begin	Для неполных профилей, которым не нашлось АППГ и ПП, заместим расходы на основе граничных значений.
	IF EXISTS (SELECT 1 FROM #T_Heads_Profile AS hp WHERE hp.F_Profile IS NOT NULL AND hp.N_Period_Last IS NULL)
	BEGIN 
		
		--	Календари
		IF OBJECT_ID ('tempdb.dbo.#UIP_Null_Work_Day') IS NOT NULL DROP TABLE #UIP_Null_Work_Day
		CREATE TABLE #UIP_Null_Work_Day 
		(
			F_Calendar			INT,			-- календарь ЛС/Отделения
			D_Date				SMALLDATETIME,	-- день
			B_IsWork			INT				-- признак рабочего дня
		)
		CREATE CLUSTERED INDEX IDX_UIP_Work_Day ON #UIP_Null_Work_Day (
			D_Date	)
			
			
		-- пустые значения
		IF OBJECT_ID('tempdb.dbo.#UIP_Null_Profiles') IS NOT NULL DROP TABLE #UIP_Null_Profiles
		CREATE TABLE #UIP_Null_Profiles
		(
			F_Head		INT,
			N_id		INT,
			N_Left		INT,
			N_Rigth		INT
		)
		CREATE CLUSTERED INDEX IDX_UIP_Profiles_Null ON #UIP_Null_Profiles (
			F_Head	)
		CREATE NONCLUSTERED INDEX IDX_UIP_Profiles_Null_N_id ON #UIP_Null_Profiles (
			N_id	)
			
			
		--	оставим интервалы не более настройки N_MAX_Replace, при анализе учитываем только рабочие дни
		IF OBJECT_ID('tempdb.dbo.#UIP_Null_Interval') IS NOT NULL DROP TABLE #UIP_Null_Interval
		CREATE TABLE #UIP_Null_Interval
		(
			F_Head		INT,			--	ссылка на головную табличку с профилем 
			N_Round		INT,			--	Настройка "Точность почасовых показаний"
			N_Left		INT,			--	Левая граница интервала (нижняя) 
			N_Rigth		INT,			--	Правая граница интервала (верхняя)
			N_Value		DECIMAL(19,6)	--	Расход для интервала
		)
		CREATE CLUSTERED INDEX IDX_UIP_Null_Interval ON #UIP_Null_Interval(
			F_Head	)
		CREATE NONCLUSTERED INDEX IDX_UIP_Null_Interval_Left ON #UIP_Null_Interval(
			N_Left	)	--	инетрвалы не пересекаются в пределах одного профиля, достаточно индекса по одной границе
			
			
		--	begin каледнарик 
			--	для каждого ПУ определим календарь. т.к. на один пу может быть несколько ТУ на разных ЛС выберем топ календарь c ЛС
			UPDATE hp
			SET F_Calendar = c.F_Calendar 
			FROM #T_Heads_Profile AS hp
			INNER JOIN (
				SELECT ROW_NUMBER() OVER (PARTITION BY hp.F_Head ORDER BY edp.B_Main DESC, ss.N_Code, cc.LINK) AS N_Row,
					hp.F_Head, COALESCE (ss.F_Calendar, sd.F_Calendar, cc.LINK) AS F_Calendar
				FROM #T_Heads_Profile AS hp
				INNER JOIN dbo.SD_Divisions AS sd
					ON	sd.LINK					= hp.F_Division
				LEFT JOIN dbo.ED_Devices_Pts AS edp
					ON	edp.F_Device_Division	= hp.F_Division
					AND edp.F_Devices			= hp.F_Devices
					AND edp.F_Energy_Types		= hp.F_Energy_Types
				LEFT JOIN dbo.ED_Registr_Pts AS erp
					ON	erp.F_Division			= edp.F_Division 
					AND erp.LINK				= edp.F_Registr_Pts
				LEFT JOIN dbo.SD_Subscr AS ss
					ON	ss.F_Division			= erp.F_Division 
					AND ss.LINK					= erp.F_Subscr
				LEFT JOIN dbo.CS_Calendars AS cc
					ON	cc.B_Default			= 1
				WHERE	hp.F_Profile			IS NOT NULL 
					AND hp.N_Period_Last		IS NULL
			)		AS c	 
				ON	c.F_Head		= hp.F_Head
				AND c.N_Row			= 1	--	Календарь с ЛС, где основное подключение ПУ, если их несколько, то с ЛС с наибольшим кодом; если на ЛС нет, то с отделения; иначе первый заведенный календарь с признаком "по умолчанию"
			WHERE	hp.F_Profile			IS NOT NULL 
				AND hp.N_Period_Last		IS NULL
			OPTION (RECOMPILE)

			--	SELECT * FROM #T_Heads_Profile
		
		
			DECLARE 
				@N_DBegin	INT,
				@N_DEnd		INT
			SET @N_DBegin	= YEAR (@D_Date0) * 10000 + MONTH (@D_Date0) * 100 + DAY (@D_Date0)
			SET	@N_DEnd		= YEAR (@D_Date1) * 10000 + MONTH (@D_Date1) * 100 + DAY (@D_Date1)
			
	
			INSERT INTO #UIP_Null_Work_Day
			(
				F_Calendar,
				D_Date,
				B_IsWork
			)
			SELECT
				c.F_Calendar,
				fdw.D_Date,
				fdw.B_isWork		
			FROM (
				-- перечень уникальных календариков 
				SELECT DISTINCT hp.F_Division, hp.F_Calendar
				FROM #T_Heads_Profile AS hp
				WHERE	hp.F_Calendar	IS NOT NULL
			)		AS c
			-- не передаём режимы работы, за выходные принимаем СБ и ВСК
			CROSS APPLY dbo.SF_Days_IsWork(c.F_Division, c.F_Calendar, NULL, @N_DBegin, @N_DEnd) fdw
			OPTION (RECOMPILE)
	
				
			--SELECT * FROM #UIP_Null_Work_Day		
		
		--	end		Календарик
		
		
		
		-- выберем пустые знаечния
		INSERT INTO #UIP_Null_Profiles (F_Head, N_id, N_Left, N_Rigth)
		SELECT p.F_Head, p.N_id, ISNULL(MAX(l.N_id), -1) AS N_Left, ISNULL(MIN(r.N_id), cp.N_Days * 24) AS N_Rigth
		FROM #T_Heads_Profile AS hp
		INNER JOIN dbo.CS_Periods AS cp
			ON	cp.N_Year * 100 + cp.N_Month = hp.N_Period
		INNER JOIN #UIP_Profiles AS p	-- Пустое значение профиля
			ON	p.F_Head		= hp.F_Head
			AND p.N_Value		IS NULL  
		-- Ближайшее заполненное значение слева (до)
		LEFT JOIN #UIP_Profiles AS l
			ON	l.F_Head		= p.F_Head
			AND l.N_Value		IS NOT NULL
			AND l.N_id			<=p.N_id
		-- Ближайшее заполненное значение справа (после)
		LEFT JOIN #UIP_Profiles AS r
			ON	r.F_Head		= p.F_Head
			AND r.N_Value		IS NOT NULL
			AND r.N_id			>=p.N_id
		WHERE	hp.F_Profile		IS NOT NULL	--	Есть профиль
			AND hp.N_Period_Last	IS NULL		--	Нет АППГ и ПП
		GROUP BY p.F_Head, p.N_id, cp.N_Days
		OPTION (RECOMPILE, FORCE ORDER)
		
	
			
		--	оставим интервалы не более настройки N_MAX_Replace, при анализе учитываем только рабочие дни
		INSERT INTO #UIP_Null_Interval (F_Head, N_Round, N_Left, N_Rigth)
		SELECT i.F_Head, i.N_Round, i.N_Left, i.N_Rigth
		FROM (
			--	Выберем уникальные интервалы по ПУ
			SELECT DISTINCT hp.F_Calendar, d.N_MAX_Replace, d.N_Round, pn.F_Head, pn.N_Left, pn.N_Rigth
			FROM #UIP_Null_Profiles AS pn
			INNER JOIN #T_Heads_Profile AS hp
				ON	hp.F_Head		= pn.F_Head
			INNER JOIN #T_Divisions AS d
				ON	d.F_Division	= hp.F_Division
				AND d.F_SubDivision = hp.F_SubDivision
		)		AS i
		INNER JOIN dbo.CS_Naturals AS cn
			ON	cn.LINK			BETWEEN i.N_Left + 1 AND i.N_Rigth - 1
		INNER JOIN #UIP_Null_Work_Day AS wd
			ON	wd.F_Calendar	= i.F_Calendar
			AND wd.D_Date		= DATEADD(day, cn.LINK/24, @D_Date0)
		GROUP BY i.F_Head, i.N_Round, i.N_Left, i.N_Rigth, i.N_MAX_Replace
		HAVING SUM(wd.B_IsWork) <= i.N_MAX_Replace		--	подчитаем количество пустых значений в интервале без учета выходных дней
		OPTION (RECOMPILE)

		
		--	Определим значения расхода для интервалов
		UPDATE ni
		SET N_Value = 
			CASE WHEN pL.N_Value + pR.N_Value IS NULL	-- если одно из значений NULL то интервал на границе периода 
				THEN ISNULL(pL.N_Value, pR.N_Value)		-- Расход равен значению на одной из границ интервала
				ELSE ROUND((pL.N_Value + pR.N_Value) / 2, ni.N_Round)
			END 		 
		FROM #UIP_Null_Interval AS ni
		LEFT JOIN #UIP_Profiles AS pL
			ON	pL.F_Head	= ni.F_Head
			AND pL.N_id		= ni.N_Left
		LEFT JOIN #UIP_Profiles AS pR
			ON	pR.F_Head	= ni.F_Head
			AND pR.N_id		= ni.N_Rigth
		OPTION (RECOMPILE)

		
		--	Скорректируем профили
		UPDATE p
		SET N_Value		= ni.N_Value,
			F_Status	= @ERS_Replace
		FROM #UIP_Null_Profiles AS np
		INNER JOIN #UIP_Null_Interval AS ni
			ON	ni.F_Head	= np.F_Head
			AND ni.N_Left	= np.N_Left
			AND ni.N_Rigth	= np.N_Rigth
		INNER JOIN #UIP_Profiles AS p
			ON	p.F_Head	= np.F_Head
			AND p.N_id		= np.N_id	
		OPTION (RECOMPILE)

		
		IF OBJECT_ID('tempdb.dbo.#UIP_Null_Interval') IS NOT NULL DROP TABLE #UIP_Null_Interval
		IF OBJECT_ID('tempdb.dbo.#UIP_Null_Profiles') IS NOT NULL DROP TABLE #UIP_Null_Profiles
		IF OBJECT_ID('tempdb.dbo.#UIP_Null_Work_Day') IS NOT NULL DROP TABLE #UIP_Null_Work_Day

	END 
	--	end		Для неполных профилей, которым не нашлось АППГ и ПП, заместим расходы на основе граничных значений.
	------------------------------------------------------------------------------------------------------------------------------		
	
		
	--	SELECT * FROM #UIP_Profiles
	------------------------------------------------------------------------------------------------------------------------------		
	--	begin	final
		--	подготовим обработанные профиля к запаковке
		UPDATE hp
		SET X_Cons = 
			(
				SELECT [Date], [Value]
				FROM (
					SELECT
						DATEADD (hh, p.N_id, @D_Date0)	AS [Date],
						p.N_Value						AS [Value]
					FROM #UIP_Profiles AS p
					WHERE	p.F_Head		= hp.F_Head
					)		AS cons
				ORDER BY cons.[Date]
				FOR XML AUTO, TYPE, ELEMENTS, ROOT('ROOT') 
			),
			X_Status = 
			(
				SELECT [Date], [Value]
				FROM (
					SELECT
						DATEADD (hh, p.N_id, @D_Date0)	AS [Date],
						p.F_Status						AS [Value]
					FROM #UIP_Profiles AS p
					WHERE	p.F_Head		= hp.F_Head
					)		AS cons
				ORDER BY cons.[Date]
				FOR XML AUTO, TYPE, ELEMENTS, ROOT('ROOT') 
			),
			X_Date_Last =
			(
				SELECT [Date], [Value]
				FROM (
					SELECT
						DATEADD (hh, p.N_id, @D_Date0)	AS [Date],
						CONVERT(VARCHAR(20), p.D_Date_Last, 112) + ' ' + 
						RIGHT('00' + CAST(DATEPART(hour, p.D_Date_Last) AS VARCHAR(2)), 2) + ':'+
						RIGHT('00' + CAST(DATEPART(minute, p.D_Date_Last) AS VARCHAR(2)), 2)
												AS [Value]
					FROM #UIP_Profiles AS p
					WHERE	p.F_Head		= hp.F_Head
					)		AS cons
				ORDER BY cons.[Date]
				FOR XML AUTO, TYPE, ELEMENTS, ROOT('ROOT') 
			)
		FROM #T_Heads_Profile AS hp
		WHERE	hp.F_Profile		IS NOT NULL
			--AND hp.N_Period_Last	IS NOT NULL
		OPTION (RECOMPILE)
	
		
		-- перезапишем сформированный профиль поверх существующего
        IF OBJECT_ID ('tempdb.dbo.#UIP_Profiles_X') IS NOT NULL DROP TABLE #UIP_Profiles_X
        CREATE TABLE #UIP_Profiles_X
        (
            F_Division      TINYINT,    
            F_Devices       INT,  
            F_Profile       BIGINT,   
            N_Cons          VARBINARY(MAX),  
			N_Param14       VARBINARY(MAX),
            N_Param15       VARBINARY(MAX)
        )
            
        CREATE CLUSTERED INDEX IDX_UIP_Profiles_X ON #UIP_Profiles_X(F_Division, F_Devices, F_Profile)
            
        
        INSERT #UIP_Profiles_X (F_Division, F_Devices, F_Profile, N_Cons, N_Param14, N_Param15)
        SELECT hp.F_Division, hp.F_Devices, hp.F_Profile, cpv.Value1, cpv.Value16, cpv.Value17
        FROM #T_Heads_Profile AS hp
        CROSS APPLY dbo.EF_PackValues (hp.X_Cons, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, hp.X_Date_Last, hp.X_Status) cpv
        WHERE   hp.F_Profile IS NOT NULL
        OPTION (RECOMPILE)


        UPDATE emp
        SET N_Cons              = hp.N_Cons,
            N_Param14			= hp.N_Param14, 
            N_Param15           = hp.N_Param15,
            D_Date_Replace_Cons = SYSDATETIME(),
            S_Modif_Date        = SYSDATETIME(),
            S_Owner             = SUSER_ID()        
        FROM #UIP_Profiles_X AS hp
        INNER JOIN dbo.ED_Meter_Profiles emp
            ON  emp.F_Division      = hp.F_Division
            AND emp.F_Devices       = hp.F_Devices
            AND emp.LINK            = hp.F_Profile
        OPTION (RECOMPILE, FORCE ORDER)
	
	--	end		final
	------------------------------------------------------------------------------------------------------------------------------		
	

		
	-- выдадим сообщения о тех профилях что не удалось полностью заместить	
	DECLARE
		@C_Error	VARCHAR(max)
	SELECT @C_Error = '' 
	
	SELECT @C_Error = @C_Error + 
		sd.C_Name + ' ' + 
		ISNULL (ssd.C_Name, '<основной участок>') + 
		' ПУ:' + ISNULL(ed.C_Serial_Number, '<без номера>') + 
		', измеряемый показатель: ' + eet.C_Short_Name +
		', отсутствует расходов ' + CAST ( COUNT (p.N_id) AS VARCHAR(5)) + CHAR(13) + CHAR(10) 
	FROM #T_Heads_Profile AS hp
	INNER JOIN dbo.ED_Devices AS ed
		ON	ed.F_Division	= hp.F_Division
		AND ed.LINK			= hp.F_Devices
	INNER JOIN dbo.ES_Energy_Types AS eet
		ON	eet.LINK		= hp.F_Energy_Types
	INNER JOIN dbo.SD_Divisions AS sd
		ON	sd.LINK			= ed.F_Division
	LEFT JOIN dbo.SD_Subdivisions AS ssd
		ON	ssd.LINK		= ed.F_SubDivision
	INNER JOIN #UIP_Profiles AS p
		ON	p.F_Head		= hp.F_Head
	LEFT JOIN dbo.ES_Readings_Status AS ers
		ON	ers.LINK		= p.F_Status
	WHERE	hp.F_Profile	IS NOT NULL
		AND(	p.N_Value		IS NULL
			OR	ers.B_InfoOnly	= 1	)
	GROUP BY sd.C_Name, ssd.C_Name, ed.C_Serial_Number, eet.C_Short_Name
	ORDER BY sd.C_Name, ssd.C_Name, ed.C_Serial_Number, eet.C_Short_Name
	OPTION (RECOMPILE)

	SELECT @N_Rowcount	= @@ROWCOUNT
	IF @N_Rowcount > 0
	BEGIN 
		INSERT dbo.CS_Error_Log (D_Date, C_Error_Text, F_Division, F_SubDivision, C_User_Name, C_Host)
		SELECT GETDATE(), 
			'Не удалось полностью заместить все отсутствующие почасовые расходы по следующим ПУ:' + CHAR(13) + CHAR(10) + 
			@C_Error,
			dbo.SF_Division(), dbo.SF_SubDivision(), SUSER_NAME(), HOST_NAME()
		SELECT @Status_Msg = 'Не удалось полностью заместить все отсутствующие почасовые расходы. Перечень таких ПУ отражен в "Сервис\Ошибки приложения".'
	END 
	
				
	IF OBJECT_ID ('tempdb.dbo.#UIP_Weeks') IS NOT NULL DROP TABLE #UIP_Weeks
	IF OBJECT_ID ('tempdb.dbp.#UIP_Days') IS NOT NULL DROP TABLE #UIP_Days
	IF OBJECT_ID ('tempdb.dbo.#UIP_Profiles') IS NOT NULL DROP TABLE #UIP_Profiles
	IF OBJECT_ID ('tempdb.dbo.#T_Heads_Profile') IS NOT NULL DROP TABLE #T_Heads_Profile
	IF OBJECT_ID ('tempdb.dbo.#T_Divisions') IS NOT NULL DROP TABLE #T_Divisions
	
	EXEC cmn.APP_Add_Msg_Log @F_Division, @PID, 0

	RETURN 1
--	История изменений старше года:
--		27.12.2016 10:33 a-shavgaev Опять чиним, вслед за изменившимся используемым представлением
--		22.12.2016 10:42 a-shavgaev Чиним, вслед за изменившимся используемым представлением
--		25.11.2016 16:24 a-shavgaev Изменено представление отделений
--		24.11.2015 14:16 a-shavgaev пустое количество почасовых отсчетов в профиле считаем за 0.
--		20.11.2015 09:47 a-shavgaev запуск из расчета
--		12.11.2015 10:35 a-naleykin добавил вызов процедуры логирования вызова процедуры
--		26.06.2015 10:15 a-shavgaev при запуске из карточки ПУ заполняем буфер отделений
--		24.10.2014 11:52 a-shavgaev добавлен параметр ЛС
--		17.09.2014 14:04 a-shavgaev при формировании профилей убран фильтр по наличию АППГ/ПП, в новом алгоритме добавлено заполнение статуса
--		09.09.2014 16:54 a-shavgaev Добавлен алгоритм замещения в случае отсутсвия АППГ и ПП
--		08.07.2014 09:50 запуск только в пределах текущего отделения пользователя
--		04.07.2014 11:53 не работало в sql2005, допилки 
END