select * from ED_Registr_Pts where link in (77645521,66376801)

select top 5  em.S_Create_Date,em.F_Delivery_Methods,em.S_Creator,ed.C_Serial_Number
from ED_Meter_Readings em
inner join ED_Devices ed
on ed.LINK=em.F_Devices
where em.F_Division=41

select * from CS_Users where link = -1605019781

select *
from IE.CD_BUF_Imp_109_First_Integration_Meter_Readings_Log lg
where lg.F_Division = 41
and C_Serial_Number='1100129583'
order by D_Date desc

select * from ED_Devices_Pts where F_Registr_Pts=5342901


--begin transaction
UPDATE ed
SET ed.D_Setup_Date = emr2.D_Date
--SELECT ed.D_Setup_Date,
--ed.C_Serial_Number--, count (1) as cnt
FROM dbo.ed_devices ed
CROSS APPLY (
SELECT TOP 1 F_Devices,
emr.D_Date
FROM dbo.ED_Meter_Readings emr
WHERE emr.F_Devices = ed.LINK
and emr.F_Division=ed.F_Division
ORDER BY
emr.D_Date
) emr2
WHERE ed.F_division = 51
AND emr2.D_Date < ed.D_Setup_Date
-- AND ed.C_Serial_Number = '009130049006338'
--GROUP BY
--ed.D_Setup_Date,
--ed.C_Serial_Number


SELECT ed.D_Setup_Date, 
ed.C_Serial_Number--, count (1) as cnt
,(select min(D_Date) from dbo.ED_Meter_Readings where F_Devices = ed.LINK) as D_Date_MR_min
FROM dbo.ed_devices ed
CROSS APPLY (
SELECT TOP 1 F_Devices,
emr.D_Date
FROM dbo.ED_Meter_Readings emr
where emr.F_Devices = ed.LINK
and emr.F_Division=ed.F_Division
ORDER BY
emr.D_Date
) emr2
WHERE ed.F_division = 51
AND emr2.D_Date < ed.D_Setup_Date
-- AND ed.C_Serial_Number = '009130049006338'
GROUP BY
ed.LINK,
ed.D_Setup_Date,
ed.C_Serial_Number



UPDATE EMM
SET emm.D_Date = emr2.D_Date
--SELECT
--ed.LINK,ed.C_Serial_Number
FROM dbo.ed_devices ed
    CROSS APPLY 
    (
    SELECT TOP 1 F_Devices,
        emr.D_Date,emr.F_Energy_Types
    FROM dbo.ED_Meter_Readings emr
    WHERE   emr.F_Division = ed.F_Division
        AND emr.F_Devices = ed.LINK
    ORDER BY emr.D_Date
    ) emr2
    INNER JOIN dbo.ED_Meter_Measures AS EMM
        ON emm.F_Division = ed.F_Division
        AND EMM.F_Devices = ed.LINK
        AND (EMM.F_Energy_Types = emr2.F_Energy_Types OR emr2.F_Energy_Types IS NULL)
WHERE ed.F_division = 51
AND emr2.D_Date < EMM.D_Date
--and ed.LINK=5722541
--AND emr2.D_Date <= ed.D_Setup_Date
