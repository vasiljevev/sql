--2	     1	2	NULL	1	NULL	5AE88A85-50A2-445F-8A89-A2D545B560ED	Владимирэнерго (ф)
--21	20	2	NULL	1	NULL	88EC6364-151F-4174-ABB2-222BC52C015A	Ивэнерго (ф)
--31	30	2	NULL	1	NULL	A3A68627-5801-41AA-9DC6-40559E7C53E7	Калугаэнерго (ф)
--41	40	2	NULL	1	NULL	0E1C8E1C-3C7A-47C4-86C1-649D61F47472	Кировэнерго (ф)
--51	50	2	NULL	1	NULL	D6677B99-8415-40E3-A9C4-FCB641BB0564	Мариэнерго (ф)
--61	60	2	NULL	1	NULL	49B1D2E2-F28A-417A-ADC9-D6B7B6F63809	Нижновэнерго (ф)
--71	70	2	NULL	1	NULL	2C82B81C-7CA8-452A-9D24-D003A1DE0FBC	РязаньЭнерго (ф)
--81	80	2	NULL	1	NULL	9B84E969-CF94-4776-A5AB-BB3F596E7FFD	ТулЭнерго (ф)
--91	90	2	NULL	1	NULL	46D4B1B2-090A-4AFA-A5E1-AEE2258CB404	Удмуртэнерго (ф)
--select NEWID()
--http://sqlcom.ru/scripts/who-is-active/

sp_WhoIsActive 
     @sort_order = '[database_name] desc,[start_time] desc',
	 @output_column_list= '[dd%][start_time][database_name][session_id][block%][program_name][sql_text][sql_command][login_name][wait_info][tasks][tran_log%][cpu%][temp%][reads%][writes%][context%][physical%][query_plan][locks][%]'--kill 161


--TRUNCATE TABLE IE.CD_Readings                        -- select count(1) from IE.CD_Readings
--TRUNCATE TABLE IE.CD_Readings_Buffer                -- select count(1) from IE.CD_Readings_Buffer
--kill 662


SELECT TOP (10) CIS.*
FROM IE.CS_Integration_Sessions AS CIS
WHERE 1=1
and C_SSIS_Name in ('MEK_Loader.exe','IMP_Readings_Complete')
--and G_Session_ID='6A5A9BC8-56B1-483F-9302-D97ED2215D30'
ORDER BY D_Start_Date desc


SELECT *
FROM msdb.dbo.sysjobs sj
WHERE    1=1
    AND convert(varchar(max), convert(varbinary(16), sj.job_id, 1), 1) = '0xE7F04997C613C64BA67D33A761BC2A63' 


SELECT  *
FROM IE.CS_Integration_Sessions_Log
WHERE 1=1
    AND F_Integration_Sessions = '61503'
    --AND C_ErrorDescription IS NOT NULL
ORDER BY LINK --DESC

--рязань грузится + затем нижний
