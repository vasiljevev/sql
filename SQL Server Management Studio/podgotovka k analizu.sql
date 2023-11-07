select * from dbo.SD_Divisions where F_Division is not null

declare @p4 varchar(max),
@id uniqueidentifier,
@Division int,
@Division_1 int,
@Year int,
@Month int
set @p4=NULL
set @id=NEWID()
set @Division=51
set @Year=2023
set @Month=5
set @Division_1= CONVERT(int,cast(@Division-1 as int))
--select * from dbo.SD_Divisions where F_Division is not null
--exec EE.OP_ED_Network_Balance_Operate @Action_id=@id,@PK=NULL,@F_Division=@Division,@Status_Msg=@p4 output,@Year=@Year,@Month=@Month
--exec PE.OP_ED_Network_Balance_Operate @Action_id=@id,@PK=NULL,@F_Division=@Division,@Status_Msg=@p4 output,@Year=@Year,@Month=@Month
--exec EE.OP_Generate_Data_Analizer @Action_id=@id,@PK=NULL,@F_Division=@Division,@Status_Msg=@p4 output,@svsubdiv=103,@N_Month=@Month,@N_Year=@Year
exec PE.OP_Generate_Data_Integration_ESK @Action_id=@id,@PK=NULL,@F_Division=@Division,@Status_Msg=@p4 output,@svsubdiv=3,@N_Month=@Month,@N_Year=@Year
--exec XRPT.RPT_109_Consolidate_Info @F_Division=@Division_1,@N_Year=@Year,@N_Month=@Month,@B_Job=1
select @p4



select distinct D_Session,D_Date_Now,* from tmp.RPT_109_Consolidate_Info 
where D_Session='0486C0B0-8B64-4722-8FBA-59F2D821AF6F'
--D_Date_Now between '20220408' and '20220409'

order by D_Date_Now desc

delete t
from tmp.RPT_109_Consolidate_Info t
where t.D_Session=
'B33B977B-F04B-4542-9271-29A38AE6346B'


exec XRPT.RPT_109_Consolidate_Info @F_Division=50,@N_Year=2022,@N_Month=4,@B_Job=1

--declare @p4 varchar(max),
--		@id uniqueidentifier
--set @p4=NULL
--set @id=NEWID()

--exec EE.OP_Generate_Data_Analizer @Action_id=@id,@PK=NULL,@F_Division=51,@Status_Msg=@p4 output,@svsubdiv=103,@N_Month=4,@N_Year=2022
--select @p4



select * from OmniUS_VE_Orig.dbo.DS_Docum_Types_Statuses where F_Docum_Types =37

select 
D_Date,N_Value
 from ED_Meter_Readings where F_Devices=79475601
order by D_Date


select F_Devices,D_Date, N_Value

from IE.CD_BUF_Imp_109_First_Integration_Meter_Readings_Log lg
where lg.F_Division = 41
and C_Serial_Number='007789061052177'
order by D_Date

select top 5 * from Tmp.Tmp_Bufer_Meter_Readings 
where 1=1
--and F_Meter_Readings is null
and C_Serial_Number like '%7789061052177%'
order by D_Date