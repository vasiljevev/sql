
SELECT ss.C_Number, ed.C_Serial_Number,emr.D_Date,  emr.F_Division--, count(1)
FROM dbo.ED_Meter_Readings emr
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
WHERE emr.F_Division in (50,51)
and emr.F_Delivery_Methods=18
and (emr.D_Date between '20220620' and '20220624')
and ss.B_EE=0
and emr.F_Readings_Status=0
order by emr.D_Date desc
--group by emr.F_Division

/*
update emr
set emr.F_Readings_Status=2
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
and emr.F_Delivery_Methods=18
and emr.D_Date='20220425'
and ss.B_EE=0
and emr.F_Readings_Status=0
--group by emr.F_Division
*/