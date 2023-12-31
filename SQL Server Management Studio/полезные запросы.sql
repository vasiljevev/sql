sp_WhoIsActive 
     @sort_order = '[database_name] desc,[start_time] desc',
	 @output_column_list= '[dd%][start_time][database_name][login_name][status][session_id][block%][program_name][sql_text][sql_command][wait_info][tasks][tran_log%][cpu%][temp%][reads%][writes%][context%][physical%][query_plan][locks][%]'--kill 161



select NEWID()

select * from SD_Divisions where F_Division is not null
select * from SD_Subdivisions where F_Division in (60,61)

select N_Count,N_Cons,N_Quantity,D_Date_Begin,D_Date_End FROM PE.FVT_Charge_Details where link=143750700

update fd
set fd.D_Date_Begin='20210801',
fd.D_Date_End='20210901'
FROM PE.fd_Charge_Details fd
where fd.link=143750700

select top 5 * from EE.FD_Paysheets_Details where link = 2470460260 --таблица
select top 5 * from EE.FD_Paysheets 
select top 5 * from EE.FVT_Paysheets_Details --where link = 45020101 -- вьюха основная с объемами
select top 5 * from pe.FVT_Charge_Details where link = 2470460260

delete 
from pe.FD_Charges where link = 1636840301






select top 5 * from EE.FVT_Paysheets_Details fvt
where 1=1
and fvt.F_Division=41

select * from SD_Divisions where F_Division is not null


select top 5 fcd.LINK,fcd.N_Quantity, ss.C_Number from pe.FVT_Charge_Details fcd
inner join SD_Subscr ss
on ss.LINK=fcd.F_Subscr
and ss.F_Division=fcd.F_Division
where 1=1
and fcd.F_Cons_Zones=2






select * from dbo.ED_Registr_Grp grp
left join dbo.ED_Registr_Pts rp2
on rp2.LINK=grp.F_Registr_Pts_Main
where 1=1
--and grp.F_Registr_Pts = 50114621
and rp2.LINK is null

--Актуализировать УПdeclare @p4 varchar(max)
declare @p4 varchar(max)
set @p4=NULL
exec EE.OP_Generate_Data_Analizer @Action_id='EFC9C275-2FA2-4AA1-AD91-7DAB3C79C8F6',@PK=NULL,@F_Division=0,@Status_Msg=@p4 output,@svsubdiv=103,@N_Month=1,@N_Year=2022
select @p4



--не заполнены поля при импорте
SELECT  RP_C_IKU,C_name,
ID_Registr_Pts,N_Code,C_Code_Ext,RP_C_Code_Tu_ESK,
* FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log 
WHERE 1=1
--and N_Code is null
--and RP_C_Code_Tu_ESK is null
and F_Division = 41
--and RP_C_IKU is not null
and (ID_Registr_Pts like  '%mkd%' or C_Code like  '%mkd%'
or RP_C_IKU is not null 
or C_Name_Obj like '%МКД%' 
--or C_name like '%МКД%' 
or C_name like '%МКД%')
--and C_MKD_C_Type is not null

--группы потребления
SELECT distinct t.F_Division,t.B_EE,
t.N_Cons_Group, COUNT(1)
FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log t
WHERE 1=1
--and t.N_Cons_Group is not null
and t.F_Division=41
--and t.B_EE=1
group by t.N_Cons_Group,t.F_Division,t.B_EE
order by t.N_Cons_Group


--тарифы
SELECT  
--t.F_Division,
t.B_EE,
cast (t.N_Tariff_Code as int) as N_Tariff_Code,
COUNT(1) as num
FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log t
WHERE 1=1
and N_Tariff_Code is not null
and t.B_EE=1
group by cast (t.N_Tariff_Code as int),t.F_Division,t.B_EE
order by cast (t.N_Tariff_Code as int)


--ценовая категория
SELECT  
--t.F_Division,
t.B_EE,
cast (t.RP_C_Price_Category as int) as RP_C_Price_Category,
COUNT(1) as num
FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log t
WHERE 1=1
and RP_C_Price_Category is null
--and t.B_EE=1
group by cast (t.RP_C_Price_Category as int),t.B_EE
order by cast (t.RP_C_Price_Category as int)




select top 8 F_Division,B_EE,* FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log t where N_Code like '%4039335%'




select * from ED_Registr_Pts 

