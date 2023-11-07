DECLARE @F_Division INT,
		@F_Subdivision INT,
		@N_Month INT,
		@N_Year INT,
		@N_Period INT

SELECT @F_Division = 25 --Отделение --
--select * from SD_Divisions where link = 25
select @F_Subdivision = null --Участок (сделать null, если по всем)
SELECT @N_Month = 10 --Месяц
SELECT @N_Year = 2021 --Год

SELECT @N_Period = @N_Year * 100 + @N_Month


---1
DECLARE @C_Subdivision VARCHAR(255)
SELECT @C_Subdivision = STUFF(
             (SELECT ',' + CAST (LINK AS VARCHAR(10))
              FROM ORL_Subdivisions_Full_List t1
			  WHERE F_Division = ISNULL(@F_Division, F_Division) and F_SubDivision = ISNULL(@F_Subdivision, F_SubDivision) and F_SubDivision is not null
              FOR XML PATH (''))
             , 1, 1, '') 

--SELECT @C_Subdivision
---2
DECLARE @Networks VARCHAR(MAX)
DECLARE @C_Network_Items VARCHAR(MAX)

SELECT @Networks = STUFF(
             (SELECT ',' + CAST (LINK AS VARCHAR(MAX))
              FROM ED_Networks t1
			  WHERE F_Division = ISNULL(@F_Division, F_Division) and F_SubDivision = ISNULL(@F_Subdivision, F_SubDivision) and F_SubDivision <> 0
              FOR XML PATH (''))
             , 1, 1, '') 

DECLARE 
	@NIT_Substation	TINYINT,
	@NIT_Feeder		TINYINT
SELECT @NIT_Substation	= LINK FROM dbo.ES_Network_Items_Types WHERE C_Const = 'NIT_Substation'
SELECT @NIT_Feeder		= LINK FROM dbo.ES_Network_Items_Types WHERE C_Const = 'NIT_Feeder'

SELECT @C_Network_Items =  STUFF(
             (SELECT ',' + CAST (eni.LINK AS VARCHAR(MAX))
			 FROM
				  (select distinct eni_ps.LINK 
				  FROM dbo.ED_Network_Items AS eni
					INNER JOIN dbo.ED_Network_Routes AS enr
						ON	enr.LINK					= eni.LINK
						AND eni.F_Network_Items_Types	= @NIT_Feeder 
					INNER JOIN dbo.ED_Network_Items AS eni_ps
						ON	eni_ps.LINK					= enr.F_Parent
						AND eni_ps.F_Network_Items_Types= @NIT_Substation
					LEFT JOIN dbo.ED_Network_Struct as eds
						ON 	eni_ps.LINK					= eds.F_Child
					INNER JOIN dbo.SF_Text_To_GuidTable(@Networks) AS en
						ON	en.LINK				= eni.F_Networks
					WHERE 1=1
						and eds.F_Parent IS NULL) AS eni
              FOR XML PATH (''))
             , 1, 1, '') 

--SELECT @Networks
--SELECT @C_Network_Items

