select en2.C_Name, en.C_Name
, sum(CASE WHEN eni.string4 IS NOT NULL
		THEN 1
		ELSE 0
		END) as [код заполен]
, sum(CASE WHEN eni.string4 IS NULL
		THEN 1
		ELSE 0
		END) as [код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK=203
		THEN 1
		ELSE 0
		END) as [ПС - код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK=204
		THEN 1
		ELSE 0
		END) as [СШСН - код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK=205
		THEN 1
		ELSE 0
		END) as [ФСН - код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK=207
		THEN 1
		ELSE 0
		END) as [ТП - код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK=208
		THEN 1
		ELSE 0
		END) as [СШНН - код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK=209
		THEN 1
		ELSE 0
		END) as [ФНН - код не заполен]
, sum(CASE WHEN eni.string4 IS NULL and enit.LINK not in (209,208,207,205,204,203)
		THEN 1
		ELSE 0
		END) as [Прочие- код не заполен]

from dbo.ED_Network_Items eni
	inner join dbo.SD_Divisions sd
		on sd.LINK = eni.F_Division
		--where eni.string4 is not null
	inner join dbo.ED_Networks en
		on en.LINK=eni.F_Networks
	left join dbo.ED_Networks en2
		on en.F_Networks = en2.LINK
	inner join dbo.ES_Network_Items_Types enit
		on enit.LINK=eni.F_Network_Items_Types
		group by en2.C_Name, en.C_Name
		order by en2.C_Name, en.C_Name;

/*select * from dbo.ES_Network_Items_Types enit;*/


/*
select top 1 eni.string4    
from dbo.ED_Network_Items eni
	inner join dbo.SD_Divisions sd
		on sd.LINK = eni.F_Division
		where eni.string4 is null
		*/

DROP TABLE IF EXISTS #TblD
Create Table #TblD(FIL varchar(255), res varchar(255), C_Short_Name varchar(255), Num varchar(255))
declare @F_division int,
		@enit_LINK_min int,
		@enit_LINK_max int,
		@F_division_min int,
		@F_division_max int

set @F_division_min=21;
set @F_division_max=121;
set	@enit_LINK_min=202;
set	@enit_LINK_max=209;

WHILE (@F_division_min <= @F_division_max)
	BEGIN
	set	@enit_LINK_min=202;
	WHILE (@enit_LINK_min <= @enit_LINK_max)
		BEGIN
			INSERT INTO #TblD (
			FIL,
			res,
			C_Short_Name,
			Num
			)
			select top 5
			en2.C_Name
			, en.C_Name
			, enit.C_Short_Name
			, eni.string4
			from dbo.ED_Network_Items eni
				inner join dbo.SD_Divisions sd
					on sd.LINK = eni.F_Division
					--where eni.string4 is not null
				inner join dbo.ED_Networks en
					on en.LINK=eni.F_Networks
				left join dbo.ED_Networks en2
					on en.F_Networks = en2.LINK
				inner join dbo.ES_Network_Items_Types enit
					on enit.LINK=eni.F_Network_Items_Types
					where eni.string4 IS NOT NULL
					and enit.LINK = @enit_LINK_min
					and eni.F_Division=@F_division_min
					and len(eni.string4) >4
				SET @enit_LINK_min = @enit_LINK_min+1
				--select * from #TblD
		END
	SET @F_division_min = @F_division_min + 1
END

select * from #TblD
order by FIL,
		 res,
		 C_Short_Name
		 