SELECT top 5
--ID_Registr_Pts,N_Code,C_Code_Ext,RP_C_Code_Tu_ESK,
* FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log 
WHERE 1=1

SELECT distinct 
sd.C_Name [филиал]
,ss.N_Code [ЛС]
,ss.C_Number [Альт номер ЛС]
,ss.B_EE [ФЛ/ЮЛ]
,erp.N_Code [код УП]
,erp.C_Name /*count(1) */ [наименование УП]
,erp.string15 [код ту ЭСК]
FROM IE.CD_BUF_Imp_109_First_Integration_ToP_TU_Log  cd
inner join SD_Divisions sd
on sd.LINK=cd.F_Division
inner join dbo.ED_Registr_Pts erp
on erp.LINK=cd.F_Registr_Pts
inner join dbo.SD_Subscr ss
on ss.LINK=erp.F_Subscr
WHERE 1=1
and cd.N_Code is null
and cd.RP_C_Code_Tu_ESK is null
and ss.LINK>0
and erp.string15 is null
order by sd.C_Name,ss.C_Number,erp.N_Code
--and 
--group by sd.C_Name,ss.B_EE
--and F_Division = 71

--отрицательные ФЛ
select distinct
ss.C_Number,
ss.N_Code
--* 
from PE.fd_Charge_Details fd
inner join SD_Subscr ss
on ss.LINK=fd.F_Subscr
inner join dbo.ED_Meter_Readings emr
on emr.LINK=fd.F_Meter_Readings
where 1=1
and fd.F_Division=41
and fd.N_Period=202110
and fd.N_Quantity<0
and emr.F_Readings_Status <>4


-- Поиск данных в коде
-- vpf - views, procedures, functions ...
-- ПОИСК в коде представлений, процедур, функций, триггеров
-- D     DEFAULT_CONSTRAINT
-- FN    SQL_SCALAR_FUNCTION
-- IF    SQL_INLINE_TABLE_VALUED_FUNCTION
-- P     SQL_STORED_PROCEDURE
-- TF    SQL_TABLE_VALUED_FUNCTION
-- TR    SQL_TRIGGER
-- V     VIEW
DECLARE @seach_text varchar(255);
SET @seach_text = '1026 '
SELECT o.type_desc AS [тип объекта], schema_name(o.[schema_id]) AS [схема], o.name AS [наименование], schema_name(o.[schema_id]) + '.' + o.name AS [полное наименование]
    --,(SELECT TOP 1 LoginName
    --  FROM SysUse.dbo.[Log]
    --  WHERE DBName IN ('Omnis', 'Omnis_old') AND EventType <> 'GRANT_DATABASE' AND EventType <> 'REVOKE_DATABASE'
    --        --AND EventType LIKE 'CREATE_%'
    --        AND SchemaName = schema_name(o.[schema_id]) 
    --        AND ObjectName = o.name
    --        AND LoginName <> 'COMPULINK\d-vanyulin'
    --        AND LoginName <> 'COMPULINK\E-Pavlichenko'
    --        AND LoginName <> 'sa'
    --  ORDER BY D_Date DESC) AS [логин]
FROM sys.sql_modules AS m
        INNER JOIN sys.objects AS o 
            ON m.[object_id] = o.[object_id] 
            --AND o.[name] LIKE 'RPT_%'
            AND o.type IN ('FN', 'IF', 'P', 'TF', 'TR', 'V')
            --AND o.type IN ('P')
WHERE m.Definition LIKE '%' + @seach_text + '%'
    --AND schema_name(o.[schema_id]) = 'PE'
ORDER BY o.type DESC, /*[логин], */o.[schema_id], o.name
GO

--раздел мнрс по процедуру
select cft.C_Display_Name from dbo.CS_Actions  ca
inner join dbo.CS_Custom_Fileld_Tables cft
on cft.LINK=ca.F_Custom_Fileld_Tables
where C_SQL_SP_Name like '%IE.CP_PTS_Matching_Create_NSI%'

--сбросить права
exec SVC.CP_Restore_Security_Settings @schema_name='XRPT',
	@object_name = 'RPT_109_Consolidate_Info'




--дашборд - консолидация
exec XRPT.RPT_109_Consolidate_Info @F_Division=0,@N_Year=2022,@N_Month=1,@B_Job=1

exec sp_WhoIsActive

select distinct D_Session,D_Date_Now from tmp.RPT_109_Consolidate_Info 
--where D_Date_Now between '20220408' and '20220409'
order by D_Date_Now desc

