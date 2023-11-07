select distinct --top 10 
ccft.C_Full_Name ccft_C_Full_Name
,ccft.C_System_Name ccft_C_System_Name
,ccfs.C_Name ccfs_C_Name
,ccfs.C_Const
,ccft2.C_Full_Name cft2_C_Full_Name
,ccft2.C_System_Name ccft2_C_System_Name
,ccf.C_System_Name
,ccf.C_Display_Name
,ccf.C_Description
,ccf.C_Const
,ccdr.C_Name
,ccdr2.C_Name
,ddt.C_Name
,ddt.C_Const
,ddt.B_InDoc
from CS_Custom_Fields ccf
	left join CS_Custom_Field_Sections ccfs
		on ccf.F_Custom_Field_Sections=ccfs.LINK
	left join CS_Custom_Fileld_Tables ccft
		on ccft.LINK=ccfs.F_Custom_Fileld_Tables
	left join CS_Custom_Fileld_Tables ccft2
		on ccf.F_Bound_Table=ccft2.LINK
	left join CS_Custom_Dictionary_Rows ccdr
		on ccdr.F_Custom_Field_Tables=ccft.LINK
	left join CS_Custom_Dictionary_Rows ccdr2
		on ccdr2.F_Custom_Field_Tables=ccft2.LINK
	left join DS_Docum_Types ddt
		on ddt.LINK=ccf.F_Type

--left join ccft.C_Full_Name 	XS_Reason_Request_Cancel_Restr
								--XS_Reason_Request_Cancel XS_Reason_Not_Access
where 1=1
--and ccft.C_System_Name like '%OV_Docs%'
and ccf.C_Display_Name like '%возобновлен%'
order by ccf.C_System_Name desc
--Объекты и в/части МО РФ; МВД; ФСБ; МЧС РФ; ФАПСИ; пункты централизованной охраны (ОПО = 65..88)
--Объекты МВД, ФСБ, МЧС, пункты централизованной охраны
--Объекты Минобороны России, МВД, ФСБ, МЧС, пункты централизованной охраны, ФАПСИ

--select top 10 * from CS_Custom_Fileld_Tables where LINK='83AB4E46-3094-4D66-991E-1A9F1FC01921'
