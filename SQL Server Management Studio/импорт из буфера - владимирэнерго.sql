DECLARE @Status_Msg VARCHAR(100)
EXEC IE.IMP_Readings
@N_Year = NULL, -- ������ ������������ ������. ���
@N_Month = NULL, -- ������ ������������ ������. �����
@F_Division = 2, -- ���������
@F_SubDivision = 0, -- �������
@B_Rewrite = 0, -- ������������ ������������ ������ ������������� �����
@B_Ignore_notMeasure = 0, -- ������������ ������ �� �������������� ������ (�� ��������� ������)
@B_Ignore_Closed_Period = 0, -- ����������� ������ � �������� ������
@B_Ignore_Prev_Periods = 0, -- �� ���������� ��������� � ���������� �������
@B_Ignore_Meter_Date = 1, -- ������������ ��������� ������ ���� ���������
@C_User = 'sa', -- ������������ ����������� �������� �������
@C_SubDivisions = null,--'113,114,115,116,117,118,119,120,121,122,123,124', -- ���������, �������
@N_Device_Type = NULL, -- ������ �� ��� ����������� ���������
@C_ASKUE_Number = null, --'bf48cf6c-f561-45f3-8709-51dd6fa20535', -- ������ �� ���� ����������
@B_Only_TFZ_Day = NULL, -- ��������� ������ �� ���� �����
@B_Interval = 1, -- ������ �������
@B_Integral = 1, -- ������ ���������
@B_Inversion = 0, -- ��� ��������
@Action_id = NULL, -- ������������� �������� (�� ������������)
@PK = 0, -- ������������� �������, �� ������� ������� �������� (�� ������������)
@B_Rewrite_Integral = 0, -- ������������ ������������ ������ ������������� �����
@G_Session_ID = 'D59F355E-F9E8-4DF0-A930-9DFCD922023D',
@Status_Msg = @Status_Msg OUTPUT

--UPDATE ie.CD_Readings SET N_Error = 0
--select distinct G_Session from ie.CD_Readings


--C_Name    F_Loading_System    F_Division    G_Session_ID
--������������ (�)    7    91    B338CF26-4206-458F-84A1-8DC0B86733AD
--������������ (�)    7    71    91E0D4E9-C275-4B0E-8CE2-491ACAA85EDE
--���������� (�)    7    51    E83B5816-3DB8-469A-86B6-6BE941E5AA15 *
--����������� (�)    7    41    52D36C89-3BB2-4725-9883-8C1ECA8AC828
--�������������� (�)    7    2    D59F355E-F9E8-4DF0-A930-9DFCD922023D *



/*
SELECT LINK, C_Name FROM dbo.ORL_Subdivisions_Full_List AS osfl



select sd.C_Name, ss.* from SD_Subdivisions ss
inner join SD_Divisions sd
on sd.LINK=ss.F_Division

where ss.link not in 
*/


 --@N_Year = NULL,  
 --@N_Month = NULL,  
 --@F_Division = 51,  
 --@F_SubDivision = 0,  
 --@B_Rewrite = 0,  
 --@B_Ignore_notMeasure = 0,  
 --@B_Ignore_Closed_Period = 0,
 --@B_Ignore_Prev_Periods = 0,  
 --@B_Ignore_Meter_Date = 1, 
 --@C_User = sa,  
 --@C_SubDivisions = 113,114,115,116,117,118,119,120,121,122,123,124, 
 --@N_Device_Type = NULL,  
 --@C_ASKUE_Number = NULL,  
 --@B_Only_TFZ_Day = NULL,  
 --@B_Interval = 1,  
 --@B_Integral = 1,  
 --@B_Inversion = 0,  
 --@Action_id = NULL,  
 --@PK = 0,  
 --@Status_Msg = @Status_Msg,  
 --@B_Rewrite_Integral = 0,  
 --@G_Session_ID = E83B5816-3DB8-469A-86B6-6BE941E5AA15,  
 --@B_Help = @B_Help, 