SELECT SUM([PayAmount])  FROM [QPShop].[dbo].[T_PayOrder] WHERE [OrderID] IN (
  SELECT [OrderID]  FROM [QPShop].[dbo].[T_UserOrder] WHERE [UserID] IN (
  SELECT DISTINCT UserID  FROM [QPShop].[dbo].[T_UserOrder] WHERE [OrderID] IN (
  SELECT [OrderID]  FROM [QPShop].[dbo].[T_PayOrder]
  )
  AND CreateTime < '2019-07-25' AND Dtype IN (2,3)  GROUP BY UserID  HAVING COUNT(OrderID)=1
) AND UserID IN (
SELECT [UserID]  FROM [Accounts].[dbo].[Accounts] WHERE RegisterDate BETWEEN '2019-07-25' AND '2019-07-26'
)
) AND ProType=1