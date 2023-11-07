select Sup.F_Partners, Par.C_Name1 as Поставщик, isnull(PR.C_Name_Dop, PR.C_Name) as РольКА, count(*) as cnt 
from dbo.ED_Suppliers Sup
        inner join dbo.CD_Partners Par
            on Par.LINK = Sup.F_Partners
        left join dbo.CS_Partner_Roles PR
            on PR.N_Bit_Number_2Power & Par.N_Partner_Roles = PR.N_Bit_Number_2Power
where Sup.F_Division = 61
    and (Sup.D_Date_End is null or Sup.D_Date_End > '20220101')
	--and Sup.F_Partners <> '3EB5D9DA-6E9E-485B-8807-A2763DD37C39'
group by Sup.F_Partners, Par.C_Name1, isnull(PR.C_Name_Dop, PR.C_Name)
order by 4 desc