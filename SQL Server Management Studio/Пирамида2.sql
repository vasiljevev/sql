select cuv.* from dbo.CS_UIVars cu 
inner join CS_UIVars_Values cuv
on cuv.F_UIVars=cu.LINK
where cu.C_Const in ('N_MKD_Readings_LastDayOfMonth','N_MKD_Readings_FirstDayOfMonth')


select * from dbo.SD_Divisions where F_Division is not null

select top 5 C_Serial_Number,string4,emr.D_Date from ED_Devices ed
inner join dbo.ED_Meter_Readings emr
on emr.F_devices=ed.link
where ed.F_Division=81
and ed.string4 is not null
and ed.B_PE=1
and ed.D_Replace_Date is null
and emr.F_Delivery_Methods=18
order by ed.LINK


select 
emr.F_Division,
count(1) 
from dbo.ED_Meter_Readings emr
where F_Delivery_Methods in (18)--(124,123)
and emr.S_Create_Date >='20220609'
and emr.F_Division=81
group by emr.F_Division


select 
emr.F_Division,
emr.D_Date,
--emr.S_Create_Date,
--cu.C_Name,
count(1) [кол-во показаний]
from dbo.ED_Meter_Readings emr
inner join dbo.CS_Users cu
on cu.LINK=emr.S_Creator
inner join ED_Devices ed on ed.LINK=emr.F_Devices
where 1=1
and F_Delivery_Methods in (18)--(124,123)
--and emr.S_Create_Date >='20220609'
and emr.D_Date>='20220301'
and emr.F_Division=81
and emr.F_Readings_Status<>2
and ed.B_EE=1
group by emr.F_Division,emr.D_Date
--,cu.C_Name
--,emr.S_Create_Date
order by emr.D_Date desc