---3.
DECLARE @Network UNIQUEIDENTIFIER
--ВРЕМЕННЫЕ ТАБЛИЦЫ
--Полезный отпуск по отчету Кавказа
IF OBJECT_ID ('tempdb.dbo.#RPT_107_PSP_Perfomance_Evaluation_edit') IS NOT NULL DROP TABLE #RPT_107_PSP_Perfomance_Evaluation_edit
CREATE TABLE #RPT_107_PSP_Perfomance_Evaluation_edit
(
	C_Network_Type VARCHAR(30),
	N_Period INT,
	F_Networks UNIQUEIDENTIFIER,
	LINK UNIQUEIDENTIFIER,
	Division NVARCHAR(250),
	Subdivision NVARCHAR(250),
	C_SubStation NVARCHAR(250),
	C_Section NVARCHAR(250),
	C_Feeder NVARCHAR(250),
	C_TP NVARCHAR(250),
	C_Network_Path NVARCHAR(250),
	Invent_Fact INT,
	plan_smr_cnt INT,
	Network_intake INT,
	Productive_supply INT,
	N_Losses INT,
	N_Losses_Percent DECIMAL(19,6),
	N_RP_Count_EE_Plus INT,
	N_RP_Count_PE_Plus INT,
	N_RP_Count_EE_Minus INT,
	N_RP_Count_PE_Minus INT,
	N_RP_Count_EE_Zero INT,
	N_RP_Count_PE_Zero INT,
	N_Quantity_EE_Plus	DECIMAL(19,6),
	N_Quantity_PE_Plus	DECIMAL(19,6),
	N_Quantity_EE_Minus	DECIMAL(19,6),
	N_Quantity_PE_Minus	DECIMAL(19,6),
	N_Quantity_EE_Zero	DECIMAL(19,6),
	N_Quantity_PE_Zero	DECIMAL(19,6),
	N_RP_Count_Calc_Method_EE	INT,
	N_RP_Count_Meter_Method_EE	INT,
	N_RP_Count_Meter_Method_PE	INT,
	N_RP_Count_Calc_Method_PE	INT,	
	N_RP_Count_Null_Method_PE	INT	
)
--select * from #RPT_107_PSP_Perfomance_Evaluation_edit
--баланс по фидерам
IF OBJECT_ID ('tempdb.dbo.#RPT_107_Fider_Balance_edit') IS NOT NULL DROP TABLE #RPT_107_Fider_Balance_edit
CREATE TABLE #RPT_107_Fider_Balance_edit
(
	C_Network_Type VARCHAR(30),
	N_Period INT,
	FSN_ID UNIQUEIDENTIFIER,
	F_Networks UNIQUEIDENTIFIER,
	c_network_pes VARCHAR(256),
	c_networks VARCHAR(256),
	FSN VARCHAR(MAX),
	N_Value_To_Fider DECIMAL(19,6),
	N_Cons_EE DECIMAL(19,6),
	N_Cons_PE DECIMAL(19,6),
	N_Cons_Hoz DECIMAL(19,6), 
	N_Loss_Technical DECIMAL(19,6),
	N_Cons DECIMAL(19,6),
	N_NB DECIMAL(19,6),
	N_Percent_NB DECIMAL(19,6),
	N_RP_Count_EE INT, 
	N_RP_Count_PE INT,
	N_RP_Count INT,
	N_RP_Count_EE_Plus INT,
	N_RP_Count_PE_Plus INT,
	N_RP_Count_EE_Minus INT,
	N_RP_Count_PE_Minus INT,
	N_RP_Count_EE_Zero INT,
	N_RP_Count_PE_Zero INT,
	N_Quantity_EE_Plus	DECIMAL(19,6),
	N_Quantity_PE_Plus	DECIMAL(19,6),
	N_Quantity_EE_Minus	DECIMAL(19,6),
	N_Quantity_PE_Minus	DECIMAL(19,6),
	N_Quantity_EE_Zero	DECIMAL(19,6),
	N_Quantity_PE_Zero	DECIMAL(19,6),
	N_RP_Count_Calc_Method_EE	INT,
	N_RP_Count_Meter_Method_EE	INT,
	N_RP_Count_Meter_Method_PE	INT,
	N_RP_Count_Calc_Method_PE	INT,	
	N_RP_Count_Null_Method_PE	INT	
)
--Баланс по РЭС
IF OBJECT_ID ('tempdb.dbo.#RPT_107_Balance_RES_edit') IS NOT NULL DROP TABLE #RPT_107_Balance_RES_edit
CREATE TABLE #RPT_107_Balance_RES_edit
(
	C_Network_Type VARCHAR(30),
	N_Period	INT,
	F_Networks UNIQUEIDENTIFIER,
	Total_OS DECIMAL(19,6), 
	Total_PO DECIMAL(19,6), 
	Total_Loss DECIMAL(19,6), 
	Total_Loss_Percent DECIMAL(19,6),
	N_RP_Count_EE_Plus INT,
	N_RP_Count_PE_Plus INT,
	N_RP_Count_EE_Minus INT,
	N_RP_Count_PE_Minus INT,
	N_RP_Count_EE_Zero INT,
	N_RP_Count_PE_Zero INT,
	N_Quantity_EE_Plus	DECIMAL(19,6),
	N_Quantity_PE_Plus	DECIMAL(19,6),
	N_Quantity_EE_Minus	DECIMAL(19,6),
	N_Quantity_PE_Minus	DECIMAL(19,6),
	N_Quantity_EE_Zero	DECIMAL(19,6),
	N_Quantity_PE_Zero	DECIMAL(19,6),
	N_RP_Count_Calc_Method_EE	INT,
	N_RP_Count_Meter_Method_EE	INT,
	N_RP_Count_Meter_Method_PE	INT,
	N_RP_Count_Calc_Method_PE	INT,	
	N_RP_Count_Null_Method_PE	INT	
)

