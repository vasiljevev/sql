DECLARE
    --@N_MKD_Readings_FirstDayOfMonth INT,
    --@N_MKD_Readings_LastDayOfMonth INT,
    --@D_Date DATETIME,
    @C_Start_Date SMALLDATETIME,
    @C_End_Date SMALLDATETIME,
    @C_Device_ID UNIQUEIDENTIFIER
SELECT
    @C_Start_Date = '20220201 00:00:00',    --��������� ���� ������� ���������
    @C_End_Date   = '20220302 00:00:00',        --�������� ���� ������� ���������
    @C_Device_ID = 'def267d2-08a8-4283-b4b6-4116b2a168d4'   --��� ���������� ��. ���� NULL, �� �� ���� ��
SELECT
    @C_Start_Date,
    @C_End_Date
--select count(*) from  dbo.ED_Meter_Readings where D_date between @C_Start_Date and @C_End_Date and cast(s_create_date as date) = cast(getdate() as date) and F_Delivery_Methods=18
--select * from  dbo.ED_Meter_Readings where D_date between @C_Start_Date and @C_End_Date and cast(s_create_date as date) = cast(getdate() as date) and F_Delivery_Methods=18
--EXEC sp_WhoIsActive
--kill 58
EXEC IE.IMP_Readings_Complete
    @C_Start_Date = @C_Start_Date,
    @C_End_Date = @C_End_Date, 
    @C_Device_ID = @C_Device_ID,
    @B_Load_Integral = 0, -- ���
    @B_Load_Interval = 1  -- ���

	--N_Error = 1		- �� ������� �� ������� ������������ � �������
	--N_Error = 2		- �� �� �������� ��������������� �����(F_Time_Zones) � ����� ������ � �����(N_Channel)
	--N_Error = 4		- ������ � ���, ��� ����������� ������ � ��� �� ���������
	--N_Error = 8		- �������������� �� ��������� �������� (�� �����)
	--N_Error = 16	- E��� �������� "������������ ������" �� ������, � ������� �� ���� ��� � ������� ��� �������� (������� �� null)
	--N_Error = 32	- ��� ���������� �������� ������ ���������� �������� ������
	--N_Error = 64	- ��� �������� �������� �������� ������
	--N_Error	= 128	- ������� ������� ������� �� ������� �������
	--N_Error	= 256	- ������� ������������ "������" ���������
	--N_Error	= 512	- �� �� ������� ��������������� ��� �������(F_Energy_Types)
	--N_Error	= 1024	- �� �� �������
	--N_Error = 2048	- �������� ������ ������ ��� 1 000 000 000, ��� ����� �������� ������� 

select *  frOM IE.CD_Readings  wHERE G_Session = '0d60405d-e2b7-41cd-b756-48f8e445b1f6' --AND n_pERIOD = 202109
select NEWID()
select NEWID()
select NEWID()

select * from ED_Devices where C_Serial_Number like '%11486103763037%'
select * from ED_Devices where string4='04db4a4d-e24a-4d25-be24-c411d546e0b9'
select * from ED_Registr_Pts where link = 345301

SELECT TOP (50) CIS.*
FROM IE.CS_Integration_Sessions AS CIS
WHERE 1=1
--and C_SSIS_Name='MEK_Loader.exe'
and G_Session_ID='1CE31998-08CC-42C5-8FAB-60496167AB24' --1CE31998-08CC-42C5-8FAB-60496167AB24
and D_start_date>='20220221'
ORDER BY D_start_date 

SELECT TOP (100) CIS.*
FROM IE.CS_Integration_Sessions AS CIS
WHERE 1=1
--and C_SSIS_Name='MEK_Loader.exe'
and G_Session_ID='55876DB3-0036-4316-92FA-09C2BAD974EA'
ORDER BY D_Start_Date desc

select top 50 * FROM IE.CD_Readings_Log_Load AS crll 
where G_Session_ID='1CE31998-08CC-42C5-8FAB-60496167AB24'


