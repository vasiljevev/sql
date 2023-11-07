/*
select distinct  
enpt.C_Name, 
--erp2.F_Subscr,
ss.C_Number,
--ss.LINK,
ss2.C_Number,
--ss2.LINK,
ss.D_Date_End,
ss2.D_Date_End,
ebt.C_Name,
ebt1.C_Name,
erp.N_Code,
erp2.N_Code

--,enp.* 
from SD_Subscr ss
inner join ED_Registr_Pts erp
on erp.F_Subscr=ss.LINK
inner join ES_Balance_Types ebt
on ebt.LINK=erp.F_Balance_Types
inner join ED_Network_Pts enp
on enp.LINK=erp.F_Network_Pts
inner join ES_Network_Pts_Types enpt
on enpt.LINK=enp.F_Network_Pts_Types
left join ED_Registr_Pts erp2
	inner join ES_Balance_Types ebt1
	on ebt1.link=erp2.F_Balance_Types
	and ebt1.C_Name not in ('Прием в сети СК','Отдача из сети СК')

on erp2.F_Network_Pts=enp.LINK
left join SD_Subscr ss2
on ss2.LINK=erp2.F_Subscr
where 1=1
--and ss.link =2660781
--and ss.link<>erp2.F_Subscr
and ebt.C_Name in ('Прием в сети СК','Отдача из сети СК')
and erp2.LINK is not null
and ss.F_Division=51
and (ss.D_Date_End is null and ss2.D_Date_End is null)

*/
/*
select distinct  
enpt.C_Name, 
--erp2.F_Subscr,
ss.C_Number,
--ss.LINK,
ss2.C_Number,
--ss2.LINK,
ss.D_Date_End,
ss2.D_Date_End,
ebt.C_Name,
ebt1.C_Name,
erp.N_Code,
erp2.N_Code

--,enp.* 
from SD_Subscr ss
inner join ED_Registr_Pts erp
on erp.F_Subscr=ss.LINK
inner join ES_Balance_Types ebt
on ebt.LINK=erp.F_Balance_Types
inner join ED_Network_Pts enp
on enp.LINK=erp.F_Network_Pts
inner join ES_Network_Pts_Types enpt
on enpt.LINK=enp.F_Network_Pts_Types
left join ED_Registr_Pts erp2
	inner join ES_Balance_Types ebt1
	on ebt1.link=erp2.F_Balance_Types
	and ebt1.C_Name not in ('Прием в сети СК','Отдача из сети СК')

on erp2.F_Network_Pts=enp.LINK
left join SD_Subscr ss2
on ss2.LINK=erp2.F_Subscr
where 1=1
--and ss.link =2660781
--and ss.link<>erp2.F_Subscr
and ebt.C_Name in ('Прием в сети СК','Отдача из сети СК')
and erp2.LINK is not null
and ss.F_Division=51
and enpt.C_Name='Поставка'
--and (ss.D_Date_End is null and ss2.D_Date_End is null)
*/

update enp
set enp.F_Network_Pts_Types=1
--select distinct  
--enpt.C_Name, 
----erp2.F_Subscr,
--ss.C_Number,
----ss.LINK,
--ss2.C_Number,
----ss2.LINK,
--ss.D_Date_End,
--ss2.D_Date_End,
--ebt.C_Name,
--ebt1.C_Name,
--erp.N_Code,
--erp2.N_Code

----,enp.* 
from SD_Subscr ss
inner join ED_Registr_Pts erp
on erp.F_Subscr=ss.LINK
inner join ES_Balance_Types ebt
on ebt.LINK=erp.F_Balance_Types
inner join ED_Network_Pts enp
on enp.LINK=erp.F_Network_Pts
inner join ES_Network_Pts_Types enpt  --select * from ES_Network_Pts_Types enpt
on enpt.LINK=enp.F_Network_Pts_Types
left join ED_Registr_Pts erp2
	inner join ES_Balance_Types ebt1
	on ebt1.link=erp2.F_Balance_Types
	--and ebt1.C_Name not in ('Прием в сети СК','Отдача из сети СК')
	on erp2.F_Network_Pts=enp.LINK
	left join SD_Subscr ss2
	on ss2.LINK=erp2.F_Subscr
where 1=1
and ss.link =2660781
--and ss.link<>erp2.F_Subscr
and ebt.C_Name in ('Прием в сети СК','Отдача из сети СК')
and ss.D_Date_End is null
and erp2.LINK is not null
and ss.F_Division=51
--and enpt.C_Name='Поставка'
