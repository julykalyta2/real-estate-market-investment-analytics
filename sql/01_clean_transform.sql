-- Real Estate Market & Investment Analytics
-- SQL dialect: SQLite 3.x
-- Input: real_estate_transactions_raw.csv imported as raw_transactions

DROP TABLE IF EXISTS clean_transactions;

CREATE TABLE clean_transactions AS
SELECT
    TRIM(listing_id) AS listing_id,
    TRIM(property_id) AS property_id,
    UPPER(TRIM(market)) AS market,
    TRIM(neighborhood) AS neighborhood,
    TRIM(property_type) AS property_type,
    DATE(close_date) AS close_date,
    CAST(strftime('%Y', close_date) AS INTEGER) AS close_year,
    CAST(strftime('%m', close_date) AS INTEGER) AS close_month,
    CAST(beds AS INTEGER) AS beds,
    CAST(baths AS REAL) AS baths,
    CAST(sqft AS INTEGER) AS sqft,
    CAST(year_built AS INTEGER) AS year_built,
    CASE
        WHEN LOWER(TRIM(renovated)) IN ('yes','y','true','1') THEN 1
        ELSE 0
    END AS renovated_flag,
    TRIM(condition) AS condition,
    CAST(list_price AS REAL) AS list_price,
    CAST(sale_price AS REAL) AS sale_price,
    CAST(days_on_market AS INTEGER) AS days_on_market,
    CAST(monthly_rent_est AS REAL) AS monthly_rent_est,
    CAST(annual_property_tax AS REAL) AS annual_property_tax,
    CAST(annual_insurance AS REAL) AS annual_insurance,
    CAST(annual_maintenance AS REAL) AS annual_maintenance,
    CAST(vacancy_rate AS REAL) AS vacancy_rate,
    CAST(management_fee_annual AS REAL) AS management_fee_annual,
    CAST(mortgage_rate AS REAL) AS mortgage_rate
FROM raw_transactions
WHERE
    sale_price > 0
    AND list_price > 0
    AND sqft > 0
    AND beds > 0
    AND baths > 0
    AND mortgage_rate > 0;

-- Add imputed fields and business metrics.
DROP TABLE IF EXISTS analytics_transactions;

CREATE TABLE analytics_transactions AS
SELECT
    *,
    COALESCE(monthly_rent_est,
             sale_price * 0.0045) AS monthly_rent,
    COALESCE(annual_property_tax,
             sale_price * 0.013) AS property_tax,
    COALESCE(annual_insurance,
             sale_price * 0.0045) AS insurance,
    COALESCE(annual_maintenance,
             COALESCE(monthly_rent_est, sale_price * 0.0045) * 12 * 0.09) AS maintenance,

    -- Gross scheduled rent
    COALESCE(monthly_rent_est, sale_price * 0.0045) * 12 AS gross_potential_rent,

    -- Effective gross income after vacancy
    COALESCE(monthly_rent_est, sale_price * 0.0045) * 12
        * (1 - vacancy_rate) AS effective_gross_income,

    -- NOI excludes financing costs
    (
        COALESCE(monthly_rent_est, sale_price * 0.0045) * 12
        * (1 - vacancy_rate)
        - COALESCE(annual_property_tax, sale_price * 0.013)
        - COALESCE(annual_insurance, sale_price * 0.0045)
        - COALESCE(annual_maintenance,
                   COALESCE(monthly_rent_est, sale_price * 0.0045) * 12 * 0.09)
        - COALESCE(management_fee_annual,
                   COALESCE(monthly_rent_est, sale_price * 0.0045) * 12 * 0.06)
    ) AS estimated_noi,

    (sale_price * 100.0 / list_price) AS sale_to_list_pct,

    (
        (
            COALESCE(monthly_rent_est, sale_price * 0.0045) * 12
            * (1 - vacancy_rate)
            - COALESCE(annual_property_tax, sale_price * 0.013)
            - COALESCE(annual_insurance, sale_price * 0.0045)
            - COALESCE(annual_maintenance,
                       COALESCE(monthly_rent_est, sale_price * 0.0045) * 12 * 0.09)
            - COALESCE(management_fee_annual,
                       COALESCE(monthly_rent_est, sale_price * 0.0045) * 12 * 0.06)
        ) / sale_price
    ) * 100 AS estimated_cap_rate,

    CASE
        WHEN days_on_market <= 14 THEN '0-14 days'
        WHEN days_on_market <= 30 THEN '15-30 days'
        WHEN days_on_market <= 60 THEN '31-60 days'
        ELSE '61+ days'
    END AS dom_bucket,

    CASE
        WHEN sale_price < 150000 THEN 'Under $150K'
        WHEN sale_price < 250000 THEN '$150K-$249K'
        WHEN sale_price < 400000 THEN '$250K-$399K'
        ELSE '$400K+'
    END AS price_band
FROM clean_transactions
WHERE sale_price BETWEEN 50000 AND 1000000;

-- Portfolio-level KPI query
SELECT
    close_year,
    market,
    COUNT(*) AS transactions,
    ROUND(AVG(sale_price), 0) AS avg_sale_price,
    ROUND(AVG(days_on_market), 1) AS avg_dom,
    ROUND(AVG(sale_to_list_pct), 2) AS avg_sale_to_list_pct,
    ROUND(AVG(estimated_cap_rate), 2) AS avg_cap_rate
FROM analytics_transactions
GROUP BY close_year, market
ORDER BY close_year, market;

-- Neighborhood opportunity ranking
WITH neighborhood_kpis AS (
    SELECT
        market,
        neighborhood,
        COUNT(*) AS transactions,
        AVG(sale_price) AS avg_sale_price,
        AVG(monthly_rent) AS avg_monthly_rent,
        AVG(estimated_cap_rate) AS avg_cap_rate,
        AVG(days_on_market) AS avg_dom
    FROM analytics_transactions
    GROUP BY market, neighborhood
)
SELECT
    *,
    RANK() OVER (
        PARTITION BY market
        ORDER BY avg_cap_rate DESC
    ) AS cap_rate_rank
FROM neighborhood_kpis
ORDER BY market, cap_rate_rank;

-- Property-type performance
SELECT
    property_type,
    COUNT(*) AS transactions,
    ROUND(AVG(sale_price),0) AS avg_sale_price,
    ROUND(AVG(monthly_rent),0) AS avg_rent,
    ROUND(AVG(estimated_noi),0) AS avg_noi,
    ROUND(AVG(estimated_cap_rate),2) AS avg_cap_rate
FROM analytics_transactions
GROUP BY property_type
ORDER BY avg_cap_rate DESC;