select * frOM IE.CD_Readings_Buffer 
wHERE 1=1
--and G_Session_ID = '1CE31998-08CC-42C5-8FAB-60496167AB24'
and C_ASKUE_Number='0d60405d-e2b7-41cd-b756-48f8e445b1f6'
and B_Profile=1
order by D_Date

select count(*)  frOM IE.CD_Readings_Buffer  wHERE G_Session_ID = 'D59043BA-5458-43D4-8C02-74893F15D358' and N_Value is not null


--ORDER BY S_Create_Date desc


--� �������
select top 50 * FROM IE.CD_Readings_Log_Load AS crll --where crll.G_Session_ID='B064496E-78B0-4141-884C-89DFE985F65C'
order by crll.link desc
select top 50 * FROM  IE.CD_Readings


--select count(*) from  dbo.ED_Meter_Readings where D_date between @C_Start_Date and @C_End_Date and cast(s_create_date as date) = cast(getdate() as date) and F_Delivery_Methods=18
TRUNCATE TABLE IE.CD_Readings                        -- select * from IE.CD_Readings
TRUNCATE TABLE IE.CD_Readings_Buffer                -- select * from IE.CD_Readings_Buffer

select NEWID()
select * from IE.CD_Readings_Buffer crb where crb.C_ASKUE_Number='bf48cf6c-f561-45f3-8709-51dd6fa20535' and crb.B_Profile=1 and crb.B_Status=1 and N_Energy_Type=0  order by crb.D_Date
select * from IE.CD_Readings where C_ASKUE_Number='bf48cf6c-f561-45f3-8709-51dd6fa20535'
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

select distinct cd.C_Device_Type [��� �-�],cd.C_Serial_Number,est.C_Name [��� ������],ed.string18 [��� ���� �� ����������]--,est2.C_Name
from IE.CD_Devices_ASKUE cd
inner join ED_Devices ed
on cd.F_Devices=ed.LINK
and cd.C_Code_ASKUE=ed.string4
inner join ES_Device_Types est
on est.LINK=ed.F_Device_Types
--left join ES_Device_Types est2
--on est2.C_Name like '%'+cd.C_Device_Type+'%'
where cd.F_Devices is not null
and est.C_Name= '����������� ���'
order by cd.C_Device_Type
--TRUNCATE TABLE IE.CD_Devices_ASKUE_Omnis
--TRUNCATE TABLE IE.CD_Events_TMP
--TRUNCATE TABLE IE.CD_Events_Device
--update ed set ed.string4 = null, ed.int1 = null from dbo.ED_Devices as ed

--delete from dbo.ED_Meter_Profiles  where F_Delivery_Methods=18 and N_Period=202109

--select * from ED_Meter_Profiles where F_Delivery_Methods=18 and N_Period=202109


--delete from  dbo.ED_Meter_Readings
--where F_Delivery_Methods=18
--and
--D_Date >= '20211202'

--delete from ee.FD_Paysheets
--where N_Period=202112

--delete from PE.FD_Charges 
--where N_Period=202112


exec ie.imp_Readings_RPT_Buffer_Data @N_Month=10,@N_Year=2021,@C_ASKUE_Number=N'8ebacce0-022f-48c5-9304-270fb8019c86',@G_Loading_System=N'd5ad9173-8e35-4dfc-b3f4-c1d2de8a7237' --�������



------------------����� � ����������� ��������
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
and crb.G_Session_ID='ad82a97e-2d2f-47da-880d-95b8aab96e11'
--and crb.C_ASKUE_Number='16a32e62-9b18-41a4-bf86-8005c91fe843'
and crb.N_Energy_Type=0
--and crd.N_Error=0
and crb.B_Profile=0
order by LINK desc
--and crb.G_Session_ID='2A3B94A1-74A1-4720-951C-FDF8DF900510'
--and crb.D_Date>'20211001'
--and crb.B_Profile=0
--------------------
select crb.* from IE.CD_Readings_Buffer crb 
select cr2.* FROM IE.CD_Readings AS cr2


