	IF OBJECT_ID ('tempdb.dbo.#T_Meter_Profiles') IS NOT NULL DROP TABLE #T_Meter_Profiles
	GO 

	DROP TABLE Tmp.Tmp_S_Alimov_202203171423

	DECLARE 
		@F_Devices INT

	-- Вставить ид-р ПУ после =, если нужна выгрузка по всем ПУ вставить значение: NULL
	SET @F_Devices = NULL

	DECLARE @N_Period INT

	-- Вставить период
	SET @N_Period = 202202

	SELECT
		emp.F_Division, 
		emp.F_SubDivision, 
		emp.F_Devices, 
		ed.C_Serial_Number,
		emp.F_Energy_Types, 
		eet.C_Short_Name,
		emp.N_Quantity, 
		emp.D_Date_Begin, 
		emp.D_Date_End, 
		
		CASE 
			WHEN edc.F_Granularity = 2 THEN DATEADD(dd, euv.Id, emp.D_Date_Begin) -- SELECT * FROM ES_Granularity
			ELSE DATEADD(minute, euv.Id * (30 * (~emp.B_Half_Hours + 1)), emp.D_Date_Begin)
		END						
		
						AS D_Date,

		euv.Value1		AS N_Value, 
		emp.N_Cons, 
		emp.N_Param15,
		emp.F_Delivery_Methods
	INTO #T_Meter_Profiles
	FROM dbo.ED_Devices ed
		INNER JOIN dbo.ES_Device_Types AS edt -- SELECT * FROM dbo.ES_Device_Types 
			ON	edt.LINK		= ed.F_Device_Types
		INNER JOIN dbo.ES_Device_Categories AS edc -- SELECT * FROM dbo.ES_Device_Categories
			ON	edc.LINK		= edt.F_Device_Categories
			AND edc.C_Const = 'EDC_Profile_Electro'
		INNER JOIN dbo.ED_Meter_Profiles emp -- SELECT * FROM dbo.ED_Meter_Profiles
			ON emp.F_Devices	= ed.LINK
			AND emp.F_Division	= ed.F_Division
			AND emp.N_Period	= @N_Period
		INNER JOIN dbo.ES_Energy_Types eet
			ON eet.LINK = emp.F_Energy_Types
			AND eet.C_Const = 'SET_Active_Energy_Out'
		CROSS APPLY dbo.EF_UnpackValues
			(	
				emp.N_Cons, emp.N_Cons2, emp.N_Param1, emp.N_Param2, emp.N_Param3, emp.N_Param4, emp.N_Param5, emp.N_Param6, emp.N_Param7,
				emp.N_Param8, emp.N_Param9, emp.N_Param10, emp.N_Param11, emp.N_Param12, emp.N_Param13, emp.N_Param14, emp.N_Param15
			) AS euv
	WHERE	1=1
		AND (
				ed.LINK = @F_Devices
			OR 
				@F_Devices IS NULL
			)

	-- Выгрузка осуществляется только по АЭ-
	SELECT 
		erp.N_Code												AS [Платежный код], 
		CONCAT(C_Name1, ' ' + C_Name2, ' ' + C_Name3)			AS [Наименование лицевого счета], 
		CAST(edp.F_Devices AS VARCHAR(12))						AS [Ид-р ПУ в Omni-US], 
		tmp.C_Serial_Number										AS [№ ПУ],
		tmp.C_Short_Name										AS [Шкала],
		CAST(YEAR(tmp.D_Date)	AS VARCHAR(4))					AS [Год],
		CAST(MONTH(tmp.D_Date)	AS VARCHAR(2))					AS [Месяц],
		CAST(DAY(tmp.D_Date)	AS VARCHAR(2))					AS [День],
		CAST(DATEPART(hh, tmp.D_Date) + 1	AS VARCHAR(2))		AS [Час],
		CAST(tmp.N_Value					AS VARCHAR(50))		AS [Значение, кВт*ч]
	INTO Tmp.Tmp_S_Alimov_202203171423
	FROM dbo.CD_Partners cp
		INNER JOIN dbo.SD_Subscr ss
			ON ss.F_Partners = cp.LINK
		INNER JOIN dbo.ED_Registr_Pts erp
			ON erp.F_Subscr = ss.LINK
		INNER JOIN dbo.ED_Devices_Pts edp
			ON edp.F_Registr_Pts = erp.LINK 
			AND edp.B_Main = 1
		INNER JOIN #T_Meter_Profiles tmp
			ON tmp.F_Devices = edp.F_Devices
	--ORDER BY edp.F_Devices, YEAR(tmp.D_Date)DESC, MONTH(tmp.D_Date) DESC, DAY(tmp.D_Date), DATEPART(hh, tmp.D_Date)

	SELECT *
	FROM 
		(
			SELECT 
				'Платежный код'					AS [Платежный код], 
				'Наименование лицевого счета'	AS [Наименование лицевого счета], 
				'Ид-р ПУ в Omni-US'				AS [Ид-р ПУ в Omni-US], 
				'№ ПУ'							AS [№ ПУ],
				'Шкала'							AS [Шкала],
				'Год'							AS [Год],
				'Месяц'							AS [Месяц],
				'День'							AS [День],
				'Час'							AS [Час],
				'Значение, кВт*ч'				   [Значение, кВт*ч]
		
			UNION ALL

			SELECT
				[Платежный код], 
				[Наименование лицевого счета], 
				[Ид-р ПУ в Omni-US], 
				[№ ПУ],
				[Шкала],
				[Год],
				[Месяц],
				[День],
				[Час],
				[Значение, кВт*ч]
			FROM Tmp.Tmp_S_Alimov_202203171423
		) AS pz
	ORDER BY 
		CASE WHEN [Платежный код] = 'Платежный код' THEN 1 ELSE 2 END, [Ид-р ПУ в Omni-US], [Год] DESC, [Месяц] DESC, [День], [Час]