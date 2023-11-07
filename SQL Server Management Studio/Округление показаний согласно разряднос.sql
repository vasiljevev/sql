-- округление показаний в соответствии с разрядностью
        UPDATE emr
        SET emr.N_Value =
            ROUND (
            ISNULL ( emr.N_Value, 0.0 ) -- показание
            , ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- число знаков после запятой
            /*
            ROUND (
            ( ISNULL ( crb.N_Value, 0.0 ) * -- показание
                POWER ( 10.000000, ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- умножаем на 10^[число знаков после запятой]
                + 
                POWER ( 10.000000, -- общее число знаков до и после запятой
                    FLOOR ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) ) + -- число знаков до запятой
                        ( ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- число знаков после запятой
                        ) 
                ) % 
                POWER ( 10.000000, -- общее число знаков до и после запятой
                    FLOOR ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) ) +  -- число знаков до запятой
                        ( ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 ) -- число знаков после запятой
                        )
                * POWER ( 10.0000000000, - ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0) -- делим на 10^([число знаков после запятой])
            , ( COALESCE ( mm.N_Digits, dtz.N_Digits, 5.2 ) * 10.0 ) % 10.0 )       
            */
        -- select count(*)
        FROM dbo.ED_Meter_Readings emr
            --  Прибор учета
            INNER JOIN dbo.ED_Devices AS ed
            --  ON ed.string4 = crb.C_ASKUE_Number
                ON ed.LINK = emr.F_Devices
                AND ed.B_EE = 1
            
            --  Тип прибора учета
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