--2	     1	2	NULL	1	NULL	5AE88A85-50A2-445F-8A89-A2D545B560ED	Владимирэнерго (ф)
--21	20	2	NULL	1	NULL	88EC6364-151F-4174-ABB2-222BC52C015A	Ивэнерго (ф)
--31	30	2	NULL	1	NULL	A3A68627-5801-41AA-9DC6-40559E7C53E7	Калугаэнерго (ф)
--41	40	2	NULL	1	NULL	0E1C8E1C-3C7A-47C4-86C1-649D61F47472	Кировэнерго (ф)
--51	50	2	NULL	1	NULL	D6677B99-8415-40E3-A9C4-FCB641BB0564	Мариэнерго (ф)
--61	60	2	NULL	1	NULL	49B1D2E2-F28A-417A-ADC9-D6B7B6F63809	Нижновэнерго (ф)
--71	70	2	NULL	1	NULL	2C82B81C-7CA8-452A-9D24-D003A1DE0FBC	РязаньЭнерго (ф)
--81	80	2	NULL	1	NULL	9B84E969-CF94-4776-A5AB-BB3F596E7FFD	ТулЭнерго (ф)
--91	90	2	NULL	1	NULL	46D4B1B2-090A-4AFA-A5E1-AEE2258CB404	Удмуртэнерго (ф)

EXEC IE.IMP_Readings_Complete
@C_Start_Date = '20220731',
@C_End_Date = '20220801',
@F_Division = 2,
@B_Run_SSIS = 1,
@B_Run_Service = 1,
@B_Remote = 1,
--@B_Load_Integral=0,
@B_Report = 1,
@B_Mail = 1,
@C_Device_ID = 'ecbf1861-e808-4089-8eea-b29cf242e8db'

	--N_Error = 1		- ПУ которым не нашлось соответствия в системе
	--N_Error = 2		- ПУ не заведена соответствующая шкала(F_Time_Zones) и номер канала в АСКУЭ(N_Channel)
	--N_Error = 4		- Данные в ПЗП, бит разрешающий запись в ПЗП не выставлен
	--N_Error = 8		- Пересекающиеся на интервале значения (не дубли)
	--N_Error = 16	- Eсли параметр "перезаписать данные" не истина, а расходы за этот час в системе уже заведены (отличны от null)
	--N_Error = 32	- При обновлении профилей новыми значениями возникла ошибка
	--N_Error = 64	- При создании профилей возникла ошибка
	--N_Error	= 128	- Попытка грузить профиль на обычный счетчик
	--N_Error	= 256	- Имеется рассчитанное "Недост" показание
	--N_Error	= 512	- ПУ не заведен соответствующая тип энергии(F_Energy_Types)
	--N_Error	= 1024	- УП не активен
	--N_Error = 2048	- Приходит расход больше чем 1 000 000 000, что может поломать триггер 

select *  frOM IE.CD_Readings 
wHERE 1=1 
and C_ASKUE_Number = '2f7e458f-2354-4ea3-aa50-368972fc1a51' 
and G_Session = '4ff43f9c-b2a1-43f3-b4f6-fe0719a5fd7a'
order by link desc
--G_Session = '0d60405d-e2b7-41cd-b756-48f8e445b1f6' --AND n_pERIOD = 202109
select NEWID()
select NEWID()
select NEWID()


UPDATE ie.CD_Readings SET N_Error = null where F_Device=37164701

ef5aa34e-782c-40d1-bd31-258bdbd9140c

select distinct
ed.LINK,
ed.string4,
ed.D_Replace_Date,
ed.C_Serial_Number,
ed.B_EE,
ed.B_PE,
ed.F_Division,
ed.F_SubDivision,
emr.D_date_max,
emr.F_Delivery_Methods,
ss.B_EE,
erp.N_code,
erp.bit14,
erp.int3,
cr.N_Error

from ED_Devices ed
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
and edp.d_date_end>=getdate()
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
and erp.D_Date_End is null
left join SD_Subscr ss
on ss.LINK=erp.F_Subscr
left join (select F_Devices, max(D_date) D_date_max, F_Delivery_Methods  from ED_Meter_Readings 
where F_Readings_Status=0 GROUP BY F_Devices,F_Delivery_Methods) emr
on emr.F_Devices=ed.LINK
inner join IE.CD_Readings cr 
on cr.F_Device=ed.LINK
and cr.F_Energy_Types=edp.F_Energy_Types
where 1=1
--and C_Serial_Number like '%36042853%'
and ed.LINK=127713481

