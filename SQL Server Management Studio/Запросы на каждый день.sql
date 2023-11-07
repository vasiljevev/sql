--delete from dbo.ED_Meter_Readings
--where 1=1
--and F_Delivery_Methods=36
--and D_Date > '20220101'

--select * from es_Delivery_Methods

select * from SD_Divisions where F_Division is not null



select * from PE.FD_Charges  where N_Period=202111 and link = 189824201
select * from PE.FD_Charge_Details where F_Charges=189824201

--delete from PE.FD_Charges 
--where N_Period in (202201,202202)

delete from ee.FD_Paysheets
where F_Division in (60,61)
and LINK_Imp is not null
--where N_Period in (202201,202202)

select ss.C_Number, ddd.C_Number, dda.* from DD_Attachments dda
inner join DD_Docs ddd
on dda.F_Docs=ddd.LINK
inner join DS_Docum_Types ddt
on ddt.link=ddd.F_Docum_Types
inner join SD_Subscr ss
on ss.link=ddd.F_Subscr

where 1=1
and ddt.LINK=37
and (dda.D_Date>='20220101' and dda.D_Date<='20220131')
and ss.B_EE=1
--delete from  dbo.ED_Network_Balance where N_Period=202109

select * from Tmp.PE_Subscr_Active_Sessions
--delete from Tmp.PE_Subscr_Active_Sessions where Session= Номер сессии

select * from all_object_20211102
EXEC sp_WhoIsActive
--kill 110

select * FROM dbo.CS_Naturals cn

select * from ES_Balance_Type_Details
SELECT count(*) FROM IE.CD_Events_TMP

SELECT * FROM dbo.FS_Status


delete from ED_Meter_Profiles
where N_Period=202112


--select * from tmp.Tmp_Copy_20210728_Load_UL_20210531 where OC_Max_Cap not in ('0')

--UPDATE dbo.ED_Meter_Readings
--   SET f_readings_status = 0
--   where edm.f_readings_status = 2


--TRUNCATE TABLE ED_Meter_Profiles
--where link=1212221

select top 10
emp.LINK,
ed.C_Serial_Number,
ed.string4,
et.C_Name,
emp.N_period,
emp.N_count,
emp.N_Cons,
emp.N_Quantity,
emp.F_Delivery_Methods,
ed.N_Rate
FROM ED_Devices ed
left join eD_Meter_Profiles emp
on emp.F_Devices=ed.LINK
left join ES_Energy_Types et
on et.link=emp.F_Energy_Types
where 1=1
--emp.D_Date_Begin >= '20210901'
and emp.N_Period=202201
and emp.F_Delivery_Methods=18
and emp.N_Count>700
and ed.N_Rate>1
and ed.C_Serial_Number like '%01111225%'

--select * from ES_Energy_Types



select distinct top 10
sd.C_Name,
sd.LINK,
ss.N_Code,
ss.C_Code,
erp.N_Code,
ed.LINK,
ed.C_serial_number,
ed.string4,
emp.N_count,
emp.*
from ED_Meter_Profiles emp
inner join ED_Devices ed
on ed.LINK=emp.F_Devices
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on edp.F_Registr_Pts=erp.LINK
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
inner join SD_Divisions sd
on sd.LINK=ss.F_Division
where 1=1
--and emp.N_Period=202201
--and ed.C_serial_number='1135936'
and ss.B_EE=1
and ss.LINK>0
--and erp.int3 is not null --принадлежность к мкд
and (edp.d_date_end is null or edp.d_date_end > GETDATE())
and (emp.N_Count<500)
and emp.N_Quantity <>0
and emp.F_Delivery_Methods=18
--and ed.C_serial_number='0102908088000714'
and ed.string4 is not null
and sd.LINK=21
order by emp.N_Period desc,ed.LINK desc


select
ed.C_serial_number,
erp.N_code,
emp.*
from ED_Meter_Profiles emp
inner join ED_Devices ed
on ed.LINK=emp.F_Devices
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts

