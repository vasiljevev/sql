select top 10  sd.C_Name, dd.C_Number,ddt.C_Name,edct.C_Name,  ed.D_Setup_Date ,edc.D_Date/*, edc.* */from ED_Device_Checks edc
inner join ED_Registr_Pts erp
on edc.F_Registr_Pts=erp.LINK
and erp.F_Division=edc.F_Division
inner join SD_Subscr ss
on ss.LINK=erp.F_Subscr
and ss.F_Division=erp.F_Division
inner join DD_Docs dd
on dd.LINK=edc.F_Docs
and dd.F_Division=ss.F_Division
inner join ED_Devices ed
on ed.LINK=edc.F_Devices
inner join DS_Docum_Types ddt
on ddt.LINK=dd.F_Docum_Types
inner join SD_Divisions sd
on sd.LINK=ss.F_Division
inner join ES_Device_Check_Types edct
on edct.LINK=edc.F_Device_Check_Types
where 1=1
and ss.B_EE=0
and (edc.int9 is not null or edc.int11 is not null or edc.int12 is not null)
--and ss.F_Division=90
and ed.D_Replace_Date is null
--and (edc.D_Date < '20221101' and edc.D_Date > '20220801')
and edct.C_Name<>'Выход из строя'
order by edc.D_Date desc