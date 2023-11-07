USE [OmniUS]
GO

SELECT [LINK]
      ,[SESSION_ID]
      ,[»м€пол€]
      ,[C_Division]
      ,[C_RES]
      ,[C_SubDivision]
      ,[ID_Registr_Pts]
      ,[N_Quantity]
      ,[N_Period0]
      ,[N_Period1]
      ,[C_Notes]
      ,[N_Time_Zones]
      ,[F_Division]
      ,[F_SubDivision]
      ,[F_Registr_Pts]
      ,[D_Date0]
      ,[D_Date1]
      ,[C_Type_Date]
      ,[bit1]
      ,[bit2]
      ,[C_Type_Data]
      ,[F_Calc_Methods]
      ,[F_Delivery_Methods]
      ,[F_Sale_Categories]
      ,[F_Subscr]
      ,[F_Supplier]
      ,[D_Docs1]
      ,[D_Docs2]
      ,[string1]
      ,[string2]
      ,[string3]
      ,[int1]
      ,[int2]
      ,[int3]
      ,[bit4]
      ,[bit5]
      ,[bit6]
      ,[C_Message]
      ,[C_Note]
      ,[S_Create_Date]
      ,[S_Creator]
      ,[N_Calc_Methods]
  FROM [IE].[CD_BUF_Imp_109_First_Integration_DopRashod_Log]

  where F_Division=41
  --and F_Registr_Pts=65400161
  and F_Subscr=51668081
  and N_Period0='03.2022'
  order by S_Create_Date desc

GO


