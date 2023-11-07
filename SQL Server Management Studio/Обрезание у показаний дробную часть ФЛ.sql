
--select * from SD_Divisions where N_Code = 9000


/* 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!Запускаем именно в транзакции, так как отключаются триггеры!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*/
set xact_abort on
begin transaction

declare @f_div int = 51,
		@d_date smalldatetime = '20220601', --Дата, после которой берем в работу показания
		@F_Delivery_Methods int = null, ---Либо по всем источникам либо по конкретному	--select * from ES_Delivery_Methods
		@b_ee bit = null --Или все или по каким-то. Если ЮЛ, то и техучет тоже


alter table dbo.ED_Meter_Readings disable trigger all
--SELECT EMR.N_Value, ROUND(EMR.N_Value, 0, 1), EMR.LINK, EMR.D_Date
UPDATE EMR SET N_Value = ROUND(EMR.N_Value, 0, 1)
	FROM dbo.SD_Subscr AS S
	INNER JOIN dbo.ED_Registr_Pts AS RP
		ON RP.F_SUBSCR = S.LINK
		AND RP.F_Division = S.F_Division
		AND (S.B_EE = @b_ee or @B_EE is null)
		--AND S.LINK > 0				---отсекаем техучет!
		AND S.F_Division = @f_div--2

	INNER JOIN dbo.ED_Devices_Pts AS DP
		ON DP.F_REGISTR_PTS = RP.LINK
		AND DP.F_Division = RP.F_Division

	INNER JOIN dbo.ED_Devices AS D
		ON D.LINK = DP.F_Devices
		AND D.F_Division = DP.F_Device_Division

	OUTER APPLY dbo.EF_Get_Device_Transf (D.F_Division, D.LINK,dateadd(month,1, @d_date), 0) AS D_T

	OUTER APPLY dbo.EF_Get_Device_Transf (D.F_Division, D.LINK, dateadd(month,1, @d_date), 1) AS D_A

	INNER JOIN ED_Meter_Readings EMR
		ON  EMR.F_Devices = D.LINK
		AND EMR.F_Division = D.F_Division
		AND EMR.D_Date > @d_date--'20220401'
		
	INNER JOIN ES_Readings_Status ERS
		ON  ERS.LINK = EMR.F_Readings_Status
		AND ERS.B_InfoOnly = 0


WHERE 1=1
AND ISNULL(D.N_RATE, 1.0) * ISNULL(D_T.N_RATE, 1.0) * ISNULL(D_A.N_RATE, 1.0)=1 
AND EMR.N_Value <> ROUND(EMR.N_Value, 0, 1)
and (emr.F_Delivery_Methods = @F_Delivery_Methods or @F_Delivery_Methods is null)
alter table dbo.ED_Meter_Readings enable trigger all
commit

