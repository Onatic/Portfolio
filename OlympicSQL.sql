--Business Problem
--As a data analyst working at a news company you are asked to visualize data that will help readers understand how countries have performed historically in the summer Olympics games.
--You also know that there is an interest in details about the competitors, so if you find anything interesting then don’t hesitate to bring that in also
--The main task is still to show historical performance for different counties, with the possibility to select your own country



SELECT [ID]
      ,[Name] AS 'Athletes Name' -- Rename Column
      ,CASE WHEN [Sex] = 'M' THEN 'Male' 
				ELSE 'Female' 
	   END AS Sex
      ,[Age]
	  ,CASE WHEN [Age] < 20 THEN 'Under 20' -- Creating Age Group
			WHEN [Age] BETWEEN 20 AND 30 THEN '20 - 30'
			WHEN [Age] BETWEEN 30 AND 40 THEN '30 - 40'
			WHEN [Age] > 40 THEN 'Over 40'
	   END AS [Age Group]
      ,[Height]
      ,[Weight]
	  ,ISNULL(NOC.country,[Olympics].[dbo].[athletes_event_results].NOC) AS Country -- Replacing Country with NOC code if Null
	  ,[Olympics].[dbo].[athletes_event_results].NOC
	  ,LEFT(Games, CHARINDEX(' ', Games) -1) AS 'Year' -- Extracting Games Column to LEFT of space
	  ,RIGHT(Games, CHARINDEX(' ', REVERSE(Games)) -1) AS 'Season' -- Extracting Games Column to RIGHT of Space
      ,[Sport]
      ,[Event]
      ,CASE WHEN [Medal] = 'NA' THEN 'No Medal' 
				ELSE Medal 
	   END AS Medal
  FROM [Olympics].[dbo].[athletes_event_results]
	 LEFT JOIN [Olympics].[dbo].NOC on (Noc.Noc = [Olympics].[dbo].[athletes_event_results].NOC or noc.country is null) -- Left Join Country NOC letter with full name if exsist
  WHERE RIGHT(Games, CHARINDEX(' ', REVERSE(Games)) -1) = 'Summer' -- filter by Summer  
  ORDER BY Year DESC
