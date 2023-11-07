IF OBJECT_ID('tempdb.dbo.#T_Empl_Roles_Rights') IS NOT NULL DROP TABLE #T_Empl_Roles_Rights

SELECT
	cer.N_Empl_Roles, cer.F_Empl_Roles, cer.C_Empl_Roles,
	pp.F_Projects, pp.C_Name AS C_Projects, pp.B_EE, pp.B_PE,
	CASE
		WHEN ISNULL(perr.B_Hidden, 0) = 0 AND ISNULL(perr.B_Disabled, 0) = 0 
			THEN 'Да'
		WHEN ISNULL(perr.B_Hidden, 0) = 1
			THEN 'Нет'
		WHEN ISNULL(perr.B_Disabled, 0) = 1
			THEN 'Чтение'
	END			AS C_Right
INTO #T_Empl_Roles_Rights
FROM
(
	SELECT 
		ROW_NUMBER() OVER (ORDER BY cer.C_Name)
					AS N_Empl_Roles,
		cer.LINK	AS F_Empl_Roles, 
		cer.C_Name	AS C_Empl_Roles
	FROM dbo.CS_Empl_Roles AS cer
) AS cer
INNER JOIN 
(
	SELECT
		pp.LINK				AS F_Projects,
		pp.B_EE,
		pp.B_PE,
		ISNULL(pp4.C_Name + ' / ', '') + ISNULL(pp3.C_Name + ' / ', '') + ISNULL(pp2.C_Name + ' / ', '') + ISNULL(pp1.C_Name + ' / ', '') + pp.C_Name
							AS C_Name
	FROM dbo.PS_Projects AS pp
	LEFT JOIN dbo.PS_Projects AS pp1
		ON	pp1.LINK			= pp.F_Projects
	LEFT JOIN dbo.PS_Projects AS pp2
		ON	pp2.LINK			= pp1.F_Projects
	LEFT JOIN dbo.PS_Projects AS pp3
		ON	pp3.LINK			= pp2.F_Projects
	LEFT JOIN dbo.PS_Projects AS pp4
		ON	pp4.LINK			= pp3.F_Projects
) AS pp
	ON	1=1
LEFT JOIN dbo.PS_Empl_Roles_Rights AS perr
	ON	perr.F_Empl_Roles		= cer.F_Empl_Roles
	AND perr.F_Projects			= pp.F_Projects	
ORDER BY pp.C_Name, cer.N_Empl_Roles



DECLARE 
	@C_Enter	NVARCHAR(10) = CHAR(13) + CHAR(10),
	@SQL_Roles1	NVARCHAR(MAX) = '',
	@SQL_Roles2	NVARCHAR(MAX) = '',
	@SQL		NVARCHAR(MAX)
	

SELECT
	@SQL_Roles1	= @SQL_Roles1 + '[' + r.N_Empl_Roles + '] AS [' + r.C_Empl_Roles + '], ' + @C_Enter
FROM
(
	SELECT DISTINCT
		CAST(N_Empl_Roles AS VARCHAR) AS N_Empl_Roles,
		C_Empl_Roles
	FROM #T_Empl_Roles_Rights	
) AS r
ORDER BY r.N_Empl_Roles
SELECT @SQL_Roles1 = SUBSTRING(@SQL_Roles1, 1, LEN(@SQL_Roles1) - 4) + @C_Enter


SELECT
	@SQL_Roles2	= @SQL_Roles2 + ', [' + r.N_Empl_Roles + ']'
FROM
(
	SELECT DISTINCT
		CAST(N_Empl_Roles AS VARCHAR) AS N_Empl_Roles
	FROM #T_Empl_Roles_Rights	
) AS r
ORDER BY r.N_Empl_Roles
SELECT @SQL_Roles2 = STUFF(@SQL_Roles2, 1, 2, NULL)


SET @SQL =
'SELECT
	F_Projects,
	C_Projects,
	CASE WHEN B_EE = 1 THEN ''Да'' ELSE '''' END AS [ЮЛ],
	CASE WHEN B_PE = 1 THEN ''Да'' ELSE '''' END AS [ФЛ],
	' + @SQL_Roles1 + '
FROM  
(
	SELECT
		N_Empl_Roles, F_Projects, C_Projects, B_EE, B_PE, C_Right
	FROM #T_Empl_Roles_Rights
) AS s  
PIVOT  
(  
  MAX(C_Right)
  FOR N_Empl_Roles IN (' + @SQL_Roles2 + ')
) AS p
ORDER BY C_Projects;
'


SELECT
	@SQL =	REPLACE
			(
				@SQL,
				'[' + CAST(r.N_Empl_Roles AS VARCHAR(10)) + '] AS [' + CAST(r.N_Empl_Roles AS VARCHAR(10)) + ']',
				'[' + CAST(r.N_Empl_Roles AS VARCHAR(10)) + '] AS [' + r.C_Empl_Roles + ']'
			)
FROM
(
	SELECT DISTINCT
		N_Empl_Roles, C_Empl_Roles
	FROM #T_Empl_Roles_Rights
) AS r	

EXEC sys.sp_executesql @SQL


IF OBJECT_ID('tempdb.dbo.#T_Empl_Roles_Rights') IS NOT NULL DROP TABLE #T_Empl_Roles_Rights