--and string4='2f7e458f-2354-4ea3-aa50-368972fc1a51'



select string4,D_Replace_Date,C_Serial_Number,B_EE,B_PE,F_Division,F_SubDivision, * from ED_Devices where string4='2f7e458f-2354-4ea3-aa50-368972fc1a51'
select string4,D_Replace_Date,C_Serial_Number,B_EE,B_PE,F_Division,F_SubDivision, * from ED_Devices where C_Serial_Number='48202422015079'

select * from ED_Registr_Pts where link = 345301
select string4,D_Replace_Date,C_Serial_Number,B_EE,B_PE,F_Division,F_SubDivision, * from ED_Devices where string4 is not null and F_Division=51 and B_PE=1

SELECT  top 100 cu.C_Name,crll.C_Parameters ,crll.C_Log_Message   ,CIS.*
FROM IE.CS_Integration_Sessions AS CIS
inner join CS_Users cu
on cu.LINK=cis.S_Creator
left join IE.CD_Readings_Log_Load AS crll
on crll.G_Session_ID=cis.G_Session_ID
left join IE.CD_Readings_Sessions AS crs
on crs.G_Session_ID=cis.G_Session_ID
left join SD_Divisions sd
on sd.LINK=crs.F_Division
WHERE 1=1
and C_SSIS_Name='MEK_Loader.exe'
--and G_Session_ID='6A5A9BC8-56B1-483F-9302-D97ED2215D30' --61DD90C7-3445-4B99-A7FF-D1E573B01792
--and D_start_date>='20220609'
ORDER BY D_start_date desc


--61DD90C7-3445-4B99-A7FF-D1E573B01792

SELECT TOP (100) CIS.*
FROM IE.CS_Integration_Sessions AS CIS
WHERE 1=1
and C_SSIS_Name='MEK_Loader.exe'
--and G_Session_ID='6A5A9BC8-56B1-483F-9302-D97ED2215D30'
ORDER BY D_Start_Date desc

select top 50 * FROM IE.CD_Readings_Log_Load AS crll 
--order by S_Create_Date desc
where G_Session_ID='d78e4fc2-2a07-4c0d-a9c8-923209a139c9'


select top 50 * frOM IE.CD_Readings_Buffer 
wHERE 1=1
and G_Session_ID = 'd78e4fc2-2a07-4c0d-a9c8-923209a139c9'
--and C_ASKUE_Number='2665257f-ec38-451c-8b54-7f71d80497c1'
--and B_Profile=1
order by D_Date

select count(*)  frOM IE.CD_Readings_Buffer  wHERE G_Session_ID = '6A5A9BC8-56B1-483F-9302-D97ED2215D30'-- and N_Value is not null


--ORDER BY S_Create_Date desc


--С ЛОГИНОМ
select top 50 * FROM IE.CD_Readings_Log_Load AS crll --where crll.G_Session_ID='B064496E-78B0-4141-884C-89DFE985F65C'
order by crll.link desc
select top 50 * FROM  IE.CD_Readings


--select count(*) from  dbo.ED_Meter_Readings where D_date between @C_Start_Date and @C_End_Date and cast(s_create_date as date) = cast(getdate() as date) and F_Delivery_Methods=18
TRUNCATE TABLE IE.CD_Readings                        -- select * from IE.CD_Readings
TRUNCATE TABLE IE.CD_Readings_Buffer                -- select * from IE.CD_Readings_Buffer

SELECT  count(1) FROM [OmniUS].[IE].[CD_Readings_TMP]


SELECT  distinct CIS.C_Const,CIS.C_SSIS_Description,CIS.C_SSIS_Name,cis.G_Session_ID
FROM IE.CS_Integration_Sessions AS CIS
inner join IE.CD_Readings cr
on cr.G_Session=CIS.G_Session_ID


select NEWID()
select * from IE.CD_Readings_Buffer crb where crb.C_ASKUE_Number='bf48cf6c-f561-45f3-8709-51dd6fa20535' and crb.B_Profile=1 and crb.B_Status=1 and N_Energy_Type=0  order by crb.D_Date

