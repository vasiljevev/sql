select 
csu.C_Category, 
csu.C_Name,
csu.C_Note,
csu.C_Const,
csuv.C_Value,
cu.C_Name
from CS_UIVars csu
	inner join CS_UIVars_Values csuv
		on csuv.F_UIVars=csu.LINK
	inner join CS_Users cu
		on cu.LINK=csuv.S_Owner
where csu.C_Name like '%ведение%'
order by csu.C_Category


select csu.C_Category, csu.C_Name,csu.C_Note,csuv.C_Value 
from CS_UIVars csu
inner join CS_UIVars_Values csuv
on csuv.F_UIVars=csu.LINK
where csu.C_Const='IsContractManagmentByDocums'
order by csu.C_Category


update csuv
set csuv.C_Value='True'
from CS_UIVars csu
inner join CS_UIVars_Values csuv
on csuv.F_UIVars=csu.LINK
where csu.C_Const='IsContractManagmentCheckDocums'

select * from CS_Partner_Roles