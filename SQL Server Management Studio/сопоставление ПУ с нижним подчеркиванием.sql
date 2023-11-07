--не сопоставлено
select 
ed.C_Note,
ed.C_Serial_Number [сер номер Омниус]
,edt.C_Name [Тип ПУ Омниус]
,cd.C_Serial_Number [Сер номер ASKUE]
,cd.C_Device_Type [Тип ПУ ASKUE]
from ED_Devices ed
inner join ie.CD_Devices_ASKUE cd
on dbo.CF_STRPART_Decimal(cd.C_Serial_Number)=dbo.CF_STRPART_Decimal(ed.C_Serial_Number)
inner join ES_Device_Types edt
on edt.LINK=ed.F_Device_Types

and cd.F_Division=ed.F_Division
and cd.F_Devices is null
where 1=1
and ed.string4 is null
and left(ed.C_Note,1)='_'
and ed.F_Division=81
--and ed.S_Modif_Date>='20220715'

--сопоставлено
select 
ed.C_Note,
ed.C_Serial_Number
,cd.C_Serial_Number
from ED_Devices ed
inner join ie.CD_Devices_ASKUE cd
on dbo.CF_STRPART_Decimal(cd.C_Serial_Number)=dbo.CF_STRPART_Decimal(ed.C_Serial_Number)
and cd.F_Division=ed.F_Division
and cd.F_Devices is not null
where 1=1
and ed.string4 is not null
and left(ed.C_Note,1)='_'
and ed.F_Division=81
and ed.S_Modif_Date>='20220715'


--не сопоставлено
select 
ed.C_Note,
ed.C_Serial_Number
,cd.C_Serial_Number
from ED_Devices ed
inner join ie.CD_Devices_ASKUE cd
on dbo.CF_STRPART_Decimal(cd.C_Serial_Number)=dbo.CF_STRPART_Decimal(ed.C_Serial_Number)
and cd.F_Division=ed.F_Division
and cd.F_Devices is null
where 1=1
and ed.string4 is null
and left(ed.C_Serial_Number,1)='0'
and ed.F_Division=81
--and ed.S_Modif_Date>='20220715'