delete t
from tmp.RPT_109_Consolidate_Info t
where t.D_Session=
'95D24BB3-8038-4EFD-8C7E-D0FB03E6F771'





select * FROM dbo.XV_Calc_Sources AS xcs WHERE xcs.C_Const like 'XCS_%'


select * from EE.FD_Paysheets_Details AS fpd where link in (42153121,42468741)

select * from EE.FD_Paysheets_Details where link = 45020101

--
update fpd
set fpd.B_Main=0
from EE.FD_Paysheets_Details AS fpd where link in (42468741)


select count(1),ep.S_Create_Date,epp.G_Session_ID from EE.ED_Pts_DMZ ep
inner join EE.ED_Pts_Period_DMZ epp
on epp.F_Pts_DMZ=ep.LINK
where 1=1
and ep.F_Division=51
and epp.G_Session_ID='285FDD5E-61B5-4F3C-A404-D6C30294FE86'
group by ep.S_Create_Date,epp.G_Session_ID
order by ep.S_Create_Date desc

select 

--EE.ED_Pts_DMZ

--данные сбыта по коду ЭСК
select top 5 pd.*
from pe.ED_Pts_Period_DMZ pd
inner join pe.ED_Pts_DMZ ep
on ep.LINK=pd.F_Pts_DMZ
where 1=1
and ep.C_Partner_Number='126001003420'
--and pd.LINK='3b4cdf20-41c9-44cf-83a7-a59d8f40d8a0'
and pd.N_Period='202201'
group by D_Date_Prev,D_Date,N_Period
order by N_Period desc

--статусы сопост УП КА
SELECT epd.F_Registr_Pts,epd.F_Accept_Status, count(epd.link)

FROM PE.ED_Pts_DMZ AS epd
group by epd.F_Registr_Pts,epd.F_Accept_Status

having count(epd.F_Registr_Pts)>1 
order by count(epd.F_Registr_Pts) desc

--настрока сопост УП КА по линкку
SELECT *
FROM PE.ED_Pts_DMZ AS epd --where epd.F_Registr_Pts=4091401


where epd.link='d486d7ab-badf-42ec-b7d4-0023b6f97c6f'

--проверка методов расчет в сетях и сбыте
SELECT
     ss.N_Code
    ,eppd.N_Quantity_Stat
    ,eppd.N_Quantity_Norm
    ,t.N_Quantity_Odds
FROM PE.ED_Pts_DMZ AS epd
    INNER JOIN pe.ED_Pts_Period_DMZ AS eppd
        ON eppd.F_Pts_DMZ = epd.LINK 
        AND eppd.F_Division = epd.F_Division
    OUTER APPLY
        (
            SELECT
                fcd.LINK
                ,ecm.C_Name
            FROM PE.FD_Charges AS fc
                INNER JOIN PE.FD_Charge_Details AS fcd
                    ON fcd.F_Charges = fc.LINK
                    AND fc.N_Period = fcd.N_Period
                INNER JOIN pe.FD_Charge_Details_Ex AS fcde
                    ON fcde.LINK = fcd.F_Charge_Details_Ex 
                    AND fcde.F_Division = fcd.F_Division
                INNER JOIN dbo.ES_Calc_Methods AS ecm
                    ON ecm.LINK = fcde.F_Calc_Methods
            where ecm.LINK = 1
            AND fcd.N_Period = eppd.N_Period
            AND fcd.F_Registr_Pts = epd.F_Registr_Pts
        ) as c
    INNER JOIN dbo.ED_Registr_Pts_Disagreements as d
        ON d.F_Registr_Pts = epd.F_Registr_Pts
        AND d.N_Period = eppd.N_Period
    INNER JOIN dbo.ED_Registr_Pts as erp
        on erp.F_Division = d.F_Division
        AND erp.LINK = d.F_Registr_Pts
    INNER JOIN dbo.SD_Subscr ss
        on ss.F_Division = erp.F_Division
        AND ss.LINK = erp.F_Subscr
    INNER JOIN PE.UI_EF_Registr_Pts_Integration_ESK(202201) AS t --select top 5 * from PE.UI_EF_Registr_Pts_Integration_ESK(202201) AS t
        on t.F_Registr_Pts = erp.LINK
