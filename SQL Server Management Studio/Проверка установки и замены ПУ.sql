select --top 50 
erp.F_division,
erp.LINK,
erp.N_Code,
ed2.C_Serial_Number,
ed2.D_Replace_Date,
ed2.string4,
ed.C_Serial_Number,
ed.D_Setup_Date,
ed.string4
from ED_Registr_Pts erp
inner join ED_Devices_Pts edp
on edp.F_Registr_Pts=erp.LINK
	inner join ED_Devices ed
	on ed.LINK=edp.F_Devices
	and ed.D_Replace_Date is null
		
left join ED_Devices_Pts edp2
on edp2.F_Registr_Pts=erp.LINK
		
		left join ED_Devices ed2
		on ed2.LINK=edp2.F_Devices
		and ed2.D_Replace_Date is not null
where 1=1
and ed2.LINK is not null
and ed2.string4=ed.string4
and ed2.C_Serial_Number<>ed.C_Serial_Number
order by erp.LINK