select distinct 
ed.C_Serial_Number
,emr.F_Division
,emr.D_Date
,count(1) 
from ED_Meter_Readings emr
inner join ED_Meter_Readings emr2
on emr.D_Date=emr2.D_Date
and emr.F_Delivery_Methods=emr2.F_Delivery_Methods
and emr.F_Devices=emr2.F_Devices
and emr.F_division=emr2.F_Division
and emr.F_Readings_Status=emr2.F_Readings_Status
and emr.F_Time_Zones=emr2.F_Time_Zones
and emr.F_Energy_Types=emr2.F_Energy_Types
AND emr.LINK<>emr2.LINK
AND emr.D_Date_Real=emr2.D_Date_Real
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
and ed.F_Division=emr.F_Division
where 1=1
and emr.F_Readings_Status=0
and emr.F_Delivery_Methods=18
--and ed.F_Division=51
group by emr.F_Division,ed.C_Serial_Number,emr.D_Date,emr.F_Time_Zones,emr.F_Energy_Types
HAVING count(1)>1
order by emr.D_Date desc