select 
cr.N_Error,
count(1)
from IE.CD_Readings cr 
where 1=1
and cr.G_Session='C389A0DD-567C-4008-BBEF-D796D429795D'
group by cr.N_Error


select --top 50
cr.N_Error,
cr.F_Device,
ed.C_Serial_Number,
ed.LINK_Imp,
cr.*

from IE.CD_Readings cr 
inner join ED_Devices ed
on ed.LINK=cr.F_Device
where 1=1
and cr.G_Session='2A3B94A1-74A1-4720-951C-FDF8DF900510'
and cr.F_Device is not null
and cr.F_Device_Division=81
and cr.N_Error=512
and ed.B_EE=1
and F_Energy_Types in (8,9)
--group by cr.N_Error





C_ASKUE_Number='bf48cf6c-f561-45f3-8709-51dd6fa20535'
select top 100 * from IE.CD_Readings_TMP where C_ASKUE_Number='bf48cf6c-f561-45f3-8709-51dd6fa20535'

select count(*) from IE.CD_Readings_TMP


select G_Session_ID, count(*) as cnt
FROM [IE].[CD_Readings_TMP] with(nolock)
group by G_Session_ID

--TRUNCATE TABLE IE.CD_Readings
--TRUNCATE TABLE IE.CD_Readings_Buffer
--TRUNCATE TABLE IE.CD_Readings_TMP
--TRUNCATE TABLE IE.CD_Readings_Device --select * from IE.CD_Readings_Device
--TRUNCATE TABLE IE.CD_Readings_Devices_ASKUE -- select * from IE.CD_Readings_Devices_ASKUE
--TRUNCATE TABLE IE.CD_Readings_Devices_Info_ASKUE  --select * from IE.CD_Readings_Devices_Info_ASKUE
--DELETE from IE.CD_Readings_Log_Load
--TRUNCATE TABLE IE.CD_Readings_Retrieves
--TRUNCATE TABLE IE.CD_Devices_ASKUE 

select distinct cd.C_Device_Type [Тип П-С],cd.C_Serial_Number,est.C_Name [Тип Омниус],ed.string18 [Тип СТЕК из примечания]--,est2.C_Name
from IE.CD_Devices_ASKUE cd
inner join ED_Devices ed
on cd.F_Devices=ed.LINK
and cd.C_Code_ASKUE=ed.string4
inner join ES_Device_Types est
on est.LINK=ed.F_Device_Types
--left join ES_Device_Types est2
--on est2.C_Name like '%'+cd.C_Device_Type+'%'
where cd.F_Devices is not null
and est.C_Name= 'Неизвестный тип'
order by cd.C_Device_Type
--TRUNCATE TABLE IE.CD_Devices_ASKUE_Omnis
--TRUNCATE TABLE IE.CD_Events_TMP
--TRUNCATE TABLE IE.CD_Events_Device
--update ed set ed.string4 = null, ed.int1 = null from dbo.ED_Devices as ed

delete from dbo.ED_Meter_Profiles  where F_Delivery_Methods=18 and N_Period=202206 and F_Division=51

--select * from ED_Meter_Profiles where F_Delivery_Methods=18 and N_Period=202109


--delete from  dbo.ED_Meter_Readings
--where F_Delivery_Methods=18
--and
--D_Date >= '20211202'

--delete from ee.FD_Paysheets
--where N_Period=202112

--delete from PE.FD_Charges 
--where N_Period=202112


exec ie.imp_Readings_RPT_Buffer_Data @N_Month=10,@N_Year=2021,@C_ASKUE_Number=N'8ebacce0-022f-48c5-9304-270fb8019c86',@G_Loading_System=N'd5ad9173-8e35-4dfc-b3f4-c1d2de8a7237' --профили



