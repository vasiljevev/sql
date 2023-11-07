


select 
count(1),epp.S_Create_Date,epp.G_Session_ID,F_Partner_Suppliers,ep.F_Division 
from EE.ED_Pts_DMZ ep
inner join EE.ED_Pts_Period_DMZ epp
on epp.F_Pts_DMZ=ep.LINK
where 1=1
and ep.F_Division=61
--and epp.G_Session_ID='799083EF-B090-4714-96EB-DF78376D70B0'
group by epp.S_Create_Date,epp.G_Session_ID,F_Partner_Suppliers,ep.F_Division
order by epp.S_Create_Date desc


select * from EE.ED_Pts_DMZ ep where ep.link = '1576b21c-f59e-4878-9256-8092072c1b77'

select string15, * from ED_Registr_Pts where string15='1100023010016'
select C_Subscr_Code, C_Registr_Pts_Code,* from EE.ED_Pts_DMZ ep where ep.C_Registr_Pts_Code='1100023010016'


select *
from EE.ED_Pts_DMZ ep
where 1=1
and ep.F_Division=61
and exists(select 1 from EE.ED_Pts_Period_DMZ where F_Division = ep.F_Division and F_Pts_DMZ = ep.LINK and G_Session_ID='CCFA0C44-3050-46F8-8CDC-A6BDEA6C8736')
;

select C_Serial_Number, count(*) as cnt
from EE.ED_Pts_DMZ ep
where 1=1
and ep.F_Division=61
and exists(select 1 from EE.ED_Pts_Period_DMZ where F_Division = ep.F_Division and F_Pts_DMZ = ep.LINK and G_Session_ID='CCFA0C44-3050-46F8-8CDC-A6BDEA6C8736')
group by C_Serial_Number
having count(*) > 1
;



select C_Serial_Number, C_Subscr_Name, *
from EE.ED_Pts_DMZ ep
where 1=1
and ep.F_Division=61
and exists(select 1 from EE.ED_Pts_Period_DMZ where F_Division = ep.F_Division and F_Pts_DMZ = ep.LINK and G_Session_ID='CCFA0C44-3050-46F8-8CDC-A6BDEA6C8736')
and ep.C_Serial_Number in (
'01983438',
'26196297',
'29879568'
)
order by 1
;

select count(*) from EE.ED_Pts_DMZ where F_Partner_Suppliers = '3EB5D9DA-6E9E-485B-8807-A2763DD37C39'
-- 28516


select * 
from EE.BUF_ED_Registr_Pts_Analizer  iRPA
where iRPA.F_Division = 61  
	and iRPA.F_Partner_Suppliers = '3EB5D9DA-6E9E-485B-8807-A2763DD37C39' 
	and iRPA.N_Period = 202110
	--and iRPA.F_Register_Pts = 6430801
	and not exists(select 1 from EE.ED_Pts_DMZ iPD where iPD.F_Division = 61  and iPD.F_Registr_Pts = iRPA.F_Register_Pts)
;

select * from EE.ED_Pts_DMZ where F_Division = 61  and F_Register_Pts = 6430801;


-- =======================================================================================================================
--1
drop table #tmp_ED_Registr_Pts_ESK;
select *, cast(0 as bit) as B_Unique_Device 
into #tmp_ED_Registr_Pts_ESK
from EE.ED_Pts_DMZ ep
where 1=1
and ep.F_Division=61
and ep.F_Registr_Pts IS NULL
and exists(select 1 from EE.ED_Pts_Period_DMZ where F_Division = ep.F_Division and F_Pts_DMZ = ep.LINK and G_Session_ID='CCFA0C44-3050-46F8-8CDC-A6BDEA6C8736')
;
-- (1082 rows affected)
-- Completion time: 2022-04-19T21:46:30.4025857+03:00


