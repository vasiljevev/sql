select
 --    T.[���� � ������� ��������]
 --   ,T.[���]
 --   ,T.[����������]
 --   ,T.[��]
 --   ,T.[��� ���]
 --   ,T.[� ��������]
 --   ,T.[sub_name]
 --   ,T.[������������ �������]
 --   ,T.[� ��]
 --   ,T.[������������ �����]
 --   ,T.[� ��������]
 --   ,T.[� �.�. ����� ����������� ����������� ���*�]
 --   ,T.[� �.�. ����� ������������� ��] as [� �.�. ����� ������������� �� �������]
 --   ,T.[����� ����] as [� �.�. ����� �������������]
 --   ,T.[���������� �� �������� �������] as [���������� �� �������� ���������]
 --   ,T.[����. �����]
 --   ,T.[����� ������� ( �� ��������, �� ��, �� ���������, ��� ����� ]
 --   ,T.[��������� ������� ����� ����������� �������]
 --   ,T.[��������� ������� ����� �������� �������]
 --   ,T.[�������� ������] AS [�������� ������ ���*�]
	--,T.[������] as [������]
 --   ,T.[���������� �� ����� (�� ��������� �����)] AS [���������� �� ����� (�� ��������� �����) ���*�],
 --   SD.C_Name [�������������],
 --   SSD.C_Name [�������],
 --   SS.N_Code [���],
 --   SS.C_Number [���� � ��],
 --   cp.C_Name1 [��],
 --   ERP.N_Code [��� ��],
 --   ERP.C_Name [������������ ��],
 --   ED.C_Serial_Number [����� ��],
    --EMR2.D_Date [���� ��������� ���������],
    --EMR2.N_Value [��������� ���������],
    --emr1.D_Date [���� �������� ���������],
    --emr1.N_Value [�������� ���������]
 --   fpd.N_MR_Value_Prev [�� Omnis],
 --   fpd.N_MR_Value [�� Omnis],
 --   T.[��������� ������� ����� ����������� �������] [�� ����],
 --   T.[��������� ������� ����� �������� �������] [�� ����],
 --   FPD.N_Quantity [������ ��],
 --   FPD1.N_Quantity [������ �����],
 --   T.[�������� ������] AS [�������� ����],
	--ABS(T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity) as [diff �����],
	--(fpd.N_MR_Value_Prev-T.[��������� ������� ����� ����������� �������]) as [������� ��],
	--(fpd.N_MR_Value-T.[��������� ������� ����� �������� �������]) as [������� ��]
	COUNT(FPD1.N_Quantity)
	,sum(T.[�������� ������]- T.[����� ����]) [���� ����]
	,sum(FPD1.N_Quantity) [���� Omnis]
	,sum(abs(T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity)) [���� �������]

--,
--case 
--when isnull(FPD1.N_Quantity,0) <> 0 and isnull(T.[�������� ������]- T.[����� ����],0) = 0 then 100 
--when isnull(T.[�������� ������]- T.[����� ����],0) = 0 then 0 
--else
--ABS((T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity)*100/T.[�������� ������]- T.[����� ����]) end as [diff �����%]

    from SD_Divisions sd
    inner join sd_subscr ss
        on  ss.F_Division  =sd.LINK
        and ss.b_ee = 1
        and ss.LINK > 0
    LEFT JOIN SD_Subdivisions SSD
        ON  SSD.LINK = SS.F_SubDivision
    inner join CD_Partners cp
        on  cp.link = ss.F_Partners
    inner join ED_Registr_Pts erp
        on  erp.F_Subscr = ss.LINK
    left join ED_Devices_Pts edp
        inner join ED_Devices ed
            ON  EDP.F_Devices = ED.LINK
            AND ED.D_Replace_Date IS NULL
        on  edp.F_Registr_Pts = erp.LINK
    ---------------------------------����� ���� �����
    --left join dbo.ED_Meter_Measures emm
    --    on  emm.LINK =
    --        (select top 1 emm1.link
    --            from dbo.ED_Meter_Measures  emm1
    --        where emm1.F_Devices = ed.LINK
    --        order by emm1.F_Time_Zones
    --        )
   
    -----------------------------------------------

    LEFT JOIN (select F_Registr_Pts, sum(N_Quantity) N_Quantity, max(N_MR_Value) N_MR_Value, min(N_MR_Value_Prev) N_MR_Value_Prev 
            from ee.FVT_Paysheets_Details
        where n_period = 202107
        and F_Registr_Pts_Main is null
    group by F_Registr_Pts
    )fpd
        ON  FPD.F_Registr_Pts = ERP.LINK
     LEFT JOIN (select F_Registr_Pts, sum(N_Quantity) N_Quantity, max(N_MR_Value) N_MR_Value, min(N_MR_Value_Prev) N_MR_Value_Prev 
            from ee.FVT_Paysheets_Details
        where n_period = 202107
    group by F_Registr_Pts
    ) fpd1
          ON  FPD1.F_Registr_Pts = ERP.LINK
    FULL OUTER JOIN TMP.TMP_PAYSHEETS_202106_v2 T
        on t.F_Registr_Pts = erp.LINK
    where 1=1
    --and SS.N_Code is not NULL
	and FPD.N_Quantity is not NULL
	and t.F_Registr_Pts is not NULL
	--and abs(T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity)>100000
	--and abs(T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity)<=100000

	--and (T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity) is not NULL
--	and ABS(T.[�������� ������
--���*�]-T.[������
--���*�]-FPD1.N_Quantity)=0
	--and 
	--case 
	--when isnull(FPD1.N_Quantity,0) <> 0 and isnull(T.[�������� ������]- T.[����� ����],0) = 0 then 100 
	--when isnull(T.[�������� ������]- T.[����� ����],0) = 0 then 0 
	--else
	--ABS((T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity)*100/T.[�������� ������]- T.[����� ����]) end > 20

	--and 
	--case 
	--when isnull(FPD1.N_Quantity,0) <> 0 and isnull(T.[�������� ������]- T.[����� ����],0) = 0 then 100 
	--when isnull(T.[�������� ������]- T.[����� ����],0) = 0 then 0 
	--else
	--ABS((T.[�������� ������]- T.[����� ����]-FPD1.N_Quantity)*100/T.[�������� ������]- T.[����� ����]) end <= 20

    --and T.[� ��������] is NULL
	--or
	--and SS.N_Code is NULL
   -- and T.[� ��������] is not  NULL
    --and T.[� ��������] <> ''
    --and T.[� ��������] = '199703091'
    ----and T.[� ��������] like '%5022991%'
    --and ss.N_Code   = 333535076
    --and erp.N_Code = '555565207'
    --order by [diff �����] DESC
    --order by [���] DESC --T.[� ��������]
OPTION (FORCE ORDER)