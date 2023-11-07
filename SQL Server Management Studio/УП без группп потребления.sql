select 
sd.C_Name			 as [������]
,ssd.C_Name			 as [�������]
,ss.B_EE			 as [��/��]
,ss.N_Code			 as [� ��]
,ss.C_Number		 as [���� � ��]
,erp.N_Code			 as [��� ��]
,erp.C_Name			 as [������������ ��]
,ed.C_Serial_Number	 as [�������� ����� ��]
,ss.LINK as [guid ��]
,erp.LINK as [guid ��]
,ed.LINK as [guid ��]
from dbo.ED_Registr_Pts erp
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
inner join SD_Divisions sd
on sd.LINK=erp.F_Division
inner join SD_Subdivisions ssd
on ssd.LINK=erp.F_SubDivision
left join ED_Devices_Pts edp
on edp.F_Registr_Pts=erp.LINK

left join ED_Devices ed
on edp.F_Devices=ed.LINK
where 1=1
and erp.int9 is null
and ss.LINK>0
--and sd.C_Name='������������ (�)'
and (erp.D_Date_End is null or erp.D_Date_End > getdate())
and ss.B_EE=1
and ss.F_Division=51
order by sd.LINK,ssd.LINK,ss.B_EE desc,ss.LINK

--and ss.N_Code=20724003283
