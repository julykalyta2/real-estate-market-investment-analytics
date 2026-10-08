# Real Estate Market & Investment Analytics

## Project Overview

This project analyzes a synthetic real-estate transaction dataset designed to mimic the type of data an analyst might receive from an MLS, brokerage CRM, property-management system, or investment-acquisitions pipeline.

The goal is to answer a practical business question:

> **Where are the strongest opportunities for residential real-estate investors, and how have pricing, market speed, rental economics, and financing conditions changed over time?**

The project demonstrates an end-to-end analytics workflow:

**Raw data → SQL data cleaning → business metrics → exploratory analysis → investment insights**

---

## Business Questions

1. How have home sale prices changed from 2022–2025?
2. Which market and neighborhoods have the strongest estimated investment returns?
3. Which property types offer the best combination of price, rent, NOI, and cap rate?
4. How does market speed (days on market) vary by neighborhood and property type?
5. How closely do sale prices track estimated monthly rent?
6. How did mortgage rates change during the study period?
7. Are there neighborhoods that combine relatively high cap rates with slower market conditions that may create negotiation opportunities?

---

## Dataset

The dataset contains **24,000 synthetic residential real-estate transactions** covering January 2022 through December 2025.

It includes two markets:

- Cleveland
- Baltimore

And five neighborhoods within each market.

### Main columns

| Column | Description |
|---|---|
| listing_id | Unique listing identifier |
| property_id | Property identifier |
| market | Metro market |
| neighborhood | Neighborhood |
| property_type | Single Family, Townhouse, Condo, Duplex, Triplex, Fourplex |
| close_date | Transaction closing date |
| beds | Bedrooms |
| baths | Bathrooms |
| sqft | Property square footage |
| year_built | Year constructed |
| renovated | Whether property was renovated |
| condition | Property condition |
| list_price | Original listing price |
| sale_price | Final sale price |
| days_on_market | Days from listing to contract/closing proxy |
| monthly_rent_est | Estimated monthly market rent |
| annual_property_tax | Annual property tax |
| annual_insurance | Estimated annual insurance |
| annual_maintenance | Estimated annual maintenance |
| vacancy_rate | Expected vacancy |
| management_fee_annual | Estimated property-management cost |
| mortgage_rate | Approximate financing environment |

### Why the data is synthetic

The data is intentionally generated to behave like real business data without exposing private client, MLS, or financial information.

It includes:

- Missing values
- Invalid records
- Outliers
- Seasonality
- Neighborhood price differences
- Property-type differences
- Market appreciation
- Mortgage-rate changes
- Rent/price relationships
- Investment-return variation

This makes the cleaning and analysis steps representative of a real analytics workflow.

---

## Data Quality Problems

The raw extract intentionally contains several issues an analyst must identify before reporting:

- Missing rental estimates
- Missing tax values
- Missing year-built values
- Missing days-on-market values
- Zero square footage
- Zero bedrooms/bathrooms
- Negative sale prices
- Invalid mortgage rates
- Different data types requiring explicit conversion

The SQL transformation removes impossible transaction records and uses documented business-rule imputations for selected missing financial fields.

---

## SQL Analysis

SQL is used to:

1. Standardize text fields.
2. Convert dates and numeric fields.
3. Remove impossible records.
4. Create year/month fields.
5. Impute missing financial estimates.
6. Calculate effective gross income.
7. Estimate NOI.
8. Calculate cap rate.
9. Calculate sale-to-list percentage.
10. Create price and DOM categories.
11. Rank neighborhoods by investment performance.

### Key investment metric

Estimated cap rate is calculated as:

```text
Cap Rate = Estimated NOI / Sale Price
```

Estimated NOI is:

```text
Effective Gross Income
- Property Taxes
- Insurance
- Maintenance
- Management Fees
```

Financing costs are excluded from NOI because cap rate is intended to compare the underlying property economics before financing.

---

## Exploratory Data Analysis

Python and Matplotlib are used to investigate the dataset visually.

### Analysis 1 — Price Trends

Median sale price is compared across markets and years to identify appreciation patterns.

### Analysis 2 — Seasonality

Average transaction volume is calculated by month to identify seasonal market behavior.

### Analysis 3 — Price vs. Rent

Sale price is compared with estimated monthly rent to evaluate the relationship between acquisition cost and rental income.

### Analysis 4 — Cap Rate by Property Type

Cap-rate distributions are compared across single-family, townhouse, condo, duplex, triplex, and fourplex properties.

### Analysis 5 — Neighborhood Opportunity

Neighborhoods are evaluated using:

- Average cap rate
- Average days on market
- Average sale price
- Transaction volume

This helps distinguish high-yield areas from expensive, highly competitive markets.

### Analysis 6 — Financing Environment

Average mortgage rates are compared across the four-year period to provide context for changing affordability and investment returns.

---

## Key Findings from the Synthetic Dataset

Because this is synthetic data, these are **portfolio-analysis findings**, not claims about the actual Cleveland or Baltimore housing markets.

### 1. Prices increased while estimated cap rates compressed

Average sale price increased in both markets from 2022 to 2025. Baltimore increased from approximately $234K to $269K, while Cleveland increased from approximately $215K to $247K. Over the same period, average estimated cap rates declined from 6.00% to 5.44% in Baltimore and from 6.30% to 5.70% in Cleveland.

**Business implication:** rising acquisition prices can reduce income yield even when the market is appreciating.

### 2. Cleveland provides stronger modeled yield than Baltimore

Across the modeled period, Cleveland generally has lower average acquisition prices and higher estimated cap rates than Baltimore.

**Business implication:** an investor focused primarily on current income would likely screen Cleveland more favorably, while a growth-focused investor might evaluate the markets differently.

