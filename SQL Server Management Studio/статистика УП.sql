--select 
--ebt.C_Short_Name,
--estb.C_Name,
--count(erp.link)
--from ED_Registr_Pts erp
--left join ES_Balance_Types ebt
--on ebt.LINK=erp.F_Balance_Types
--left join ES_Balance_Type_Details estb
--on estb.LINK=erp.F_Balance_Type_Details
--where erp.D_Date_End is null
--GROUP BY ebt.C_Short_Name,estb.C_Name
--order by ebt.C_Short_Name,estb.C_Name

select 
ebt.C_Short_Name,
estb.C_Name,
count(erp.link) as [кол-во УП]
from ES_Balance_Types ebt
inner join ES_Balance_Type_Details estb
on ebt.LINK=estb.F_Balance_Types
left join ED_Registr_Pts erp
on erp.F_Balance_Types=ebt.LINK
and estb.LINK=erp.F_Balance_Type_Details
where erp.D_Date_End is null
GROUP BY ebt.C_Short_Name,estb.C_Name
order by ebt.C_Short_Name,estb.C_Name
