select 
sd.C_Name			 as [Филиал]
,ssd.C_Name			 as [участок]
,ss.B_EE			 as [ЮЛ/ФЛ]
,ss.N_Code			 as [№ ЛС]
,ss.C_Number		 as [Альт № ЛС]
,erp.N_Code			 as [Код УП]
,erp.C_Name			 as [Наименование УП]
,ed.C_Serial_Number	 as [Серийный номер ПУ]
,ss.LINK as [guid ЛС]
,erp.LINK as [guid УП]
,ed.LINK as [guid ПУ]
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
--and sd.C_Name='РязаньЭнерго (ф)'
and (erp.D_Date_End is null or erp.D_Date_End > getdate())
and ss.B_EE=1
and ss.F_Division=51
order by sd.LINK,ssd.LINK,ss.B_EE desc,ss.LINK

--and ss.N_Code=20724003283
