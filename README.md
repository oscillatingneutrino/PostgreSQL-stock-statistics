# PostgreSQL-stock-statistics
Advanced PostgreSQL query using CTE's, window functions, and aggregate statistics to analyze stock closing returns.

## Table of Contents
- [Overview](#Overview)
- [Dataset](#Dataset)
- [Features](#Features)
- [Table Schema](#Table-Schema)
- [Usage](usage)
- [Requirements](#Requirements)
- [SQL  Queries](#SQL-Queries)
- [Results](#Results)

## Overview
This project calculates the returns from the closing stock price, and using these values uses aggregate functions and window functions to calculates the mean, trimmed mean, median, Absolute Deviation about the Mean, the Absolute Deviation about the Median, and the Standard Deviation. This project exists as a personal project to further understand statistical analysis.

## Dataset
This project uses data from a csv file containing the following 9 columns. Of the following, only the date, close, and company are used.
- Columns: date, open, high, low, close, volume, dividend, stock splits, and company
- Snippet: 2023-11-29,	190.8999939,	192.0899963,	189.8699951,	189.8849945,	16472085,	0,	0,	AAPL

## Features
-Computes the mean, trimmed mean, median, and stamdard deviation per company
-Computes the mean absolute deviation and the median absolute deviation.

## Table Schema
If you import the sample CSV using COPY stocks_data FROM '.../csv' I recommend using the following table schema. Note that because of PostgreSQL's specificity about case sensitivity with column names (and for the sake of convenience), keep the names of the columns lowercase. This only applies during data import

```sql
CREATE_TABLE stocks_data (
  date date,
  open numeric,
  high numeric,
  low numeric,
  close numeric,
  volume numeric,
  dividend numeric,
  stock splits numeric,
  company text
);
```
## Usage
1. Import your data into PostgreSQL.
2. Run the provided SQL file in psql or pgAdmin
3. Obtain the outputs

## Requirements
This project was created (and thus uses and functions) using standard PostgreSQL with all features available in versions of POSTGRESQL 13 or later. Furhtermore, **psql** or a GUI such as **PGAdmin** is needed to run queries. Finally, a table named `stocks_data` with the provided schema is necessary.

## SQL Queries
5 unique Common Table Expressions (CTEs) were used. Their purposes are as follows:
1. cter
 - This CTE calculates the returns from the closing stock price by obtaining the closing stock price and subtracting it from the closing stock price of the date prior. Note that unless your data provides daily measurements, the calculation will be based on the next available date e.g. days when the stock market is closed (i.e. holidays, etc.) will not be included with simulated or extrapolated data.
 - This CTE is also capable of returning the closing stock price of the date prior to the current one, but this function is not used and thus commented out.
2. menmed
 - THIS CTE calculates the mean using AVG(), the median by calculating the 50th percentile using PERCENTILE_CONT, and the standard deviation using STDDEV_SAMP of each company. These figures are all rounded to 5 places after the decimal. 
3. trimm
 - This CTE uses a subquery and CUME_DIST to trim the top and bottom 1% of the closing stock returns for each company, leaving a range of values from the 1st to the 99th percentile. This figure is rounded to 5 places after the decimal.
4.  mean_madcow
 - This CTE calculates the absolute deviation about the mean by using AVG(), ABS(), the returns, and the mean calculated in menmed. This figure is rounded to 5 places after the decimal.
5. median_madcow
 - This CTE calculates the absolute deviation about the median by using PERCENTILE_CONT(), ABS(), the returns, and the median calculated in menmed. This figure is rounded to 5 places after the decimal.

## Results
![Sample Results](sample_result.png)