--ПОДВЕДЕНИЕ ИТОГА ПО СЕТИ
--Заполнение буфера узлов для EE
		INSERT INTO Tmp.EE_ED_Network_Balance_Items
		(
			F_Network_Items,
			N_Period,
			N_Dt_Period
		)
		SELECT 
			fpd.F_Network_Items,
			fp.N_Period,
			fp.N_Dt_Period

		  FROM EE.FD_Paysheets AS fp
			INNER JOIN EE.FD_Paysheets_Details AS fpd
				ON    fpd.F_Paysheets = fp.LINK
				AND fpd.N_Period = fp.N_Period
				AND fpd.F_Division = fp.F_Division
		WHERE fp.F_Division = ISNULL(@F_Division, fp.F_Division)
			AND fp.N_Period = @N_Period
		GROUP BY 
			fpd.F_Network_Items,
			fp.N_Period,
			fp.N_Dt_Period
    
		--EXEC EE.OP_ED_Network_Balance_Operate
		--	@F_Division = @F_Division

		--EXEC PE.OP_ED_Network_Balance_Operate
		--	@F_Division		= @F_Division,
		--	@Month			= @N_Month,
		--	@Year			= @N_Year,
		--	@Action_id		= 'c49206fd-0595-463a-998d-97a6724320e4',
		--	@PK				= NULL,
		--	@Status_Msg		= NULL



--ВЫЗОВ ПРОЦЕДУР
exec CUS.RPT_107_PSP_Perfomance_Evaluation_edit @C_Subdivisions=@C_Subdivision,@start_period=@N_Period,@end_period=@N_Period
exec EE.RPT_107_Fider_Balance_edit @N_Month0=@N_Month,@N_Month1=@N_Month,@N_Year0=@N_Year,@N_Year1=@N_Year,@Filial=null,@Network=@Networks,@Pes=null,@C_Network_Items=@C_Network_Items,@N_Percent=N'0',@B_Group_Feeder=0


DECLARE networks_cursor CURSOR FOR 
SELECT LINK FROM dbo.ED_Networks  WHERE F_Division = ISNULL(@F_Division, F_Division) AND F_SubDivision = ISNULL(@F_Subdivision, F_SubDivision) and F_SubDivision <> 0
OPEN networks_cursor  
FETCH NEXT FROM networks_cursor INTO @Network  

WHILE @@FETCH_STATUS = 0  
BEGIN  
    exec EE.RPT_107_Balance_RES_edit @N_Year=@N_Year,@N_Month=@N_Month,@F_Networks=@Network
	FETCH NEXT FROM networks_cursor INTO @Network 
END 

CLOSE networks_cursor  
DEALLOCATE networks_cursor 

--ФОРМИРОВАНИЕ РЕЗУЛЬТАТА

IF OBJECT_ID ('tempdb.dbo.#RPT_Result') IS NOT NULL DROP TABLE #RPT_Result
CREATE TABLE #RPT_Result
(
	C_Network_Type VARCHAR(30),
	C_Closed_Period VARCHAR(30),
	C_Period VARCHAR(30),
	N_Period INT,
	C_Pes VARCHAR(255),
	C_Res VARCHAR(255),
	C_Fsn VARCHAR(255),
	C_TP  VARCHAR(255),
	N_Quantity_Res_OS DECIMAL(19,6),
	N_Quantity_Res_PO DECIMAL(19,6),
	N_Quantity_Res_Loss DECIMAL(19,6),
	N_Quantity_Res_Loss_Percent DECIMAL(19,6),
	N_Quantity_NIT_Feeder_OS DECIMAL(19,6),	
	N_Quantity_NIT_Feeder_PO DECIMAL(19,6),	
	N_Quantity_NIT_Feeder_Loss DECIMAL(19,6),	
	N_Quantity_NIT_Feeder_Loss_Percent	DECIMAL(19,6),
	N_Count_EE_PE	INT,
	N_Quantity_NIT_TP_OS	DECIMAL(19,6),
	N_Quantity_NIT_TP_PO	DECIMAL(19,6),
	N_Quantity_NIT_TP_Loss	DECIMAL(19,6),
	N_Quantity_NIT_TP_Loss_Percent DECIMAL(19,6),
	N_Quantity_OS DECIMAL(19,6),
	N_Quantity_PO DECIMAL(19,6),
	N_Quantity_Loss DECIMAL(19,6),
	N_Quantity_Loss_Percent DECIMAL(19,6),
	N_RP_Count_EE_Plus			INT,
	N_RP_Count_PE_Plus			INT,
	N_RP_Count_EE_Minus			INT,
	N_RP_Count_PE_Minus			INT,
	N_RP_Count_EE_Zero			INT,
	N_RP_Count_PE_Zero			INT,
	N_Quantity_EE_Plus			DECIMAL(19,6),
	N_Quantity_PE_Plus			DECIMAL(19,6),
	N_Quantity_EE_Minus			DECIMAL(19,6),
	N_Quantity_PE_Minus			DECIMAL(19,6),
	N_Quantity_EE_Zero			DECIMAL(19,6),
	N_Quantity_PE_Zero			DECIMAL(19,6),
	N_RP_Count_Calc_Method_EE	INT,
	N_RP_Count_Meter_Method_EE	INT,
	N_RP_Count_Meter_Method_PE	INT,
	N_RP_Count_Calc_Method_PE	INT,	
	N_RP_Count_Null_Method_PE	INT	
)



