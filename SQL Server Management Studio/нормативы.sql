select 
sd.C_Name
--��
,ss.B_EE
,ss.bit2  [���. ���������]
,ss.bit11 [�������� ���������]
,ss.bit12 [�������������� ����������]
--������							
,scp.bit1	[������� �����			]
,scp.bit11	[��������� ���������	]
,scp.bit14	[�������������� �����	]
,scp.bit2	[����������� ����		]
,scp.bit6	[����������� ���������	]
,scp.bit7	[������� �������������	]
,scp.int6	[���������� ������		]
,sct.C_Name
--���������
,scps.bit7  [������������]
,scps.bit8  [����������������]
,scps.bit10 [����������������������]
,scps.bit11 [������ ���]
,sum(scq.N_Square)
,sum(scq.N_Placement_Count)
from dbo.SD_Subscr ss
inner join dbo.SD_Divisions sd
on sd.LINK=ss.F_Division
and ss.LINK>0
inner join dbo.ED_Registr_Pts erp
on erp.F_Subscr=ss.LINK
inner join dbo.ED_Network_Pts enp
on enp.LINK=erp.F_Network_Pts
inner join dbo.SD_Conn_Points scp
on scp.link=enp.F_Conn_Points
left join dbo.SD_Conn_Points_Sub scps
on scps.F_Conn_Points=scp.LINK
left join dbo.SS_Conn_Status_Types sct
on sct.LINK=scp.F_Conn_Status_Types
left join dbo.SD_Contract_Squares scq
on scq.F_Conn_Points_Sub=scps.LINK
--left join dbo.SD_Conn_Points_Sub scps2
--on scps2.F_Conn_Points=scps.LINK
--where ss.link=19884681
where sd.LINK=61
group by 
sd.C_Name,ss.B_EE,ss.bit2,ss.bit11,scps.bit7,scps.bit8,scps.bit10,scps.bit11
,scp.bit1	
,scp.bit11	
,scp.bit14	
,scp.bit2	
,scp.bit6	
,scp.bit7	
,scp.int6	
,ss.bit12
,sct.C_Name
order by sd.C_Name,ss.B_EE,ss.bit2,ss.bit11,scps.bit7,scps.bit8,scps.bit10,scps.bit11
,scp.bit1	
,scp.bit11	
,scp.bit14	
,scp.bit2	
,scp.bit6	
,scp.bit7	
,scp.int6
,ss.bit12
,sct.C_Name