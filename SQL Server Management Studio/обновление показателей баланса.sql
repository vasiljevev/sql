select count(erp.link) from ED_Registr_Pts erp
left join ee.FD_Paysheets_Details fcd
	on fcd.F_Registr_Pts=erp.LINK
	and fcd.F_Division=erp.F_Division
left join ee.FD_Paysheets_Details_Ex_Tech e2
	on e2.link=fcd.F_Paysheets_Details_Ex_Tech
	and e2.F_Division=fcd.F_Division
where 1=1
and (erp.F_Balance_Type_Details=33 or e2.F_Balance_Type_Details=33)

select * from ES_Balance_Type_Details

delete from  ES_Balance_Type_Details where link = 52


exec sp_WhoIsActive

--обновление ДПБ на УП
update erp
set erp.F_Balance_Type_Details=55
--select count(fcd.link) 
from ED_Registr_Pts erp
left join ee.FD_Paysheets_Details fcd
	on fcd.F_Registr_Pts=erp.LINK
	and fcd.F_Division=erp.F_Division
left join ee.FD_Paysheets_Details_Ex_Tech e2
	on e2.link=fcd.F_Paysheets_Details_Ex_Tech
	and e2.F_Division=fcd.F_Division
where 1=1
and (erp.F_Balance_Type_Details=53 or e2.F_Balance_Type_Details=53)

update erp
set erp.F_Balance_Type_Details_Sec=55
--select count(fcd.link) 
from ED_Registr_Pts erp
left join ee.FD_Paysheets_Details fcd
	on fcd.F_Registr_Pts=erp.LINK
	and fcd.F_Division=erp.F_Division
left join ee.FD_Paysheets_Details_Ex_Tech e2
	on e2.link=fcd.F_Paysheets_Details_Ex_Tech
	and e2.F_Division=fcd.F_Division
where 1=1
and (erp.F_Balance_Type_Details_Sec=53 or e2.F_Balance_Type_Details=53)



--обновление ДПБ на РВ
update e2
set e2.F_Balance_Type_Details=55
--select count(fcd.link) 
from ee.FD_Paysheets_Details_Ex_Tech e2
left join ee.FD_Paysheets_Details fcd
	on e2.link=fcd.F_Paysheets_Details_Ex_Tech
	and e2.F_Division=fcd.F_Division
left join ED_Registr_Pts erp
	on fcd.F_Registr_Pts=erp.LINK
	and fcd.F_Division=erp.F_Division
where 1=1
and (erp.F_Balance_Type_Details=53 or e2.F_Balance_Type_Details=53)

--обновление ДПБ в балансах
update enb
set enb.F_Balance_Type_Details=55
--select * 
from dbo.ED_Network_Balance enb
where F_Balance_Type_Details=53

delete from  ES_Balance_Type_Details where link = 53
delete from  dbo.ES_Network_Items_Conf where F_Balance_Type_Details_Sec= 53 or F_Balance_Type_Details= 53


select distinct erpcm.F_Division from ED_Registr_Pts_Calc_Methods erpcm
left join ED_Registr_Pts erp
on erp.LINK=erpcm.F_Registr_Pts
and erp.F_Division=erpcm.F_Division
where erpcm.F_Calc_Methods=52

--select distinct erpcm.F_Division 
update erpcm
set erpcm.F_Calc_Methods=211
from ED_Registr_Pts_Calc_Methods erpcm
left join ED_Registr_Pts erp
on erp.LINK=erpcm.F_Registr_Pts
and erp.F_Division=erpcm.F_Division
where erpcm.F_Calc_Methods=52


delete from ES_Calc_Methods where link = 52