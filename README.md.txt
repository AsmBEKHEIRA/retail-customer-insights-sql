# Retail Customer Insights SQL Analysis

## Project Overview

This project focuses on analyzing retail customer behavior using Python, PostgreSQL, pgAdmin 4 and SQL.

The dataset was first cleaned and prepared in Python, then imported into a PostgreSQL database for deeper business analysis.  
The main goal of this project is to extract actionable insights about customer revenue, purchasing behavior, promotions, subscriptions, age groups and product performance.

## Tools Used

- Python
- Pandas
- PostgreSQL
- pgAdmin 4
- SQL
- Jupyter Notebook

## Dataset Description

The dataset contains customer shopping behavior information, including:

- Customer ID
- Age
- Gender
- Item Purchased
- Category
- Purchase Amount (USD)
- Location
- Size
- Color
- Season
- Review Rating
- Subscription Status
- Shipping Type
- Discount Applied
- Promo Code Used
- Previous Purchases
- Payment Method
- Frequency of Purchases
- Age Group
- Frequency Days

## Data Preparation

Before running the SQL analysis, the data was cleaned and transformed in Python.

Main preparation steps included:

- Cleaning column names
- Handling missing values
- Creating an age group column
- Mapping purchase frequency into number of days
- Importing the cleaned DataFrame into PostgreSQL

The final table used for analysis is:

```sql
public.customers