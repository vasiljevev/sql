
/*
 --ДЛЯ ФЛ и ЮЛ
update emr
set 
F_Readings_Status_Orig = emr.F_Readings_Status,
F_Readings_Status = case when emr.F_Readings_Status = 0 then 4
							 when emr.F_Readings_Status = 4 then 0
						else emr.F_Readings_Status	
						end
,C_Notes = emr.C_Notes + '#Изменен статус в связи с перекрутом'
--select *
from ED_Meter_Readings emr
inner join #t t
	on t.LINK_MR = emr.LINK
where abs(t.N_CONS_TOTAL) > abs((t.N_Value-t.N_VALUE_PREV)*t.N_RATE)	

drop table #t
select * from #t where #t.C_Serial_Number='23896627'
 order by #t.ЛС

*/

--delete from pe.FD_Charges where N_Period = 202109
--select * from SD_Divisions

declare
	@F_Division		INT,
	@F_Subscr		INT				= NULL,
	@F_Registr_Pts	INT				= NULL,
	@D_Date0		SMALLDATETIME	= NULL,
	@D_Date1		SMALLDATETIME	= NULL,
	@N_Cons			INT					  ,
	@B_EE			BIT				= 1
--with recompile	

select 
	 @F_Division = 61
	,@F_Subscr = null --70970741,--28959321,
	,@D_Date0 = '20220302'--dateadd(YEAR,-14,GETDATE())
	,@D_Date1 = '20220501'--GETDATE()
	,@N_Cons = 5000
	,@B_EE = 1

IF @F_Division IS NULL
	AND @F_Subscr IS NULL
	AND @F_Registr_Pts IS NULL
	RETURN

DECLARE	@XS_Formula_PU		UNIQUEIDENTIFIER,
		@XS_Metering_Scheme	UNIQUEIDENTIFIER

SELECT
	@XS_Formula_PU = LINK
FROM dbo.CS_Custom_Fileld_Tables
WHERE C_System_Name = 'XS_Formula_PU'
SELECT
	@XS_Metering_Scheme = LINK
FROM dbo.CS_Custom_Fileld_Tables
WHERE C_System_Name = 'XS_Metering_Scheme'


DECLARE @B_Short_NetworkPath BIT
SET @B_Short_NetworkPath = 0

IF
	(
		SELECT TOP 1
			CUVV.C_Value
		FROM dbo.CS_UIVars CUV
			INNER JOIN dbo.CS_UIVars_Values CUVV
				ON CUVV.F_UIVars = CUV.LINK
				AND CUVV.F_Division = @F_Division
		WHERE CUV.C_Const = 'IsShort_NetworkPath'
	)
	= 'True'
	SET @B_Short_NetworkPath = 1