select top 50 * FROM IE.CD_Readings_Sessions AS crs
order by crs.link desc

--����� ��������� �-� � ��������
select  ed.C_Serial_Number, tz.C_Name, et.C_name,cr2.* FROM IE.CD_Readings AS cr2
inner join ED_Devices ed
on ed.LINK=cr2.F_Device
left join FS_Time_Zones tz
on tz.LINK=cr2.F_Time_Zones
left join ES_Energy_Types et --select * from ES_Energy_Types
on et.LINK=cr2.F_Energy_Types
where 
1=1
and cr2.G_Session='2BD48945-6F29-40A4-ABA8-B5B208CB9C81'
and C_ASKUE_Number='16a32e62-9b18-41a4-bf86-8005c91fe843'
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
t.C_ASKUE_Number='bf48cf6c-f561-45f3-8709-51dd6fa20535'
order by t.link desc

select DISTINCT G_Session_ID FROM ie.CD_Readings_Buffer WHERE B_Profile = 1


UPDATE ie.CD_Readings SET N_Error = 0


----------------�������� ��������� �� ������
DECLARE @Status_Msg VARCHAR(100)
EXEC IE.IMP_Readings
@N_Year = NULL, -- ������ ������������ ������. ���
@N_Month = NULL, -- ������ ������������ ������. �����
@F_Division = 0, -- ���������
@F_SubDivision = 0, -- �������
@B_Rewrite = 0, -- ������������ ������������ ������ ������������� �����
@B_Ignore_notMeasure = 0, -- ������������ ������ �� �������������� ������ (�� ��������� ������)
@B_Ignore_Closed_Period = 0, -- ����������� ������ � �������� ������
@B_Ignore_Prev_Periods = 0, -- �� ���������� ��������� � ���������� �������
@B_Ignore_Meter_Date = 1, -- ������������ ��������� ������ ���� ���������
@C_User = 'sa', -- ������������ ����������� �������� �������
@C_SubDivisions = '10,11,12,13,14,15,16,17,18,19,2,3,4,5,6,7,8,9', -- ���������, �������
@N_Device_Type = NULL, -- ������ �� ��� ����������� ���������
@C_ASKUE_Number = null, --'bf48cf6c-f561-45f3-8709-51dd6fa20535', -- ������ �� ���� ����������
@B_Only_TFZ_Day = NULL, -- ��������� ������ �� ���� �����
@B_Interval = 0, -- ������ �������
@B_Integral = 1, -- ������ ���������
@B_Inversion = 0, -- ��� ��������
@Action_id = NULL, -- ������������� �������� (�� ������������)
@PK = 0, -- ������������� �������, �� ������� ������� �������� (�� ������������)
@B_Rewrite_Integral = 1, -- ������������ ������������ ������ ������������� �����
@G_Session_ID = '55876DB3-0036-4316-92FA-09C2BAD974EA',
@Status_Msg = @Status_Msg OUTPUT


--��������� �� ����
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


--OmniUS.dbo.CF_STRPART_Decimal(p9.[��������� �����])

select 
ed.C_Serial_Number
,ed.string4
--,emr.F_Delivery_Methods
,emr.D_date_max
from ED_Devices ed
left join (select F_Devices, max(D_date) D_date_max, F_Delivery_Methods from ED_Meter_Readings where F_Delivery_Methods=18 GROUP BY F_Devices,F_Delivery_Methods) emr
on ed.LINK=emr.F_Devices
where 
1=1
and ed.string4 is not null
--and emr.D_date_max is null
--and ed.C_Serial_Number='5082928'
and emr.F_Delivery_Methods=18
--and
--cast(emr.S_Create_Date as date) = '20211123'
and emr.D_date_max >= '20220201'
--and ed.C_Serial_Number='03024984'




--��������� ��������� � �������

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


