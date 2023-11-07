киров 41
иваново 21
28-07-
5-07

select * from SD_Divisions



select sd.C_name, count(emr.link)
from dbo.ED_Meter_Readings emr
left join ee.FD_Paysheets_Details fpd
on fpd.F_Meter_Readings=emr.LINK
left join SD_Divisions sd
on sd.LINK=emr.F_Division
left join ED_Devices ed
on ed.LINK=emr.F_Devices
left join ED_Devices_Pts edp
on edp.F_Devices = ed.LINK
left join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
inner join CS_Users csu
on csu.LINK=emr.S_Creator
left join CS_Users csu2
on csu.LINK=emr.S_Owner
where 1=1
and emr.F_Mobile is not null
and fpd.link is null
and emr.D_Date>'20230101' and emr.D_Date<'20230701'
and emr.F_Division in (21,41)
and (emr.S_Create_Date>='20230728' and emr.S_Create_Date<'20230729')
and ss.B_EE=0
--and emr.F_Readings_Status<>11--<>2 and emr.F_Readings_Status<>11
group by sd.C_name
--and csu.C_Name='MR\Pushkin.AS'
--and ed.C_Serial_Number='38263787'
--and ed.B_PE=1





--﻿UPDATE emr
--SET F_Readings_Status = 11,
--	F_Readings_Status_Orig = 0,
--	C_Notes2 = 'Корректировка статусов задублированных пкз'
select ed.C_Serial_Number,emr.*
from dbo.ED_Meter_Readings AS emr
INNER JOIN 
(
	SELECT emr.F_Mobile, emr.N_Value, max (emr.D_Date) AS D_Date
	FROM dbo.ED_Meter_Readings emr
	WHERE F_Mobile IS NOT NULL
		--AND emr.F_Readings_Status = 0
		AND emr.F_Delivery_Methods = 158
		AND emr.D_Date >= '20230101'
		AND emr.F_Division = 81
	GROUP BY emr.F_Mobile, emr.N_Value
	HAVING COUNT(*) > 1
) AS mr
	ON emr.F_Mobile = mr.F_Mobile
	AND emr.N_Value = mr.N_Value
LEFT JOIN PE.FD_Charge_Details fcd
	ON fcd.F_Meter_Readings = emr.LINK
LEFT JOIN EE.FD_Paysheets_Details fpd
	ON fpd.F_Meter_Readings = emr.LINK

left join ED_Devices ed
	on ed.LINK=emr.F_Devices
WHERE 1=1
	AND fcd.LINK IS NULL
	AND fpd.LINK IS NULL
	AND DAY(emr.D_Date) <> 1
	AND emr.F_Readings_Status = 0
	AND DATEDIFF(day, emr.D_Date, mr.D_Date) < 31
	--AND emr.F_Devices = 35491801


--	select F_Mobile from ED_Meter_Readings where link = 3323640061

select * from es_state

--select * from SD_Divisions
update dbo.ED_Meter_Readings
set F_Readings_Status_Orig=F_Readings_Status,F_Readings_Status=11,C_Notes2='загрузка28-07-2023'
from dbo.ED_Meter_Readings emr
left join ee.FD_Paysheets_Details fpd
on fpd.F_Meter_Readings=emr.LINK
left join SD_Divisions sd
on sd.LINK=emr.F_Division
left join ED_Devices ed
on ed.LINK=emr.F_Devices
left join ED_Devices_Pts edp
on edp.F_Devices = ed.LINK
left join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
inner join CS_Users csu
on csu.LINK=emr.S_Creator
left join CS_Users csu2
on csu.LINK=emr.S_Owner
where 1=1
and emr.F_Mobile is not null
and fpd.link is null
and emr.D_Date>'20230101' and emr.D_Date<'20230701'
and emr.F_Division in (21,41)
and (emr.S_Create_Date>='20230728' and emr.S_Create_Date<'20230729')
and ss.B_EE=0