SELECT --top 100
	sd.C_Name [ПУЭС],
	ssd.C_Name [РЭС],
	s.b_ee [ФЛ=0, ЮЛ = 1],
	s.n_code [ЛС],
	MR_CR.LINK [LINK_MR],
	MR_CR.F_Division [DIVISION_MR],
	SD.C_Name [C_PUES],
	S.LINK																		AS F_SUBSCR,
	S.N_Code	[C_SUBSCR_CODE],
	RP.LINK																		AS F_REGISTR_PTS,
	MR_CR.F_Devices,
	MR_CR.F_Time_Zones,
	dbo.CF_Get_C_CodeName(TZ.N_Code, TZ.C_Name)									AS C_TIME_ZONES,
	dbo.CF_Get_C_CodeName(DM.N_Code, DM.C_Name)									AS C_DELIVERY_METHODS,
	MR_CR.D_Date ,
	MR_CR.D_Date_Real,		--	Реальная дата показания, заполянется для показаний импортируемых
	MR_CR.N_Value ,
	MR_CR.N_Cons ,
	MR_CR.C_Notes ,
	D.C_Serial_Number ,
	DT.C_Name																	AS C_DEVICE_TYPES,
	D.D_Setup_Date ,
	D.D_Replace_Date ,

	ISNULL(D.N_RATE, 1.0) * ISNULL(D_T.N_RATE, 1.0) * ISNULL(D_A.N_RATE, 1.0)	AS N_RATE,

	MR_PR.D_Date																AS D_PREV_DATE,
	MR_PR.N_Value																AS N_VALUE_PREV,
	DATEDIFF(day, MR_PR.D_Date, ISNULL(MR_CR.D_Date_TS, MR_CR.D_Date))			AS N_DAYS_TOTAL,
	--iif(DATEDIFF(day, MR_CR.D_Date_Prev, ISNULL(MR_CR.D_Date_TS, MR_CR.D_Date)) = MR_CR.S_Days, MR_CR.S_Days, MR_CR.S_Days-1) AS N_DAYS_TOTAL,

	CASE
		WHEN (MR_CR.N_Value IS NULL) AND (MR_CR.N_Cons IS NULL)
			THEN NULL
		ELSE CAST(
			ROUND( -- округляем потребление
			CASE
				WHEN RS.B_Reverse = 1
					THEN -- если "Реверс"
						ISNULL(
						CASE
							WHEN MR_CR.N_Value <= MR_PR.N_Value
								THEN MR_CR.N_Value - MR_PR.N_Value
							ELSE -1 * (CAST(POWER(10, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2))) AS DECIMAL(19, 6)) + MR_PR.N_Value - MR_CR.N_Value)
						END, 0.0)
				WHEN RS.B_Reverse_Zero = 1	THEN
						dbo.MF_Max(ISNULL(
						CASE
							WHEN MR_CR.N_Value <= MR_PR.N_Value
								THEN MR_CR.N_Value - MR_PR.N_Value
							ELSE -1 * (CAST(POWER(10, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2))) AS DECIMAL(19, 6)) + MR_PR.N_Value - MR_CR.N_Value)
						END, 0.0),0.0)
				WHEN RS.B_Reset = 1
					THEN 0 -- если "Сброс"
				ELSE (ISNULL(MR_CR.N_Value - MR_PR.N_Value, 0.0) * POWER(10.000000,
					(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2) * 10.0) % 10.0) + POWER(10.000000, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)) + ((COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2) * 10.0) % 10.0)))
					% POWER(10.000000, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)) + ((COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2) * 10.0) % 10.0)) * POWER(10.0000000000, -(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)
					* 10.0) % 10.0)
			END
			* ISNULL(D.N_RATE, 1.0) * ISNULL(D_T.N_RATE, 1.0) * ISNULL(D_A.N_RATE, 1.0), ISNULL(SI.N_PRECISION, 0)
			)
			+
			ROUND(ISNULL(MR_CR.N_Cons, 0), ISNULL(SI.N_PRECISION, 0)) * (1.0 - ISNULL(CD.N_Value,0.0))  -- округляем потери
			AS DECIMAL(29, 6))
	END																			AS N_CONS_TOTAL,

	COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)								AS N_DIGITS,
	ET.C_Short_Name																AS C_ENERGY_TYPES,
	--NP.F_Conn_Points,
	CP.C_Address + ISNULL(' - ' + S.N_Premise_Number, '')						AS C_CONN_POINTS_ADDRESS,
	dbo.CF_Get_C_CodeName(CP.N_Code, CP.C_Name)									AS C_CONN_POINTS,
	dbo.CF_Get_C_CodeName(RP.N_Code, RP.C_Name)									AS C_REGISTR_PTS,

	MR_CR.F_Readings_Status,
	dbo.CF_Get_C_CodeName(rs.N_Code, rs.C_Name)									AS _BOUND_F_READINGS_STATUS,
	EDCT.B_Control_Check
	--'' end_column
	--,CAST(POWER(10, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2))) AS DECIMAL(19, 6)) + MR_PR.N_Value - MR_CR.N_Value
