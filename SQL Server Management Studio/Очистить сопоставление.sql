DECLARE
@B_All BIT = 1



IF @B_All = 1
BEGIN



TRUNCATE TABLE [IE].[CD_Readings]
TRUNCATE TABLE [IE].[CD_Readings_Buffer]
TRUNCATE TABLE [IE].[CD_Readings_Device]
TRUNCATE TABLE [IE].[CD_Readings_Devices_ASKUE]
TRUNCATE TABLE [IE].[CD_Readings_Devices_Info_ASKUE]
TRUNCATE TABLE [IE].[CD_Readings_Log]
DELETE FROM [IE].[CD_Readings_Log_Load]
TRUNCATE TABLE [IE].[CD_Readings_Retrieves]
TRUNCATE TABLE [IE].[CD_Readings_Sessions]
DELETE FROM [IE].[CD_Devices_ASKUE] WHERE F_Division IN (70, 71)
DELETE FROM [IE].[CD_Devices_ASKUE_Omnis] WHERE F_Division IN (70, 71)
TRUNCATE TABLE [IE].[CD_Readings_TMP]
TRUNCATE TABLE [IE].[CD_Events_TMP]
TRUNCATE TABLE [IE].[CD_Events_Device]

END

IF @B_All = 1
BEGIN

UPDATE d
SET
int1 = NULL,
string4 = NULL
FROM dbo.ED_Devices AS d
WHERE 1 = 1
AND F_Division IN (70, 71)
AND (int1 IS NOT NULL OR string4 IS NOT NULL)

END