INSERT INTO #RPT_Result(	
	C_Network_Type						,
	C_Closed_Period						,
	C_Period							,
	N_Period							,
	C_Pes								,
	C_Res								,
	C_Fsn								,
	C_TP								,
	N_Quantity_Res_OS					,
	N_Quantity_Res_PO					,
	N_Quantity_Res_Loss					,
	N_Quantity_Res_Loss_Percent			,
	N_Quantity_NIT_Feeder_OS			,	
	N_Quantity_NIT_Feeder_PO			,	
	N_Quantity_NIT_Feeder_Loss			,	
	N_Quantity_NIT_Feeder_Loss_Percent	,
	N_Count_EE_PE						,
	N_Quantity_NIT_TP_OS				,
	N_Quantity_NIT_TP_PO				,
	N_Quantity_NIT_TP_Loss				,
	N_Quantity_NIT_TP_Loss_Percent		,
	N_Quantity_OS					,
	N_Quantity_PO					,
	N_Quantity_Loss					,
	N_Quantity_Loss_Percent,
	N_RP_Count_EE_Plus			
	,N_RP_Count_PE_Plus			
	,N_RP_Count_EE_Minus			
	,N_RP_Count_PE_Minus			
	,N_RP_Count_EE_Zero			
	,N_RP_Count_PE_Zero			
	,N_Quantity_EE_Plus			
	,N_Quantity_PE_Plus			
	,N_Quantity_EE_Minus			
	,N_Quantity_PE_Minus			
	,N_Quantity_EE_Zero			
	,N_Quantity_PE_Zero			
	,N_RP_Count_Calc_Method_EE	
	,N_RP_Count_Meter_Method_EE	
	,N_RP_Count_Meter_Method_PE	
	,N_RP_Count_Calc_Method_PE	
	,N_RP_Count_Null_Method_PE				
)

SELECT	res.C_Network_Type, 
		null, 
		CONVERT(varchar(10), dbo.CF_Month_Date_N_Period(res.N_Period), 102),
		res.N_Period,
		sd.C_Name,
		en.C_name,
		NULL,
		NULL,
		res.Total_OS * 1000,
		res.Total_PO *1000,
		res.Total_Loss *1000,
		res.Total_Loss_Percent *100,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		res.Total_OS * 1000,
		res.Total_PO *1000,
		res.Total_Loss *1000,
		res.Total_Loss_Percent *100,
		res.N_RP_Count_EE_Plus			
		,res.N_RP_Count_PE_Plus			
		,res.N_RP_Count_EE_Minus			
		,res.N_RP_Count_PE_Minus			
		,res.N_RP_Count_EE_Zero			
		,res.N_RP_Count_PE_Zero			
		,res.N_Quantity_EE_Plus			
		,res.N_Quantity_PE_Plus			
		,res.N_Quantity_EE_Minus			
		,res.N_Quantity_PE_Minus			
		,res.N_Quantity_EE_Zero			
		,res.N_Quantity_PE_Zero			
		,res.N_RP_Count_Calc_Method_EE	
		,res.N_RP_Count_Meter_Method_EE	
		,res.N_RP_Count_Meter_Method_PE	
		,res.N_RP_Count_Calc_Method_PE	
		,res.N_RP_Count_Null_Method_PE	

FROM #RPT_107_Balance_RES_edit AS res
INNER JOIN dbo.ED_Networks as en
	ON en.LINK = res.F_Networks
INNER JOIN dbo.SD_Divisions AS sd
	on sd.LINK = en.F_Division

