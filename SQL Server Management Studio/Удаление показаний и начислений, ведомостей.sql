sp_WhoIsActive 
     @sort_order = '[database_name] desc,[start_time] desc',
	 @output_column_list= '[dd%][start_time][database_name][session_id][block%][program_name][sql_text][sql_command][login_name][wait_info][tasks][tran_log%][cpu%][temp%][reads%][writes%][context%][physical%][query_plan][locks][%]'--kill 161



select * from SD_Divisions where F_Division is not null
drop table #tbl_ED_Meter_Readings
------1
--заполнить временные таблицы с показаниями
SELECT F_Division, F_Devices, LINK, ROW_NUMBER() over(order by D_Date) as ID
INTO #tbl_ED_Meter_Readings
FROM dbo.ED_Meter_Readings
WHERE F_Division in (60,61)
and F_Delivery_Methods in (18)
and D_Date>='20220826'
--and S_Create_Date>='20200830'
--углев
order by D_Date ASC
select MAX(ID) FROM #tbl_ED_Meter_Readings;  -- 72936

SELECT DISTINCT F_Division FROM #tbl_ED_Meter_Readings


--удалить 
update emr
set emr.F_Readings_Status=2
--SELECT  emr.F_Division, count(1)
FROM dbo.ED_Meter_Readings emr
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
WHERE emr.F_Division in (40,41)
and emr.F_Delivery_Methods=158
and emr.D_Date>='20220502'
and emr.F_Mobile is not null
--and ss.B_EE=0
and emr.F_Readings_Status=0
group by emr.F_Division


----удалить начисления по показаниям временной таблицы
DECLARE @i bigint, @i_max bigint;
SET @i = 1;
select @i_max = max(ID) FROM #tbl_ED_Meter_Readings;

WHILE (@i < @i_max + 3000)
BEGIN
	DELETE TOP (3000) FROM fc
	FROM #tbl_ED_Meter_Readings T
		inner join pe.FD_Charge_Details fcd
		on fcd.F_Meter_Readings=t.LINK
		and t.F_Division=fcd.F_Division
		inner join PE.FD_Charges fc
		on fc.LINK=fcd.F_Charges
		and fc.F_Division=fcd.F_Division

	WHERE T.ID >= @i AND T.ID < @i + 3000
	PRINT @i;
	SET @i = @i + 3000;
END;


--удалить ведомости по показаниям временной таблицы
--DECLARE @i bigint, @i_max bigint;
SET @i = 1;
select @i_max = max(ID) FROM #tbl_ED_Meter_Readings;

WHILE (@i < @i_max + 3000)
BEGIN
	DELETE TOP (3000) FROM fc
	FROM #tbl_ED_Meter_Readings T
		inner join ee.FD_Paysheets_Details fcd
		on fcd.F_Meter_Readings=t.LINK
		and t.F_Division=fcd.F_Division
		inner join eE.FD_Paysheets fc
		on fc.LINK=fcd.F_Paysheets
		and fc.F_Division=fcd.F_Division

	WHERE T.ID >= @i AND T.ID < @i + 3000
	PRINT @i;
	SET @i = @i + 3000;
END;




--drop table #tbl_ED_Meter_Readings
--удалить показания по показаниям временной таблицы
--DECLARE @i bigint, @i_max bigint;
SET @i = 1;
select @i_max = max(ID) FROM #tbl_ED_Meter_Readings;

WHILE (@i < @i_max + 3000)
BEGIN
	DELETE TOP (3000) FROM MR
	FROM #tbl_ED_Meter_Readings T
		INNER JOIN dbo.ED_Meter_Readings MR
			ON MR.F_Division = T.F_Division
			AND MR.F_Devices = T.F_Devices
			AND MR.LINK = T.LINK
	WHERE T.ID >= @i AND T.ID < @i + 3000
	PRINT @i;
	SET @i = @i + 3000;
END



SELECT DISTINCT F_Division, N_period FROM #tbl_eE_FD_Paysheets
drop table #tbl_eE_FD_Paysheets

SELECT F_Division, LINK,N_period, ROW_NUMBER() over(order by D_Date) as ID
INTO #tbl_eE_FD_Paysheets
FROM eE.FD_Paysheets fc
WHERE fc.F_Division in (40,41)
and fc.LINK_Imp is not null
and fc.N_Period=202203
--and F_Delivery_Methods=18
--and D_Date>='20220401'
order by D_Date ASC

/*
--удалить ведомости по показаниям временной таблицы
DECLARE @i bigint, @i_max bigint;
SET @i = 1;
select @i_max = max(ID) FROM #tbl_eE_FD_Paysheets;

WHILE (@i < @i_max + 50000)
BEGIN
	DELETE TOP (50000) FROM fc
	FROM #tbl_eE_FD_Paysheets T
		inner join eE.FD_Paysheets fc
		on fc.LINK=t.LINK
		and fc.F_Division=t.F_Division

	WHERE T.ID >= @i AND T.ID < @i + 50000
	PRINT @i;
	SET @i = @i + 50000;
END

*/