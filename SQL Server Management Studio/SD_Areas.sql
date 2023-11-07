update SD_Areas
set int1=null where link = 161

update ED_Registr_Pts_Cap
set S_Create_Date=S_Create_Date
where F_Division=61


delete from ED_Registr_Pts_Areas where link=2960


delete from  SD_Areas where link in (461,481)
delete from dbo.ED_Registr_Pts_Areas where F_Areas in (461,481)

update dbo.ED_Registr_Pts_Areas
set D_Date='20210101'
where F_Areas in (441,501)


select * from ED_Registr_Pts_Areas where F_Registr_Pts=86095921
select * from  SD_Areas where link = 239981


select * from ED_Registr_Pts_Cap where link = 904020

update ED_Registr_Pts_Cap
set N_Cap2=550
where link = 903820

delete from SD_Areas where link = 141
delete from ee.FD_Paysheets where N_Period >= 202201

update ES_Alternative_Calc_Methods_Groups
set F_Balance_Type=null,F_Owner_Types=null,F_Service_Org_Types=null

--select * from ES_Alternative_Calc_Methods_Groups 
where link = 7

exec sp_whoisactive
kill 66

Договор ГП (ГК, ЭСК) - Поставка потерь


select * from CD_Partners where link = '45621c67-b41f-4b29-8538-263485410b0f'

update CD_Partners
set C_Name1 = 'ЭСК передача доходы',C_Name2='ЭСК передача доходы'
where link = '45621c67-b41f-4b29-8538-263485410b0f'


delete from ED_Device_Checks where link = 985194260

select * from Ed_Meter_Measures where F_devices = 176604080 and d_date = '2023-02-15 00:00:00'

update Ed_Meter_Measures
set D_date_end = '2079-06-06 00:00:00'
where F_devices = 176604080 --and d_date = '2023-02-15 00:00:00'

select * from Ed_Meter_Measures where F_devices <> 176604080 --and d_date = '2023-02-15 00:00:00'


delete from ED_Meter_Readings where F_devices = 176604080


select * from ED_Devices where C_Serial_Number = '8002666666667810345'

delete from ED_Meter_Profiles where F_Devices= 14502121 and N_Year=2020


select * from ED_Registr_Pts_Period where link = 541


select * from UI_EV_Suppliers where link = 'f7db2021-4cb4-4d74-ad9f-28b012468b7a'

update CD_Partners
set C_Name1 = 'Договор ГП (ГК, ЭСК) - Поставка потерь',C_Name2='Договор ГП (ГК, ЭСК) - Поставка потерь'
where link = '8940AFDF-8677-4D66-851E-7E0E4E1E29DA'

Договор ГП (ГК, ЭСК) - Поставка потерь №1-П  от 01.01.2008


select * from ED_Meter_Readings where F_Delivery_Methods=131

update ED_Meter_Readings
set F_Readings_Status = 0 where F_Delivery_Methods=131



select * from ED_Registr_Pts_Period where link = 481

update er
set er.N_value=100
--select * 
from ED_Registr_Pts_Period er where link = 521


select * from ED_Device_Checks where link = 16884021

delete from ED_Device_Checks where link = 16884841




[9:29] Сергей Николаев Дмитриевич
SELECT * FROM dbo.CS_Config

UPDATE dbo.CS_COnfig

SET DTS_Path = 'G:\OmnisDTS\',
DTSTempDIR = 'G:\OmnisDTS\Temp\'



select csu.C_Category, csu.C_Name,csu.C_Note,csuv.C_Value 
from CS_UIVars csu
inner join CS_UIVars_Values csuv
on csuv.F_UIVars=csu.LINK
where csu.C_Const='IsUseConf_PartnerRoles_RB_F46_F23'
order by csu.C_Category

update CS_UIVars_Values 
set C_Value='false'
from CS_UIVars csu
inner join CS_UIVars_Values csuv
on csuv.F_UIVars=csu.LINK
where csu.C_Const='IsUseConf_PartnerRoles_RB_F46_F23'

select bit3 from ED_Registr_Pts where link = 20321101

update ED_Registr_Pts
set bit5=0,bit3=0
where link = 20322101

select * from ES_Delivery_Methods

update ES_Delivery_Methods
set N_Deviation = 100, N_Deviation_Year = 100 where N_Deviation is not null


select edm.N_Priority, edm.* from ES_Delivery_Methods edm order by edm.N_Priority

update edm
set edm.N_Priority=1
from ES_Delivery_Methods edm
where edm.C_Const=
'EDM_Auto'


select * from CS_Calc_Defaults where C_Const = 'B_Meter_Readings_Generate_byProfiles'

update CS_Calc_Defaults
set N_Value=1
where C_Const = 'ECM_Last_Year_Alg_Cons'


N'CCD_DMZ_Set_Auto_Approved', 



select * from ES_Device_Event_Types

update ES_Device_Event_Types
set B_Events=1
where link = 4


update ES_Device_Event_Types
set N_Priority=7
where link = 2

select * from ED_Meter_Readings
where 1=1
and D_Date='20211001'
and F_Division=24
and F_SubDivision=70
and F_Delivery_Methods=131
and N_Value>20000

update ED_Meter_Readings
set N_Value=11000
where 1=1
and D_Date='20211001'
and F_Division=24
and F_SubDivision=70
and F_Delivery_Methods=131
and N_Value>20000