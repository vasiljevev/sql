/*

update dbo.ED_Meter_Readings
set F_Readings_Status = 2
WHERE F_Division = 51
    and F_Mobile is not null
    and F_Delivery_Methods = 158
    and D_Date >= '20220701'
    and F_Subdivision = 100
	*/

select * from SD_Divisions where F_Division is not null
drop table #tbl_ED_Meter_Readings
------1
--заполнить временные таблицы с показаниями
SELECT emr.F_Division, emr.F_Devices, emr.LINK, ROW_NUMBER() over(order by emr.D_Date) as ID
INTO #tbl_ED_Meter_Readings
FROM dbo.ED_Meter_Readings emr
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
and ed.F_Division=emr.F_Division
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on edp.F_Registr_Pts=erp.LINK
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
WHERE emr.F_Division in (60,61)
and emr.F_Delivery_Methods in (18)
and (emr.D_Date>='20220901' and emr.D_Date<'20221001')
and emr.F_Readings_Status=0
--and emr.D_Date_Real is null
and ss.B_EE=0
--and emr.F_Mobile is not null
--and S_Create_Date>='20200830'
--углев
order by D_Date ASC
select MAX(ID) FROM #tbl_ED_Meter_Readings;  -- 98310
SELECT DISTINCT F_Division FROM #tbl_ED_Meter_Readings


DECLARE @i bigint, @i_max bigint;
SET @i = 1;
select @i_max = max(ID) FROM #tbl_ED_Meter_Readings;

WHILE (@i < @i_max + 10000)
BEGIN
	update TOP (10000) emr
	set emr.F_Readings_Status = 2
	FROM dbo.ED_Meter_Readings emr
		
		inner join #tbl_ED_Meter_Readings T
		on emr.link=t.LINK
		and t.F_Division=emr.F_Division
	WHERE T.ID >= @i AND T.ID < @i + 10000
	PRINT @i;
	SET @i = @i + 10000;
END;