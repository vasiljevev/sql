select
 --    T.[Прин к сетевой компании]
 --   ,T.[РЭС]
 --   ,T.[Подстанция]
 --   ,T.[ТП]
 --   ,T.[код ТчП]
 --   ,T.[№ договора]
 --   ,T.[sub_name]
 --   ,T.[Наименование объекта]
 --   ,T.[№ ТУ]
 --   ,T.[Наименование точки]
 --   ,T.[№ счетчика]
 --   ,T.[в т.ч. Объём безучётного потребления кВт*ч]
 --   ,T.[в т.ч. Объём корректировки ТГ] as [в т.ч. Объём корректировки за текущий]
 --   ,T.[объем корр] as [в т.ч. Объём корректировки]
 --   ,T.[Количество ЭЭ учтенной счетчик] as [Количество ЭЭ учтенной счетчиком]
 --   ,T.[Коэф. учета]
 --   ,T.[Метод расчета ( по мощности, по ПУ, по нормативу, все какие ]
 --   ,T.[Показания прибора учета предыдущего периода]
 --   ,T.[Показания прибора учета текущего периода]
 --   ,T.[Полезный отпуск] AS [Полезный отпуск кВт*ч]
	--,T.[Потери] as [Потери]
 --   ,T.[Количество ЭЭ ВСЕГО (по головному учету)] AS [Количество ЭЭ ВСЕГО (по головному учету) кВт*ч],
 --   SD.C_Name [Подразделение],
 --   SSD.C_Name [Участок],
 --   SS.N_Code [№ЛС],
 --   SS.C_Number [Альт № Лс],
 --   cp.C_Name1 [КА],
 --   ERP.N_Code [Код УП],
 --   ERP.C_Name [Наименование УП],
 --   ED.C_Serial_Number [Номер ПУ],
    --EMR2.D_Date [Дата начальных показаний],
    --EMR2.N_Value [Начальные показания],
    --emr1.D_Date [Дата конечных показаний],
    --emr1.N_Value [Конечные показания]
 --   fpd.N_MR_Value_Prev [НП Omnis],
 --   fpd.N_MR_Value [КП Omnis],
 --   T.[Показания прибора учета предыдущего периода] [НП СТЭК],
 --   T.[Показания прибора учета текущего периода] [КП СТЭК],
 --   FPD.N_Quantity [Расход УП],
 --   FPD1.N_Quantity [Расход общий],
 --   T.[Полезный отпуск] AS [Полезный СТЭК],
	--ABS(T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity) as [diff полез],
	--(fpd.N_MR_Value_Prev-T.[Показания прибора учета предыдущего периода]) as [разница НП],
	--(fpd.N_MR_Value-T.[Показания прибора учета текущего периода]) as [разница КП]
	COUNT(FPD1.N_Quantity)
	,sum(T.[Полезный отпуск]- T.[объем корр]) [Итог СТЭК]
	,sum(FPD1.N_Quantity) [Итог Omnis]
	,sum(abs(T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity)) [Итог разница]

--,
--case 
--when isnull(FPD1.N_Quantity,0) <> 0 and isnull(T.[Полезный отпуск]- T.[объем корр],0) = 0 then 100 
--when isnull(T.[Полезный отпуск]- T.[объем корр],0) = 0 then 0 
--else
--ABS((T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity)*100/T.[Полезный отпуск]- T.[объем корр]) end as [diff полез%]

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
    ---------------------------------берем одну шкалу
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
	--and abs(T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity)>100000
	--and abs(T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity)<=100000

	--and (T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity) is not NULL
--	and ABS(T.[Полезный отпуск
--кВт*ч]-T.[Потери
--кВт*ч]-FPD1.N_Quantity)=0
	--and 
	--case 
	--when isnull(FPD1.N_Quantity,0) <> 0 and isnull(T.[Полезный отпуск]- T.[объем корр],0) = 0 then 100 
	--when isnull(T.[Полезный отпуск]- T.[объем корр],0) = 0 then 0 
	--else
	--ABS((T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity)*100/T.[Полезный отпуск]- T.[объем корр]) end > 20

	--and 
	--case 
	--when isnull(FPD1.N_Quantity,0) <> 0 and isnull(T.[Полезный отпуск]- T.[объем корр],0) = 0 then 100 
	--when isnull(T.[Полезный отпуск]- T.[объем корр],0) = 0 then 0 
	--else
	--ABS((T.[Полезный отпуск]- T.[объем корр]-FPD1.N_Quantity)*100/T.[Полезный отпуск]- T.[объем корр]) end <= 20

    --and T.[№ договора] is NULL
	--or
	--and SS.N_Code is NULL
   -- and T.[№ договора] is not  NULL
    --and T.[№ счетчика] <> ''
    --and T.[№ договора] = '199703091'
    ----and T.[№ счетчика] like '%5022991%'
    --and ss.N_Code   = 333535076
    --and erp.N_Code = '555565207'
    --order by [diff полез] DESC
    --order by [№ЛС] DESC --T.[№ договора]
OPTION (FORCE ORDER)