UNION ALL

SELECT	fider.C_Network_Type, 
		null, 
		CONVERT(varchar(10), dbo.CF_Month_Date_N_Period(fider.N_Period), 102),
		fider.N_Period,
		fider.c_network_pes,
		fider.c_networks,
		fider.FSN,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		fider.N_Value_To_Fider,
		fider.N_Cons,
		fider.N_NB,
		fider.N_Percent_NB,
		fider.N_RP_Count,
		NULL,
		NULL,
		NULL,
		NULL,
		fider.N_Value_To_Fider,
		fider.N_Cons,
		fider.N_NB,
		fider.N_Percent_NB,
		fider.N_RP_Count_EE_Plus			
		,fider.N_RP_Count_PE_Plus			
		,fider.N_RP_Count_EE_Minus			
		,fider.N_RP_Count_PE_Minus			
		,fider.N_RP_Count_EE_Zero			
		,fider.N_RP_Count_PE_Zero			
		,fider.N_Quantity_EE_Plus			
		,fider.N_Quantity_PE_Plus			
		,fider.N_Quantity_EE_Minus			
		,fider.N_Quantity_PE_Minus			
		,fider.N_Quantity_EE_Zero			
		,fider.N_Quantity_PE_Zero			
		,fider.N_RP_Count_Calc_Method_EE	
		,fider.N_RP_Count_Meter_Method_EE	
		,fider.N_RP_Count_Meter_Method_PE	
		,fider.N_RP_Count_Calc_Method_PE	
		,fider.N_RP_Count_Null_Method_PE	
FROM #RPT_107_Fider_Balance_edit AS fider

UNION ALL

SELECT	tp.C_Network_Type, 
		null, 
		CONVERT(varchar(10), dbo.CF_Month_Date_N_Period(tp.N_Period), 102),
		tp.N_Period,
		tp.Division,
		tp.SubDivision,
		tp.C_Network_Path,
		tp.C_TP,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		tp.Invent_Fact, --кол-во ПУ с тех.учетом 
		tp.Network_intake,
		tp.Productive_supply,
		tp.N_Losses,
		tp.N_Losses_Percent,
		tp.Network_intake,
		tp.Productive_supply,
		tp.N_Losses,
		tp.N_Losses_Percent,
		N_RP_Count_EE_Plus ,
		N_RP_Count_PE_Plus ,
		N_RP_Count_EE_Minus ,
		N_RP_Count_PE_Minus ,
		N_RP_Count_EE_Zero ,
		N_RP_Count_PE_Zero ,
		N_Quantity_EE_Plus	,
		N_Quantity_PE_Plus	,
		N_Quantity_EE_Minus	,
		N_Quantity_PE_Minus	,
		N_Quantity_EE_Zero	,
		N_Quantity_PE_Zero	,
		N_RP_Count_Calc_Method_EE,
		N_RP_Count_Meter_Method_EE,
		N_RP_Count_Meter_Method_PE,
		N_RP_Count_Calc_Method_PE,	
		N_RP_Count_Null_Method_PE	
FROM #RPT_107_PSP_Perfomance_Evaluation_edit AS tp

