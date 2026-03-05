# ======> Business Overview
-- Total Customers
SELECT DISTINCT
    COUNT(customer_id) AS `Total Customer`
FROM
    customers;
-- Total MRR
SELECT 
    SUM(monthly_charges) AS `Total MRR`
FROM
    billing;
-- Overall Churn Rate
SELECT 
    CONCAT(ROUND((SUM(CASE
                        WHEN churn_label = 'Yes' THEN 1
                        ELSE 0
                    END) / COUNT(*)) * 100,
                    2),
            '%') AS `Churn Rate Percentage`
FROM
    churn;
-- Revenue Lost Due to Churn
SELECT 
    SUM(b.monthly_charges) AS `Lost MRR`
FROM
    billing b
        JOIN
    churn ch ON b.customer_id = ch.customer_id
WHERE
    ch.churn_label = 'Yes';
/*--> Short Insight
The Company has 7,043 customers generating ₹455K in monthly reccuring revenue.
However, approximately 26% customers churned, leading to ₹139K revenue loss. 
*/

#=====> Contract Type Analysis
-- Contract Type Vs Churn
SELECT 
    s.contract AS Contract,
    COUNT(*) AS `Total Customers`,
    SUM(CASE
        WHEN ch.churn_label = 'Yes' THEN 1
        ELSE 0
    END) AS Churned,
    CONCAT(ROUND((SUM(CASE
                        WHEN ch.churn_label = 'Yes' THEN 1
                        ELSE 0
                    END) / COUNT(*)) * 100,
                    2),
            '%') AS `Churn Rate Percentage`
FROM
    subscriptions s
        JOIN
    churn ch ON s.customer_id = ch.customer_id
GROUP BY s.contract
ORDER BY Churned DESC;
/*--> Short Insight
Month-to-month contracts show significantly higher churn 42%
compared to long-term contracts (below 11%).
Long-term commitments strongly improve retention. 
*/

#=====> City Analysis
-- Top Cities by Customer
SELECT DISTINCT
    COUNT(*) AS `Total Customers`,
    city AS City,
    ROUND(SUM(b.monthly_charges), 2) AS `Total Monthly Charge`
FROM
    customers c
        JOIN
    billing b ON c.customer_id = b.customer_id
GROUP BY city
ORDER BY `Total Customers` DESC;
-- City-wise Churn Rate
SELECT 
    c.city AS City,
    COUNT(*) `Total Customers`,
    SUM(CASE
        WHEN ch.churn_label = 'Yes' THEN 1
        ELSE 0
    END) AS Churn,
    CONCAT(ROUND((SUM(CASE
                        WHEN ch.churn_label = 'Yes' THEN 1
                        ELSE 0
                    END) / COUNT(*)) * 100,
                    2),
            '%') AS `Churn Rate Percentage`
FROM
    customers c
        JOIN
    churn ch ON c.customer_id = ch.customer_id
GROUP BY c.city
HAVING COUNT(*) > 30
ORDER BY `Churn Rate Percentage` DESC;
/*--> Short Insight
San Diego shows high customer concentration along with
high churn rate (33%) making it on a high-risk revenue region. 
*/

#=====> Tenure Analysis
-- Tenure vs churn
SELECT 
    CASE
        WHEN s.tenure_months <= 12 THEN '0-1 Year'
        WHEN s.tenure_months <= 24 THEN '1-2 Years'
        ELSE '2+ Years'
    END AS Tenure,
    COUNT(*) AS Total,
    SUM(CASE
        WHEN ch.churn_label = 'Yes' THEN 1
        ELSE 0
    END) AS Churned,
    CONCAT(ROUND(SUM(CASE
                        WHEN ch.churn_label = 'Yes' THEN 1
                        ELSE 0
                    END) / COUNT(*) * 100,
                    2),
            '%') AS `Churn Rate Percentage`
FROM
    subscriptions s
        JOIN
    churn ch ON s.customer_id = ch.customer_id
GROUP BY Tenure
ORDER BY Churned DESC;
/*--> Short Insight
Nearly half of customers churn within the first year,
indicating early_stage customer experience is critical.
*/

#=====> Feature Adoption Analysis
-- Feature Adoption vs Churn
SELECT 
    srv.tech_support AS `Tech Support`,
    COUNT(*) AS Total,
    SUM(CASE
        WHEN ch.churn_label = 'Yes' THEN 1
        ELSE 0
    END) AS Churn,
    CONCAT(ROUND((SUM(CASE
                        WHEN ch.churn_label = 'Yes' THEN 1
                        ELSE 0
                    END) / COUNT(*)) * 100,
                    2),
            '%') AS `Churn Rate Percentage`
FROM
    services srv
        JOIN
    churn ch ON srv.customer_id = ch.customer_id
GROUP BY srv.tech_support;
/*--> Short Insight
Customers without tech support churn at nearly 3x higher rate,
indicating service support directly impacts retention. 
*/
/* =====> Final Sumary
The analysis indentifies contract type, early tenure, and lack of
tech support as primary churn drivers. Converting short-term
contracts into annual plans and strenghtening first-year
engagement can significantly reduce revenue leakege. 
*/ 