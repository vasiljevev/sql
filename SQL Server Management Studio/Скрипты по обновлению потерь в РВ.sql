	
--#624512 Россети ЦиП. #HD46844 Расчет потерь ЮЛ. Проверка потерь в тп.
-------Description----------
--Необходимо создать скрипт по заполнению поля потери в сгенерированных начислениях:
--	* если на уп в поле "Потери ТП" указан метод расчета потерь "Расход (помес)" 
--	* необходимо заполнить Н-квантити-лос-тп 
--	* уменьшить н-конс на величину указанного значения в параметрах расчета потерь.
--Скрипт будет использован по всем сгенерированным ведомостям и других филиалов  при методе "Расход (помес)"

	
	DECLARE
		@G_Session_ID		uniqueidentifier,
		@F_Division			int,
		@F_Division_prev	int,
		@N_Period			int,		--если заполнены то только по ним
		@F_Registr_Pts		int,		--если заполнены то только по ним
		@B_EE				bit,		--Обрабатывать ЮЛ?
		@C_Message			varchar(500)

	--инициализируем переменные

	SET @G_Session_ID = '00000000-2022-0427-0940-000000000000'-- NEWID()
	SET @B_EE = 1

	SET @N_Period		= 202203
	SET @F_Registr_Pts	= 65400161


	SET @C_Message = 'Сессия: ' + CAST(@G_Session_ID AS VARCHAR(36)) 
	PRINT @C_Message

	IF OBJECT_ID('tempdb..#T_Divisions') IS NOT NULL DROP TABLE #T_Divisions
	CREATE TABLE #T_Divisions 
	(
		F_Division	int,
		C_Name		varchar(300)
	)

	INSERT INTO #T_Divisions (F_Division, C_Name)
	SELECT LINK, C_Name
	FROM SD_Divisions sd
	WHERE F_Division IS NOT NULL
	AND LINK NOT IN (0,1,2) --Исключаем управление,владимирЭнерго
	AND LINK = 41			-- Пока только по Кирову

	IF OBJECT_ID('IE.Imp_CD_Paysheets_Details_Loss_Updates') IS NULL 
	CREATE TABLE IE.Imp_CD_Paysheets_Details_Loss_Updates
	(
		LINK										INT IDENTITY(1,1),
		G_Session_ID								UNIQUEIDENTIFIER,
		F_Division									INT,
		N_Period									INT,
		F_Registr_Pts								INT,
		F_Subscr									INT,
		F_FVT_Paysheets_Details						BIGINT,
		F_Paysheets_Details_EE                      BIGINT,
		F_Paysheets_Details                         BIGINT,
		F_Paysheets									BIGINT,
		N_Quantity									DECIMAL(19,6),
		N_Cons_Old                                  DECIMAL(19,6),
		N_Transf_Losses_Old                         DECIMAL(19,6),
		F_Transf_Loss_Old							INT,
		N_Cons_New									DECIMAL(19,6),
		N_Transf_Losses_New							DECIMAL(19,6),
		F_Transf_Loss_New                           INT,
		D_Date_Begin_Registr_Pts_Loss				SMALLDATETIME,
		D_Date_End_Registr_Pts_Loss                 SMALLDATETIME,
		C_Const_Loss_Algorithms						VARCHAR(50),
		C_Name_Loss_Algorithms						VARCHAR(150),
		LINK_Imp									VARCHAR(36),
		S_Creator_Paysheets_Details 				INT,
		B_Update									BIT DEFAULT(0),		--если информацию обновляли то планируем проставлять 1
		C_Message									VARCHAR(1000),
		string1										VARCHAR(255),		--доп стринговые поля
		string2										VARCHAR(255),		--доп стринговые поля
		string3										VARCHAR(255),		--доп стринговые поля
		int1										INT,				--доп интовые поля
		int2										INT,				--доп интовые поля
		int3										INT,				--доп интовые поля
		S_Creator									INT DEFAULT (dbo.CF_User_ID()),
		S_Create_Date								SMALLDATETIME DEFAULT(GETDATE())
	)
	

	SET @F_Division = (SELECT MIN(F_Division) FROM #T_Divisions)

	--Работаем в цикле по филиалам
	WHILE @F_Division IS NOT NULL
	BEGIN

		--заполним буфер
		INSERT INTO IE.Imp_CD_Paysheets_Details_Loss_Updates 
					(G_Session_ID, F_Division, N_Period, F_Registr_Pts, F_Subscr, F_FVT_Paysheets_Details, F_Paysheets_Details_EE, F_Paysheets_Details, F_Paysheets, N_Quantity, N_Cons_Old, N_Transf_Losses_Old, F_Transf_Loss_Old, N_Cons_New, N_Transf_Losses_New, F_Transf_Loss_New, D_Date_Begin_Registr_Pts_Loss, D_Date_End_Registr_Pts_Loss, C_Const_Loss_Algorithms, C_Name_Loss_Algorithms, LINK_Imp, S_Creator_Paysheets_Details)
		SELECT 
				@G_Session_ID						AS G_Session_ID,
				fpd.F_Division						AS F_Division,
				fpd.N_Period						AS N_Period,
				pd.F_Registr_Pts					AS F_Registr_Pts,
				fp.F_Subscr							AS F_Subscr,
				fpd.LINK							AS F_FVT_Paysheets_Details,
				fpde.LINK							AS F_Paysheets_Details_EE,
				pd.LINK								AS F_Paysheets_Details,
				fp.LINK								AS F_Paysheets,		
				fpd.N_Quantity						AS N_Quantity,
				fpd.N_Cons							AS N_Cons_Old,
				fpd.N_Transf_Losses					AS N_Transf_Losses_Old,
				fpd.F_Transf_Loss					AS F_Transf_Loss_Old,
				fpd.N_Cons - erpl.N_Value			AS N_Cons_New,
				erpl.N_Value						AS N_Transf_Losses_New,
				erpl.LINK							AS F_Transf_Loss_New,
				erpl.D_Date_Begin					AS D_Date_Begin_Registr_Pts_Loss,
				erpl.D_Date_End						AS D_Date_End_Registr_Pts_Loss,
				ela.C_Name							AS C_Const_Loss_Algorithms,
				ela.C_Const							AS C_Name_Loss_Algorithms,
				fpd.LINK_Imp						AS LINK_Imp,
				fpd.S_Creator						AS S_Creator_Paysheets_Details
		FROM EE.FVT_Paysheets_Details fpd
		INNER JOIN EE.FD_Paysheets_Details_EE fpde
			ON fpde.LINK = fpd.LINK
			AND fpde.F_Division = fpd.F_Division
			AND fpde.N_Period = fpd.N_Period
		INNER JOIN EE.FD_Paysheets_Details pd
			ON pd.F_Registr_Pts = fpd.F_Registr_Pts
			AND pd.F_Division = fpd.F_Division
			AND pd.N_Period = fpd.N_Period
		INNER JOIN EE.FD_Paysheets fp
			ON fp.LINK = pd.F_Paysheets
			AND fp.F_Division = pd.F_Division
			AND fp.N_Period = pd.N_Period
		INNER JOIN dbo.ED_Registr_Pts_Loss erpl
			ON erpl.F_Registr_Pts = fpd.F_Registr_Pts
			AND erpl.F_Division = fpd.F_Division
			AND pd.D_Date_Begin >= erpl.D_Date_Begin
			AND pd.D_Date_End <= erpl.D_Date_End 
		INNER JOIN dbo.ES_Loss_Algorithms ela
			ON ela.LINK = erpl.F_Loss_Algorithms
			AND ela.C_Const = 'ELA_Transf_Const_Month' -- расчет помес
		WHERE fpd.F_Division = 41
			AND fpd.LINK_Imp IS NOT NULL
			AND pd.N_Quantity > 0	-- Нулевые объемы не нужно
			AND (pd.N_Period = @N_Period OR @N_Period IS NULL)
			AND (pd.F_Registr_Pts = @F_Registr_Pts OR @F_Registr_Pts IS NULL)
			AND fpde.N_Transf_Losses IS NULL	-- Поле не заполено должно быть
		ORDER by pd.F_Registr_Pts

	--Приступим к обнолвению

	UPDATE fpde
	SET fpde.F_Transf_Loss = t.F_Transf_Loss_New,
		fpde.N_Transf_Losses = t.N_Transf_Losses_New
	--SELECT fpde.F_Transf_Loss , t.F_Transf_Loss_New,
	--	fpde.N_Transf_Losses , t.N_Transf_Losses_New
	FROM IE.Imp_CD_Paysheets_Details_Loss_Updates t
	INNER JOIN EE.FD_Paysheets_Details_EE fpde
		ON fpde.LINK = t.F_Paysheets_Details_EE
		AND fpde.F_Division = t.F_Division
		AND fpde.N_Period = t.N_Period
	WHERE t.G_Session_ID = '00000000-2022-0427-0940-000000000000'
	--AND t.F_Registr_Pts = 65400161 AND t.N_Period = 202203

	SET @F_Division = (SELECT MIN(F_Division) FROM #T_Divisions WHERE F_Division > @F_Division)

	END


