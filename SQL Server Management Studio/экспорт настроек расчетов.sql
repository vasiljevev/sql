select csu.LINK as [csu], csuv.LINK as [csuv],  csu.C_Category , csu.C_Name,csu.C_Note,csuv.C_Value 
from CS_UIVars csu
inner join CS_UIVars_Values csuv
on csuv.F_UIVars=csu.LINK
--where csu.C_Const='IsUseConf_PartnerRoles_RB_F46_F23'
order by csu.C_Category


select distinct
N_Code,
c_name,
C_Const,
N_Value,
C_Note,
C_Section
from CS_Calc_Defaults
order by C_Section

select * from FS_Sale_Items

select * from ES_Calc_Methods

select * from ES_Alternative_Calc_Methods_Groups 