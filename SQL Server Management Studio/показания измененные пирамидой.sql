select --top 10
--sd.C_Name
sds.C_Name [�������]
,ss.N_Code [� ��]
,ss.C_Number [���� ����� ��]
,ss.B_EE
,dbo.CF_FIO (cp.C_Name1, cp.C_Name2, cp.C_Name3)[��]
--,edd.F_SubDivision
,edd.C_Serial_Number [C������� ����� ��]
,est.C_Name [��� �������]
,edd.string4 [��� �����]
--,edd.F_Device_Types
,emr.N_Value [��������� ����]
,emr.D_Date [���� ������ ��������� ����]
,emr.S_Create_Date [���� ������� ��������� ����]
,emr1.N_Value [��������� �����]
,emr1.D_Date   [���� ������ ��������� �����]
,emr1.S_Create_Date [���� ������� ��������� �����]
 

 

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
    and emr1.F_Delivery_Methods = 18
left join SD_Divisions sd
	on sd.LINK=edd.F_Division
left join SD_Subdivisions sds
	on sds.LINK=edd.F_SubDivision
left join ED_Devices_Pts edp
	on edp.F_Devices=edd.LINK
left join ED_Registr_Pts erp
	on  edp.F_Registr_Pts = erp.LINK
left join SD_Subscr SS
	on erp.F_Subscr = ss.LINK
left join CD_Partners cp
	on  cp.LINK = ss.F_Partners


where
--emr.F_Readings_Status<>emr.F_Readings_Status_Orig
--and
emr.F_Delivery_Methods=36
--and ss.B_EE=0
and
edd.C_Serial_Number='011486121748820'
order by sds.C_Name,ss.N_Code,ss.C_Number,edd.C_Serial_Number,emr.D_Date