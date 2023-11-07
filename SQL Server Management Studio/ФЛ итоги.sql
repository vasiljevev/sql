SELECT 
    --t.*,
   -- T.[��� ��������]
   --,t.[��]
   --,t.[������� ���� � �������� (��/���)]
   --,t.[��� ��������]
   --,t.[�����]
   --,t.[���]
   --,t.[�������� ������]
   --,t.[������� ����������]
   --,t.[���������� ������� ���������� � ����� �����������]
   --,t.[��� ������� �����]
   --,t.[����� ������� �����]
   --,t.[���� �����]
   --,t.[����-�����]
   --,t.[��������. ���������]
   --,t.[���� ��������. ���������]
   --,t.[��������� ���������]
   --,t.[���� ��������� ���������]
   --,t.[������ �� ������]
   --,t.[� �.�. ���������� ����������� � ����]
   --,t.[���]
   --,t.[�����]
   --,t.[������� ����������]
   --,t.[���������� ����� � ����.]
   --,t.[� �.�. ����� ����������� �� ���.��� � ����.]
   --,t.[� �.�. ����� ����������� �� ������� ������� � ����.]
   --,t.[�������������� � ������� ��������]
   --,t.[���]
   --,t.[����������]
   --,t.[�����]
   --,t.[��]
   --,t.[����� �����������]
   --,t.[���� �����?]
   --,t.[����� � ����]
   --,t.[����� �� ����]
   --,t.[������������� ��]
   --,t.[��� ��������� ����� ���� �������]
   --,t.[���� �������� �����������]
   --,t.[����� ���� � �������� �����������]
   --,t.[��� ������ ��]
   --,t.[��� ��. ����������]
   --,t.[��� ���]
   --,t.[���������� ��������� (��������)]
   --,t.[�������]
   --,t.[���� ������ ��������� �/� : ��������� "������"]
   --,(t.[�����]-t.[���������� ����� � ����.]) as [���� ����],
   -- SD.C_Name [�������������],
   -- SSD.C_Name [�������],
   -- SS.N_Code [���],
   -- dbo.CF_FIO (cp.C_Name1, cp.C_Name2, cp.C_Name3) [��],
   -- SS.C_Number [���� � ��],
   -- ERP.N_Code [��� ��],
   -- ERP.C_Name [������������ ��],
   -- ED.C_Serial_Number [����� ��]
   -- ,t.[���� �����]
   --,t.[����-�����] as [���� ����]
   --,t.[��������. ���������] as [�� ����]
   ----,t.[���� ��������. ���������] as [��� ����]
   -- --,MR_PR.D_Date [��� Omnis]
   -- ,MR_PR.N_Value [�� Omnis]
   --,t.[��������� ���������] as [�� ����]
   ----,t.[���� ��������� ���������] as [��� ����]
   ----,EMR.D_Date [��� Omnis]
   --,EMR.N_Value [�� Omnis]
   COUNT(FPD.N_Quantity)
   ,sum(t.[�����]-t.[���������� ����� � ����.]) [���� ����]
   ,sum(FPD.N_Quantity) [���� Omnis]
   ,sum(abs(FPD.N_Quantity-(t.[�����]-t.[���������� ����� � ����.]))) [���� �������]

    --case 
    --when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
    --when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
    --else
    --ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/(t.[�����]-t.[���������� ����� � ����.])) end as [diff �����%]

 
    --,T.*
    --select *
    from SD_Divisions sd
    inner join sd_subscr ss
        on  ss.F_Division  =sd.LINK
        and ss.b_ee = 0
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
    LEFT JOIN (select FD.F_Registr_Pts, sum(FD.N_Quantity) N_Quantity, MIN(F_Meter_Readings) F_Meter_Readings from pe.FVT_Charge_Details FD
        --LEFT JOIN ED_Meter_Readings EMR
        --    ON  EMR.LINK = FD.F_Meter_Readings
        where n_period = 202107
    group by F_Registr_Pts
    )fpd
        ON  FPD.F_Registr_Pts = ERP.LINK
    LEFT JOIN ED_Meter_Readings EMR
        ON  EMR.LINK = FPD.F_Meter_Readings
    /*FULL OUTER*/ inner JOIN TMP.tmp_Charges_202107 T
        on t.F_Registr_Pts = erp.LINK--fpd.F_Registr_Pts
    LEFT JOIN dbo.ED_Meter_Readings     AS MR_PR
         ON  MR_PR.F_Devices = EMR.F_Devices
         AND MR_PR.F_Division = EMR.F_Division
         AND MR_PR.F_Energy_Types = EMR.F_Energy_Types
         AND MR_PR.F_Time_Zones = EMR.F_Time_Zones
         AND MR_PR.D_Date < EMR.D_Date
         AND MR_PR.LINK = (
              SELECT
                     TOP 1 MX.LINK
              FROM   dbo.ED_Meter_Readings MX
              INNER JOIN dbo.ES_Readings_Status RSi
                     ON  RSi.LINK = MX.F_Readings_Status
                     AND RSi.B_InfoOnly = 0
              WHERE   MX.F_Devices = EMR.F_Devices
                     AND MX.F_Division = EMR.F_Division
                     AND MX.F_Energy_Types = EMR.F_Energy_Types
                     AND MX.F_Time_Zones = EMR.F_Time_Zones
                     AND MX.D_Date < EMR.D_Date
              ORDER BY
                  MX.D_Date DESC
             )

 
where 
--T.[�����] is not null
--and 


	FPD.N_Quantity is not NULL
	and t.F_Registr_Pts is not NULL
and
ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)) >100000
--and ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)) <= 100000

--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end > 20

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end > 10

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end <= 20

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end > 5

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end <= 10

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end > 0

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end <= 5

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 100 
--when isnull(t.[�����]-t.[���������� ����� � ����.],0) = 0 then 0 
--else
--ABS((t.[�����]-t.[���������� ����� � ����.]-FPD.N_Quantity)*100/
--(t.[�����]-t.[���������� ����� � ����.])) end = 0