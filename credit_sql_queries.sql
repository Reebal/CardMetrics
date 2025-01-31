use banking;
SELECT * FROM banking.cards_data;


# Credit utilization rate by income bracket
SELECT 
    u.id AS client_id,
    CASE 
        WHEN u.yearly_income <= 30000 THEN 'Low Income'
        WHEN u.yearly_income > 30000 AND u.yearly_income <= 70000 THEN 'Middle Income'
        WHEN u.yearly_income > 70000 THEN 'High Income'
        ELSE 'Unknown'
    END AS income_bracket,
    c.card_brand,
    ROUND(SUM(u.total_debt) / NULLIF(SUM(c.credit_limit), 0) * 100, 2) AS credit_utilization_rate,
    COUNT(c.card_brand) AS total_cards
FROM 
    users_data u
JOIN 
    cards_data c 
    ON u.id = c.client_id
WHERE 
    c.card_type = "Credit" -- Focus on credit cards only
    AND c.credit_limit > 0 -- Exclude invalid or frozen accounts
GROUP BY 
    income_bracket, c.card_brand, u.id;

#avg credit limits by card brands
select
	card_brand,
    round(avg(credit_limit),0) as avg_credit_limit, 
    count(distinct id) as total_cards
from 
	cards_data
where
	card_type = "Credit"
group by
		card_brand
order by
		2 desc;

#cards expiring soon
SELECT 
    DATE_FORMAT(expires, '%M') AS Expiry_month,
    COUNT(id) AS `Total cards`,
    count(case when card_brand = "Amex" then 1 else NULL end) as Amex,
    count(case when card_brand = "Discover" then 1 else NULL end) as Discover,
    count(case when card_brand = "Mastercard" then 1 else NULL end) as Mastercard,
    count(case when card_brand = "Visa" then 1 else NULL end) as Visa
FROM 
    cards_data
WHERE 
    EXTRACT(YEAR FROM expires) = 2024
GROUP BY 
    expiry_month;

# new customers every year    
SELECT 
    YEAR(acct_open_date) AS `year`, 
    SUM(CASE WHEN card_brand = 'Amex' THEN 1 ELSE 0 END) AS `Amex`,
    SUM(CASE WHEN card_brand = 'Mastercard' THEN 1 ELSE 0 END) AS `Mastercard`,
    SUM(CASE WHEN card_brand = 'Visa' THEN 1 ELSE 0 END) AS `Visa`,
    SUM(CASE WHEN card_brand = 'Discover' THEN 1 ELSE 0 END) AS `Discover`
FROM 
    cards_data
WHERE 
    acct_open_date IS NOT NULL -- Optional, ensures valid dates
GROUP BY 
    YEAR(acct_open_date)
ORDER BY 
    `year` ASC;
    



WITH monthly_data AS (
    SELECT 
        MONTH(T.date) AS `Month`,
        T.use_chip as Transaction_Type,
        C.Card_Type as Card_Type,
        C.Card_Brand as Card_Brand,
        ROUND(SUM(T.amount), 0) AS Revenue,
        COUNT(T.id) AS `Number_of_Transactions`,
        ROUND(SUM(T.amount) / COUNT(T.id), 2) AS `Average_Transaction_Value`
    FROM transactions_data T join cards_data C
    on T.client_id = C.client_id
    WHERE T.date >= '2010-01-01' and T.date <= '2010-10-31'  -- Date filter for excluding November
    GROUP BY 
        MONTH(T.date), 
        Transaction_Type, 
        Card_Type, 
        Card_Brand
)
SELECT 
    `Month`,
    Transaction_Type,
    Card_Type,
    Card_Brand,
    Revenue,
    `Number_of_Transactions`,
    `Average_Transaction_Value`,
    LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    ) AS Previous_Month_Revenue,
    ROUND(((Revenue - LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) / LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) * 100, 2) AS Revenue_Growth_Rate,
    LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    ) AS Previous_Month_Transactions,
    ROUND((( `Number_of_Transactions` - LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) / LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) * 100, 2) AS Transaction_Growth_Rate
FROM monthly_data;

WITH monthly_data AS (
    SELECT 
        MONTH(T.date) AS `Month`,
        T.use_chip AS Transaction_Type,
        C.Card_Type AS Card_Type,
        C.Card_Brand AS Card_Brand,
        ROUND(SUM(T.amount), 0) AS Revenue,
        COUNT(T.id) AS `Number_of_Transactions`,
        ROUND(SUM(T.amount) / COUNT(T.id), 2) AS `Average_Transaction_Value`
    FROM transactions_data T 
    JOIN cards_data C ON T.client_id = C.client_id
    #WHERE T.date >= '2010-01-01' AND T.date < '2010-11-01'  -- Excludes November
    GROUP BY 
        MONTH(T.date), 
        Transaction_Type, 
        Card_Type, 
        Card_Brand
)
SELECT 
    `Month`,
    Transaction_Type,
    Card_Type,
    Card_Brand,
    Revenue,
    `Number_of_Transactions`,
    `Average_Transaction_Value`,
    LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    ) AS Previous_Month_Revenue,
    ROUND(((Revenue - LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) / LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) * 100, 2) AS Revenue_Growth_Rate,
    LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    ) AS Previous_Month_Transactions,
    ROUND((( `Number_of_Transactions` - LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) / LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) * 100, 2) AS Transaction_Growth_Rate
FROM monthly_data;


# Creating a Transactions dataset with filters ready for Tableau visualization
WITH monthly_data AS (
    SELECT 
        MONTH(T.date) AS `Month`,
        T.use_chip AS Transaction_Type,
        C.Card_Type AS Card_Type,
        C.Card_Brand AS Card_Brand,
        ROUND(SUM(T.amount), 0) AS Revenue,
        COUNT(T.id) AS `Number_of_Transactions`,
        ROUND(SUM(T.amount) / COUNT(T.id), 2) AS `Average_Transaction_Value`
    FROM transactions_data T 
    JOIN cards_data C ON T.client_id = C.client_id
    WHERE T.date >= '2010-01-01' AND T.date < '2010-11-01'   -- from Jan to Oct because dataset is missing values after that
    GROUP BY 
        MONTH(T.date), 
        Transaction_Type, 
        Card_Type, 
        Card_Brand
)
SELECT 
    `Month`,
    Transaction_Type,
    Card_Type,
    Card_Brand,
    Revenue,
    `Number_of_Transactions`,
    `Average_Transaction_Value`,
    LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    ) AS Previous_Month_Revenue,
    ROUND(((Revenue - LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) / LAG(Revenue) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) * 100, 2) AS Revenue_Growth_Rate,
    LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    ) AS Previous_Month_Transactions,
    ROUND((( `Number_of_Transactions` - LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) / LAG(`Number_of_Transactions`) OVER (
        PARTITION BY Transaction_Type, Card_Type, Card_Brand 
        ORDER BY `Month`
    )) * 100, 2) AS Transaction_Growth_Rate
FROM monthly_data;