------------------БУФЕР С ПОКАЗАНИЯМИ ПИРАМИДЫ
select distinct ed.C_Serial_Number, crd.N_Error,crb.*,ftz.C_Name from IE.CD_Readings_Buffer crb 
inner join ED_Devices ed
on ed.string4=crb.C_ASKUE_Number
inner join ie.CD_Readings crd
on crd.G_Session=crb.G_Session_ID
and crd.C_ASKUE_Number=crb.C_ASKUE_Number
left join FS_Time_Zones ftz
on ftz.LINK=crb.N_Time_Zone
where 1=1
--crb.C_ASKUE_Number='4f9af708-3dad-4370-89c7-860e0fed06fb'
and crb.G_Session_ID='6A5A9BC8-56B1-483F-9302-D97ED2215D30'
--and crb.C_ASKUE_Number='94ed6a44-a77f-47c7-a118-a4e6cf3b6b50'
--and crb.N_Energy_Type=0
--and crd.N_Error=0
--and crb.B_Profile=0
order by LINK desc
--and crb.G_Session_ID='2A3B94A1-74A1-4720-951C-FDF8DF900510'
--and crb.D_Date>'20211001'
--and crb.B_Profile=0
--------------------
select crb.* from IE.CD_Readings_Buffer crb 
select cr2.* FROM IE.CD_Readings AS cr2


select --top 50 
sd.C_Name,
crs.* FROM IE.CD_Readings_Sessions AS crs
left join SD_Divisions sd
on sd.LINK=crs.F_Division
order by crs.link desc

--буфер показаний п-с с ошибками
select  ed.C_Serial_Number, tz.C_Name, et.C_name,cr2.* FROM IE.CD_Readings AS cr2
inner join ED_Devices ed
on ed.LINK=cr2.F_Device
left join FS_Time_Zones tz
on tz.LINK=cr2.F_Time_Zones
left join ES_Energy_Types et --select * from ES_Energy_Types
on et.LINK=cr2.F_Energy_Types
where 
1=1
and cr2.G_Session='6A5A9BC8-56B1-483F-9302-D97ED2215D30'
--and C_ASKUE_Number='94ed6a44-a77f-47c7-a118-a4e6cf3b6b50'
--and B_Profile=0
order by cr2.link desc

select top 10 * FROM [IE].[CD_Readings_Loading_System] crls
order by crls.link desc

select top 10 * FROM IE.CS_Integration_Sessions cis
order by cis.link desc

select top 10 * FROM IE.CD_Readings_Devices_ASKUE t
order by t.link desc

select top 10 
ed.C_Serial_Number,
t.* 
FROM IE.CD_Readings_TMP t
left join ED_Devices ed
on ed.string4=t.C_ASKUE_Number
where t.B_Hour=0
and
t.C_ASKUE_Number='94ed6a44-a77f-47c7-a118-a4e6cf3b6b50'
order by t.link desc

select DISTINCT G_Session_ID FROM ie.CD_Readings_Buffer WHERE B_Profile = 1


UPDATE ie.CD_Readings SET N_Error = null where F_Device=37164701


----------------ЗАГРУЗКА ПОКАЗАНИЙ ИЗ БУФЕРА
DECLARE @Status_Msg VARCHAR(100)
EXEC IE.IMP_Readings
@N_Year = NULL, -- период записываемых данных. Год
@N_Month = NULL, -- период записываемых данных. Месяц
@F_Division = 0, -- отделение
@F_SubDivision = 0, -- участок
@B_Rewrite = 0, -- перезаписать существующие данные интервального учета
@B_Ignore_notMeasure = 0, -- игнорировать данные по несуществующим шкалам (не формируем ошибки)
@B_Ignore_Closed_Period = 0, -- допускается запись в закрытый период
@B_Ignore_Prev_Periods = 0, -- не записывать показания в предыдущие периоды
@B_Ignore_Meter_Date = 1, -- игнорировать настройку выбора даты показаний
@C_User = 'sa', -- пользователь запустивший операцию импорта
@C_SubDivisions = '10,11,12,13,14,15,16,17,18,19,2,3,4,5,6,7,8,9', -- отделение, участок
@N_Device_Type = NULL, -- фильтр на тип загружаемых показаний
@C_ASKUE_Number = null, --'bf48cf6c-f561-45f3-8709-51dd6fa20535', -- фильтр по коду интеграции
@B_Only_TFZ_Day = NULL, -- загружать только по зоне сутки
@B_Interval = 0, -- грузим профили
@B_Integral = 1, -- грузим показания
@B_Inversion = 0, -- тип инверсии
@Action_id = NULL, -- идентификатор операции (не используется)
@PK = 0, -- идентификатор объекта, на котором вызвана операция (не используется)
@B_Rewrite_Integral = 1, -- перезаписать существующие данные интегрального учета
@G_Session_ID = '55876DB3-0036-4316-92FA-09C2BAD974EA',
@Status_Msg = @Status_Msg OUTPUT


