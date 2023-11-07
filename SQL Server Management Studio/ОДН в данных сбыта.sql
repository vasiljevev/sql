select  
ss.C_Number,
ss.C_Code,
erp.N_Code

from EE.ED_Pts_Period_DMZ epp
inner join EE.ED_Pts_DMZ ep
on ep.LINK=epp.F_Pts_DMZ
inner join SD_Subscr ss
on ss.LINK=ep.F_Subscr
inner join ED_Registr_Pts erp
on erp.LINK=ep.F_Registr_Pts

where 1=1
and epp.F_Division=51
and (epp.N_Calc_Cons is not null and epp.N_Calc_Cons <>0)
and epp.N_Period=202206
order by epp.S_Create_Date desc


select * from PE.ED_Pts_DMZ epp where link = '77e360c2-f283-4bf6-9f96-049aa6c0dd20'



delete from PE.ED_Pts_Period_DMZ  where F_Pts_DMZ = '129c6526-a623-467f-a239-c7d3de19cf4c'
go
delete from PE.ED_Pts_DMZ  where link = '129c6526-a623-467f-a239-c7d3de19cf4c'
go