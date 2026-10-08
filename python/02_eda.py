import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

DATA = Path("real_estate_transactions_raw.csv")
OUT = Path("figures")
OUT.mkdir(exist_ok=True)

df = pd.read_csv(DATA, parse_dates=["close_date"])

# Basic cleaning for EDA
df = df[
    (df["sale_price"] > 0) &
    (df["list_price"] > 0) &
    (df["sqft"] > 0) &
    (df["beds"] > 0) &
    (df["baths"] > 0) &
    (df["mortgage_rate"] > 0)
].copy()

# Impute fields using transparent business rules
df["monthly_rent"] = df["monthly_rent_est"].fillna(df["sale_price"] * 0.0045)
df["property_tax"] = df["annual_property_tax"].fillna(df["sale_price"] * 0.013)
df["insurance"] = df["annual_insurance"].fillna(df["sale_price"] * 0.0045)
df["maintenance"] = df["annual_maintenance"].fillna(df["monthly_rent"] * 12 * 0.09)

df["effective_gross_income"] = (
    df["monthly_rent"] * 12 * (1 - df["vacancy_rate"])
)
df["estimated_noi"] = (
    df["effective_gross_income"]
    - df["property_tax"]
    - df["insurance"]
    - df["maintenance"]
    - df["management_fee_annual"].fillna(df["monthly_rent"] * 12 * 0.06)
)
df["cap_rate"] = df["estimated_noi"] / df["sale_price"] * 100
df["sale_to_list_pct"] = df["sale_price"] / df["list_price"] * 100
df["price_per_sqft"] = df["sale_price"] / df["sqft"]

df["year"] = df["close_date"].dt.year
df["month"] = df["close_date"].dt.month

# 1. Median sale price by year and market
trend = (
    df.groupby(["year", "market"], as_index=False)["sale_price"]
      .median()
)

plt.figure(figsize=(10, 6))
for market, g in trend.groupby("market"):
    plt.plot(g["year"], g["sale_price"], marker="o", label=market)
plt.title("Median Sale Price by Market")
plt.xlabel("Year")
plt.ylabel("Median Sale Price ($)")
plt.legend()
plt.grid(alpha=0.25)
plt.tight_layout()
plt.savefig(OUT / "01_median_sale_price_trend.png", dpi=160)
plt.close()

# 2. Monthly transaction volume / seasonality
monthly = (
    df.assign(month_name=df["close_date"].dt.month)
      .groupby(["year", "month_name"])
      .size()
      .reset_index(name="transactions")
)
seasonality = monthly.groupby("month_name")["transactions"].mean()

plt.figure(figsize=(10, 6))
plt.plot(seasonality.index, seasonality.values, marker="o")
plt.title("Average Monthly Transaction Volume")
plt.xlabel("Month")
plt.ylabel("Average Transactions")
plt.xticks(range(1, 13))
plt.grid(alpha=0.25)
plt.tight_layout()
plt.savefig(OUT / "02_transaction_seasonality.png", dpi=160)
plt.close()

# 3. Price vs. rent relationship
sample = df.sample(min(5000, len(df)), random_state=42)

plt.figure(figsize=(10, 6))
plt.scatter(sample["sale_price"], sample["monthly_rent"], alpha=0.22)
plt.title("Sale Price vs. Estimated Monthly Rent")
plt.xlabel("Sale Price ($)")
plt.ylabel("Monthly Rent ($)")
plt.grid(alpha=0.25)
plt.tight_layout()
plt.savefig(OUT / "03_price_vs_rent.png", dpi=160)
plt.close()

# 4. Cap-rate distribution by property type
types = sorted(df["property_type"].dropna().unique())
groups = [df.loc[df["property_type"] == t, "cap_rate"].dropna() for t in types]

plt.figure(figsize=(11, 6))
plt.boxplot(groups, tick_labels=types, showfliers=False)
plt.title("Estimated Cap Rate by Property Type")
plt.xlabel("Property Type")
plt.ylabel("Cap Rate (%)")
plt.xticks(rotation=25)
plt.grid(axis="y", alpha=0.25)
plt.tight_layout()
plt.savefig(OUT / "04_cap_rate_by_type.png", dpi=160)
plt.close()

# 5. Neighborhood opportunity matrix
opp = (
    df.groupby(["market", "neighborhood"])
      .agg(
          avg_cap_rate=("cap_rate", "mean"),
          avg_dom=("days_on_market", "mean"),
          avg_price=("sale_price", "mean"),
          transactions=("listing_id", "count")
      )
      .reset_index()
)

plt.figure(figsize=(10, 7))
for market, g in opp.groupby("market"):
    plt.scatter(
        g["avg_dom"], g["avg_cap_rate"],
        s=np.sqrt(g["transactions"]) * 18,
        alpha=0.75, label=market
    )
    for _, r in g.iterrows():
        plt.annotate(
            r["neighborhood"],
            (r["avg_dom"], r["avg_cap_rate"]),
            xytext=(5, 5), textcoords="offset points", fontsize=8
        )

plt.title("Investment Opportunity: Cap Rate vs. Days on Market")
plt.xlabel("Average Days on Market")
plt.ylabel("Average Estimated Cap Rate (%)")
plt.legend()
plt.grid(alpha=0.25)
plt.tight_layout()
plt.savefig(OUT / "05_neighborhood_opportunity.png", dpi=160)
plt.close()

# 6. Mortgage-rate environment
rates = df.groupby("year")["mortgage_rate"].mean()

plt.figure(figsize=(9, 5))
plt.plot(rates.index, rates.values, marker="o")
plt.title("Average Mortgage Rate in Transaction Sample")
plt.xlabel("Year")
plt.ylabel("Mortgage Rate (%)")
plt.grid(alpha=0.25)
plt.tight_layout()
plt.savefig(OUT / "06_mortgage_rates.png", dpi=160)
plt.close()

# Key summary table
summary = (
    df.groupby(["year", "market"])
      .agg(
          transactions=("listing_id", "count"),
          median_sale_price=("sale_price", "median"),
          avg_dom=("days_on_market", "mean"),
          avg_cap_rate=("cap_rate", "mean"),
          avg_price_per_sqft=("price_per_sqft", "mean")
      )
      .reset_index()
)
summary.to_csv(OUT / "market_summary.csv", index=False)

print(summary.round(2))