update T set T.B_Unique_Device = 1
--select *
from #tmp_ED_Registr_Pts_ESK T
where not exists(select 1 from #tmp_ED_Registr_Pts_ESK iT where iT.C_Serial_Number = T.C_Serial_Number and iT.LINK <> T.LINK)
-- (1076 rows affected)
-- Completion time: 2022-04-19T21:49:50.8799520+03:00


--drop table #tmp_ED_Registr_Pts_SETI;
select *, cast(0 as bit) as B_Unique_Device 
into #tmp_ED_Registr_Pts_SETI
from EE.BUF_ED_Registr_Pts_Analizer  iRPA
where iRPA.F_Division = 61  
	and iRPA.F_Partner_Suppliers = '3EB5D9DA-6E9E-485B-8807-A2763DD37C39' 
	and iRPA.N_Period = 202110
	--and iRPA.F_Register_Pts = 6430801
	and not exists(select 1 from EE.ED_Pts_DMZ iPD where iPD.F_Division = 61  and iPD.F_Registr_Pts = iRPA.F_Register_Pts)
;
-- (1556 rows affected)
-- Completion time: 2022-04-19T21:47:40.9466200+03:00


update T set T.B_Unique_Device = 1
--select *
from #tmp_ED_Registr_Pts_SETI T
where not exists(select 1 from #tmp_ED_Registr_Pts_SETI iT where iT.C_Serial_Number = T.C_Serial_Number and iT.LINK <> T.LINK)
-- (1428 rows affected)
-- Completion time: 2022-04-19T21:49:06.0487168+03:00


-- сопоставлению по нмоеру ПУ
select t1.C_Subscr_Name, t1.C_Serial_Number, t2.C_CP_Building_Address
from #tmp_ED_Registr_Pts_ESK t1
		inner join #tmp_ED_Registr_Pts_SETI t2
			on t2.C_Serial_Number = t1.C_Serial_Number
where t1.B_Unique_Device = 1
	and t2.B_Unique_Device = 1
;


UPDATE t1
SET
	F_SubDivision				= ISNULL(RP.F_SubDivision, t1.F_SubDivision),			-- Участок
	F_Networks					= ISNULL(NIP.F_Networks, t1.F_Networks),				-- Сечение учёта
	F_Network_Items				= NIP.F_Network_Items,									-- Элемент сети
	F_Network_Pts				= RP.F_Network_Pts,										-- Точка поставки
	F_Partners					= P.LINK,												-- Потребитель
	F_Subscr					= S.LINK,												-- Лицевой счёт
	F_Registr_Pts				= RP.LINK,												-- Учётный показатель
	F_Sale_Items				= ISNULL(RP.F_Sale_Items, t1.F_Sale_Items),				-- Вид энергии
	F_Energy_Levels				= ISNULL(RP.F_Energy_Levels, t1.F_Energy_Levels)		-- Уровень напряжения
--select count(*)
FROM #tmp_ED_Registr_Pts_ESK t1
		inner join #tmp_ED_Registr_Pts_SETI t2
			on t2.C_Serial_Number = t1.C_Serial_Number
			and t1.B_Unique_Device = 1
			and t2.B_Unique_Device = 1
		LEFT JOIN dbo.ED_Registr_Pts AS RP
			INNER JOIN dbo.SD_Subscr AS S
				ON S.F_Division = RP.F_Division
				AND S.LINK		= RP.F_Subscr
				AND S.B_Tech	= 0
				AND S.B_EE		= 1
			INNER JOIN dbo.CD_Partners AS P
				ON P.LINK		= S.F_Partners
			INNER JOIN dbo.ED_Network_Pts AS NP
				ON NP.LINK = RP.F_Network_Pts
			OUTER APPLY (SELECT TOP 1 iNIP.F_Network_Items, iNI.F_Networks
							FROM dbo.ED_Network_Item_Pts iNIP
								INNER JOIN dbo.ED_Network_Items iNI
									ON iNI.LINK = iNIP.F_Network_Items
							WHERE iNIP.F_Network_Pts	= ISNULL(NP.F_Network_Pts, NP.LINK)
							AND iNIP.D_Date_Begin	< '20790606'
							AND iNIP.D_Date_End		> '20220101'
							ORDER BY iNIP.D_Date_Begin DESC
						) AS NIP
			--LEFT JOIN dbo.SD_Conn_Points AS CP
			--	ON CP.LINK = NP.F_Conn_Points
				
			ON RP.F_Division	= t2.F_Division
			AND RP.F_Subscr		= t2.F_Subscr
			AND RP.LINK			= t2.F_Register_Pts
;
-- (803 rows affected)
-- Completion time: 2022-04-19T22:00:26.2693691+03:00



UPDATE t1
SET
	F_Device_Division			= Dev.F_Division,										-- Отделение прибора учёта
	F_Devices					= Dev.F_Devices,										-- Прибор учёта
	F_Device_Types				= Dev.F_Device_Types,									-- Тип прибора учёта
	F_Device_Locations			= Dev.F_Device_Locations,								-- Место установки прибора учёта
	F_Owner_Types				= Dev.F_Owner_Types 									-- Тип владельца прибора учёта
--select count(*)
FROM #tmp_ED_Registr_Pts_ESK t1
		inner join #tmp_ED_Registr_Pts_SETI t2
			on t2.C_Serial_Number = t1.C_Serial_Number
			and t1.B_Unique_Device = 1
			and t2.B_Unique_Device = 1
		CROSS APPLY (SELECT TOP 1 iD.F_Division, iDP.F_Devices, iD.F_Device_Types, iD.F_Device_Locations, iD.F_Owner_Types, LTRIM(RTRIM(iD.C_Serial_Number)) AS C_Serial_Number
						FROM dbo.ED_Devices_Pts AS iDP
							INNER JOIN dbo.ED_Devices AS iD
								ON iD.LINK = iDP.F_Devices
						WHERE iDP.F_Division		= t2.F_Division
						AND iDP.F_Registr_Pts	= t2.F_Register_Pts
						AND iD.D_Setup_Date		< '20790606'
						AND (iD.D_Replace_Date	> '20220101' OR iD.D_Replace_Date IS NULL)
						ORDER BY iD.D_Setup_Date DESC, iDP.LINK DESC
		) AS Dev
WHERE t1.C_Serial_Number = Dev.C_Serial_Number
;
-- (803 rows affected)
-- Completion time: 2022-04-19T22:06:10.8924460+03:00


UPDATE T
SET 
	F_SubDivision				= t1.F_SubDivision		,
	F_Networks					= t1.F_Networks			,
	F_Network_Items				= t1.F_Network_Items	,
	F_Network_Pts				= t1.F_Network_Pts		,
	F_Partners					= t1.F_Partners			,
	F_Subscr					= t1.F_Subscr			,
	F_Registr_Pts				= t1.F_Registr_Pts		,
	F_Sale_Items				= t1.F_Sale_Items		,
	F_Energy_Levels				= t1.F_Energy_Levels	,
	F_Device_Division			= t1.F_Device_Division	,
	F_Devices					= t1.F_Devices			,
	F_Device_Types				= t1.F_Device_Types		,
	F_Device_Locations			= t1.F_Device_Locations	,
	F_Owner_Types				= t1.F_Owner_Types		
--SELECT COUNT(*)
FROM #tmp_ED_Registr_Pts_ESK t1
		INNER JOIN EE.ED_Pts_DMZ T
			ON T.F_Division = t1.F_Division
			AND T.LINK = t1.LINK
WHERE t1.F_Registr_Pts IS NOT NULL
;
-- (803 rows affected)
-- Completion time: 2022-04-19T22:09:47.9599689+03:00
