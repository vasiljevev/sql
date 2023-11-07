select top 10 dds.F_Partners,dds.F_Docs,ddt.C_name,COUNT(dds.F_Subscr) from 
UI_DV_Docs_Subscrs dds
inner join dbo.SD_Subscr ss
on ss.LINK=dds.F_Subscr
and (ss.D_Date_End >=GETDATE() or ss.D_Date_End is null)
inner join dbo.DD_Docs dd
on dd.LINK=dds.F_Docs

inner join dbo.DS_Docum_Types ddt
on ddt.LINK=dd.F_Docum_Types
where 1=1
--and dds.F_Subscr_Division = 51--F_Division = 51
--and F_Partners='28AE969A-6AC5-4276-90CB-5ABD9AC85BAB'
group by dds.F_Partners,dds.F_Docs,ddt.C_name
order by COUNT(dds.F_Subscr) desc


select * from CD_Partners where link = '465F62DB-1CD5-4604-9512-417B3D8D800D'