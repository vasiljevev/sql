select 
ss.C_Number [alt num], 
erp.string15 [tu esk NE], 
ep.C_Subscr_Code [alt num GP], 
ep.C_Registr_Pts_Code [tu esk GP],
ep.C_Serial_Number [ed ser num GP]
,erp.* 
,ep.*
from ED_Registr_Pts erp
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
left join EE.ED_Pts_DMZ ep
on ep.C_Registr_Pts_Code=erp.string15
where erp.string15='1100023010016'