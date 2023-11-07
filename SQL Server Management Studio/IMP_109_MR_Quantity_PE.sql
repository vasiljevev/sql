USE [OmniUS_Test]
GO
/****** Object:  StoredProcedure [IE].[IMP_109_MR_Quantity_PE]    Script Date: 25.06.2023 20:00:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:		a-hamidullov
-- CREATE date:	22.02.2022
-- ALTER date:	14.06.2023 sd-nikolaev	проверки на парные импортируемые показания
--				15.07.2022 sd-nikolaev	заполнение полей перерасчёт и Коэфф.трансф.
--				06.07.2022 sd-nikolaev	добавил группировку по дате показаний
--				08.06.2022 sd-nikolaev	заполнение полей в пределах и выше соц.норм
--				13.05.2022 a-hamidullov оптимизация
--				28.04.2022 sd-nikolaev	для поля C_Building_Num добавил left 50
--				15.04.2022 a-hamidullov обработка B_NoActual
--				01.04.2022 a-hamidullov досопоставление ПУ и признак несопоставленного ПУ
--				15.03.2022 a-hamidullov нулевые показания при отсутствии даты показания не загружать
--				15.03.2022 a-hamidullov досопоставление при повторной прогрузке данных
-- Description:	Импорт показаний и расходов потребтелей ФЛ от ГП/ЭСК
-- ===================================================================
ALTER PROCEDURE [IE].[IMP_109_MR_Quantity_PE]
	@G_Session_ID			UNIQUEIDENTIFIER,			-- Сессия
	@F_Division				INT,						-- Отделение
	@F_Supplier				UNIQUEIDENTIFIER,			-- Поставщик (контрагент)	
	@N_Year					SMALLINT,					-- Год
	@N_Month				TINYINT,					-- Месяц
	@B_Imp_MR				BIT = 1,					-- 1 - загрузить показания
	@F_Employer				UNIQUEIDENTIFIER = NULL,	-- Сотрудник, запустивший импорт
	@C_File_Name			VARCHAR(500) = NULL,		-- Наименование импортируемого файла
	@B_Debug				TINYINT = 0					-- 1 - режим отладки кода
AS
BEGIN
	SET NOCOUNT, XACT_ABORT, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL ON
	SET NUMERIC_ROUNDABORT, CURSOR_CLOSE_ON_COMMIT OFF

	-- переменные
	DECLARE	@F_Networks				UNIQUEIDENTIFIER,	-- сечение учёта
			@N_Period				INT,				-- период
			@S_Creator				INT,				-- автор записи
			@B_First_To_First		BIT,				-- логика дат с 1 по 1
			@D_Date_Begin			SMALLDATETIME,		-- дата начала периода
			@D_Date_End				SMALLDATETIME,		-- дата окончания периода
			@SIT_Active_Energy		SMALLINT,			-- вид энергии: Акт.ЭЭ
			@SET_Active_Energy_Out	TINYINT,			-- измеряемый показатель: АЭ-
			@EDM_Check_Ut			TINYINT,	        -- источник показаний Данные сбыта
			@TFZ_Day				TINYINT,	        -- сутки
			@TFZ_DayTime			TINYINT,	        -- день
			@TFZ_Nigth				TINYINT,	        -- ночь
			@TFZ_Peak				TINYINT,	        -- пик
			@TFZ_SemiPeak			TINYINT		        -- полупик
	;
	
	-- Сечечение учёта
	SELECT TOP 1 @F_Networks	= LINK FROM dbo.ED_Networks WHERE F_Division = @F_Division AND F_Networks IS NULL;

	-- Акт.ЭЭ
	SELECT	@SIT_Active_Energy	= LINK FROM dbo.FS_Sale_Items WHERE C_Const = 'SIT_Active_Energy';
	
	-- Активная энергия - отдача
	SELECT	@SET_Active_Energy_Out	= LINK FROM dbo.ES_Energy_Types WHERE C_Const = 'SET_Active_Energy_Out';

	-- Тарифные зоны
	SELECT	@TFZ_Day			= LINK FROM dbo.FS_Time_Zones WHERE C_Const = 'TFZ_Day';
	SELECT	@TFZ_DayTime		= LINK FROM dbo.FS_Time_Zones WHERE C_Const = 'TFZ_DayTime';
	SELECT	@TFZ_Nigth			= LINK FROM dbo.FS_Time_Zones WHERE C_Const = 'TFZ_Nigth';
	SELECT	@TFZ_Peak			= LINK FROM dbo.FS_Time_Zones WHERE C_Const = 'TFZ_Peak';
	SELECT	@TFZ_SemiPeak		= LINK FROM dbo.FS_Time_Zones WHERE C_Const = 'TFZ_SemiPeak';

	-- Показание ЭСК / КА
	SELECT	@EDM_Check_Ut		= LINK FROM dbo.ES_Delivery_Methods WHERE C_Const = 'EDM_Check_Ut';

	-- логика с 1 по 1
	SELECT	@B_First_To_First	= N_Value FROM dbo.CF_Get_Calc_Defaults(@F_Division, 0, 'B_NxtPeriodMR_Calc_In_Curr', NULL, 0);
	
	-- дата начала периода
	SELECT	@D_Date_Begin		= dbo.CF_Month_Date(@N_Month, @N_Year);
	
	-- дата окончания периода
	IF @B_First_To_First = 0
		SELECT @D_Date_End		= dbo.CF_Month_Date_End(@N_Month, @N_Year); -- dbo.CF_Date_Round()
	ELSE
		SELECT @D_Date_End		= dbo.CF_Month_Date_Next(@N_Month, @N_Year);
	;
	
	-- период
	SELECT	@N_Period = @N_Year * 100 + @N_Month;
	
	-- автор записи
	SELECT	@S_Creator = U.LINK 
	FROM dbo.SD_Employers E
			INNER JOIN dbo.CS_Users U
				ON U.S_SID = E.S_USID
				AND U.C_Name = E.C_UID
	WHERE E.LINK = @F_Employer
	;

	-- переменные для журналирования интеграции
	DECLARE @C_Error_Message		VARCHAR(300),		-- Сообщение об ошибке
			@G_SSIS_ID				UNIQUEIDENTIFIER,	-- Ид-р пакета интеграции
			@C_SSIS_Name			NVARCHAR(255),		-- Системное наименование пакета интеграции
			@C_SSIS_Description		NVARCHAR(MAX)		-- Наименование пакета интеграции
	;

	-- инциализация параметров журналирования
	SELECT TOP 1
			@G_SSIS_ID				= G_SSIS_ID,
			@C_SSIS_Name			= C_SSIS_Name,
			@C_SSIS_Description		= C_SSIS_Description
	FROM IE.CS_Integration_Sessions
	WHERE G_Session_ID = @G_Session_ID
	;

	--IF @G_SSIS_ID IS NULL
	--SET @G_SSIS_ID = NEWID()
	--;

	-- проверка на закрытый период
	IF EXISTS(SELECT 1 FROM dbo.SD_Divisions WHERE LINK = @F_Division AND N_Year_Last	* 100 + N_Month_Last >= @N_Period)
	BEGIN
		SET @C_Error_Message = 'Импорт в закрытый период запрещён!';
		EXEC [IE].[CP_IS_Add_Log]
			@G_Session_ID			= @G_Session_ID,
			@G_SourceID				= @G_SSIS_ID,
			@C_SourceName			= @C_SSIS_Name,
			@C_SourceDescription	= @C_SSIS_Description,			
			@N_ErrorCode			= 1,
			@C_ErrorDescription		= @C_Error_Message
		;
		EXEC [IE].[CP_IS_Close]
			@G_Session_ID = @G_Session_ID,
			@B_Status = 1
		;
		
		RETURN 1

	END

	-- временная таблица
	IF OBJECT_ID ('tempdb..#IE_CD_109_MR_Quantity_PE') IS NOT NULL
	DROP TABLE #IE_CD_109_MR_Quantity_PE
	;

	CREATE TABLE #IE_CD_109_MR_Quantity_PE (
		ID									INT IDENTITY(1,1),				-- ид-р		
		G_Session_ID						UNIQUEIDENTIFIER	NOT NULL,	-- Сессия
		F_IE_CD_109_MR_Quantity_PE_Group	INT					NULL,		-- LINK в таблице #IE_CD_109_MR_Quantity_PE_Group
		F_IE_CD_109_MR_Quantity_PE			INT					NOT NULL,	-- LINK в таблице IE.CD_109_MR_Quantity_PE

		C_Number_Subscr						VARCHAR(100)		NULL,		-- Номер ЛС сбыта
		C_Name1								VARCHAR(100)		NULL,		-- Фамилия
		C_Name2								VARCHAR(100)		NULL,		-- Имя
		C_Name3								VARCHAR(100)		NULL,		-- Отчество
		C_Municipalities					VARCHAR(100)		NULL,		-- Нас. пункт
		C_Provinces							VARCHAR(100)		NULL,		-- Район
		C_Streets							VARCHAR(100)		NULL,		-- Улица
		C_Building_Num						VARCHAR(100)		NULL,		-- Дом
		C_Premise_Number					VARCHAR(50)			NULL,		-- Квартира
		C_Room_Number						VARCHAR(50)			NULL,		-- Комната
		C_Device_Types						VARCHAR(100)		NULL,		-- Тип ПУ
		C_Serial_Number						VARCHAR(100)		NULL,		-- Номер ПУ
		N_Rate								INT					NULL,		-- Коэфф.трансф.
		D_Date_Prev							SMALLDATETIME		NULL,		-- Дата предыдущих показаний
		N_Value_Prev						DECIMAL(19, 6)		NULL,		-- Предыдущие показания
		C_Delivery_Methods_Prev				VARCHAR(100)		NULL,		-- Источник предыдущих показаний
		D_Date								SMALLDATETIME		NULL,		-- Дата текущих показаний
		N_Value								DECIMAL(19, 6)		NULL,		-- Текущие показания
		C_Delivery_Methods					VARCHAR(100)		NULL,		-- Источник текущих показаний
		N_Quantity_Full						DECIMAL(22, 9)		NULL,		-- Итоговое потребление
		N_Quantity_Dev						DECIMAL(22, 9)		NULL,		-- Потребление по ПУ
		N_Quantity_AvgMonth					DECIMAL(22, 9)		NULL,		-- Среднемесячное потребление
		N_Quantity_Norm						DECIMAL(22, 9)		NULL,		-- Нормативное потребление
		N_Quantity_Act						DECIMAL(22, 9)		NULL,		-- Акт БУ
		N_Quantity_Recalc					DECIMAL(22, 9)		NULL,		-- Перерасчёт
		N_Quantity_ODN						DECIMAL(22, 9)		NULL,		-- ОДН
		N_Quantity_SocNorm_Limit			DECIMAL(22, 9)		NULL,		-- Потребление в пределах соц.нормы
		N_Quantity_SocNorm_Over				DECIMAL(22, 9)		NULL,		-- Потребление сверх соц.нормы
		N_Kodusl							INT					NULL,		-- Код услуги
		N_Old_Ls							VARCHAR(100)		NULL,		-- Номер ЛС старый
		C_Status_Sch						VARCHAR(500)		NULL,		-- Состояние ПУ
		C_Sostoyanie						VARCHAR(500)		NULL,		-- Активность
		C_Conn_Types						VARCHAR(100)		NULL,		-- Тип строения
		C_Network							VARCHAR(500)		NULL,		-- Сеть
		N_Code_Subscr						VARCHAR(100)		NULL,		-- Номер ЛС ЦиП
		string1								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string2								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string3								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string4								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string5								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string6								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string7								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		string8								VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		C_Error_Message						VARCHAR(1000)		NULL,		-- Сообщение об ошибке

		-- системные поля АИС Omni-US
		F_Partner_Suppliers					UNIQUEIDENTIFIER	NULL,		-- Поставщик (контрагент ГП/ЭСК)
		F_Division							TINYINT				NULL,		-- Отделение
		F_SubDivision						TINYINT				NULL,		-- Участок
		F_Networks							UNIQUEIDENTIFIER	NULL,		-- Сечение учёта
		F_Network_Items						UNIQUEIDENTIFIER	NULL,		-- Элемент сети
		F_Network_Pts						UNIQUEIDENTIFIER	NULL,		-- Точка поставки
		--F_Regions							INT					NULL,		-- Регион
		--F_Provinces						INT					NULL,		-- Район
		--F_Towns							INT					NULL,		-- Город мун. значения
		--F_Municipalities					INT					NULL,		-- Нас. пункт
		--F_Streets							INT					NULL,		-- Улица
		--F_Fias_Address					UNIQUEIDENTIFIER	NULL,		-- ФИАС до улицы включительно
		--F_Fias_House						UNIQUEIDENTIFIER	NULL,		-- ФИАС дома
		F_Partners							UNIQUEIDENTIFIER	NULL,		-- Потребитель
		F_Subscr							INT					NULL,		-- Лицевой счёт
		F_Conn_Points						UNIQUEIDENTIFIER	NULL,		-- Объект Л/С
		F_Conn_Points_Sub					UNIQUEIDENTIFIER	NULL,		-- Кв. Л/С
		F_Registr_Pts						INT					NULL,		-- Учётный показатель
		F_Sale_Items						SMALLINT			NULL,		-- Вид энергии
		--F_Energy_Levels					TINYINT				NULL,		-- Уровень напряжения
		F_Device_Division					TINYINT				NULL,		-- Отделение прибора учёта
		F_Devices							INT					NULL,		-- Прибор учёта
		F_Device_Types						INT					NULL,		-- Тип прибора учёта
		F_Device_Locations					INT					NULL,		-- Место установки прибора учёта
		F_Owner_Types						INT					NULL,		-- Тип владельца прибора учёта
		F_Energy_Types						TINYINT				NULL,		-- Измеряемые показатели
		F_Time_Zones						TINYINT 			NULL,		-- Временные зоны
		S_Creator							INT					NULL,		-- Автор записи
		S_Create_Date						SMALLDATETIME		NULL		-- Дата создания записи
	)
	;
/*
	-- наполнение временной таблицы в разрезе Сети
	INSERT INTO #IE_CD_109_MR_Quantity_PE (
		 G_Session_ID
		,F_IE_CD_109_MR_Quantity_PE
		,C_Number_Subscr
		,C_Name1
		,C_Name2
		,C_Name3
		,C_Municipalities
		,C_Provinces
		,C_Streets
		,C_Building_Num
		,C_Premise_Number
		,C_Room_Number
		,C_Device_Types
		,C_Serial_Number
		,N_Rate
		,D_Date_Prev
		,N_Value_Prev
		,C_Delivery_Methods_Prev
		,D_Date
		,N_Value
		,C_Delivery_Methods
		,N_Quantity_Full
		,N_Quantity_Dev
		,N_Quantity_AvgMonth
		,N_Quantity_Norm
		,N_Quantity_Act
		,N_Quantity_Recalc
		,N_Quantity_ODN
		,N_Quantity_SocNorm_Limit
		,N_Quantity_SocNorm_Over
		,N_Kodusl
		,N_Old_Ls
		,C_Status_Sch
		,C_Sostoyanie
		,C_Conn_Types
		,C_Network
		,N_Code_Subscr
		,string1
		,string2
		,string3
		,string4
		,string5
		,string6
		,string7
		,string8
	)
	SELECT 
		 G_Session_ID
		,LINK AS F_IE_CD_109_MR_Quantity_PE
		,NULLIF(LTRIM(RTRIM(C_Number_Subscr				)), '') AS C_Number_Subscr			
		,NULLIF(LTRIM(RTRIM(C_Name1						)), '') AS C_Name1					
		,NULLIF(LTRIM(RTRIM(C_Name2						)), '') AS C_Name2					
		,NULLIF(LTRIM(RTRIM(C_Name3						)), '') AS C_Name3					
		,NULLIF(LTRIM(RTRIM(C_Municipalities			)), '') AS C_Municipalities		
		,NULLIF(LTRIM(RTRIM(C_Provinces					)), '') AS C_Provinces					
		,NULLIF(LTRIM(RTRIM(C_Streets					)), '') AS C_Streets				
		,NULLIF(LTRIM(RTRIM(C_Building_Num				)), '') AS C_Building_Num			
		,NULLIF(LTRIM(RTRIM(C_Premise_Number			)), '') AS C_Premise_Number		
		,NULLIF(LTRIM(RTRIM(C_Room_Number				)), '') AS C_Room_Number			
		,NULLIF(LTRIM(RTRIM(C_Device_Types				)), '') AS C_Device_Types			
		,NULLIF(LTRIM(RTRIM(C_Serial_Number				)), '') AS C_Serial_Number			
		,N_Rate					
		,D_Date_Prev				
		,N_Value_Prev			
		,NULLIF(LTRIM(RTRIM(C_Delivery_Methods_Prev		)), '') AS C_Delivery_Methods_Prev	
		,D_Date					
		,N_Value					
		,NULLIF(LTRIM(RTRIM(C_Delivery_Methods			)), '') AS C_Delivery_Methods		
		,N_Quantity_Full			
		,N_Quantity_Dev			
		,N_Quantity_AvgMonth		
		,N_Quantity_Norm			
		,N_Quantity_Act			
		,N_Quantity_Recalc		
		,N_Quantity_ODN			
		,N_Quantity_SocNorm_Limit
		,N_Quantity_SocNorm_Over	
		,N_Kodusl				
		,NULLIF(LTRIM(RTRIM(N_Old_Ls					)), '') AS N_Old_Ls				
		,NULLIF(LTRIM(RTRIM(C_Status_Sch				)), '') AS C_Status_Sch			
		,NULLIF(LTRIM(RTRIM(C_Sostoyanie				)), '') AS C_Sostoyanie			
		,NULLIF(LTRIM(RTRIM(C_Conn_Types				)), '') AS C_Conn_Types			
		,NULLIF(LTRIM(RTRIM(C_Network					)), '') AS C_Network				
		,NULLIF(LTRIM(RTRIM(N_Code_Subscr				)), '') AS N_Code_Subscr			
		,NULLIF(LTRIM(RTRIM(string1						)), '') AS string1					
		,NULLIF(LTRIM(RTRIM(string2						)), '') AS string2					
		,NULLIF(LTRIM(RTRIM(string3						)), '') AS string3					
		,NULLIF(LTRIM(RTRIM(string4						)), '') AS string4					
		,NULLIF(LTRIM(RTRIM(string5						)), '') AS string5					
		,NULLIF(LTRIM(RTRIM(string6						)), '') AS string6					
		,NULLIF(LTRIM(RTRIM(string7						)), '') AS string7					
		,NULLIF(LTRIM(RTRIM(string8						)), '') AS string8					
*/  SELECT * 
	INTO [sewer].tmp.CD_109_MR_Quantity_PE
	FROM IE.CD_109_MR_Quantity_PE T
	--WHERE T.G_Session_ID = @G_Session_ID
		--AND T.C_Network IN ('ПАО "Россети Центр и Приволжье"', 'ПАО "МРСК ЦЕНТРА И ПРИВОЛЖЬЯ"')
	;
	/*
	-- проверка наличия данных по ожидаемым значениям в поле Сеть
	IF NOT EXISTS(SELECT 1 FROM #IE_CD_109_MR_Quantity_PE WHERE G_Session_ID = @G_Session_ID)
	BEGIN
		SET @C_Error_Message = 'Нет данных для загрузки в разрезе поля Сеть!';
		EXEC [IE].[CP_IS_Add_Log]
			@G_Session_ID			= @G_Session_ID,
			@G_SourceID				= @G_SSIS_ID,
			@C_SourceName			= @C_SSIS_Name,
			@C_SourceDescription	= @C_SSIS_Description,
			@N_ErrorCode			= 2,
			@C_ErrorDescription		= @C_Error_Message
		;
		EXEC [IE].[CP_IS_Close]
			@G_Session_ID = @G_Session_ID,
			@B_Status = 1
		;
		
		RETURN 1

	END

	-- Сутки (вначале для всех строк без условий)
	UPDATE T
	SET T.F_Time_Zones = TZ.LINK
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.FS_Time_Zones AS TZ
				ON TZ.C_Const = 'TFZ_Day'
	WHERE T.G_Session_ID = @G_Session_ID
	;

	-- День
	UPDATE T
	SET T.F_Time_Zones = TZ.LINK
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.FS_Time_Zones AS TZ
				ON TZ.C_Const = 'TFZ_DayTime'
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Status_Sch LIKE '%День%'
	;

	-- Ночь
	UPDATE T
	SET T.F_Time_Zones = TZ.LINK
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.FS_Time_Zones AS TZ
				ON TZ.C_Const = 'TFZ_Nigth'
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Status_Sch LIKE '%Ночь%'
	;

	-- Пик
	UPDATE T
	SET T.F_Time_Zones = TZ.LINK
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.FS_Time_Zones AS TZ
				ON TZ.C_Const = 'TFZ_Peak'
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Status_Sch LIKE '%Пик%'
	;

	-- Полупик
	UPDATE T
	SET T.F_Time_Zones = TZ.LINK
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.FS_Time_Zones AS TZ
				ON TZ.C_Const = 'TFZ_SemiPeak'
	WHERE T.G_Session_ID = @G_Session_ID
		AND (T.C_Status_Sch LIKE '%ППик%'
			OR
			T.C_Status_Sch LIKE '%Полупик%'
			)
	;

	-- Не указан код ЛС сбыта
	UPDATE T
	SET T.C_Error_Message = ISNULL(T.C_Error_Message, '') + ' Не указан код ЛС сбыта.'
	FROM #IE_CD_109_MR_Quantity_PE AS T
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Number_Subscr IS NULL
	;

	--
	;WITH	devices 
		AS	(
				SELECT DISTINCT 
					C_Number_Subscr, 
					C_Serial_Number,
					D_Date_Prev,
					D_Date,
					CASE 
						WHEN F_Time_Zones IN (4) THEN 1 
						WHEN F_Time_Zones IN (5) THEN 2 
						WHEN F_Time_Zones IN (1) THEN 4 
						WHEN F_Time_Zones IN (15) THEN 8 
					END AS N_Code

				FROM #IE_CD_109_MR_Quantity_PE T
				WHERE	1=1
					AND T.F_Time_Zones NOT IN (3) -- исключаем сутки
					AND T.C_Number_Subscr IS NOT NULL
					AND T.C_Serial_Number IS NOT NULL
			)

	UPDATE T
	SET C_Error_Message = ISNULL(T.C_Error_Message, '') + ' Парное импортируемое показание по полям "Дата предыдущего показания" или "Дата текущего показания" отсутствует. '
	FROM #IE_CD_109_MR_Quantity_PE T
			INNER JOIN 
				(
					SELECT 
						C_Number_Subscr,
						C_Serial_Number,
						D_Date_Prev,
						D_Date,
						SUM(N_Code) AS N_Check 
					FROM devices 
					GROUP BY C_Number_Subscr, C_Serial_Number, D_Date_Prev,						D_Date
				) dev
				ON dev.C_Number_Subscr		= T.C_Number_Subscr
				AND dev.C_Serial_Number		= T.C_Serial_Number
				AND ISNULL(dev.D_Date_Prev ,  '20790606') = ISNULL(T.D_Date_Prev ,  '20790606')
				AND ISNULL(dev.D_Date ,  '20790606') = ISNULL(T.D_Date ,  '20790606')
			INNER JOIN dbo.FS_Time_Zones ftz
				ON ftz.LINK			= T.F_Time_Zones
		WHERE	1=1
			AND (
					T.F_Time_Zones IN (4) AND dev.N_Check NOT IN (3,13)
				OR 
					T.F_Time_Zones IN (1,15) AND dev.N_Check NOT IN (13)
				OR 
					T.F_Time_Zones IN (5) AND dev.N_Check NOT IN (3)
				)
	
	-- Нет ошибок
	UPDATE T
	SET T.C_Error_Message = NULL
	FROM #IE_CD_109_MR_Quantity_PE AS T
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Error_Message = ''
	;

	-- Перенос ошибок со временной таблицы в буферную таблицу пакета интеграции
	UPDATE T2
	SET T2.C_Error_Message = T.C_Error_Message
	--select *
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN IE.CD_109_MR_Quantity_PE AS T2
				ON	T2.G_Session_ID = T.G_Session_ID
				AND	T2.LINK			= T.F_IE_CD_109_MR_Quantity_PE
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Error_Message IS NOT NULL
	;

	-- Очистка временной таблицы от ошибочных записей
	DELETE FROM T
	FROM #IE_CD_109_MR_Quantity_PE AS T
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.C_Error_Message IS NOT NULL
	;


	-- Инициализация системных полей АИС Omni-US: сечения учёта, элемент сети, ТоП, КА, ЛС, УП
	UPDATE T
	SET
		F_Partner_Suppliers			= @F_Supplier,											-- Поставщик (контрагент ГП/ЭСК)
		F_Division					= @F_Division,											-- Отделение
		F_SubDivision				= ISNULL(RP.F_SubDivision, 0),							-- Участок
		F_Networks					= ISNULL(NIP.F_Networks, @F_Networks),					-- Сечение учёта
		F_Network_Items				= NIP.F_Network_Items,									-- Элемент сети
		F_Network_Pts				= RP.F_Network_Pts,										-- Точка поставки
		F_Conn_Points				= S.F_Conn_Points,										-- Объект Л/С
		F_Conn_Points_Sub			= S.F_Conn_Points_Sub,									-- Кв. Л/С
		--F_Regions					= CP.F_Regions,											-- Регион
		--F_Provinces				= CP.F_Provinces,										-- Район
		--F_Towns					= CP.F_Towns,											-- Город мун. значения
		--F_Municipalities			= CP.F_Municipalities,									-- Нас. пункт
		--F_Streets					= CP.F_Streets,											-- Улица
		--F_Fias_Address			= CP.F_Fias_Address,									-- ФИАС до улицы включительно
		--F_Fias_House				= CP.F_Fias_House,										-- ФИАС дома
		F_Partners					= P.LINK,												-- Потребитель
		F_Subscr					= S.LINK,												-- Лицевой счёт
		F_Registr_Pts				= RP.LINK,												-- Учётный показатель
		F_Sale_Items				= ISNULL(RP.F_Sale_Items, @SIT_Active_Energy),			-- Вид энергии
		--F_Energy_Levels				= ISNULL(RP.F_Energy_Levels, EL.LINK),					-- Уровень напряжения
		F_Energy_Types				= @SET_Active_Energy_Out,								-- Измеряемые показатели
		S_Creator					= @S_Creator,											-- Автор записи
		S_Create_Date				= GETDATE()												-- Дата создания записи
	FROM #IE_CD_109_MR_Quantity_PE AS T
			--LEFT JOIN dbo.ES_Energy_Levels AS EL
			--	ON EL.C_Const = CASE
			--						WHEN T.C_Energy_Levels = 'ВН' THEN 'BH1'
			--						WHEN T.C_Energy_Levels = 'СН1' THEN 'CH_I'
			--						WHEN T.C_Energy_Levels = 'СН2' THEN 'CH_II'
			--						WHEN T.C_Energy_Levels = 'НН' THEN 'НН'
			--					END
			LEFT JOIN dbo.ED_Registr_Pts AS RP
				INNER JOIN dbo.SD_Subscr AS S
					ON S.F_Division = RP.F_Division
					AND S.LINK		= RP.F_Subscr
					AND S.B_Tech	= 0
					AND S.B_EE		= 0
				INNER JOIN dbo.CD_Partners AS P
					ON P.LINK		= S.F_Partners
				INNER JOIN dbo.ED_Network_Pts AS NP
					ON NP.LINK		= RP.F_Network_Pts
				CROSS APPLY (SELECT TOP 1 iSup.F_Partners AS F_Supplier
							 FROM dbo.ED_Suppliers AS iSup
							 WHERE iSup.F_Network_Pts	= ISNULL(NP.F_Network_Pts, NP.LINK)
								AND iSup.D_Date_Begin	< @D_Date_End
								AND (iSup.D_Date_End	> @D_Date_Begin OR iSup.D_Date_End IS NULL)
							 ORDER BY iSup.D_Date_Begin DESC
							) AS Sup
				OUTER APPLY (SELECT TOP 1 iNIP.F_Network_Items, iNI.F_Networks
							 FROM dbo.ED_Network_Item_Pts iNIP
									INNER JOIN dbo.ED_Network_Items iNI
										ON iNI.LINK = iNIP.F_Network_Items
							 WHERE iNIP.F_Network_Pts	= ISNULL(NP.F_Network_Pts, NP.LINK)
								AND iNIP.D_Date_Begin	< @D_Date_End
								AND iNIP.D_Date_End		> @D_Date_Begin
							 ORDER BY iNIP.D_Date_Begin DESC
							) AS NIP
				LEFT JOIN dbo.SD_Conn_Points AS CP
					ON CP.LINK				= S.F_Conn_Points
				LEFT JOIN dbo.SD_Conn_Points_Sub AS CPS
					ON CPS.F_Conn_Points	= S.F_Conn_Points
					AND CPS.LINK			= S.F_Conn_Points_Sub
				
				ON RP.F_Division	= @F_Division
				AND S.C_Number		= T.C_Number_Subscr
				AND RP.D_Date_Begin	< @D_Date_End
				AND (RP.D_Date_End	> @D_Date_Begin OR RP.D_Date_End IS NULL)
				AND S.D_Date_Begin	< @D_Date_End
				AND (S.D_Date_End	> @D_Date_Begin	OR S.D_Date_End IS NULL)									
				AND Sup.F_Supplier	= @F_Supplier
	WHERE T.G_Session_ID = @G_Session_ID
	;

	-- Инициализация системных полей АИС Omni-US: Прибор учёта
	-- а)
	UPDATE T
	SET
		F_Registr_Pts				= RP.LINK,												-- Учётный показатель
		F_Device_Division			= Dev.F_Division,										-- Отделение прибора учёта
		F_Devices					= Dev.F_Devices,										-- Прибор учёта
		F_Device_Types				= Dev.F_Device_Types,									-- Тип прибора учёта
		F_Device_Locations			= Dev.F_Device_Locations,								-- Место установки прибора учёта
		F_Owner_Types				= Dev.F_Owner_Types 									-- Тип владельца прибора учёта
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.ED_Registr_Pts AS RP
				ON RP.F_Division	= T.F_Division
				AND RP.F_Subscr		= T.F_Subscr
				AND RP.D_Date_Begin	< @D_Date_End
				AND (RP.D_Date_End	> @D_Date_Begin OR RP.D_Date_End IS NULL)
			CROSS APPLY (SELECT TOP 1 iD.F_Division, iDP.F_Devices, iD.F_Device_Types, iD.F_Device_Locations, iD.F_Owner_Types, LTRIM(RTRIM(iD.C_Serial_Number)) AS C_Serial_Number
						 FROM dbo.ED_Devices_Pts AS iDP
								INNER JOIN dbo.ED_Devices AS iD
									ON iD.LINK = iDP.F_Devices
						 WHERE /*iDP.F_Division		= RP.F_Division
							AND */iDP.F_Registr_Pts	= RP.LINK
							AND iD.D_Setup_Date		< @D_Date_End
							AND (iD.D_Replace_Date	> @D_Date_Begin OR iD.D_Replace_Date IS NULL)
						 ORDER BY iD.D_Setup_Date DESC, iDP.LINK DESC
			) AS Dev
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Subscr IS NOT NULL
		AND T.F_Devices IS NULL
		AND T.C_Serial_Number IS NOT NULL
		AND T.C_Serial_Number = Dev.C_Serial_Number
	;

	-- б)
	UPDATE T
	SET
		F_Registr_Pts				= RP.LINK,												-- Учётный показатель
		F_Device_Division			= Dev.F_Division,										-- Отделение прибора учёта
		F_Devices					= Dev.F_Devices,										-- Прибор учёта
		F_Device_Types				= Dev.F_Device_Types,									-- Тип прибора учёта
		F_Device_Locations			= Dev.F_Device_Locations,								-- Место установки прибора учёта
		F_Owner_Types				= Dev.F_Owner_Types 									-- Тип владельца прибора учёта
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.ED_Registr_Pts AS RP
				ON RP.F_Division	= T.F_Division
				AND RP.F_Subscr		= T.F_Subscr
				AND RP.D_Date_Begin	< @D_Date_End
				AND (RP.D_Date_End	> @D_Date_Begin OR RP.D_Date_End IS NULL)
			CROSS APPLY (SELECT TOP 1 iD.F_Division, iDP.F_Devices, iD.F_Device_Types, iD.F_Device_Locations, iD.F_Owner_Types, LTRIM(RTRIM(iD.C_Serial_Number)) AS C_Serial_Number
						 FROM dbo.ED_Devices_Pts AS iDP
								INNER JOIN dbo.ED_Devices AS iD
									ON iD.LINK = iDP.F_Devices
						 WHERE /*iDP.F_Division		= RP.F_Division
							AND */iDP.F_Registr_Pts	= RP.LINK
							AND iD.D_Setup_Date		< @D_Date_End
							AND (iD.D_Replace_Date	> @D_Date_Begin OR iD.D_Replace_Date IS NULL)
						 ORDER BY iD.D_Setup_Date DESC, iDP.LINK DESC
			) AS Dev
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Subscr IS NOT NULL
		AND T.F_Devices IS NULL
		AND T.C_Serial_Number IS NOT NULL
		AND LEN(T.C_Serial_Number) >= 4
		AND T.C_Serial_Number LIKE '%' + Dev.C_Serial_Number
	;

	-- в)
	UPDATE T
	SET
		F_Registr_Pts				= RP.LINK,												-- Учётный показатель
		F_Device_Division			= Dev.F_Division,										-- Отделение прибора учёта
		F_Devices					= Dev.F_Devices,										-- Прибор учёта
		F_Device_Types				= Dev.F_Device_Types,									-- Тип прибора учёта
		F_Device_Locations			= Dev.F_Device_Locations,								-- Место установки прибора учёта
		F_Owner_Types				= Dev.F_Owner_Types 									-- Тип владельца прибора учёта
	FROM #IE_CD_109_MR_Quantity_PE AS T
			INNER JOIN dbo.ED_Registr_Pts AS RP
				ON RP.F_Division	= T.F_Division
				AND RP.F_Subscr		= T.F_Subscr
				AND RP.D_Date_Begin	< @D_Date_End
				AND (RP.D_Date_End	> @D_Date_Begin OR RP.D_Date_End IS NULL)
			CROSS APPLY (SELECT TOP 1 iD.F_Division, iDP.F_Devices, iD.F_Device_Types, iD.F_Device_Locations, iD.F_Owner_Types, LTRIM(RTRIM(iD.C_Serial_Number)) AS C_Serial_Number
						 FROM dbo.ED_Devices_Pts AS iDP
								INNER JOIN dbo.ED_Devices AS iD
									ON iD.LINK = iDP.F_Devices
						 WHERE /*iDP.F_Division		= RP.F_Division
							AND */iDP.F_Registr_Pts	= RP.LINK
							AND iD.D_Setup_Date		< @D_Date_End
							AND (iD.D_Replace_Date	> @D_Date_Begin OR iD.D_Replace_Date IS NULL)
						 ORDER BY iD.D_Setup_Date DESC, iDP.LINK DESC
			) AS Dev
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Subscr IS NOT NULL
		AND T.F_Devices IS NULL
		AND T.C_Serial_Number IS NOT NULL
		AND LEN(T.C_Serial_Number) >= 4
		AND Dev.C_Serial_Number LIKE '%' + T.C_Serial_Number
	;



	-- временная таблица уникальных номеров ЛС сбыта и Номера ПУ
	IF OBJECT_ID ('tempdb..#IE_CD_109_MR_Quantity_PE_Group') IS NOT NULL
	DROP TABLE #IE_CD_109_MR_Quantity_PE_Group
	;

	CREATE TABLE #IE_CD_109_MR_Quantity_PE_Group (
		ID									INT IDENTITY(1,1),				-- ид-р		
		G_Session_ID						UNIQUEIDENTIFIER	NOT NULL,	-- Сессия

		C_Number_Subscr						VARCHAR(100)		NULL,		-- Номер ЛС сбыта
		C_Name1								VARCHAR(100)		NULL,		-- Фамилия
		C_Name2								VARCHAR(100)		NULL,		-- Имя
		C_Name3								VARCHAR(100)		NULL,		-- Отчество
		C_Municipalities					VARCHAR(100)		NULL,		-- Нас. пункт
		C_Provinces							VARCHAR(100)		NULL,		-- Район
		C_Streets							VARCHAR(100)		NULL,		-- Улица
		C_Building_Num						VARCHAR(100)		NULL,		-- Дом
		C_Premise_Number					VARCHAR(50)			NULL,		-- Квартира
		C_Room_Number						VARCHAR(50)			NULL,		-- Комната
		C_Device_Types						VARCHAR(100)		NULL,		-- Тип ПУ
		C_Serial_Number						VARCHAR(100)		NULL,		-- Номер ПУ
		N_Rate								INT					NULL,		-- Коэфф.трансф.
		N_Quantity_Full						DECIMAL(22, 9)		NULL,		-- Итоговое потребление
		N_Quantity_Dev						DECIMAL(22, 9)		NULL,		-- Потребление по ПУ
		N_Quantity_AvgMonth					DECIMAL(22, 9)		NULL,		-- Среднемесячное потребление
		N_Quantity_Norm						DECIMAL(22, 9)		NULL,		-- Нормативное потребление
		N_Quantity_Act						DECIMAL(22, 9)		NULL,		-- Акт БУ
		N_Quantity_Recalc					DECIMAL(22, 9)		NULL,		-- Перерасчёт
		N_Quantity_ODN						DECIMAL(22, 9)		NULL,		-- ОДН
		N_Quantity_SocNorm_Limit			DECIMAL(22, 9)		NULL,		-- Потребление в пределах соц.нормы
		N_Quantity_SocNorm_Over				DECIMAL(22, 9)		NULL,		-- Потребление сверх соц.нормы
		--N_Kodusl							INT					NULL,		-- Код услуги
		--N_Old_Ls							VARCHAR(100)		NULL,		-- Номер ЛС старый
		--C_Status_Sch						VARCHAR(500)		NULL,		-- Состояние ПУ
		C_Sostoyanie						VARCHAR(500)		NULL,		-- Активность
		C_Conn_Types						VARCHAR(100)		NULL,		-- Тип строения
		C_Network							VARCHAR(500)		NULL,		-- Сеть
		--N_Code_Subscr						VARCHAR(100)		NULL,		-- Номер ЛС ЦиП
		--string1							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string2							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string3							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string4							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string5							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string6							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string7							VARCHAR(250)		NULL,		-- Дополнительные поля расширения
		--string8							VARCHAR(250)		NULL,		-- Дополнительные поля расширения

		D_Date_Meter_Reading_Prev			SMALLDATETIME		NULL,		-- Дата предыдущих показаний
		D_Date_Meter_Reading_Current		SMALLDATETIME		NULL,		-- Дата показаний

		N_Day_Meter_Readings_Prev			DECIMAL(19, 6)		NULL,		-- Показание предыдущее: Сутки, День
		N_Day_Meter_Readings_Current		DECIMAL(19, 6)		NULL,		-- Показание текущее: Сутки, День

		N_Night_Meter_Readings_Prev			DECIMAL(19, 6)		NULL,		-- Показание предыдущее: Ночь
		N_Night_Meter_Readings_Current		DECIMAL(19, 6)		NULL,		-- Показание текущее: Ночь

		N_Peak_Meter_Readings_Prev			DECIMAL(19, 6)		NULL,		-- Показание предыдущее: Пик
		N_Peak_Meter_Readings_Current		DECIMAL(19, 6)		NULL,		-- Показание текущее: Пик

		N_SemiPeak_Meter_Readings_Prev		DECIMAL(19, 6)		NULL,		-- Показание предыдущее: Полупик
		N_SemiPeak_Meter_Readings_Current	DECIMAL(19, 6)		NULL,		-- Показание текущее: Полупик


		-- системные поля АИС Omni-US
		F_Partner_Suppliers					UNIQUEIDENTIFIER	NULL,		-- Поставщик (контрагент ГП/ЭСК)
		F_Division							TINYINT				NULL,		-- Отделение
		F_SubDivision						TINYINT				NULL,		-- Участок
		F_Networks							UNIQUEIDENTIFIER	NULL,		-- Сечение учёта
		F_Network_Items						UNIQUEIDENTIFIER	NULL,		-- Элемент сети
		F_Network_Pts						UNIQUEIDENTIFIER	NULL,		-- Точка поставки
		--F_Regions							INT					NULL,		-- Регион
		--F_Provinces						INT					NULL,		-- Район
		--F_Towns							INT					NULL,		-- Город мун. значения
		--F_Municipalities					INT					NULL,		-- Нас. пункт
		--F_Streets							INT					NULL,		-- Улица
		--F_Fias_Address					UNIQUEIDENTIFIER	NULL,		-- ФИАС до улицы включительно
		--F_Fias_House						UNIQUEIDENTIFIER	NULL,		-- ФИАС дома
		F_Partners							UNIQUEIDENTIFIER	NULL,		-- Потребитель
		F_Subscr							INT					NULL,		-- Лицевой счёт
		F_Conn_Points						UNIQUEIDENTIFIER	NULL,		-- Объект Л/С
		F_Conn_Points_Sub					UNIQUEIDENTIFIER	NULL,		-- Кв. Л/С
		F_Registr_Pts						INT					NULL,		-- Учётный показатель
		F_Sale_Items						SMALLINT			NULL,		-- Вид энергии
		--F_Energy_Levels					TINYINT				NULL,		-- Уровень напряжения
		F_Device_Division					TINYINT				NULL,		-- Отделение прибора учёта
		F_Devices							INT					NULL,		-- Прибор учёта
		F_Device_Types						INT					NULL,		-- Тип прибора учёта
		F_Device_Locations					INT					NULL,		-- Место установки прибора учёта
		F_Owner_Types						INT					NULL,		-- Тип владельца прибора учёта
		F_Energy_Types						TINYINT				NULL,		-- Измеряемые показатели
		--F_Time_Zones						TINYINT 			NULL,		-- Временные зоны
		S_Creator							INT					NULL,		-- Автор записи
		S_Create_Date						SMALLDATETIME		NULL,		-- Дата создания записи
		
		C_PES								VARCHAR(150)		NULL,		-- ПЭС
		C_RES								VARCHAR(150)		NULL,		-- РЭС
		F_Pts_DMZ							UNIQUEIDENTIFIER	NULL		-- ид-р записи PE.ED_Pts_DMZ
	)
	;

	-- для ФЛ одна строка на один учётный показатель АИС Omni-US, 
	-- при этом показаания по временным зонам отражаются в столбцах, а не в виде отдельных строк
	INSERT INTO #IE_CD_109_MR_Quantity_PE_Group (
		 G_Session_ID
		,C_Number_Subscr
		,C_Name1
		,C_Name2
		,C_Name3
		,C_Municipalities
		,C_Provinces
		,C_Streets
		,C_Building_Num
		,C_Premise_Number
		,C_Room_Number
		,C_Device_Types
		,C_Serial_Number
		,N_Rate
		,N_Quantity_Full
		,N_Quantity_Dev
		,N_Quantity_AvgMonth
		,N_Quantity_Norm
		,N_Quantity_Act
		,N_Quantity_Recalc
		,N_Quantity_ODN
		,N_Quantity_SocNorm_Limit
		,N_Quantity_SocNorm_Over
		,D_Date_Meter_Reading_Prev
		,D_Date_Meter_Reading_Current
	)
	SELECT 
		 G_Session_ID
		,C_Number_Subscr
		,C_Name1
		,C_Name2
		,C_Name3
		,C_Municipalities
		,C_Provinces
		,C_Streets
		,C_Building_Num
		,C_Premise_Number
		,C_Room_Number
		,C_Device_Types
		,C_Serial_Number
		,MAX(N_Rate)					AS N_Rate
		,SUM(N_Quantity_Full)			AS N_Quantity_Full
		,SUM(N_Quantity_Dev)			AS N_Quantity_Dev
		,SUM(N_Quantity_AvgMonth)		AS N_Quantity_AvgMonth
		,SUM(N_Quantity_Norm)			AS N_Quantity_Norm
		,SUM(N_Quantity_Act)			AS N_Quantity_Act
		,SUM(N_Quantity_Recalc)			AS N_Quantity_Recalc
		,SUM(N_Quantity_ODN)			AS N_Quantity_ODN
		,SUM(N_Quantity_SocNorm_Limit)	AS N_Quantity_SocNorm_Limit
		,SUM(N_Quantity_SocNorm_Over)	AS N_Quantity_SocNorm_Over
		,D_Date_Prev					AS D_Date_Prev
		,D_Date							AS D_Date
	FROM #IE_CD_109_MR_Quantity_PE AS T
	WHERE T.G_Session_ID = @G_Session_ID
	GROUP BY 
		 G_Session_ID
		,C_Number_Subscr
		,C_Name1
		,C_Name2
		,C_Name3
		,C_Municipalities
		,C_Provinces
		,C_Streets
		,C_Building_Num
		,C_Premise_Number
		,C_Room_Number
		,C_Device_Types
		,C_Serial_Number
		,D_Date_Prev
		,D_Date
	;

	UPDATE Tupd
	SET Tupd.F_IE_CD_109_MR_Quantity_PE_Group = T.ID
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN #IE_CD_109_MR_Quantity_PE AS Tupd
				ON Tupd.G_Session_ID = T.G_Session_ID
				AND ISNULL(Tupd.C_Number_Subscr		, '-') = ISNULL(T.C_Number_Subscr	, '-')
				AND ISNULL(Tupd.C_Name1				, '-') = ISNULL(T.C_Name1			, '-')
				AND ISNULL(Tupd.C_Name2				, '-') = ISNULL(T.C_Name2			, '-')
				AND ISNULL(Tupd.C_Name3				, '-') = ISNULL(T.C_Name3			, '-')
				AND ISNULL(Tupd.C_Municipalities	, '-') = ISNULL(T.C_Municipalities	, '-')
				AND ISNULL(Tupd.C_Provinces			, '-') = ISNULL(T.C_Provinces		, '-')
				AND ISNULL(Tupd.C_Streets			, '-') = ISNULL(T.C_Streets			, '-')
				AND ISNULL(Tupd.C_Building_Num		, '-') = ISNULL(T.C_Building_Num	, '-')
				AND ISNULL(Tupd.C_Premise_Number	, '-') = ISNULL(T.C_Premise_Number	, '-')
				AND ISNULL(Tupd.C_Room_Number		, '-') = ISNULL(T.C_Room_Number		, '-')
				AND ISNULL(Tupd.C_Device_Types		, '-') = ISNULL(T.C_Device_Types	, '-')
				AND ISNULL(Tupd.C_Serial_Number		, '-') = ISNULL(T.C_Serial_Number	, '-')
				AND ISNULL(Tupd.D_Date_Prev ,  '20790606') = ISNULL(T.D_Date_Meter_Reading_Prev, '20790606')
				AND ISNULL(Tupd.D_Date		,  '20790606') = ISNULL(T.D_Date_Meter_Reading_Current, '20790606')
	;

	UPDATE T
	SET 
		 C_Network							= T2.C_Network
		,F_Partner_Suppliers				= T2.F_Partner_Suppliers
		,F_Division							= T2.F_Division			
		,F_SubDivision						= T2.F_SubDivision		
		,F_Networks							= T2.F_Networks			
		,F_Network_Items					= T2.F_Network_Items	
		,F_Network_Pts						= T2.F_Network_Pts		
		,F_Partners							= T2.F_Partners			
		,F_Subscr							= T2.F_Subscr		
		,F_Conn_Points						= T2.F_Conn_Points
		,F_Conn_Points_Sub					= T2.F_Conn_Points_Sub
		,F_Registr_Pts						= T2.F_Registr_Pts		
		,F_Sale_Items						= T2.F_Sale_Items		
		,F_Device_Division					= T2.F_Device_Division	
		,F_Devices							= T2.F_Devices			
		,F_Device_Types						= T2.F_Device_Types		
		,F_Device_Locations					= T2.F_Device_Locations	
		,F_Owner_Types						= T2.F_Owner_Types		
		,F_Energy_Types						= T2.F_Energy_Types
		,C_Sostoyanie						= T2.C_Sostoyanie
		,C_Conn_Types						= T2.C_Conn_Types
		,C_PES								= ISNULL(N_P.C_Name, N.C_Name)
		,C_RES								= IIF(N_P.C_Name IS NOT NULL, N.C_Name, NULL)
		,S_Creator							= T2.S_Creator
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN #IE_CD_109_MR_Quantity_PE AS T2
				ON T2.F_IE_CD_109_MR_Quantity_PE_Group = T.ID
			LEFT JOIN dbo.ED_Networks AS N
				ON N.LINK = T2.F_Networks
			LEFT JOIN dbo.ED_Networks AS N_P
				ON N_P.LINK = N.F_Networks
	WHERE T.G_Session_ID = @G_Session_ID
	;

	-- Сутки, День
	UPDATE T
	SET 
		 N_Day_Meter_Readings_Prev			= T2.N_Value_Prev
		,N_Day_Meter_Readings_Current		= T2.N_Value

	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN #IE_CD_109_MR_Quantity_PE AS T2
				ON T2.F_IE_CD_109_MR_Quantity_PE_Group = T.ID
	WHERE T.G_Session_ID = @G_Session_ID
		AND T2.F_Time_Zones IN (@TFZ_Day, @TFZ_DayTime)
	;

	-- Ночь
	UPDATE T
	SET 
		 N_Night_Meter_Readings_Prev		= T2.N_Value_Prev
		,N_Night_Meter_Readings_Current		= T2.N_Value
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN #IE_CD_109_MR_Quantity_PE AS T2
				ON T2.F_IE_CD_109_MR_Quantity_PE_Group = T.ID
	WHERE T.G_Session_ID = @G_Session_ID
		AND T2.F_Time_Zones IN (@TFZ_Nigth)
	;

	-- Пик
	UPDATE T
	SET 
		 N_Peak_Meter_Readings_Prev			= T2.N_Value_Prev
		,N_Peak_Meter_Readings_Current		= T2.N_Value
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN #IE_CD_109_MR_Quantity_PE AS T2
				ON T2.F_IE_CD_109_MR_Quantity_PE_Group = T.ID
	WHERE T.G_Session_ID = @G_Session_ID
		AND T2.F_Time_Zones IN (@TFZ_Peak)
	;

	-- Полупик
	UPDATE T
	SET 
		 N_SemiPeak_Meter_Readings_Prev		= T2.N_Value_Prev
		,N_SemiPeak_Meter_Readings_Current	= T2.N_Value
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN #IE_CD_109_MR_Quantity_PE AS T2
				ON T2.F_IE_CD_109_MR_Quantity_PE_Group = T.ID
	WHERE T.G_Session_ID = @G_Session_ID
		AND T2.F_Time_Zones IN (@TFZ_SemiPeak)
	;

	-- если нет даты предыдущего показания и значение равно 0
	UPDATE T
	SET N_Day_Meter_Readings_Prev			= IIF(T.N_Day_Meter_Readings_Prev <> 0, T.N_Day_Meter_Readings_Prev, NULL),
		N_Night_Meter_Readings_Prev			= IIF(T.N_Day_Meter_Readings_Prev <> 0, T.N_Day_Meter_Readings_Prev, NULL),
		N_Peak_Meter_Readings_Prev			= IIF(T.N_Day_Meter_Readings_Prev <> 0, T.N_Day_Meter_Readings_Prev, NULL),
		N_SemiPeak_Meter_Readings_Prev		= IIF(T.N_Day_Meter_Readings_Prev <> 0, T.N_Day_Meter_Readings_Prev, NULL)
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
	WHERE T.D_Date_Meter_Reading_Prev IS NULL
		AND (
				T.N_Day_Meter_Readings_Prev		= 0
			OR T.N_Night_Meter_Readings_Prev	= 0	
			OR T.N_Peak_Meter_Readings_Prev		= 0
			OR T.N_SemiPeak_Meter_Readings_Prev	= 0
	)
	;

	-- если нет даты показания и значение равно 0
	UPDATE T
	SET N_Day_Meter_Readings_Current			= IIF(T.N_Day_Meter_Readings_Current <> 0, T.N_Day_Meter_Readings_Current, NULL),
		N_Night_Meter_Readings_Current			= IIF(T.N_Day_Meter_Readings_Current <> 0, T.N_Day_Meter_Readings_Current, NULL),
		N_Peak_Meter_Readings_Current			= IIF(T.N_Day_Meter_Readings_Current <> 0, T.N_Day_Meter_Readings_Current, NULL),
		N_SemiPeak_Meter_Readings_Current		= IIF(T.N_Day_Meter_Readings_Current <> 0, T.N_Day_Meter_Readings_Current, NULL)
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
	WHERE T.D_Date_Meter_Reading_Current IS NULL
		AND (
				T.N_Day_Meter_Readings_Current		= 0
			OR T.N_Night_Meter_Readings_Current		= 0	
			OR T.N_Peak_Meter_Readings_Current		= 0
			OR T.N_SemiPeak_Meter_Readings_Current	= 0
	)
	;

	-- ========================================================================================================================================
	-- инициализация F_Pts_DMZ
	UPDATE T
	SET T.F_Pts_DMZ	= PD.LINK
	--SELECT * 
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN PE.ED_Pts_DMZ AS PD
				ON	PD.F_Division						= @F_Division
				AND PD.F_Partner_Suppliers				= @F_Supplier
				AND ISNULL(PD.C_Partner_Number, '-')	= ISNULL(T.C_Number_Subscr, '-')
				AND ISNULL(PD.C_Serial_Number, '-')		= ISNULL(T.C_Serial_Number, '-')
				AND PD.B_NoActual						= 0
	WHERE T.G_Session_ID = @G_Session_ID
	OPTION (FORCE ORDER)
	;

	-- досопоставление УП
	UPDATE PD
	SET	F_SubDivision			= T.F_SubDivision		,
		F_Networks				= T.F_Networks			,
		F_Network_Items			= T.F_Network_Items		,
		F_Network_Pts			= T.F_Network_Pts		,
		F_Conn_Points			= T.F_Conn_Points		,
		F_Conn_Points_Sub		= T.F_Conn_Points_Sub	,
		F_Subscr				= T.F_Subscr			,
		F_Device_Types			= T.F_Device_Types		,
		F_Devices				= T.F_Devices			,
		F_Registr_Pts			= T.F_Registr_Pts		,
		B_DiffDeviceNum			= IIF(T.F_Devices IS NULL, 1, 0)
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN PE.ED_Pts_DMZ AS PD
				ON PD.F_Division		= T.F_Division
				AND PD.LINK				= T.F_Pts_DMZ
				AND PD.F_Registr_Pts	IS NULL
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Registr_Pts IS NOT NULL
	OPTION (FORCE ORDER)
	;

	-- досопоставление ПУ
	UPDATE PD
	SET	F_Device_Types			= T.F_Device_Types		,
		F_Devices				= T.F_Devices			,
		B_DiffDeviceNum			= 0
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN PE.ED_Pts_DMZ AS PD
				ON PD.F_Division		= T.F_Division
				AND PD.LINK				= T.F_Pts_DMZ
				AND PD.F_Registr_Pts	= T.F_Registr_Pts
				AND PD.F_Devices		IS NULL
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Devices IS NOT NULL
	OPTION (FORCE ORDER)
	;

    -- импорт УП ЭСК в буферную таблицу по УП, которые не сопоставились с записями таблицы PE.ED_Pts_DMZ или требуется повторное сопоставление
    INSERT INTO PE.ED_Pts_DMZ (
		 C_SO_Name
		,C_PES
		,C_RES
		,C_RES_Msk
		,C_PC
		,C_Fider
		,C_RP
		,C_Line
		,C_TP
		,C_Other
		,C_IKTS
		,C_Partner
		,C_Partner_Number
		,C_City
		,C_Street
		,C_Number_House
		,C_Number_Premise
		,C_Serial_Number
		,C_Device_Type
		,N_Koeff
		,F_Division
		,F_SubDivision
		,F_Partner_Suppliers
		,F_Networks
		,F_Network_Items
		,F_Network_Pts
		,F_Conn_Points
		,F_Conn_Points_Sub
		,F_Subscr
		,F_Device_Types
		,F_Devices
		,F_Registr_Pts
		,S_Creator  
    )
    SELECT DISTINCT
		 T.C_Network AS C_SO_Name
		,T.C_PES
		,T.C_RES
		,NULL AS C_RES_Msk
		,NULL AS C_PC
		,NULL AS C_Fider
		,NULL AS C_RP
		,NULL AS C_Line
		,NULL AS C_TP
		,NULL AS C_Other
		,NULL AS C_IKTS
		,ISNULL(dbo.CF_FIO(T.C_Name1, T.C_Name2, T.C_Name3), '') AS C_Partner
		,T.C_Number_Subscr AS C_Partner_Number
		,T.C_Municipalities AS C_City
		,T.C_Streets AS C_Street
		,LEFT(T.C_Building_Num, 50) AS C_Number_House
		,T.C_Premise_Number + ISNULL(' ком.' + T.C_Room_Number, '') AS C_Number_Premise
		,T.C_Serial_Number
		,T.C_Device_Types AS C_Device_Type
		,T.N_Rate AS N_Koeff
		,T.F_Division
		,T.F_SubDivision
		,F_Partner_Suppliers
		,T.F_Networks
		,T.F_Network_Items
		,T.F_Network_Pts
		,T.F_Conn_Points
		,T.F_Conn_Points_Sub
		,T.F_Subscr
		,T.F_Device_Types
		,T.F_Devices
		,T.F_Registr_Pts
		,T.S_Creator        
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Pts_DMZ IS NULL
	;

    -- инициализация F_Pts_DMZ, для записей, вставленных в текущем сеансе
	UPDATE T
	SET T.F_Pts_DMZ	= PD.LINK
	--SELECT * 
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN PE.ED_Pts_DMZ AS PD
				ON	PD.F_Division						= @F_Division
				AND PD.F_Partner_Suppliers				= @F_Supplier
				AND ISNULL(PD.C_Partner_Number, '-')	= ISNULL(T.C_Number_Subscr, '-')
				AND ISNULL(PD.C_Serial_Number, '-')		= ISNULL(T.C_Serial_Number, '-')
				AND PD.B_NoActual						= 0
	WHERE T.G_Session_ID = @G_Session_ID
		AND T.F_Pts_DMZ IS NULL
	OPTION (FORCE ORDER)
	;

    -- удаляем все ранее загруженные потребления ЭСК по УП (присутствующие во временной таблице) по указанному периоду
    DELETE FROM PPD
    FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN PE.ED_Pts_Period_DMZ AS PPD
				ON  PPD.F_Pts_DMZ    = T.F_Pts_DMZ
				AND PPD.N_Period     = @N_Period
				AND PPD.F_Division   = T.F_Division
    WHERE T.G_Session_ID = @G_Session_ID
	;
	
    -- загрузка потребления ФЛ в раздел "Интеграция со сбытом ФЛ" - левый нижний грид
    INSERT INTO PE.ED_Pts_Period_DMZ (
        F_Pts_DMZ,
        N_Period,
        C_Energy_Levels_T,
        C_Energy_Levels_F,
        C_Partner_Type,
        C_Device_Status,
        D_Device_Date_Replace,
        C_Partner_Group,
        C_IKTU,
        C_Accounting_Category,
        C_Residential_Category,
        C_Slab_Category,
        C_Number_Rooms,
        C_Number_People,
        C_Scheme_Number,
        C_Contract_Number,
        C_Object_Number,        
        N_Day_Meter_Readings_Prev,
        N_Day_Meter_Readings_Current,
        N_Night_Meter_Readings_Prev,
        N_Night_Meter_Readings_Current,
        N_Peak_Meter_Readings_Prev,
        N_Peak_Meter_Readings_Current,
        N_SemiPeak_Meter_Readings_Prev,
        N_SemiPeak_Meter_Readings_Current,
        D_Date_Meter_Reading_Prev,
        D_Date_Meter_Reading_Current,
        N_Losses_Percent,
        N_Losses,
        N_Losses_Line_Percent,
        N_Losses_Line,
        N_Losses_Transformer_Percent,
        N_Losses_Transformer,
        N_Losses_Transformer_Idle,
        N_Losses_Transformer_Idle_Quantity,
        N_Quantity_Act,
        N_Quantity_ODN,
        N_Quantity_Stat,
        N_Quantity_Norm,
		N_Quantity_Soc_Limit,
		N_Quantity_Soc_Over,
        N_Quantity_Full,
		N_Quantity_Pereras,
		N_Ktr,
        C_Note,
        C_Source,
        C_TO,
        C_KO,       
        N_Device_Value,
        D_Date_Setup,
        D_Date_Replace,
        C_ASKUE,    
        F_Division,
        LINK_Imp,
		S_Creator
    )
    SELECT
        T.F_Pts_DMZ,
        @N_Period AS N_Period,
        NULL AS C_Energy_Levels_T,
        NULL AS C_Energy_Levels_F,
        T.C_Sostoyanie AS C_Partner_Type,
        NULL AS C_Device_Status,
        NULL AS D_Device_Date_Replace,
        NULL AS C_Partner_Group,
        NULL AS C_IKTU,
        NULL AS C_Accounting_Category,
        NULL AS C_Residential_Category,
        NULL AS C_Slab_Category,
        NULL AS C_Number_Rooms,
        NULL AS C_Number_People,
        NULL AS C_Scheme_Number,
        NULL AS C_Contract_Number,
        NULL AS C_Object_Number,
        T.N_Day_Meter_Readings_Prev,
        T.N_Day_Meter_Readings_Current,
        T.N_Night_Meter_Readings_Prev,
        T.N_Night_Meter_Readings_Current,
        T.N_Peak_Meter_Readings_Prev,
        T.N_Peak_Meter_Readings_Current,
        T.N_SemiPeak_Meter_Readings_Prev,
        T.N_SemiPeak_Meter_Readings_Current,
        T.D_Date_Meter_Reading_Prev,
        T.D_Date_Meter_Reading_Current,
        NULL AS N_Losses_Percent,
        NULL AS N_Losses,
        NULL AS N_Losses_Line_Percent,
        NULL AS N_Losses_Line,
        NULL AS N_Losses_Transformer_Percent,
        NULL AS N_Losses_Transformer,
        NULL AS N_Losses_Transformer_Idle,
        NULL AS N_Losses_Transformer_Idle_Quantity,
        T.N_Quantity_Act,
        T.N_Quantity_ODN,
        T.N_Quantity_AvgMonth		AS N_Quantity_Stat,
        T.N_Quantity_Norm,
		T.N_Quantity_SocNorm_Limit	AS N_Quantity_Soc_Limit,
		T.N_Quantity_SocNorm_Over	AS N_Quantity_Soc_Over,
        T.N_Quantity_Full,
		T.N_Quantity_Recalc			AS N_Quantity_Pereras,
		T.N_Rate					AS N_Ktr,
        T.C_Conn_Types				AS C_Note,
        @C_File_Name				AS C_Source,
        NULL AS C_TO,
        NULL AS C_KO,
        NULL AS N_Device_Value,
        NULL AS D_Date_Setup,
        NULL AS D_Date_Replace,
        NULL AS C_ASKUE,
        T.F_Division,
        @G_Session_ID AS LINK_Imp,
		T.S_Creator
    FROM #IE_CD_109_MR_Quantity_PE_Group AS T
	WHERE T.G_Session_ID = @G_Session_ID
	;
	/*
    -- обновление само на себя поля F_Registr_Pts, 
	-- чтобы в триггере [TRU_PE_ED_Pts_DMZ] сработал участок кода 
	-- синхронизации объёмов ГП/ЭСК в таблицу dbo.ED_Registr_Pts_Disagreements
	UPDATE PD
	SET F_Registr_Pts = PD.F_Registr_Pts
	--SELECT * 
	FROM #IE_CD_109_MR_Quantity_PE_Group AS T
			INNER JOIN PE.ED_Pts_DMZ AS PD
				ON	PD.F_Division		= T.F_Division
				AND PD.LINK				= T.F_Pts_DMZ
				AND PD.F_Registr_Pts	IS NOT NULL
	WHERE T.G_Session_ID = @G_Session_ID
	OPTION (FORCE ORDER)
	;
	*/

    -- синхронизация расходов ЭСК/ГП из раздела "Интеграция со сбытом" в раздел УП ФЛ "Расходы ГП и разногласия"
	DECLARE @c_sql_r VARCHAR(MAX)
    SET @c_sql_r = ''    
    SELECT @c_sql_r = '
    EXEC IE.IMP_102_MR_Quantity_PE
        @Action_id = ''' + CAST(@G_Session_ID AS VARCHAR(MAX)) + ''',
        @PK = NULL,
        @F_Supplier = ' + ISNULL('''' + CAST(@F_Supplier AS VARCHAR(MAX)) + '''', 'NULL') + ',
        @F_Division = ' + CAST(@F_Division AS VARCHAR(MAX)) + ',
        @Status_Msg = NULL,
        @N_Period = ' + CAST(@N_Period AS VARCHAR(MAX)) + ',
        @F_SubDivision = NULL,
        @C_Subscr = NULL,
        @B_Deny_Calc_Old_RP = 0'
    ;
    EXEC (@c_sql_r)
	;


    -- загрузка и проверка показаний
    IF @B_Imp_MR = 1
    BEGIN

        EXEC IE.IMP_102_FL_Meter_Readings_Analizer
            @Action_id                  = @G_Session_ID, 
            @F_Division                 = @F_Division,
            @PK                         = NULL,
            @Status_Msg                 = NULL,

            @F_Division_SubDivision     = NULL, -- определяется в самой процедуре импорта показаний, возможно придётся переделать
            @N_Year                     = @N_Year,
            @N_Month                    = @N_Month,

            @F_Network_Sup              = @F_Supplier,   -- Поставщик (контрагент)
            @F_Network_PES              = @F_Networks,
			@F_Mode                     = 1,
            
            @B_Load_Nulled              = 0,
            @B_Delete_Invalid           = 0
			;

    END

	-- иницилазация полей сбыта в таблице PE.BUF_ED_Registr_Pts_Integration_ESK (основной грид раздела "Интграция со сбытом ФЛ")
	UPDATE T
	SET 
		B_Exists_Dmz							= 1, -- если ниже INNER заменить на LEFT, OUTER, то нужно реализовать проставление нулевого значения
		B_ESK_Exist								= 1, -- если ниже INNER заменить на LEFT, OUTER, то нужно реализовать проставление нулевого значения

		N_ESK_Quantity_Act						= ESK_Q.N_Quantity_Act,
		N_ESK_Quantity_ODN						= ESK_Q.N_Quantity_ODN,
		N_ESK_Quantity_Stat						= ESK_Q.N_Quantity_Stat,
		N_ESK_Quantity_Norm						= ESK_Q.N_Quantity_Norm,
		N_ESK_Quantity_Full						= ESK_Q.N_Quantity_Full,

		N_ESK_Losses							= ESK_Q.N_Losses,
		N_ESK_Losses_Line_Percent				= ESK_Q.N_Losses_Line_Percent,
		N_ESK_Losses_Transformer_Percent		= ESK_Q.N_Losses_Transformer_Percent,
		N_ESK_Losses_Transformer_Idle			= ESK_Q.N_Losses_Transformer_Idle,

		N_ESK_Quantity_Calc						= ESK_Q.N_Quantity_Calc,
		N_ESK_Quantity_PU						= ESK_Q.N_Quantity_PU,
		N_ESK_Quantity_PU_Only_Positive			= CASE
														WHEN ESK_Q.N_Quantity_PU < 0.0 THEN NULL
														ELSE ESK_Q.N_Quantity_PU
												  END,

		N_ESK_TZ_Count							= ESK_Q.N_TZ_Count
	FROM (	SELECT t2.F_Division, t2.F_Registr_Pts
			FROM #IE_CD_109_MR_Quantity_PE_Group AS t1
					INNER JOIN PE.ED_Pts_DMZ t2
						ON t2.F_Division	= t1.F_Division
						AND t2.LINK			= t1.F_Pts_DMZ
			WHERE t2.F_Registr_Pts IS NOT NULL
			GROUP BY t2.F_Division, t2.F_Registr_Pts
	) AS RP
			INNER JOIN PE.BUF_ED_Registr_Pts_Integration_ESK T
				ON  T.F_Division	= RP.F_Division
				AND T.N_Period		= @N_Period
				AND T.F_Registr_Pts = RP.F_Registr_Pts
			CROSS APPLY
			(
				SELECT 
					iT.F_Division																									AS F_Division, 
					iT.F_Registr_Pts																								AS F_Registr_Pts, 
					NULLIF(iT.N_Quantity_Act, 0)																					AS N_Quantity_Act,
					NULLIF(iT.N_Quantity_ODN, 0)																					AS N_Quantity_ODN,			         
					NULLIF(iT.N_Quantity_Stat, 0)																					AS N_Quantity_Stat,
					NULLIF(iT.N_Quantity_Norm, 0)																					AS N_Quantity_Norm,
					iT.N_Quantity_Full																								AS N_Quantity_Full,
					NULLIF(iT.N_Losses, 0)																							AS N_Losses, 
					NULLIF(iT.N_Losses_Line_Percent, 0)																				AS N_Losses_Line_Percent,
					NULLIF(iT.N_Losses_Transformer_Percent, 0)																		AS N_Losses_Transformer_Percent,
					NULLIF(iT.N_Losses_Transformer_Idle, 0)																			AS N_Losses_Transformer_Idle,
					NULLIF(iT.N_Quantity_Calc, 0)																					AS N_Quantity_Calc, 
					ISNULL(iT.N_Quantity_Full, 0) - ISNULL(iT.N_Losses, 0) - iT.N_Quantity_Calc - ISNULL(iT.N_Quantity_Act, 0)		AS N_Quantity_PU,
					iT.N_TZ_Count																									AS N_TZ_Count
				FROM 
					(
							SELECT
									EPD.F_Division																								AS F_Division,
									EPD.F_Registr_Pts																							AS F_Registr_Pts,			             
									SUM(EPPD.N_Quantity_Act)																					AS N_Quantity_Act,
									SUM(EPPD.N_Quantity_ODN)																					AS N_Quantity_ODN,
									SUM(EPPD.N_Quantity_Stat)																					AS N_Quantity_Stat,
									SUM(EPPD.N_Quantity_Norm)																					AS N_Quantity_Norm,			             
									SUM(EPPD.N_Quantity_Full)																					AS N_Quantity_Full,
									SUM(EPPD.N_Losses)																							AS N_Losses,
									SUM(EPPD.N_Losses_Line_Percent)																				AS N_Losses_Line_Percent,
									SUM(EPPD.N_Losses_Transformer_Percent)																		AS N_Losses_Transformer_Percent,
									SUM(EPPD.N_Losses_Transformer_Idle)																			AS N_Losses_Transformer_Idle,			             
									SUM(ISNULL(EPPD.N_Quantity_ODN, 0) + ISNULL(EPPD.N_Quantity_Stat, 0) + ISNULL(EPPD.N_Quantity_Norm, 0))		AS N_Quantity_Calc,			             
									-- кол-во тарифных зон по сведениям сбыта
									MAX(
										CASE
											WHEN (	EPPD.N_Day_Meter_Readings_Current IS NULL OR EPPD.N_Day_Meter_Readings_Current = 0)
												AND EPPD.N_Night_Meter_Readings_Current IS NOT NULL
												AND EPPD.N_Peak_Meter_Readings_Current IS NOT NULL
												AND EPPD.N_SemiPeak_Meter_Readings_Current IS NOT NULL
											THEN 3
											WHEN     EPPD.N_Day_Meter_Readings_Current IS NOT NULL
												AND  EPPD.N_Night_Meter_Readings_Current IS NOT NULL
												AND (EPPD.N_Peak_Meter_Readings_Current IS NULL OR EPPD.N_Peak_Meter_Readings_Current = 0)
												AND (EPPD.N_SemiPeak_Meter_Readings_Current IS NULL OR EPPD.N_SemiPeak_Meter_Readings_Current = 0)
											THEN 2
											WHEN     EPPD.N_Day_Meter_Readings_Current IS NOT NULL
												AND (EPPD.N_Night_Meter_Readings_Current IS NULL OR EPPD.N_Night_Meter_Readings_Current = 0)
												AND (EPPD.N_Peak_Meter_Readings_Current IS NULL OR EPPD.N_Peak_Meter_Readings_Current = 0)
												AND (EPPD.N_SemiPeak_Meter_Readings_Current IS NULL OR EPPD.N_SemiPeak_Meter_Readings_Current = 0)
											THEN 1
											ELSE 0
										END
									)																											AS N_TZ_Count
							FROM PE.ED_Pts_DMZ EPD --WITH (FORCESEEK) 
									INNER JOIN PE.ED_Pts_Period_DMZ EPPD
										ON  EPPD.F_Division = EPD.F_Division
										AND EPPD.N_Period   = @N_Period
										AND EPPD.F_Pts_DMZ  = EPD.LINK
							WHERE EPD.F_Division		= T.F_Division
								AND EPD.F_Registr_Pts	= T.F_Registr_Pts
							GROUP BY EPD.F_Division, EPD.F_Registr_Pts
				) iT
			) AS ESK_Q
	WHERE 1 = 1
	;

	-- удаляем временные таблицы
	IF OBJECT_ID ('tempdb..#IE_CD_109_MR_Quantity_PE_Group') IS NOT NULL
	DROP TABLE #IE_CD_109_MR_Quantity_PE_Group
	;
	IF OBJECT_ID ('tempdb..#IE_CD_109_MR_Quantity_PE') IS NOT NULL
	DROP TABLE #IE_CD_109_MR_Quantity_PE
	;
*/
	RETURN 1

END
