--drop table #t
set xact_abort on
begin transaction

DECLARE @DST_RemoveDevice   TINYINT;
SELECT  @DST_RemoveDevice   = ddt.LINK FROM dbo.DS_Docum_Types      AS ddt WHERE ddt.C_Const = 'DST_RemoveDevice'; -- select * from dbo.DS_Docum_Types AS ddt WHERE ddt.C_Const = 'DST_RemoveDevice'
DECLARE @DST_ReplaceDevice  TINYINT;
SELECT  @DST_ReplaceDevice  = ddt.LINK FROM dbo.DS_Docum_Types      AS ddt WHERE ddt.C_Const = 'DST_ReplaceDevice'; -- select * from dbo.DS_Docum_Types AS ddt WHERE ddt.C_Const = 'DST_ReplaceDevice'
DECLARE @DCT_Remove     INT;
SELECT @DCT_Remove      = LINK FROM dbo.ES_Device_Check_Types WHERE C_Const = 'DCT_Remove';


select flt.LINK F_Registr_Pts,
	   ed.LINK F_Devices,
	   cast(0 as bit) b_v
into #t
--edp.F_Registr_Pts, count(*) cnt
	from (
			select erp.LINK, count(*) cnt, min(ed.D_Setup_Date)  D_Setup_Date, min(ed.S_Create_Date) S_Create_Date
				from ED_Devices_Pts edp
				inner join ED_Devices ed
					on  ed.link = edp.F_Devices
				inner join ED_Registr_Pts erp
					on  erp.LINK = edp.F_Registr_Pts
			group by erp.LINK
			having count(*) > 1  ---733
			--order by 2 desc
			) flt
	inner join ED_Devices_Pts edp
		inner join ED_Devices ed
			on  ed.link = edp.F_Devices
		on  flt.LINK = edp.F_Registr_Pts
		and flt.D_Setup_Date = ed.D_Setup_Date
		and flt.S_Create_Date = ed.S_Create_Date
		and ed.D_Replace_Date is not null
--where flt.LINK = 659481
--group by edp.F_Registr_Pts
--having count(*) > 1 
---881501


select	 ed.LINK F_Devices
		,edp.LINK f_Devices_Pts
	into #del
	from #t t
	inner join ED_Devices_Pts edp
		on  edp.F_Registr_Pts = t.F_Registr_Pts
		and edp.F_Devices <> t.F_Devices
	inner join ED_Devices ed
		on ed.LINK = edp.F_Devices
	INNER JOIN dbo.CS_Users cu
        ON cu.LINK = ed.S_Creator
        AND cu.C_Name IN ('YANTARENERGO\y-vasilev'
                          ,'COMPULINK\s-alimov'
                          ,'YANTARENERGO\a-pozdeev'
                          ,'YANTARENERGO\s-alimov'
                          ,'YANTARENERGO\k-belousov'
                          ,'YANTARENERGO\m-granek'
                          ,'YANTARENERGO\u-pavlov'
                          ,'YANTARENERGO\e-vasilyev'
                          ,'YANTARENERGO\m-vasilev'
                          ,'YANTARENERGO\OmniUS_admin'
                          ,'YANTARENERGO\v-kurbatov'
                          ,'YANTARENERGO\y-nesterov'
                          ,'YANTARENERGO\Aleksandrova-IV'
						  ,'YANTARENERGO\Nikolenko-OV'
						  ,'YANTARENERGO\OMNIUS$')

print 'delete edp'
delete edp
--select *
	from #del d
	inner join ED_Devices_Pts edp
		on  edp.F_Devices = d.F_Devices

print 'delete ed'

delete ed
--select *
	from #del d
	inner join ED_Devices ed
		on  d.F_Devices = ed.LINK

print 'UPDATE #t'
UPDATE t
SET b_v = 1
FROM dbo.ED_Devices ed
	inner join #t t
		on  t.F_Devices = ed.LINK
    INNER JOIN dbo.CS_Users cu
        ON cu.LINK = ed.S_Creator
        AND cu.C_Name IN ('YANTARENERGO\y-vasilev'
                          ,'COMPULINK\s-alimov'
                          ,'YANTARENERGO\a-pozdeev'
                          ,'YANTARENERGO\s-alimov'
                          ,'YANTARENERGO\k-belousov'
                          ,'YANTARENERGO\m-granek'
                          ,'YANTARENERGO\u-pavlov'
                          ,'YANTARENERGO\e-vasilyev'
                          ,'YANTARENERGO\m-vasilev'
                          ,'YANTARENERGO\OmniUS_admin'
                          ,'YANTARENERGO\v-kurbatov'
                          ,'YANTARENERGO\y-nesterov'
                          ,'YANTARENERGO\Aleksandrova-IV'
						  ,'YANTARENERGO\Nikolenko-OV'
						  ,'YANTARENERGO\OMNIUS$')

print 'UPDATE ed'
UPDATE ed
SET D_Replace_Date = NULL,
    F_Replacement_Reason = NULL
FROM dbo.ED_Devices ed
	inner join #t t
		on  t.F_Devices = ed.LINK
		and t.b_v = 1

select dd.LINK f_docs
into #docs
FROM dbo.ED_Device_Checks edc
    INNER JOIN dbo.DD_Docs dd
        ON dd.F_Division    = dd.F_Division
        AND dd.LINK         = edc.F_Docs
        AND dd.F_Docum_Types    IN (@DST_RemoveDevice,@DST_ReplaceDevice)
        AND dd.LINK_Imp         IS NOT NULL
    INNER JOIN #t t
		on  t.F_Devices = edc.F_Devices
		and t.b_v = 1
WHERE edc.F_Device_Check_Types = @DCT_Remove

print 'DELETE edc'
DELETE edc -- select COUNT(*) 
FROM dbo.ED_Device_Checks edc
    INNER JOIN dbo.DD_Docs dd
        ON dd.F_Division    = dd.F_Division
        AND dd.LINK         = edc.F_Docs
        AND dd.F_Docum_Types    IN (@DST_RemoveDevice,@DST_ReplaceDevice)
        AND dd.LINK_Imp         IS NOT NULL
    INNER JOIN #t t
		on  t.F_Devices = edc.F_Devices
		and t.b_v = 1
WHERE edc.F_Device_Check_Types = @DCT_Remove

print 'DELETE dd'
DELETE dd
--select *
	from DD_Docs dd
	inner join #docs d
		on  d.f_docs = dd.LINK

--select * from #t

drop table #t
drop table #del
drop table #docs
--rollback
COMMIT