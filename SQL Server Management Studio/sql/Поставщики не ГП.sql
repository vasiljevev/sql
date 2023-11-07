SELECT
        [CDP].C_Name1 as КА,
		[SDS].N_Code as ЛС,
		[SDS].C_Number as Альт_номер,
		
		[EDRP].N_Code as Код_уп,
		Par.C_Name1 as Поставщик
		
		--[EDRP].[LINK],
  --      [EDRP].[F_Division],
  --      [EDS].[F_Partners]
        --[ED].[LINK],
        --[EDMR].[D_Date],
        --[EDMR].[F_Readings_Status],
        --DENSE_RANK() OVER(PARTITION BY [EDRP].[LINK], ED.[LINK]  ORDER BY [ED].[D_Setup_Date] DESC)
    FROM [dbo].[ED_Registr_Pts] [EDRP] 
        INNER JOIN [dbo].[FS_Sale_Items] [FSSI] 
            ON [EDRP].[F_Sale_Items]    = [FSSI].[LINK]
        LEFT JOIN [dbo].[ES_Balance_Types] [ESBT_PR] 
            ON [ESBT_PR].[LINK]         = [EDRP].[F_Balance_Types]
        INNER JOIN  [dbo].[ED_Network_Pts] [ENP]
            ON  [ENP].[LINK]            = [EDRP].[F_Network_Pts]
        INNER JOIN [dbo].[ED_Suppliers] [EDS]
            ON [EDS].[F_Network_Pts]    = [ENP].[F_Network_Item]

		inner join dbo.CD_Partners Par
            on Par.LINK = [EDS].F_Partners
        --INNER JOIN [#RPT_Supplier] [EDSS]
        --    ON  [EDSS].[F_Supplier]     = [EDS].[F_Partners]
        INNER JOIN [dbo].[ES_Network_Pts_Types] [ESNPT] 
            ON [ENP].[F_Network_Pts_Types] = [ESNPT].[LINK]
        INNER JOIN [dbo].[SD_Subscr] [SDS] 
            ON  [SDS].[LINK]            = [EDRP].[F_Subscr]
            AND [SDS].[F_Division]      = [EDRP].[F_Division]
        INNER JOIN [dbo].[CD_Partners] [CDP] 
            ON  [CDP].[LINK]            = [SDS].[F_Partners]
        INNER JOIN [dbo].[ED_Devices_Pts] [EDP]
            ON [EDP].[F_Registr_Pts]    = [EDRP].[LINK]
            --AND [EDP].[F_Energy_Types]  = @SET_Active_Energy_Out
        --INNER JOIN [dbo].[ED_Devices]  ED 
        --    ON  [ED].[LINK]             = [EDP].[F_Devices] 
        --    AND [ED].[D_Setup_Date]     <= @DateEnd
        --                AND (
        --                            [ED].[D_Replace_Date]   >= @DateBegin
        --                        OR  [ED].[D_Replace_Date]   IS NULL
        --                    )
        --INNER JOIN [dbo].[ED_Meter_Readings] [EDMR]
        --    ON  [ED].[LINK]             = [EDMR].[F_Devices]
        --    AND [ED].[F_Division]       = [EDMR].[F_Division]
        WHERE 1 = 1
                AND [EDS].[F_Partners] <> '3EB5D9DA-6E9E-485B-8807-A2763DD37C39'
                --AND [EDRP].[D_Date_Begin] <= @DateEnd
                --AND (
                --            [EDRP].[D_Date_End] >= @DateBegin
                --        OR  [EDRP].[D_Date_End] IS NULL
                --    )
				and ([EDS].D_Date_End is null or [EDS].D_Date_End > '20220101')
				and [EDS].F_Division = 61
				order by [SDS].LINK,[EDRP].[LINK]