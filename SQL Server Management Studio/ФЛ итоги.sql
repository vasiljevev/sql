SELECT 
    --t.*,
   -- T.[Код абонента]
   --,t.[УК]
   --,t.[Наличие ОДПУ в расчетах (Да/Нет)]
   --,t.[Тип строения]
   --,t.[Адрес]
   --,t.[ФИО]
   --,t.[Тарифная группа]
   --,t.[Уровень напряжения]
   --,t.[Физический уровень напряжения в точке подключения]
   --,t.[Тип прибора учета]
   --,t.[Номер прибора учета]
   --,t.[Зона суток]
   --,t.[Знач-ность]
   --,t.[Предпосл. показания]
   --,t.[Дата предпосл. показаний]
   --,t.[Последние показания]
   --,t.[Дата последних показаний]
   --,t.[Расход за период]
   --,t.[в т.ч. безучетное потребление в кВтч]
   --,t.[ОДН]
   --,t.[Итого]
   --,t.[Признак начисления]
   --,t.[Перерасчет ИТОГО в кВтч.]
   --,t.[в т.ч. Объём перерасчета за тек.год в кВтч.]
   --,t.[в т.ч. Объём перерасчета за прошлые периоды в кВтч.]
   --,t.[Принадлежность к сетевой компании]
   --,t.[РЭС]
   --,t.[Подстанция]
   --,t.[Фидер]
   --,t.[ТП]
   --,t.[Точка подключения]
   --,t.[Есть АСКУЭ?]
   --,t.[АСКУЭ с даты]
   --,t.[АСКУЭ по дату]
   --,t.[Производитель ПУ]
   --,t.[Нет показаний свыше трех месяцев]
   --,t.[Дата введения ограничения]
   --,t.[номер акта о введении ограничения]
   --,t.[код фидера СН]
   --,t.[код Тр. подстанции]
   --,t.[код ТчП]
   --,t.[Непринятое показание (сторонее)]
   --,t.[Причина]
   --,t.[Дата начала параметра л/с : Состояние "Закрыт"]
   --,(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]) as [итог СТЭК],
   -- SD.C_Name [Подразделение],
   -- SSD.C_Name [Участок],
   -- SS.N_Code [№ЛС],
   -- dbo.CF_FIO (cp.C_Name1, cp.C_Name2, cp.C_Name3) [КА],
   -- SS.C_Number [Альт № Лс],
   -- ERP.N_Code [Код УП],
   -- ERP.C_Name [Наименование УП],
   -- ED.C_Serial_Number [Номер ПУ]
   -- ,t.[Зона суток]
   --,t.[Знач-ность] as [Разр СТЭК]
   --,t.[Предпосл. показания] as [НП СТЭК]
   ----,t.[Дата предпосл. показаний] as [ДНП СТЭК]
   -- --,MR_PR.D_Date [ДНП Omnis]
   -- ,MR_PR.N_Value [НП Omnis]
   --,t.[Последние показания] as [КП СТЭК]
   ----,t.[Дата последних показаний] as [ДКП СТЭК]
   ----,EMR.D_Date [ДКП Omnis]
   --,EMR.N_Value [КП Omnis]
   COUNT(FPD.N_Quantity)
   ,sum(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]) [Итог СТЭК]
   ,sum(FPD.N_Quantity) [Итог Omnis]
   ,sum(abs(FPD.N_Quantity-(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]))) [Итог разница]

    --case 
    --when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
    --when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
    --else
    --ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end as [diff полез%]

 
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
--T.[Итого] is not null
--and 


	FPD.N_Quantity is not NULL
	and t.F_Registr_Pts is not NULL
and
ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)) >100000
--and ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)) <= 100000

--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end > 20

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end > 10

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end <= 20

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end > 5

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end <= 10

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end > 0

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end <= 5

--and
--case 
--when isnull(FPD.N_Quantity,0) <> 0 and isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 100 
--when isnull(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.],0) = 0 then 0 
--else
--ABS((t.[Итого]-t.[Перерасчет ИТОГО в кВтч.]-FPD.N_Quantity)*100/
--(t.[Итого]-t.[Перерасчет ИТОГО в кВтч.])) end = 0