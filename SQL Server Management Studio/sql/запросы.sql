--SELECT * FROM dbo.CS_Config

--SELECT DISTINCT YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(D_Date AS SMALLDATETIME))
--FROM IE.CD_BUF_Imp_109_First_Integration_Meter_Readings_Log
--WHERE 1=1
--and F_Division = 61 
--AND F_Meter_Readings IS NOT NULL
--order by YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(D_Date AS SMALLDATETIME))

--статистика показаний по ФЛ и ЮЛ в буфере
select 
DISTINCT YEAR(TRY_CAST(cd.D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(cd.D_Date AS SMALLDATETIME)),ed.B_EE,COUNT(ed.B_EE)
FROM IE.CD_BUF_Imp_109_First_Integration_Meter_Readings_Log cd
left join ED_Devices ed
on ed.LINK =cd.F_Devices
and ed.F_Division=cd.F_Division
WHERE 1=1
and cd.F_Division = 61 
AND cd.F_Meter_Readings IS NOT NULL
--and ed.B_EE=0
and YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) in (2021,2022)
GROUP by YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(D_Date AS SMALLDATETIME)),ed.B_EE
order by YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(D_Date AS SMALLDATETIME)) desc,ed.B_EE


--Показания ЮЛ
select 
DISTINCT YEAR(TRY_CAST(cd.D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(cd.D_Date AS SMALLDATETIME)),MONTH(TRY_CAST(cd.D_Date AS SMALLDATETIME)),cd.D_Date,cd.N_Value,ed.B_EE,ed.C_Serial_Number
FROM IE.CD_BUF_Imp_109_First_Integration_Meter_Readings_Log cd
left join ED_Devices ed
on ed.LINK =cd.F_Devices
and ed.F_Division=cd.F_Division
WHERE 1=1
and cd.F_Division = 61 
AND cd.F_Meter_Readings IS NOT NULL
and ed.B_EE=1
--and YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) in (2021)
and cd.C_Serial_Number='15587489'
order by YEAR(TRY_CAST(D_Date AS SMALLDATETIME)) * 100 + MONTH(TRY_CAST(D_Date AS SMALLDATETIME)) desc,ed.B_EE


--кол- во УП
select count(erp.link) from ED_Registr_Pts erp
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
where 1=1
and ss.B_EE=0
and ss.F_Division=61
and erp.D_Date_End is null


SELECT G_Session_ID,F_Division,F_SubDivision,N_Template_ID,C_Path_On_Client,C_Creator,C_Table_Name,B_Bufer,F_Status,B_Error,S_Create_Date,C_Note
FROM IE.CD_BUF_First_Integration_Data
WHERE 1=1
and B_Bufer = 1 
--AND F_Status = 1
AND F_Division = 61
ORDER BY S_Create_Date desc,N_Template_ID


--профили
select count(emp.LINK) from ED_Meter_Profiles emp
inner join ED_Devices ed
on ed.LINK=emp.F_Devices
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
where 1=1
and ed.F_Division=51
and ss.LINK>0
and ss.B_EE=1


--показаний по исчточенику
select count(emr.LINK) from ED_Meter_Readings emr
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
where 1=1
and ed.F_Division=51
and ss.LINK>0
and ss.B_EE=1
and emr.F_Readings_Status=0
and emr.F_Delivery_Methods in (50,128)
and emr.D_Date>='20220102' and emr.D_Date<='20220201'


--ПУ в пирамиде
select count(ed.LINK) from ED_Devices ed
inner join ED_Devices_Pts edp
on edp.F_Devices=ed.LINK
inner join ED_Registr_Pts erp
on erp.LINK=edp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
where 1=1
and ed.F_Division=51
and ss.LINK>0
and ss.B_EE=1
--and ed.string4 is not null

--ПУ в пирамиде
select count(erp.LINK) from ED_Registr_Pts erp
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
where 1=1
and ss.F_Division=51
and ss.LINK>0
and ss.B_EE=1