WHere eppd.N_Period = 202201
AND (eppd.N_Quantity_Stat > 0
OR eppd.N_Quantity_Norm > 0)
AND c.LINK IS NOT NULL
AND epd.F_Division IN (50,51)
--AND ISNULL(d.N_Cons_DA,0) > 0
--eppd.LINK = 'e15b1e65-50dc-4b86-997e-c792decc0225'
--SELECT
--  ecm.C_Name
--FROM PE.FD_Charges AS fc
--  INNER JOIN PE.FD_Charge_Details AS fcd
--      ON fcd.F_Charges = fc.LINK
--      AND fc.N_Period = fcd.N_Period
--  INNER JOIN pe.FD_Charge_Details_Ex AS fcde
--      ON fcde.LINK = fcd.F_Charge_Details_Ex 
--      AND fcde.F_Division = fcd.F_Division
--  INNER JOIN dbo.ES_Calc_Methods AS ecm
--      ON ecm.LINK = fcde.F_Calc_Methods
--where ecm.LINK = 1
--and fcd.N_Period = 202201


select * from ES_Device_Types


SELECT
     sd.C_Name
	 ,eppd.N_Period
    ,sum(eppd.N_Quantity_Full)
FROM PE.ED_Pts_DMZ AS epd
    INNER JOIN pe.ED_Pts_Period_DMZ AS eppd
        ON eppd.F_Pts_DMZ = epd.LINK 
        AND eppd.F_Division = epd.F_Division

    INNER JOIN dbo.SD_Subscr ss
        on ss.F_Division = epd.F_Division
        AND ss.LINK = epd.F_Subscr
	inner join dbo.SD_Divisions sd
		on sd.link=epd.F_Division
WHere 1=1
--eppd.N_Period = 202201
AND epd.F_Division IN (50,51)
group by sd.C_Name,eppd.N_Period--,eppd.N_Quantity_Full




drop table #tmp_pts
SELECT
     sd.C_Name
	 ,eppd.N_Period
    ,sum(eppd.N_Quantity_Full) as N_Quantity_Full
	,sum(eppd2.N_Quantity) as N_Quantity
into #tmp_pts
FROM dbo.SD_Divisions sd
inner join dbo.ED_Registr_Pts erp
on erp.F_Division=sd.link
inner join  PE.ED_Pts_DMZ AS epd
on epd.F_registr_pts=erp.LINK
and sd.link=epd.F_Division
    INNER JOIN pe.ED_Pts_Period_DMZ AS eppd
        ON eppd.F_Pts_DMZ = epd.LINK 
        AND eppd.F_Division = epd.F_Division
    --INNER JOIN dbo.SD_Subscr ss
    --    on ss.F_Division = epd.F_Division
    --    AND ss.LINK = epd.F_Subscr


inner join dbo.ED_Registr_Pts erp2
on erp2.F_Division=sd.link
inner join ee.ED_Pts_DMZ AS epd2
on epd2.F_registr_pts=erp2.LINK
and sd.link=epd2.F_Division
    INNER JOIN ee.ED_Pts_Period_DMZ AS eppd2
        ON eppd2.F_Pts_DMZ = epd2.LINK 
        AND eppd2.F_Division = epd2.F_Division
WHere 1=1
--eppd.N_Period = 202201
AND epd.F_Division=epd2.F_Division
--IN (50,51)
group by sd.C_Name,eppd.N_Period--,eppd.N_Quantity_Full
select * from #tmp_pts


select * from dbo.SD_Conn_Points scp
where scp.F_Division=51

