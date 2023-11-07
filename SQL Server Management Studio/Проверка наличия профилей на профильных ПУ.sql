declare @N_Period int,
		@F_Division int
		
set @N_Period=202206
set @F_Division=51

SELECT DISTINCT
	 SS.N_Code					[ЛС]
	,SS.C_Number				[Альт.ЛС]
	,SA.C_Name					[ГТП]
	,ERP.N_Code					[Код УП]
	,ERP.C_Name					[Наименование УП]
	,ED.C_Serial_Number			[Номер ПУ]
	,EDT.C_Name					[Тип ПУ]
	,EDC.C_Name					[Кат.ПУ]
	,@N_Period				    [Период]
	,CASE  WHEN EMP.LINK IS NULL THEN 'Профиль не загружен'
		   WHEN EMP.N_Count= cp.N_Hours THEN 'Профиль полный'
		else 'Профиль не полный' END
								[Профиль]
	,EMP.N_Count				[Кол-во загруженных часов профиля]
	,cp.N_Hours					[Кол-во часов в периоде]
	,ED.string4					[Код интеграции	АСКУЭ]
	,CCDR.C_Name				[Ценовая категория OMNIUS]
	,sa.C_Name					[Наименование ГТП]
	--,t.[Наименование тарифа]	[Наименование тарифа СТЕК]
	--,t.[Ценовая категория]		[Ценовая категория СТЕК]
	,EEL.C_Name					[УН OmniUS]
	,CCDR1.C_Name				[Тарифная категория]
	FROM ED_Registr_Pts ERP
	INNER JOIN SD_Subscr SS
		ON  SS.LINK = ERP.F_Subscr
		AND SS.B_EE = 1
		AND SS.LINK > 0
		AND (SS.D_Date_End is null or SS.D_Date_End > getdate())
		AND ERP.F_Subscr > 0
		AND ERP.F_Sale_Category = 1
		AND (erp.D_Date_End is null or erp.D_Date_End > getdate())
	LEFT JOIN ED_Registr_Pts_Areas ERPA
		INNER JOIN SD_Areas SA
			ON  SA.LINK = ERPA.F_Areas
		ON  ERPA.F_Registr_Pts = ERP.LINK
	
	INNER JOIN ED_Devices_Pts EDP
		INNER JOIN ED_Devices ED
			ON  ED.LINK = EDP.F_Devices
			AND (ED.D_Replace_Date is null or ED.D_Replace_Date > getdate())
			
		INNER JOIN ES_Device_Types EDT
			ON  EDT.LINK = ED.F_Device_Types
		INNER JOIN ES_Device_Categories EDC
			ON  EDC.C_Const = 'EDC_Profile_Electro'		--Профильный счетчик (часы)
		ON  EDP.F_Registr_Pts = ERP.LINK
	INNER JOIN CS_Custom_Dictionary_Rows CCDR
		ON  CCDR.LINK = ERP.int16
	--	and CCDR.C_Name IN ('Четвертая', 'Шестая')
	LEFT JOIN ED_Meter_Profiles EMP
		ON  EMP.F_Devices = ED.LINK
		AND EMP.N_Period  = @N_Period
	LEFT join CS_Periods cp
	on cp.N_Period=@N_Period
	--left join [Sewer].[dbo].[TMP_PAYSHEETS] T
	--	on  t.F_Registr_PTS = erp.LINK
	LEFT JOIN ES_Energy_Levels EEL
		ON  EEL.LINK = ERP.F_Energy_Levels
	LEFT JOIN CS_Custom_Dictionary_Rows CCDR1
		ON  CCDR1.LINK = ERP.int14
WHERE 1=1
and SS.F_Division=@F_Division
order by EMP.N_Count desc
--and ss.C_Number='12100000369'
--and erp.N_Code='640'
--and EMP.LINK IS NULL
--and ERPA.LINK is null
--AND T.[Ценовая категория] IN( ' Четвертая ',' Шестая ')

--SELECT * FROM ES_Device_Categories
--SELECT DISTINCT T.[Ценовая категория] FROM [Sewer].[dbo].[TMP_PAYSHEETS] T


--select top 5 * from dbo.CS_Periods