into #t
FROM dbo.SD_Subscr AS S
	INNER JOIN SD_Divisions SD
		ON  SD.LINK = S.F_Division
		AND (SD.F_Division = @F_Division OR SD.LINK = @F_Division)
	left join SD_Subdivisions ssd
		on  ssd.LINK = s.F_SubDivision
	INNER JOIN dbo.ED_Registr_Pts AS RP
		ON RP.F_SUBSCR = S.LINK
		AND RP.F_Division = S.F_Division
		AND S.B_EE = @B_EE
		AND S.LINK > 0

	INNER JOIN dbo.FS_Sale_Items AS SI
		ON SI.LINK = RP.F_Sale_Items
	INNER JOIN ED_Network_Pts NP
		ON NP.LINK = RP.F_Network_Pts

	INNER JOIN dbo.ED_Devices_Pts AS DP
		ON DP.F_REGISTR_PTS = RP.LINK

	INNER JOIN dbo.ED_Devices AS D
		ON D.LINK = DP.F_Devices
	INNER JOIN dbo.ES_Device_Types AS DT
		ON DT.LINK = D.F_Device_Types

	INNER JOIN dbo.ED_Meter_Readings AS MR_CR
		ON	MR_CR.F_Devices		= D.LINK
		AND MR_CR.F_Division	= D.F_Division
		AND (	MR_CR.F_Energy_Types = DP.F_Energy_Types
			OR	MR_CR.F_Energy_Types IS NULL)
		AND (	RP.D_Date_End_Round >= MR_CR.D_Date
			OR	RP.D_Date_End_Round IS NULL)
		AND (	MR_CR.D_Date_BL		>= @D_Date0
			OR	@D_Date0			IS NULL)
		AND (	MR_CR.D_Date_BL		<= @D_Date1
			OR	@D_Date1			IS NULL)

	INNER JOIN dbo.ES_Readings_Status RS
		ON RS.LINK = MR_CR.F_Readings_Status
	INNER JOIN dbo.FS_Time_Zones AS TZ
		ON TZ.LINK = MR_CR.F_Time_Zones
	INNER JOIN dbo.ES_Delivery_Methods AS DM
		ON DM.LINK = MR_CR.F_Delivery_Methods
	INNER JOIN dbo.ES_Device_Check_Types EDCT
		ON EDCT.LINK = DM.F_Device_Check_Types
	INNER JOIN dbo.ES_Energy_Types AS ET
		ON ET.LINK = MR_CR.F_Energy_Types

	LEFT JOIN dbo.SD_Conn_Points AS CP
		ON CP.LINK = NP.F_Conn_Points

	LEFT JOIN dbo.EV_Devices_Meter_Measures MM
		ON MM.F_Devices = MR_CR.F_Devices
		AND MM.F_Division = MR_CR.F_Division
		AND MM.F_Energy_Types = MR_CR.F_Energy_Types
		AND MM.F_Time_Zones = MR_CR.F_Time_Zones


	LEFT JOIN dbo.ED_Meter_Readings AS MR_PR -- предыдущее показание
		ON MR_PR.F_Division = MR_CR.F_Division
		AND MR_PR.F_Devices = MR_CR.F_Devices
		AND MR_PR.F_Energy_Types = MR_CR.F_Energy_Types
		AND MR_PR.F_Time_Zones = MR_CR.F_Time_Zones
		-- Элегантно и супер быстро, больше никаких TOP 1 
		AND MR_PR.LINK = MR_CR.MR_LINK_Prev

		--	Трансформатор тока, актуальный на дату показания
	OUTER APPLY dbo.EF_Get_Device_Transf (D.F_Division, D.LINK, MR_CR.D_Date, 0) AS D_T

	--	Трансформатор напряжения, актуальный на дату показания
	OUTER APPLY dbo.EF_Get_Device_Transf (D.F_Division, D.LINK, MR_CR.D_Date, 1) AS D_A
	CROSS APPLY dbo.CF_Get_Calc_Defaults(MR_CR.F_Division, MR_CR.F_SubDivision, 'B_Disable_Calc_DA_N_Cons_EMR', NULL, 0) AS CD
WHERE 1=1
	AND (S.LINK = @F_Subscr OR @F_Subscr IS NULL)
	AND ((RP.LINK = @F_Registr_Pts
		AND @F_Registr_Pts IS NOT NULL)
		OR @F_Registr_Pts IS NULL)
	--AND S.N_Code = 501440019552
	--and MR_CR.LINK = 1254313421
----
AND ABS(
	CASE
		WHEN (MR_CR.N_Value IS NULL) AND (MR_CR.N_Cons IS NULL)
			THEN NULL
		ELSE CAST(
			ROUND( -- округляем потребление
			CASE
				WHEN RS.B_Reverse = 1
					THEN -- если "Реверс"
						ISNULL(
						CASE
							WHEN MR_CR.N_Value <= MR_PR.N_Value
								THEN MR_CR.N_Value - MR_PR.N_Value
							ELSE -1 * (CAST(POWER(10, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2))) AS DECIMAL(19, 6)) + MR_PR.N_Value - MR_CR.N_Value)
						END, 0.0)
				WHEN RS.B_Reverse_Zero = 1	THEN
						dbo.MF_Max(ISNULL(
						CASE
							WHEN MR_CR.N_Value <= MR_PR.N_Value
								THEN MR_CR.N_Value - MR_PR.N_Value
							ELSE -1 * (CAST(POWER(10, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2))) AS DECIMAL(19, 6)) + MR_PR.N_Value - MR_CR.N_Value)
						END, 0.0),0.0)
				WHEN RS.B_Reset = 1
					THEN 0 -- если "Сброс"
				ELSE (ISNULL(MR_CR.N_Value - MR_PR.N_Value, 0.0) * POWER(10.000000,
					(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2) * 10.0) % 10.0) + POWER(10.000000, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)) + ((COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2) * 10.0) % 10.0)))
					% POWER(10.000000, FLOOR(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)) + ((COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2) * 10.0) % 10.0)) * POWER(10.0000000000, -(COALESCE(MM.N_DIGITS, MM.N_Type_Digits, 5.2)
					* 10.0) % 10.0)
			END
			* ISNULL(D.N_RATE, 1.0) * ISNULL(D_T.N_RATE, 1.0) * ISNULL(D_A.N_RATE, 1.0), ISNULL(SI.N_PRECISION, 0)
			)
			+
			ROUND(ISNULL(MR_CR.N_Cons, 0), ISNULL(SI.N_PRECISION, 0)) * (1.0 - ISNULL(CD.N_Value,0.0))  -- округляем потери
			AS DECIMAL(29, 6))
	END		
	)		
		>= @N_Cons
