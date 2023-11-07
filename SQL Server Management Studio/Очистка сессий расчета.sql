SELECT DISTINCT sd.C_name,t.S_Create_Date, t.C_User_Name, 'EXEC PE.UI_APP_Batch_Commit @Session=' + CAST(Session AS VARCHAR(50)) + ';
DELETE FROM Tmp.PE_Subscr_Active_Sessions WHERE [Session]=' + CAST(Session AS VARCHAR(50)) + ';'
, Session FROM Tmp.PE_Subscr_Active_Sessions t 
left join SD_Divisions sd
on sd.LINK=t.F_Division
where t.S_Create_Date<= DATEADD(DD,-1,getdate())
order by sd.C_name,t.S_Create_Date asc