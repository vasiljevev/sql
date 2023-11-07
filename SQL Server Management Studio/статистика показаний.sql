--2	     1	2	NULL	1	NULL	5AE88A85-50A2-445F-8A89-A2D545B560ED	Владимирэнерго (ф)
--21	20	2	NULL	1	NULL	88EC6364-151F-4174-ABB2-222BC52C015A	Ивэнерго (ф)
--31	30	2	NULL	1	NULL	A3A68627-5801-41AA-9DC6-40559E7C53E7	Калугаэнерго (ф)
--41	40	2	NULL	1	NULL	0E1C8E1C-3C7A-47C4-86C1-649D61F47472	Кировэнерго (ф)
--51	50	2	NULL	1	NULL	D6677B99-8415-40E3-A9C4-FCB641BB0564	Мариэнерго (ф)
--61	60	2	NULL	1	NULL	49B1D2E2-F28A-417A-ADC9-D6B7B6F63809	Нижновэнерго (ф)
--71	70	2	NULL	1	NULL	2C82B81C-7CA8-452A-9D24-D003A1DE0FBC	РязаньЭнерго (ф)
--81	80	2	NULL	1	NULL	9B84E969-CF94-4776-A5AB-BB3F596E7FFD	ТулЭнерго (ф)
--91	90	2	NULL	1	NULL	46D4B1B2-090A-4AFA-A5E1-AEE2258CB404	Удмуртэнерго (ф)
declare @D_date as smalldatetime, @D_date_S as smalldatetime, @F_Division as tinyint
set @D_date='20221210'--convert(smalldatetime,'20220731')
set @D_date_S='20221222'--convert(smalldatetime,'20220731')
set @F_Division=51
select 
sd.C_Name
,convert(date,emr.S_Create_Date) [дата загрузки]
--,emr.S_Create_Date
,convert(date,emr.D_Date) [дата показания]
,ed.B_PE as [ФЛ]
,ed.B_EE as [ЮЛ]
,count(emr.link) [кол-во показаний]
from ED_Devices ed
left join  ED_Meter_Readings emr
on ed.LINK=emr.F_Devices
and ed.F_Division=emr.F_Division
inner join SD_Divisions sd
on sd.LINK=ed.F_Division
where 
1=1
and ed.string4 is not null
and ed.F_Division = @F_Division
--in (
--91,
--81,
--61,
--51,
--41,
--21,
--2 ,
--41)
--and ed.B_PE=1
and emr.F_Delivery_Methods=18
and emr.F_Readings_Status=0
and (convert(date,emr.D_Date) >= @D_date) 
and convert(date,emr.S_Create_Date) >= @D_date_S
GROUP BY sd.C_Name,convert(date,emr.S_Create_Date),convert(date,emr.D_Date),ed.B_PE,ed.B_EE--,emr.S_Create_Date,
order by sd.C_Name desc,  convert(date,emr.D_Date) desc, convert(date,emr.S_Create_Date) desc
/*

declare @D_date as smalldatetime
set @D_date='20220801'--convert(smalldatetime,'20220731')

select 
sd.C_Name,
ed.F_SubDivision
,convert(date,emr.S_Create_Date) [дата загрузки]
--,emr.S_Create_Date
,convert(date,emr.D_Date) [дата показания]
,ed.C_Serial_Number
from ED_Devices ed
left join  ED_Meter_Readings emr
on ed.LINK=emr.F_Devices
and ed.F_Division=emr.F_Division
inner join SD_Divisions sd
on sd.LINK=ed.F_Division

where 
1=1
and ed.string4 is not null
and ed.F_Division in (

2
)
--and ed.B_PE=1
and emr.F_Delivery_Methods=18
and emr.F_Readings_Status=0
and (convert(date,emr.D_Date) >= @D_date) 
and convert(date,emr.S_Create_Date) >= @D_date
order by sd.C_Name desc,  convert(date,emr.D_Date) desc, convert(date,emr.S_Create_Date) desc
*/
