# Power BI Dashboard Build Guide

## Dashboard objective

Create a four-page Power BI report that answers:

> Where are the strongest residential real-estate investment opportunities, and how are market conditions changing?

---

# Page 1 — Executive Market Overview

### KPI cards

1. Transactions
2. Median Sale Price
3. Average Days on Market
4. Average Cap Rate
5. Average Mortgage Rate

### Visuals

**Top-left:** Line chart
- X-axis: Date / Year-Month
- Y-axis: Median Sale Price
- Legend: Market

**Top-right:** Clustered column chart
- X-axis: Year
- Y-axis: Transactions
- Legend: Market

**Bottom-left:** Line chart
- X-axis: Month
- Y-axis: Transactions
- Use Month Number as the sort column

**Bottom-right:** Line chart
- X-axis: Year
- Y-axis: Average Mortgage Rate

### Slicers

- Market
- Neighborhood
- Property Type
- Year
- Condition

---

# Page 2 — Investment Opportunity

### KPI cards

- Average Cap Rate
- Total Estimated NOI
- Average Monthly Rent
- Average Price / Sq Ft

### Main visual

Scatter chart:

- X-axis: Average Days on Market
- Y-axis: Average Cap Rate
- Size: Transactions
- Legend: Market
- Details: Neighborhood

Interpretation:

Upper-left = potentially attractive combination of higher yield and faster market activity.

Upper-right = higher yield but slower market.

Lower-left = lower yield and faster market.

Lower-right = lower yield and slower market.

### Supporting table

Columns:

- Market
- Neighborhood
- Transactions
- Average Sale Price
- Average Rent
- Average NOI
- Average Cap Rate
- Average DOM
- Cap Rate Rank

Apply conditional formatting to Average Cap Rate.

---

# Page 3 — Property Type Analysis

### Visual 1

Clustered column chart:

- Axis: Property Type
- Values: Median Sale Price

### Visual 2

Clustered column chart:

- Axis: Property Type
- Values: Average Cap Rate

### Visual 3

Box plot if using a custom visual:

- Category: Property Type
- Values: Cap Rate

### Visual 4

Scatter:

- X: Sale Price
- Y: Monthly Rent
- Legend: Property Type

### Business question

Which property types provide the strongest income economics relative to acquisition price?

---

# Page 4 — Market Drilldown

Use drill-through by Neighborhood.

### KPI cards

- Transactions
- Median Sale Price
- Average DOM
- Average Cap Rate
- Average Rent

### Charts

1. Monthly median sale price
2. Monthly transaction volume
3. Sale-to-list percentage
4. Price per square foot
5. Cap rate distribution
6. Mortgage-rate trend

### Drill-through behavior

Right-click a neighborhood on the Opportunity page → Drill through → Neighborhood Detail.

---

# Recommended dashboard design

Keep the report clean and professional.

Use:

- White/light neutral background
- One accent color
- Dark gray text
- Minimal borders
- Consistent number formatting
- $K / $M abbreviations for financial metrics
- Percentages to one decimal place
- Cap rates to one decimal place

Avoid:

- Pie charts with many categories
- 3D charts
- Excessive colors
- Decorative graphics
- More than 6–7 major visuals per page

---

# Data model

Use a simple star schema:

Date Dimension
      |
      | 1-to-many
      v
Real Estate Fact

Relationship:

Date[Date]
→ powerbi_real_estate_fact[close_date]

Mark `powerbi_date_dimension` as the Date Table in Power BI.

Sort:

Date[Month] by Date[Month Number]

---

# Recommended slicer interactions

Market → filters all visuals.

Neighborhood → filters all visuals.

Property Type → filters all visuals.

Year → filters all visuals.

Condition → filters property performance visuals.

---

# Interview talking points

If asked why you built this dashboard:

> "I wanted to move beyond descriptive charts and create a decision-support dashboard. The dashboard allows a user to compare markets, neighborhoods and property types while looking at both market performance and investment economics."

If asked about cap rate:

> "I calculated estimated NOI after vacancy, property taxes, insurance, maintenance and management costs, then divided NOI by acquisition price. I excluded financing costs so cap rate could be used to compare the underlying property economics."

If asked about limitations:

> "The data is synthetic, so the dashboard demonstrates analytical methodology rather than predicting actual market returns. In a production environment I would replace the synthetic transaction data with MLS or brokerage data and validate the rent, expense and financing assumptions."

