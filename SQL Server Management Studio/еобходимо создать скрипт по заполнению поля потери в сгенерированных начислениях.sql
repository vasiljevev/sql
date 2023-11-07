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
	

SELECT 
				ss.C_Number,
				ss.N_Code,
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
		inner join SD_Subscr ss
			on ss.link=fp.F_Subscr
			
		WHERE fpd.F_Division = 41
			AND fpd.LINK_Imp IS NOT NULL
			AND pd.N_Quantity > 0	-- Нулевые объемы не нужно
			AND (pd.N_Period = @N_Period OR @N_Period IS NULL)
			--AND (pd.F_Registr_Pts = @F_Registr_Pts OR @F_Registr_Pts IS NULL)
			--AND fpde.N_Transf_Losses IS NULL	-- Поле не заполено должно быть
		ORDER by pd.F_Registr_Pts