--показаний на дату
select 
ed.C_Serial_Number
,emr.D_Date
--,emr.F_Readings_Status
--,emr.S_Create_Date
,emr.N_Value
--,emr.C_Notes
--,emr.LINK
--,erp.LINK
,fpd.N_Quantity
from dbo.ED_Meter_Readings emr 
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
--and emr.F_Time_Zones=3
and emr.F_Energy_Types=9
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts ERP
on erp.LINK=edp.F_Registr_Pts
left join ( select sum(N_Quantity) N_Quantity, F_Registr_Pts from EE.FVT_Paysheets_Details where N_Period=202111 GROUP BY F_Registr_Pts) fpd
         ON erp.LINK        = fpd.F_Registr_Pts
where 
--ed.B_PE=0
--and
emr.F_Delivery_Methods=131
--and cast(emr.S_Create_Date as date) = '20211203'
and (emr.D_Date > '20211120' and emr.D_Date < '20211205')
--and ed.C_Serial_Number='03024984'


--OmniUS.dbo.CF_STRPART_Decimal(p9.[Заводской Номер])

select 
ed.C_Serial_Number
,ed.string4
--,emr.F_Delivery_Methods
,emr.D_date_max
from ED_Devices ed
left join (select F_Devices, max(D_date) D_date_max, F_Delivery_Methods from ED_Meter_Readings 
/*where F_Delivery_Methods=18 */ GROUP BY F_Devices,F_Delivery_Methods) emr
on ed.LINK=emr.F_Devices
where 
1=1
and ed.string4 is not null
and ed.F_Division=51
--and emr.D_date_max is null
--and ed.C_Serial_Number='8042204'
and emr.F_Delivery_Methods=18
--and
--cast(emr.S_Create_Date as date) = '20211123'
and (emr.D_date_max >= '20220720') 
--and ed.LINK=1110180474
--and ed.C_Serial_Number='03024984'




--Несколько показаний в периоде

select 
ed.C_Serial_Number
,sd.C_Name
,count(emr.link)
from dbo.ED_Meter_Readings emr 
left join ED_Devices ed
on ed.LINK=emr.F_Devices
and ed.D_Replace_Date is null
left join SD_Divisions sd
on sd.LINK=ed.F_Division

where 
ed.B_PE=1
and emr.F_Readings_Status=0
and emr.F_Delivery_Methods not in (44,15)
--and
--emr.F_Delivery_Methods=18

and (emr.D_Date >= '20211010'
and emr.D_Date <= '20211025')
group by ed.C_Serial_Number,sd.C_Name

having count(emr.link)>1 
order by count(emr.link) desc



select distinct REPLACE(REPLACE(DT1.C_Name, ' ', ''), '-', ''),DTZ1.N_Digits,DT1.string10 from dbo.ES_Device_Types DT1
			INNER JOIN dbo.ED_Device_Tariff_Zones DTZ1
				ON DTZ1.F_Device_Types = DT1.LINK
				AND DTZ1.F_Energy_Types = 1	


select count (1),
CASE 
when emp.N_Count=744 THEN 'full'
ELSE 'not full'
end AS polnota
 FROM dbo.ED_Meter_Profiles emp 
 WHERE 1=1
 and emp.N_Period=202205
 and emp.F_Division in (50,51)
 and emp.F_Delivery_Methods=18
 GROUP BY 
 CASE 
when emp.N_Count=744 THEN 'full'
ELSE 'not full'
END



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
emp.S_Modif_Date
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
and emp.N_Period=202201
--and ed.C_serial_number='1135936'
and ss.B_EE=1
and ss.LINK>0
--and erp.int3 is not null --принадлежность к мкд
and (edp.d_date_end is null or edp.d_date_end > GETDATE())
--and (emp.N_Count<700)
and emp.N_Quantity <>0
and emp.F_Delivery_Methods=18
--and ed.C_serial_number='05030990'
and ed.string4 is not null
and ed.F_Division=51
--and sd.LINK=21
order by emp.S_Modif_Date desc--,ed.LINK DESC