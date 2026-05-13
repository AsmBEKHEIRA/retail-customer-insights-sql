SELECT *
FROM public.customers

1- calcul CA par genre 

SELECT 
    "Gender",
    SUM("Purchase Amount (USD)") AS total_revenue
FROM public.customers
GROUP BY "Gender";

2- Identification des clients utilisant un code promo et dépassant le panier moyen

SELECT 
    "Customer ID",
    "Gender",
    "Age",
    "Item Purchased",
    "Category",
    "Purchase Amount (USD)",
    "Promo Code Used",
    (SELECT AVG("Purchase Amount (USD)") FROM public.customers) AS average_purchase
FROM public.customers
WHERE "Promo Code Used" = 'Yes'
AND "Purchase Amount (USD)" > (
    SELECT AVG("Purchase Amount (USD)")
    FROM public.customers
)
ORDER BY "Purchase Amount (USD)" DESC
LIMIT 30;

3-Classement des 3 produits avec la meilleure satisfaction client moyenne

SELECT 
    "Item Purchased",
    AVG("Review Rating") AS average_rating
FROM public.customers
GROUP BY "Item Purchased"
ORDER BY average_rating DESC
LIMIT 3;

4-Catégories générant le plus de revenu

SELECT 
    "Category",
    SUM("Purchase Amount (USD)") AS total_revenue
FROM public.customers
GROUP BY "Category"
ORDER BY total_revenue DESC;

5- Panier moyen par genre

SELECT 
    "Gender",
    ROUND(AVG("Purchase Amount (USD)")::numeric, 2) AS average_purchase
FROM public.customers
GROUP BY "Gender";

6- Rentabilité par tranche d’âge

SELECT 
    "age_group",
    COUNT(*) AS number_of_customers,
    SUM("Purchase Amount (USD)") AS total_revenue,
    ROUND(AVG("Purchase Amount (USD)")::numeric, 2) AS average_purchase
FROM public.customers
GROUP BY "age_group"
ORDER BY total_revenue DESC;

7- Comparaison des dépenses entre clients inscrits et non inscrits

SELECT 
    "Subscription Status",
    COUNT(*) AS number_of_customers,
    SUM("Purchase Amount (USD)") AS total_revenue,
    ROUND(AVG("Purchase Amount (USD)")::numeric, 2) AS average_purchase
FROM public.customers
GROUP BY "Subscription Status"
ORDER BY average_purchase DESC;

8-Comparaison du chiffre d’affaires avec et sans code promo

SELECT 
    "Promo Code Used",
    COUNT(*) AS number_of_orders,
    SUM("Purchase Amount (USD)") AS total_revenue,
    ROUND(AVG("Purchase Amount (USD)")::numeric, 2) AS average_purchase
FROM public.customers
GROUP BY "Promo Code Used"
ORDER BY total_revenue DESC;

9-Segmentation des clients selon leur valeur d’achat et leur fréquenc

SELECT 
    "Customer ID",
    COUNT(*) AS number_of_orders,
    SUM("Purchase Amount (USD)") AS total_spent,
    ROUND(AVG("Purchase Amount (USD)")::numeric, 2) AS average_purchase,
    AVG("Frequency Days") AS average_frequency_days,
    CASE 
        WHEN SUM("Purchase Amount (USD)") >= (
            SELECT AVG(total_customer_spent)
            FROM (
                SELECT SUM("Purchase Amount (USD)") AS total_customer_spent
                FROM public.customers
                GROUP BY "Customer ID"
            ) sub
        )
        AND COUNT(*) >= 2
        THEN 'High Value Customer'

        WHEN SUM("Purchase Amount (USD)") < (
            SELECT AVG(total_customer_spent)
            FROM (
                SELECT SUM("Purchase Amount (USD)") AS total_customer_spent
                FROM public.customers
                GROUP BY "Customer ID"
            ) sub
        )
        THEN 'Low Value Customer'

        ELSE 'Medium Value Customer'
    END AS customer_segment
FROM public.customers
GROUP BY "Customer ID"
ORDER BY total_spent DESC;

10- Segmentation des produits selon satisfaction client et chiffre d’affaires


WITH product_performance AS (
    SELECT 
        "Item Purchased",
        "Category",
        COUNT(*) AS number_of_orders,
        SUM("Purchase Amount (USD)") AS total_revenue,
        ROUND(AVG("Purchase Amount (USD)")::numeric, 2) AS average_purchase,
        ROUND(AVG("Review Rating")::numeric, 2) AS average_rating
    FROM public.customers
    GROUP BY 
        "Item Purchased",
        "Category"
),
averages AS (
    SELECT
        AVG(total_revenue) AS avg_revenue,
        AVG(average_rating) AS avg_rating
    FROM product_performance
)
SELECT 
    p."Item Purchased",
    p."Category",
    p.number_of_orders,
    p.total_revenue,
    p.average_purchase,
    p.average_rating,
    CASE
        WHEN p.average_rating >= a.avg_rating 
             AND p.total_revenue < a.avg_revenue
        THEN 'High Potential Product'
        WHEN p.average_rating >= a.avg_rating 
             AND p.total_revenue >= a.avg_revenue
        THEN 'Star Product'
        WHEN p.average_rating < a.avg_rating 
             AND p.total_revenue >= a.avg_revenue
        THEN 'Revenue Driver but Low Satisfaction'
        ELSE 'Low Priority Product'
    END AS product_segment
FROM product_performance p
CROSS JOIN averages a
ORDER BY 
    product_segment,
    p.average_rating DESC,
    p.total_revenue DESC;