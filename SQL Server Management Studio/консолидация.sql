exec XRPT.RPT_109_Consolidate_Info @F_Division=50,@N_Year=2022,@N_Month=1,@B_Job=1


SELECT 
      sd.C_Name                      AS [Филиал]                             ,
            ISNULL(ssd.C_Name, 'Общий участок')  AS [РЭС]                                ,
            trci.C_Name                    AS [ЮЛ/ФЛ]                              ,
            cp.C_Name1                     AS [Поставщик ЭСК]                      ,
            trci.N_Count_Pts_ESK           AS [УП ЭСК]                             ,
            trci.N_Count_Pts_ESK_Trash     AS [УП ЭСК в мусоре]                    ,
            trci.N_Count_Pts               AS [УП СК]                              ,
            trci.N_Count_Devices           AS [ПУ СК]                              ,
            trci.N_Count_Devices_PS_All    AS [Всего ПУ в П-С]                     ,
            trci.N_Count_Devices_PS        AS [ПУ сопоставлено с ПС]               ,
            trci.N_Count_Readings_PS       AS [Пкз П-С]                            ,
            trci.N_Count_Readings_MK       AS [Пкз МК]                             ,
            trci.N_Count_Readings_Other    AS [Пкз ост]                            ,
            trci.N_Count_Readings          AS [Пкз всего]                          ,
            trci.N_Count_Profiles          AS [Профильные показания]               ,
            trci.N_Count_Pts_WO_Readings   AS [Кол-во ТУ без пкз]                  ,
            CAST(trci.N_Quantity            AS DECIMAL(13,0))  AS [СК, кВт*ч]                          ,
            CAST(trci.N_Quantity_ESK        AS DECIMAL(13,0))  AS [ЭСК, кВт*ч]                         ,
            CAST(trci.N_Quantity_Disagree   AS DECIMAL(13,0))  AS [Разногласий всего, кВт*ч]           ,
            CAST(trci.N_Quantity_Disagree_N AS DECIMAL(13,0))  AS [Разногласий отрицательных, кВт*ч]   ,
            CAST(trci.N_Quantity_Disagree_P AS DECIMAL(13,0))  AS [Разногласий положительных, кВт*ч]   ,
            trci.N_Count_RP_WO_ESK         AS [ТУ СК неспост ЭСК]                  ,
            trci.N_Count_RP_WO_NE          AS [ТУ ЭСК неспост СК]                  ,
            trci.N_Count_Readings_Over     AS [Перекруты]                          ,
            trci.N_Count_Devices_Rate      AS [Расч K >100000]                     ,
   trci.D_Date_Now                AS [Дата]                               ,
   trci.N_Percent_Disagree_ESK    AS [Процент],
   trci.*
     FROM Tmp.RPT_109_Consolidate_Info AS trci  --select * FROM Tmp.RPT_109_Consolidate_Info where F_main_Division = 50 select * from dbo.SD_Subdivisions where F_Division=51 select * from dbo.SD_Divisions
  INNER JOIN dbo.SD_Divisions AS sd
            ON  sd.LINK         =  trci.F_main_Division
  INNER JOIN dbo.SD_Divisions AS sd2
   ON  sd.LINK         = sd2.F_Division
        LEFT JOIN dbo.SD_Subdivisions AS ssd
            ON  sd2.link        = ssd.F_Division
            AND trci.F_Division = ssd.LINK
        LEFT JOIN dbo.CD_Partners AS cp
            ON  cp.LINK         = trci.F_Supplier
			where trci.C_Name in ('ЮЛ','ФЛ')
			order by trci.D_Date_Now desc


			select B_i from ED_Registr_Pts where link = 64885861