where emp.N_Period=202201
--and emp.F_Delivery_Methods=18
--ed.C_serial_number='1135936'
order by emp.F_Devices, emp.D_Date_End


--DELETE FROM PE.FD_Charges
--DELETE FROM ee.FD_Paysheets

----CREATE TABLE tmp.ED_Meter_Readings_Copy_20210208

select 
ss.C_Code
,erp.N_Code
,ed.C_Serial_Number
,emr.D_Date
,emr.N_Value
,emr.F_Delivery_Methods
from dbo.ED_Meter_Readings emr 
left join ED_Devices ed
on ed.LINK=emr.F_Devices
left join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
left join ED_Registr_Pts ERP
on erp.LINK=edp.F_Registr_Pts
left join SD_Subscr ss
on ss.LINK=erp.F_Subscr
where 
1=1
and ss.B_EE=1
and emr.F_Readings_Status=0
--and emr.F_Delivery_Methods=36
--and ERP.int3 is not null
--and ed.C_Serial_Number='0753571108859203'
--and cast(emr.S_Create_Date as date) = '20220125'
and emr.D_Date >= '20220126'
--and
--emr.D_Date < '20211002'
order by emr.D_Date


--SELECT * INTO tmp.ED_Meter_Readings_Copy_20210308 FROM старая_таблица WHERE 1=0

--DELETE from dbo.ED_Meter_Readings where F_Delivery_Methods=18

--DROP TABLE tmp.ED_Meter_Readings_Copy_20210308


--select count(edm.link) from ED_Meter_Readings edm where edm.F_Delivery_Methods=18
----left join dbo.ED_Devices edd
----on 


--select count (edd.LINK)
--from tmp.ED_Meter_Readings_Copy_20210208_2 edm
--left join dbo.ED_Devices edd
--on edm.f_devices=edd.link
----left join dbo.
--where edm.F_Delivery_Methods=36

--select count (distinct edd.LINK)
--from dbo.ED_Devices edd
--inner join dbo.ED_Meter_Readings edm
--on edd.link=edm.f_devices
----left join dbo.
--where edm.F_Delivery_Methods=18

select enr.C_Name,eni.C_Name from ED_Network_Ring enr
inner join ED_Network_Items_Rings enir
on enir.F_Network_Ring=enr.LINK
inner join ED_Network_Items eni
on eni.LINK=enir.F_Network_Items


--ALTER TABLE ED_Meter_Readings DISABLE TRIGGER ALL
--DELETE ED_Meter_Readings
--select * 
--into dbo.ED_Meter_Readings
--from tmp.ED_Meter_Readings_Copy_20210308

--INSERT INTO dbo.ED_Meter_Readings SELECT * FROM tmp.ED_Meter_Readings_Copy_20210308
--ALTER TABLE ED_Meter_Readings ENABLE TRIGGER ALL

--SELECT *  FROM dbo.DS_Contract_Status WHERE  C_Const = 'DCS_DisconectCancel';

--ALTER TABLE ED_Meter_Readings DISABLE TRIGGER ALL
--DELETE ED_Meter_Readings
--ALTER TABLE ED_Meter_Readings ENABLE TRIGGER ALL


--select * from ED_Meter_Readings

select --top 10
edd.C_Serial_Number
,est.C_Name
,edd.string4
--,edd.F_Device_Types
,emr.N_Value
,emr.D_Date
,emr.S_Create_Date
,emr1.N_Value 
,emr1.D_Date
,emr1.S_Create_Date
 

 

from dbo.ED_Meter_Readings emr
inner join ED_Devices edd
    on  edd.LINK=emr.F_Devices
inner join ES_Device_Types est
    on  edd.F_Device_Types=est.LINK
inner join ED_Meter_Readings emr1
    on  emr1.F_Division = emr.F_Division
    and emr1.F_Devices = emr.F_Devices
    and emr1.F_Energy_Types = emr.F_Energy_Types
    and emr1.F_Time_Zones = emr.F_Time_Zones
    and emr1.D_Date = emr.D_Date
    --and emr1.F_Delivery_Methods = 18