### 3. Condo properties have the highest modeled cap rate

In this synthetic dataset, condos average approximately a 6.55% estimated cap rate, compared with 5.95% for single-family homes and 5.16% for fourplexes. This is intentionally different from the simplistic assumption that a larger multifamily property must always produce the best yield.

**Business implication:** property type alone is not enough; acquisition price and rent economics need to be evaluated together.

### 4. Neighborhood economics vary substantially

Park Heights has the highest modeled Baltimore cap rate at approximately 8.29%, while Collinwood leads Cleveland at approximately 7.94%. Higher-priced neighborhoods such as Canton, Federal Hill, and Shaker Heights show lower modeled cap rates.

**Business implication:** neighborhood-level analysis can uncover income opportunities that are hidden by metro-level averages.

### 5. High-yield neighborhoods can also have faster modeled turnover

The highest-cap-rate neighborhoods in the synthetic data also tend to have lower average days on market than several higher-priced neighborhoods. This creates an interesting screening question: whether an investor should prioritize yield, acquisition liquidity, or a balance of both.

### 6. Seasonality should be included in market reporting

The transaction data intentionally contains stronger spring/summer activity and softer winter activity. Looking only at a single month could therefore give a misleading impression of market demand.

---

## Tools

- **SQL / SQLite** — data cleaning, transformation, aggregation, window functions
- **Python** — data preparation and exploratory analysis
- **Pandas** — data manipulation
- **NumPy** — numerical calculations
- **Matplotlib** — visualization
- **GitHub** — portfolio presentation

---

## Project Structure

```text
real-estate-analytics/
│
├── data/
│   └── real_estate_transactions_raw.csv
│
├── sql/
│   └── 01_clean_transform.sql
│
├── python/
│   └── 02_eda.py
│
├── figures/
│   ├── 01_median_sale_price_trend.png
│   ├── 02_transaction_seasonality.png
│   ├── 03_price_vs_rent.png
│   ├── 04_cap_rate_by_type.png
│   ├── 05_neighborhood_opportunity.png
│   └── 06_mortgage_rates.png
│
└── README.md
```

---

## How to Run

### 1. Load the CSV into SQLite

Create a table called:

```sql
raw_transactions
```

and import:

```text
data/real_estate_transactions_raw.csv
```

### 2. Run the SQL script

Run:

```text
sql/01_clean_transform.sql
```

This creates:

```text
clean_transactions
analytics_transactions
```

### 3. Run the Python analysis

Install dependencies:

```bash
pip install pandas numpy matplotlib
```

Then:

```bash
python python/02_eda.py
```

The script creates the charts in the `figures/` directory.


---

## Power BI Dashboard

The project also includes a Power BI-ready analytical layer.

The dashboard is designed as a four-page decision-support report:

1. **Executive Market Overview** — pricing, transaction volume, seasonality, and mortgage rates.
2. **Investment Opportunity** — neighborhood cap rates, NOI, rent, DOM, and an opportunity matrix.
3. **Property Type Analysis** — comparing acquisition prices, rental economics, and cap rates.
4. **Market Drilldown** — detailed neighborhood-level analysis.

### Power BI files

- `powerbi_real_estate_fact.csv` — cleaned analytical fact table
- `powerbi_date_dimension.csv` — date dimension
- `powerbi_dax_measures.dax` — reusable DAX measures
- `POWER_BI_DASHBOARD_GUIDE.md` — complete dashboard build instructions

### Why Power BI is included

SQL demonstrates data preparation, Python demonstrates exploratory analysis, and Power BI demonstrates how an analyst can turn the results into an interactive decision-support product.

The intended workflow is:

```text
Raw CSV
   ↓
SQL cleaning & transformation
   ↓
Analytical dataset
   ├──→ Python EDA
   │
   └──→ Power BI dashboard
            ↓
      Business recommendations
```


---

## Analyst Takeaways

This project demonstrates more than chart creation. The workflow connects technical analysis to business decisions:

**Data quality → reliable metrics → market comparison → investment decision support**

The most important analytical lesson is that no single metric should be used to identify an investment opportunity.

For example:

- A high cap rate may indicate strong cash-flow potential, but it may also reflect higher property risk.
- A low days-on-market figure can indicate strong demand, but it can also make acquisition more competitive.
- A high sale price does not necessarily indicate poor investment value if rental income and NOI are also high.
- Mortgage rates can materially change the economics of an otherwise attractive acquisition.

A strong investment-screening process therefore considers **price, rent, NOI, cap rate, market liquidity, property type, and financing conditions together.**

---

## Future Improvements

A production version of this project could add:

- Property-level time series
- Actual MLS listing histories
- Geographic coordinates
- Census demographics
- Crime and school data
- Rent growth
- Renovation costs
- Loan amortization
- Cash-on-cash return
- DSCR
- IRR
- Equity multiple
- Interactive Power BI dashboard
- Automated SQL pipeline
- Predictive price or rent model

---

## Portfolio Skills Demonstrated

### SQL
- Data cleaning
- Type conversion
- CASE statements
- COALESCE / missing-value handling
- Aggregation
- CTEs
- Window functions
- Business metric creation

### Python
- Data validation
- Feature engineering
- Groupby analysis
- Statistical summaries
- Exploratory data analysis
- Matplotlib visualization

### Business Analysis
- KPI definition
- Investment screening
- Market comparison
- Trend identification
- Data-quality assessment
- Translating analysis into business recommendations

---

## Disclaimer

This project uses entirely synthetic data created for educational and portfolio purposes. The markets, transactions, financial values, and investment metrics do not represent actual MLS records or actual investment opportunities.
