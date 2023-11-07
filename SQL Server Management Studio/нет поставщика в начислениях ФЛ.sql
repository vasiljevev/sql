SELECT top 10
ss.N_code,ss.C_number,


fcd.LINK,fcd.LINK_Imp,fcd.N_Period,fcd.F_Subscr,fcd.F_Division,fcd.F_SubDivision,fc.F_Supplier,fcd.F_Registr_Pts, fcd.S_Create_Date,fcd.S_Creator 

FROM PE.FD_Charge_Details fcd
INNER JOIN PE.FD_Charges  fc
    ON fc.LINK = fcd.F_Charges
	and fc.F_Division=fcd.F_Division
inner join sd_subscr ss
on ss.link=fc.F_subscr
WHERE fc.F_Supplier is null
and fc.F_Division = 61
order by fcd.N_Period desc


select * from SD_Subscr where link = 51667341