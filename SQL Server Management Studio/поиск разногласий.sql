select top 5
ss.N_Code,
ss.C_Number,

erp.N_Period,
erp.N_Cons_SO_Soc_Limit,
erp.N_Cons_SO_Soc_Over,
erp.N_Cons_SO,
erp.N_Cons_DA_Soc_Limit,
erp.N_Cons_DA_Soc_Over,
erp.N_Cons_Soc_Limit,
erp.N_Cons_Soc_Over,
erp.N_Cons,
erp.N_Cons_SO,
erp.N_Cons_DA,

erp.* 
from ED_Registr_Pts_Disagreements erp
inner join ED_Registr_Pts erp2
on erp2.LINK=erp.F_Registr_Pts
inner join SD_Subscr ss
on ss.LINK=erp2.F_Subscr
where 1=1
and erp.N_Cons_SO_Soc_Limit <> erp.N_Cons_SO_Soc_Over
and erp.N_Cons_SO_Soc_Limit > 0
and erp.N_Cons_SO_Soc_Over > 0
--and erp.N_Period>=202203
--and ss.N_Code=210590003