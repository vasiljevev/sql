declare @N_Period int,
		@F_Sale_Category tinyint
set @N_Period=202201
set @F_Sale_Category=1
select --distinct 
sd.C_Name
--,uaa.C_Calc_Methods
--,uaa.C_Div_Name
,uaa.C_Number
,uaa.C_Subscr_Name
,uaa.F_Subscr
--,uaa.
,sum(uaa.N_Quantity_Main) [Полный расход]
,sum(uaa.N_Quantity) [расход сети]
,sum(uaa.N_ESK_Quantity) [расход эск]
,sum(uaa.N_Quantity_Odds) [разница]
,count(1) [кол-во точек]
from EE.UI_AF_Analizer(@N_Period,@F_Sale_Category) uaa

left join dbo.SD_Divisions sd
on sd.LINK=uaa.F_Division
--left join dbo.
where 1=1
and uaa.B_EE=1
and uaa.RP_F_Balance_Type=16
and uaa.RP_F_Sale_Items=67
and uaa.B_Suspicious=1
--and sd.C_Name='Мариэнерго (ф)'
--and uaa.
--and uaa.
--and uaa.
--and uaa.
--and uaa.
group by
sd.LINK
,sd.C_Name
,uaa.F_Subscr
,uaa.C_Subscr_Name
,uaa.C_Number
order by sd.LINK,sum(uaa.N_Quantity_Odds) desc


select * from PE.UI_EF_Registr_Pts_Integration_ESK(202201)


select top 5 ss.C_Code,ss.C_Number, pd.F_Registr_Pts, ppd.N_Losses,ppd.N_Quantity_Act,ppd.N_Quantity_Norm,ppd.N_Quantity_ODN,ppd.N_Quantity_Stat,ppd.N_Device_Value, ppd.N_Quantity_Full,ppd.* from PE.ED_Pts_Period_DMZ AS PPD
inner join pe.ED_Pts_DMZ pd
on pd.LINK=ppd.F_Pts_DMZ
inner join SD_Subscr ss
on ss.LINK=pd.F_Subscr
				
	WHERE	1=1
		AND PPD.N_Quantity_ODN    <> 0
		and ppd.F_Division=51
		and ppd.N_Period=202201
		and ss.C_Number='126003000156'
		--and PPD.N_Losses is not null


select * from EE.ED_Pts_Period_DMZ AS PPD2
				
	WHERE	1=1
		--AND PPD2.N_Quantity_ODN <> 0
		and ppd2.F_Division=51
		and ppd2.N_Period=202201

		select top 5 *  from ee.FD_Paysheets_details
		select top 5 *  from ee.FD_Paysheets

		select top 5 * from [EE].[FVT_Paysheets_Details]




		
		select * from ED_Registr_Pts where N_Code = '080000010659' and F_Division=90

		select * from SD_Divisions



select 
erp.D_Date_End as erp_D_Date_End,
epd.D_Date_Begin as epd_D_Date_Begin,
epd.F_Registr_Pts,
epd.B_DiffDeviceNum,
epd.S_Create_Date, 
epd.C_Serial_Number,
ppd.N_Period,
ppd.N_Quantity
--,epd.*
from EE.ED_Pts_DMZ  epd
left join ED_Registr_Pts erp
on erp.LINK=epd.F_Registr_Pts
left join ee.ED_Pts_Period_DMZ ppd
on ppd.F_Pts_DMZ=epd.LINK
where 1=1
--and C_Registr_Pts_Code = '121000023177' or F_Registr_Pts = 51584081;
and erp.D_Date_End is not null

select * from PE.UI_EF_Registr_Pts_Integration_ESK(202201) uaa
WHERE 1=1
AND uaa.F_Division=51
and uaa.B_Suspicious=1


declare @N_Period int
set @N_Period=202201
select
sd.C_Name as sd_C_Name
,sbd.C_Name as sbd_C_Name
,uaa.N_Period as N_Period
,sum(uaa.N_Quantity)							 as N_Quantity
,sum(uaa.N_Quantity_Diff)						 as N_Quantity_Diff
,sum(uaa.N_Quantity_Net)						 as N_Quantity_Net
,sum(uaa.N_Quantity_Norm)						 as N_Quantity_Norm
,sum(uaa.N_Quantity_Odds)						 as N_Quantity_Odds
,sum(uaa.N_Quantity_Stat)						 as N_Quantity_Stat
,sum(uaa.Percentage_Difference_N_Quantity)		 as Percentage_Difference_N_Quantity
,sum(uaa.N_ESK_Act_Cons)						 as N_ESK_Act_Cons
,sum(uaa.N_ESK_Calc_Cons)						 as N_ESK_Calc_Cons
,sum(uaa.N_ESK_Cons)							 as N_ESK_Cons
,sum(uaa.N_ESK_Losses)							 as N_ESK_Losses
,sum(uaa.N_ESK_Quantity)						 as N_ESK_Quantity
from PE.UI_EF_Registr_Pts_Integration_ESK(@N_Period) uaa
inner join dbo.SD_Divisions sd
on sd.LINK=uaa.F_Division
inner join dbo.SD_Subdivisions sbd
on sbd.LINK=uaa.F_SubDivision
where 1=1
and uaa.B_Suspicious=1
--and sd.LINK=71
group by
sd.C_Name
,sbd.C_Name
,uaa.N_Period


--declare @N_Period int
--set @N_Period=202201
select
uaa.F_Division as F_Division
,uaa.F_SubDivision as F_SubDivision
,uaa.N_Period as N_Period
,sum(uaa.N_Quantity)							 as N_Quantity
,sum(uaa.N_Quantity_Diff)						 as N_Quantity_Diff
,sum(uaa.N_Quantity_Net)						 as N_Quantity_Net
,sum(uaa.N_Quantity_Norm)						 as N_Quantity_Norm
,sum(uaa.N_Quantity_Odds)						 as N_Quantity_Odds
,sum(uaa.N_Quantity_Stat)						 as N_Quantity_Stat
,sum(uaa.Percentage_Difference_N_Quantity)		 as Percentage_Difference_N_Quantity
,sum(uaa.N_ESK_Act_Cons)						 as N_ESK_Act_Cons
,sum(uaa.N_ESK_Calc_Cons)						 as N_ESK_Calc_Cons
,sum(uaa.N_ESK_Cons)							 as N_ESK_Cons
,sum(uaa.N_ESK_Losses)							 as N_ESK_Losses
,sum(uaa.N_ESK_Quantity)						 as N_ESK_Quantity
from PE.UI_EF_Registr_Pts_Integration_ESK(202201) uaa
inner join dbo.SD_Divisions sd
on sd.LINK=uaa.F_Division
inner join dbo.SD_Subdivisions sbd
on sbd.LINK=uaa.F_SubDivision
where 1=1
and uaa.B_Suspicious=1
--and sd.LINK=71
group by
uaa.F_Division 
,uaa.F_SubDivision 
,uaa.N_Period 
