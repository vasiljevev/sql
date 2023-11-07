DECLARE
	@PERIOD_0 INT,
	@PERIOD_1 INT,
	@b_ee	  INT,
	@B_PE	  INT,
	@F_Division TINYINT = NULL

SELECT 
	@PERIOD_0 =202101,
	@PERIOD_1 =202204,
	@b_ee	  = 1,
	@B_PE	  = 0,
	@F_Division = 61


	/*
delete t
--select *
	from IE.CD_211_Meter_Analizer_Log_Detail t --IE.CD_BUF_Universally
where 1=1
--and cast(s_create_date as date) = '20200829'
and int2 between @PERIOD_0 and @PERIOD_1

select distinct n_period from EE.ED_Pts_Period_DMZ eppd where eppd.F_division=61


*/
--select eppd.*
delete eppd
		FROM EE.ED_Pts_DMZ ept
			
		INNER JOIN EE.ED_Pts_Period_DMZ eppd
			ON eppd.F_Pts_DMZ = ept.LINK		
where @b_ee = 1
and eppd.n_period between @PERIOD_0 and @PERIOD_1
and eppd.F_Division=@F_Division


--select eppd.*
delete eppd
		FROM PE.ED_Pts_DMZ ept
			
		INNER JOIN PE.ED_Pts_Period_DMZ eppd
			ON eppd.F_Pts_DMZ = ept.LINK		
where @B_PE = 1
and  eppd.n_period between @PERIOD_0 and @PERIOD_1
and eppd.F_Division=@F_Division

delete erpd
--select *
	from ED_Registr_Pts_Disagreements erpd
where @B_PE = 1
and  erpd.n_period between @PERIOD_0 and @PERIOD_1
and erpd.F_Division=@F_Division

--удаление пустых шапок
delete ep
--select count(1) 
from EE.ED_Pts_DMZ ep
left join EE.ED_Pts_Period_DMZ epp
on epp.F_Pts_DMZ=ep.LINK
where 1=1
and ep.F_Division=@F_Division
and epp.F_Pts_DMZ is null


--select * from IE.CD_211_Meter_Analizer

/*
DECLARE
	@PERIOD_0 INT,
	@PERIOD_1 INT

SELECT 
	@PERIOD_0 =202108,
	@PERIOD_1 =202108

select g_session_id, int2, s_creator,cast(s_create_date as date), 
case when int4 = 1 then 'FL'
	 when int4 = 2 then 'UL'
	 when int4 = 3 then 'mkd'
	else cast(int4 as varchar) 
end	as [type], 

sum(N_Cons_All) N_Cons_All, count(*) cnt
	from OmniUS_TEST.IE.CD_211_Meter_Analizer_Log_Detail t --IE.CD_BUF_Universally
where 1=1
--and cast(s_create_date as date) = '20200829'
and int2 between @PERIOD_0 and @PERIOD_1
group by g_session_id, int2, s_creator,cast(s_create_date as date), int4
order by 5, 2


select g_session_id, int2, s_creator,cast(s_create_date as date), 
case when int4 = 1 then 'FL'
	 when int4 = 2 then 'UL'
	 when int4 = 3 then 'mkd'
	else cast(int4 as varchar) 
end	as [type], 

sum(N_Cons_All) N_Cons_All, count(*) cnt
	from OmniUS.IE.CD_211_Meter_Analizer_Log_Detail t --IE.CD_BUF_Universally
where 1=1
--and cast(s_create_date as date) = '20200829'
and int2 between @PERIOD_0 and @PERIOD_1
group by g_session_id, int2, s_creator,cast(s_create_date as date), int4
order by 5, 2

*/