where
emr.F_Readings_Status<>emr.F_Readings_Status_Orig
and
emr.F_Delivery_Methods=36

 

--select * from ES_Delivery_Methods   --18
---- удалить начисления по ФЛ
--DELETE FROM PE.FD_Charges where N_Period=202107
---- удалить все показания АСКУЭ
--DELETE FROM ED_Meter_Profiles
--DELETE from dbo.ED_Meter_Readings where F_Delivery_Methods=36 and D_Date>'20210801'
----восстановить статусы первоначальные
--UPDATE ED_Meter_Readings
--SET    ED_Meter_Readings.F_Readings_Status = ED_Meter_Readings.F_Readings_Status_Orig
--where ED_Meter_Readings.F_Readings_Status_Orig is not null

select distinct
edd.C_Serial_Number
,emr.D_Date
,emr.N_Value
,emr.F_Readings_Status
,edm.C_Name
,cu.C_Name
,cu1.C_Name
,emr.*
from ED_Devices edd
inner join dbo.ED_Meter_Readings emr
on edd.LINK=emr.F_Devices
inner join dbo.CS_Users cu
on cu.LINK=emr.S_Creator
inner join dbo.CS_Users cu1
on cu1.LINK=emr.S_Owner
inner join ED_Devices_Pts edp
on edp.F_Devices=edd.LINK
inner join ED_Registr_Pts erp
on edp.F_Registr_Pts=erp.LINK
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
inner join ES_Delivery_Methods edm
on edm.LINK=emr.F_Delivery_Methods
where
1=1
and ss.B_EE=1
--and edm.C_Name='Контрольное показание'
--and emr.F_Readings_Status=2
--and edd.C_Serial_Number='34773039'
--and ss.LINK=1972861
--and (emr.S_Modif_Date >= '20220125' or emr.S_Create_Date >= '20220125')
--and (cu.C_Name='YANTARENERGO\Tropnikova-II' or cu1.C_Name='YANTARENERGO\Tropnikova-II')
--and (emr.D_Date >= '20211226' and emr.D_Date <= '20211231')
order by emr.D_Date desc



select ss.B_EE, erpd.* from ED_Registr_Pts_Disagreements erpd
inner join ED_Registr_Pts erp
on erpd.F_Registr_Pts=erp.LINK
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr

 where 1=1
 and erpd.N_Period=202112
 and ss.B_EE=0


 update ED_Devices
 set int1 = null 
 --select int1,string4 from ED_Devices
 where 1=1
 and int1 is not null
 and string4 is null


 	SELECT
	cu.C_Name S_Creator,
	cu2.C_Name S_Deleted_Creator,
	cu3.C_Name S_Deleted_Owner,
		emrd.*
	FROM  dbo.ED_Meter_Readings_Deleted AS emrd
	inner join dbo.ED_Devices ed
	on ed.LINK=emrd.F_Devices
	left join dbo.CS_Users cu
	on emrd.S_Creator=cu.LINK
	left join dbo.CS_Users cu2
	on emrd.S_Deleted_Creator=cu.LINK
	left join dbo.CS_Users cu3
	on emrd.S_Deleted_Owner=cu.LINK
	where 1=1
	and ed.
	order by emrd.D_Date desc


	select ed.C_Serial_Number,ed.B_EE,dd.* from DD_Attachments dda
	inner join DD_Docs dd
	on dd.link=DDA.F_Docs
	INNER JOIN DS_Docum_Types DDT --select * from DS_Docum_Types DDT where DDT.LINK in (63,64,65,141)
	on ddt.link=dd.F_Docum_Types
	inner join ED_Device_Checks edc
	on edc.F_Docs=dd.LINK
	inner join ED_Devices ed
	on ed.LINK=edc.F_Devices
	where DDT.LINK in (63,64,65,141)
	and dd.S_Create_Date>='20220101'
	and ed.B_EE=1