select 
		C_Network_Type						,
		C_Closed_Period						,
		C_Period							,
		N_Period							,
		C_Pes								,
		C_Res								,
		C_Fsn								,
		C_TP							,	
		ISNULL(CAST(N_Quantity_Res_OS					AS VARCHAR),'') AS N_Quantity_Res_OS					,					
		ISNULL(CAST(N_Quantity_Res_PO					AS VARCHAR),'') AS N_Quantity_Res_PO					,		
		ISNULL(CAST(N_Quantity_Res_Loss					AS VARCHAR),'')	AS N_Quantity_Res_Loss					,
		ISNULL(CAST(N_Quantity_Res_Loss_Percent			AS VARCHAR),'')	AS N_Quantity_Res_Loss_Percent			,
		ISNULL(CAST(N_Quantity_NIT_Feeder_OS			AS VARCHAR),'')	AS N_Quantity_NIT_Feeder_OS				,	
		ISNULL(CAST(N_Quantity_NIT_Feeder_PO			AS VARCHAR),'')	AS N_Quantity_NIT_Feeder_PO				,	
		ISNULL(CAST(N_Quantity_NIT_Feeder_Loss			AS VARCHAR),'')	AS N_Quantity_NIT_Feeder_Loss			,	
		ISNULL(CAST(N_Quantity_NIT_Feeder_Loss_Percent	AS VARCHAR),'')	AS N_Quantity_NIT_Feeder_Loss_Percent	,
		ISNULL(CAST(N_Count_EE_PE						AS VARCHAR),'')	AS N_Count_EE_PE						,
		ISNULL(CAST(N_Quantity_NIT_TP_OS				AS VARCHAR),'')	AS N_Quantity_NIT_TP_OS					,
		ISNULL(CAST(N_Quantity_NIT_TP_PO				AS VARCHAR),'')	AS N_Quantity_NIT_TP_PO					,
		ISNULL(CAST(N_Quantity_NIT_TP_Loss				AS VARCHAR),'')	AS N_Quantity_NIT_TP_Loss				,
		ISNULL(CAST(N_Quantity_NIT_TP_Loss_Percent		AS VARCHAR),'')	AS N_Quantity_NIT_TP_Loss_Percent		,
		ISNULL(CAST(N_Quantity_OS						AS VARCHAR),'')	AS N_Quantity_OS						,
		ISNULL(CAST(N_Quantity_PO						AS VARCHAR),'')	AS N_Quantity_PO						,
		ISNULL(CAST(N_Quantity_Loss						AS VARCHAR),'')	AS N_Quantity_Loss						,
		ISNULL(CAST(N_Quantity_Loss_Percent				AS VARCHAR),'')	AS N_Quantity_Loss_Percent				,
		ISNULL(CAST(N_RP_Count_EE_Plus					AS VARCHAR),'') AS N_RP_Count_EE_Plus					,			
		ISNULL(CAST(N_RP_Count_PE_Plus					AS VARCHAR),'') AS N_RP_Count_PE_Plus					,
		ISNULL(CAST(N_RP_Count_EE_Minus					AS VARCHAR),'') AS N_RP_Count_EE_Minus					,
		ISNULL(CAST(N_RP_Count_PE_Minus					AS VARCHAR),'') AS N_RP_Count_PE_Minus					,
		ISNULL(CAST(N_RP_Count_EE_Zero					AS VARCHAR),'') AS N_RP_Count_EE_Zero					,
		ISNULL(CAST(N_RP_Count_PE_Zero					AS VARCHAR),'') AS N_RP_Count_PE_Zero					,
		ISNULL(CAST(N_Quantity_EE_Plus					AS VARCHAR),'') AS N_Quantity_EE_Plus					,
		ISNULL(CAST(N_Quantity_PE_Plus					AS VARCHAR),'') AS N_Quantity_PE_Plus					,
		ISNULL(CAST(N_Quantity_EE_Minus					AS VARCHAR),'') AS N_Quantity_EE_Minus					,
		ISNULL(CAST(N_Quantity_PE_Minus					AS VARCHAR),'') AS N_Quantity_PE_Minus					,
		ISNULL(CAST(N_Quantity_EE_Zero					AS VARCHAR),'') AS N_Quantity_EE_Zero					,
		ISNULL(CAST(N_Quantity_PE_Zero					AS VARCHAR),'') AS N_Quantity_PE_Zero					,
		ISNULL(CAST(N_RP_Count_Calc_Method_EE			AS VARCHAR),'') AS N_RP_Count_Calc_Method_EE			,
		ISNULL(CAST(N_RP_Count_Meter_Method_EE			AS VARCHAR),'') AS N_RP_Count_Meter_Method_EE			,
		ISNULL(CAST(N_RP_Count_Meter_Method_PE			AS VARCHAR),'') AS N_RP_Count_Meter_Method_PE			,
		ISNULL(CAST(N_RP_Count_Calc_Method_PE			AS VARCHAR),'') AS N_RP_Count_Calc_Method_PE			,
		ISNULL(CAST(N_RP_Count_Null_Method_PE			AS VARCHAR),'') AS N_RP_Count_Null_Method_PE			 
from #RPT_Result 
order by 
	CASE 
		WHEN C_Network_Type = 'RES' THEN 1 
		WHEN C_Network_Type = 'NIT_Feeder' THEN 2 
		ELSE 3 
	END, 
	C_Pes, 
	C_Res,
	C_Fsn

----SELECT * FROM #RPT_107_Fider_Balance_edit 
----SELECT * FROM #RPT_107_Balance_RES_edit
----SELECT * FROM #RPT_107_PSP_Perfomance_Evaluation_edit

--52843927-4edc-46bb-8ae8-02aedfc47f71
--АКХП	1СШ-6	Ф-7	125	АКХП / 1СШ-6 / Ф-7