select 
sd.C_Name
--ЛС
,ss.B_EE
,ss.bit2  [Соц. поддержка]
,ss.bit11 [Сельское население]
,ss.bit12 [Принадлежность сезонности]
--Объект							
,scp.bit1	[Наличие лифта			]
,scp.bit11	[Надворные постройки	]
,scp.bit14	[Циркуляционный насос	]
,scp.bit2	[Общедомовой учет		]
,scp.bit6	[Центральное отопление	]
,scp.bit7	[Горячее водоснабжение	]
,scp.int6	[Количество этажей		]
,sct.C_Name
--помещение
,scps.bit7  [Электроплита]
,scps.bit8  [Электроотопление]
,scps.bit10 [Электроводонагреватель]
,scps.bit11 [Теплый пол]
,sum(scq.N_Square)
,sum(scq.N_Placement_Count)
from dbo.SD_Subscr ss
inner join dbo.SD_Divisions sd
on sd.LINK=ss.F_Division
and ss.LINK>0
inner join dbo.ED_Registr_Pts erp
on erp.F_Subscr=ss.LINK
inner join dbo.ED_Network_Pts enp
on enp.LINK=erp.F_Network_Pts
inner join dbo.SD_Conn_Points scp
on scp.link=enp.F_Conn_Points
left join dbo.SD_Conn_Points_Sub scps
on scps.F_Conn_Points=scp.LINK
left join dbo.SS_Conn_Status_Types sct
on sct.LINK=scp.F_Conn_Status_Types
left join dbo.SD_Contract_Squares scq
on scq.F_Conn_Points_Sub=scps.LINK
--left join dbo.SD_Conn_Points_Sub scps2
--on scps2.F_Conn_Points=scps.LINK
--where ss.link=19884681
where sd.LINK=61
group by 
sd.C_Name,ss.B_EE,ss.bit2,ss.bit11,scps.bit7,scps.bit8,scps.bit10,scps.bit11
,scp.bit1	
,scp.bit11	
,scp.bit14	
,scp.bit2	
,scp.bit6	
,scp.bit7	
,scp.int6	
,ss.bit12
,sct.C_Name
order by sd.C_Name,ss.B_EE,ss.bit2,ss.bit11,scps.bit7,scps.bit8,scps.bit10,scps.bit11
,scp.bit1	
,scp.bit11	
,scp.bit14	
,scp.bit2	
,scp.bit6	
,scp.bit7	
,scp.int6
,ss.bit12
,sct.C_Name


SELECT * FROM dbo.CS_Conn_Types   WHERE C_Const = 'CT_Porch'

select 
edm.C_Name,
edm.LINK,
emr.S_Create_Date,
emr.D_Date,
count(1) from 
ED_Meter_Readings  emr
inner join ES_Delivery_Methods edm
on edm.LINK=emr.F_Delivery_Methods
where emr.F_Division=41
and edm.LINK=158
and emr.D_Date<'20220301'
GROUP BY edm.C_Name,emr.S_Create_Date,edm.LINK,emr.D_Date
order by emr.D_Date

--select * from SD_Divisions

begin tran
delete emr
from 
ED_Meter_Readings emr
inner join ES_Delivery_Methods edm
on edm.LINK=emr.F_Delivery_Methods
where emr.F_Division=41
and edm.LINK=158
and emr.D_Date<'20220301'

commit



--удаление данных из таблицы кусками по 10 000
drop table #tbl_ED_Meter_Readings;

SELECT F_Division, F_Devices, LINK, ROW_NUMBER() over(order by D_Date) as ID
INTO #tbl_ED_Meter_Readings
FROM dbo.ED_Meter_Readings
WHERE F_Division = 41
and F_Delivery_Methods=158
and D_Date<'20220401'
order by D_Date ASC
select MAX(ID) FROM #tbl_ED_Meter_Readings;  -- 12349132	215569

SELECT DISTINCT F_Division FROM #tbl_ED_Meter_Readings

DECLARE @i bigint, @i_max bigint;
SET @i = 1;
select @i_max = max(ID) FROM #tbl_ED_Meter_Readings;

WHILE (@i < @i_max + 10000)
BEGIN
	DELETE TOP (10000) FROM MR
	FROM #tbl_ED_Meter_Readings T
		INNER JOIN dbo.ED_Meter_Readings MR
			ON MR.F_Division = T.F_Division
			AND MR.F_Devices = T.F_Devices
			AND MR.LINK = T.LINK
	WHERE T.ID >= @i AND T.ID < @i + 10000
	PRINT @i;
	SET @i = @i + 10000;
END


--проверка перекрутов при обработчике показаний
select 
emr.N_Value [prev]
,emr.D_Date [D_Date prev]
,emr2.N_Value [tek]
,emr2.D_Date [D_Date tek]
,ed.C_Serial_Number
,ed.LINK 
from ED_Meter_Readings emr
inner join ED_Devices ed
on ed.LINK=emr.F_Devices
left join ED_Meter_Readings emr2
on emr2.MR_LINK_Prev=emr.LINK
where 1=1
and emr.F_Division=51
and emr.F_Delivery_Methods in (44,15)
and emr.N_Value<>round(emr.N_Value,0,1)
and round(emr.N_Value,0,1)=round(emr2.N_Value,0,1)
--and ed.C_Serial_Number='012506167243055'
and (emr2.D_Date>='20220401' and emr2.D_Date<'20220501')
and ed.B_PE=1
order by ed.LINK