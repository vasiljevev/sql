-- ���������� ��������� � ������������ � ������������
        UPDATE emr
        SET emr.N_Value =
            ROUND (
            ISNULL ( emr.N_Value, 0.0 ) -- ���������
            , ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- ����� ������ ����� �������
            /*
            ROUND (
            ( ISNULL ( crb.N_Value, 0.0 ) * -- ���������
                POWER ( 10.000000, ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- �������� �� 10^[����� ������ ����� �������]
                + 
                POWER ( 10.000000, -- ����� ����� ������ �� � ����� �������
                    FLOOR ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) ) + -- ����� ������ �� �������
                        ( ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- ����� ������ ����� �������
                        ) 
                ) % 
                POWER ( 10.000000, -- ����� ����� ������ �� � ����� �������
                    FLOOR ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) ) +  -- ����� ������ �� �������
                        ( ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- ����� ������ ����� �������
                        )
                * POWER ( 10.0000000000, - ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0) -- ����� �� 10^([����� ������ ����� �������])
            , ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 )       
            */
        -- select count(*)
        FROM dbo.ED_Meter_Readings emr
            --  ������ �����
            INNER JOIN dbo.ED_Devices AS ed
            --  ON ed.string4 = crb.C_ASKUE_Number
                ON ed.LINK = emr.F_Devices
                AND ed.B_EE = 1
            
            --  ��� ������� �����
            INNER JOIN dbo.ES_Device_Types AS edt
                ON edt.LINK = ed.F_Device_Types
            INNER JOIN dbo.ED_Devices_Pts dp
                ON dp.F_Devices = ed.LINK
                AND dp.F_Device_Division = ed.F_Division
                AND dp.B_Main = 1
            LEFT JOIN dbo.ED_Meter_Measures mm
                ON ed.F_Division = mm.F_Division
                AND ed.LINK = mm.F_Devices
                AND dp.F_Energy_Types = mm.F_Energy_Types
            LEFT JOIN dbo.ES_Energy_Types et
                ON et.LINK = dp.F_Energy_Types
                AND et.B_Meter_Measures = 1
            LEFT JOIN dbo.ED_Device_Tariff_Zones dtz
                ON dtz.F_Device_Types = ed.F_Device_Types
                AND (dtz.F_Energy_Types = et.F_Energy_Types OR dtz.F_Energy_Types = et.LINK)
        WHERE emr.F_Delivery_Methods = 18 --and mm.N_Digits is not null