--ВЫВОЖУ ЕСЛИ РЕВЕРС, ТО ПРЕДЫДУЩЕЕ ПОКАЗАНИЕ МЕНЬШЕ ТЕКУЩЕГО ИЛИ ДОСТ ГДЕ ПРЕДЫДУЩЕЕ ПОКАЗАНИЕ МЕНЬШЕ ТЕКУЩЕГО
AND ((MR_CR.N_Value < MR_PR.N_Value AND MR_CR.F_Readings_Status = 0)
		OR
	 (MR_CR.N_Value > MR_PR.N_Value AND MR_CR.F_Readings_Status = 4)
	 )

		
select *
,N_Value [Текущее показание]
,N_VALUE_PREV [Предыдущее показание]
,t.N_CONS_TOTAL [расход до реверса]
,(t.N_Value-t.N_VALUE_PREV)*N_RATE [расход после реверса]
 from #t t
 where abs(t.N_CONS_TOTAL) > abs((t.N_Value-t.N_VALUE_PREV)*N_RATE)	

 

---------------------------------------------
/*
----------------------ДЛЯ ЮЛ---------------
  --АСКУЭ,  ВЫЗЫВАЮЩИЕ ПЕРЕКРУТ В НЕДОСТ
   UPDATE EMR
SET F_Readings_Status = 2,
	C_Notes = 'Вызывает аномальный расход'
--SELECT EMR.*
	FROM ED_Meter_Readings EMR
	INNER JOIN ED_Devices_Pts EDP
		ON  EMR.F_Devices = EDP.F_Devices
		AND EMR.F_Division = 31 BETWEEN 5 AND 10
	INNER JOIN ED_Registr_Pts ERP
		ON  ERP.LINK = EDP.F_Registr_Pts
		AND ERP.F_Sale_Category = 1 -- FL
		AND EMR.F_Readings_Status <> 2
		AND EMR.F_Delivery_Methods = 18  -- ASCUE
		AND EMR.D_Date BETWEEN '20190702' AND '20190801'	
	inner join #t t
		on  emr.LINK = t.LINK_MR
		and t.C_DELIVERY_METHODS = '[5] АСКУЭ'		
		and cast(emr.S_Create_Date as date) = '20190805'
		and abs(t.N_CONS_TOTAL) > abs((t.N_Value-t.N_VALUE_PREV)*N_RATE)	

		--ОСТАЛЬНЫЕ ПОКАЗАНИЯ ВЕРНУТЬ СТАТУС
  UPDATE EMR1
SET F_Readings_Status = EMR1.F_Readings_Status_Orig,
	C_Notes = null
--SELECT EMR1.*
	FROM ED_Meter_Readings EMR
	INNER JOIN ED_Devices_Pts EDP
		ON  EMR.F_Devices = EDP.F_Devices
		AND EMR.F_Division BETWEEN 5 AND 10
	INNER JOIN ED_Registr_Pts ERP
		ON  ERP.LINK = EDP.F_Registr_Pts
		AND ERP.F_Sale_Category = 1 -- FL
		AND EMR.F_Readings_Status <> 2
		AND EMR.F_Delivery_Methods = 18  -- ASCUE
		AND EMR.D_Date BETWEEN '20190702' AND '20190801'
	INNER JOIN ED_Meter_Readings EMR1
		ON  EMR1.F_Division = EMR.F_Division
		AND EMR1.F_Devices = EMR.F_Devices
		AND EMR1.F_Energy_Types = EMR.F_Energy_Types
		AND EMR1.F_Time_Zones = EMR.F_Time_Zones
		AND EMR1.D_Date BETWEEN '20190702' AND '20190801'
		AND EMR1.F_Delivery_Methods NOT IN (15,18,44)
		AND EMR1.LINK <> EMR.LINK
		AND EMR1.F_Readings_Status = 2
	inner join #t t
		on  emr.LINK = t.LINK_MR
		and t.C_DELIVERY_METHODS = '[5] АСКУЭ'
		and emr1.C_Notes = 'Приоритет на показание с АСКУЭ'
		and cast(emr1.S_Modif_Date as date) = '20190805'
		and abs(t.N_CONS_TOTAL) > abs((t.N_Value-t.N_VALUE_PREV)*N_RATE)	
		drop table #t
		*/
--ORDER BY DIVISION_MR, C_SUBSCR_CODE, D_Date desc