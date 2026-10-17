
# Cart Abandonment Analysis

An e-commerce analytics portfolio project using **MySQL** and **Power BI** to analyze customer sessions, cart activity, purchase conversion, product behaviour, traffic sources, and revenue trends.

## 1. Project Overview

E-commerce businesses need to understand how visitors interact with products, add items to carts, and complete purchases. This project analyzes recorded e-commerce events and transactions to identify behavioural patterns, evaluate conversion performance, and explore revenue trends.

The project uses SQL for data analysis and Power BI for interactive reporting.

### Objectives

- Analyze customer browsing and cart activity.
- Measure purchase conversion and recorded cart abandonment.
- Compare performance across traffic sources and devices.
- Investigate product and category-level activity.
- Analyze customer purchasing behaviour.
- Track revenue trends and compare business performance over time.
- Present findings through an interactive Power BI dashboard.

## 2. Tools and Technologies

| Tool | Purpose |
|---|---|
| MySQL Workbench | Database management, data exploration, and SQL analysis |
| Microsoft Power BI | Data modelling, DAX calculations, and interactive reporting |
| Microsoft Excel | Data-quality documentation, issue tracking, and metric definitions |
| CSV | Data storage and transfer |

## 3. Dataset and Data Model

The project uses the Retail Rocket e-commerce dataset, prepared into six related tables.

| Table | Description |
|---|---|
| `visitors` | Visitor identifiers and visitor attributes |
| `sessions` | Session dates, device types, traffic sources, and session status |
| `events` | Recorded views, add-to-cart actions, removals, and transaction events |
| `cart_items` | Products recorded in cart activity |
| `products` | Product catalogue, categories, brands, costs, and prices |
| `transactions` | Transaction identifiers, dates, and order values |

**Total records across the six prepared tables:** 29,125.

The tables are related through visitor, session, and product identifiers where appropriate. The data model supports analysis across customer sessions, events, products, and transactions.

## 4. SQL Analysis

Ten business questions were investigated using MySQL.

1. Identify products with the highest recorded cart activity and value.
2. Find traffic sources with purchase conversion above a defined threshold.
3. Identify categories with the highest average order value.
4. Compare average revenue per visitor across countries.
5. Find products with cart activity but no recorded purchase activity.
6. Compare monthly revenue with the previous month using `LAG()`.
7. Rank traffic sources by revenue using `DENSE_RANK()`.
8. Analyze recorded abandoned cart sessions by device type.
9. Identify visitors spending more than the average visitor spending.
10. Identify products priced above their category average using window functions.

### SQL Skills Demonstrated

- `SELECT`, `WHERE`, `GROUP BY`, and `HAVING`
- Aggregate functions and conditional logic
- Relational joins
- Subqueries and Common Table Expressions (CTEs)
- Date-based analysis
- Window functions, including `LAG()` and `DENSE_RANK()`
- Data-quality investigation and result interpretation

The finalized SQL solutions are stored in the `03_SQL` folder.

## 5. Power BI Dashboard

The interactive report contains five pages.

### Page 1 — Executive Overview

Provides a high-level summary of revenue, transactions, average order value, sessions, purchase conversion, and recorded cart abandonment.

Includes revenue trends, traffic-source comparisons, device distribution, and session status.

### Page 2 — Cart & Conversion

Explores cart sessions, purchase sessions, recorded abandoned cart sessions, conversion rates, and differences across devices and traffic sources.

### Page 3 — Product Analysis

Examines the product catalogue, product prices and costs, cart activity by brand, category-level comparisons, and catalogue-based profit margin metrics.

### Page 4 — Customer & Traffic

Analyzes visitors, sessions per visitor, purchasing visitors, visitor purchase rate, traffic-source performance, and device patterns.

### Page 5 — Revenue & Trends

Explores total revenue, transaction volume, average and highest order values, revenue per purchasing visitor, and monthly revenue trends.

The report includes DAX measures, interactive slicers, visual comparisons, and page navigation.

## 6. Key Findings

The following results were obtained and reconciled against SQL calculations during report development.

| Metric | Result |
|---|---:|
| Total recorded revenue | $18,346,886.52 |
| Total transactions | 830 |
| Average order value | $22,104.68 |
| Highest order value | $44,980.90 |
| Total recorded sessions | 3,500 |
| Sessions with recorded add-to-cart activity | 2,501 |
| Purchase conversion rate | 23.71% |
| Recorded cart abandonment rate | 82.21% |
| Visitors with recorded sessions | 1,536 |
| Visitors with recorded transactions | 669 |
| Products in the catalogue | 180 |

### Interpretation

- Recorded purchase sessions account for approximately 23.71% of all recorded sessions.
- The recorded cart abandonment rate is 82.21% under the project's event-based definition.
- Customer and traffic-source metrics help compare recorded purchasing behaviour across different segments.
- Monthly revenue analysis supports trend analysis and period-over-period comparisons.

These figures describe the prepared dataset and should not be interpreted as verified performance figures for a real business.

## 7. Data Quality and Analytical Limitations

### Recorded Cart Abandonment

A session is classified as having recorded cart abandonment when it contains an add-to-cart event but no recorded transaction event.

This is an event-based proxy, not definitive proof that a customer abandoned a purchase. Incomplete event tracking may affect the result.

### Transactions Without Recorded Add-to-Cart Events

Some transaction events have no recorded add-to-cart event. This may indicate incomplete tracking or an alternate purchase journey. These records should not automatically be treated as invalid data.

### Visitor Counts

The dataset contains 1,800 visitor identifiers in the `visitors` table, 1,536 distinct visitors with recorded sessions, and 669 distinct visitors with recorded transactions.

These counts measure different populations and are not interchangeable.

### Product-Level Revenue

The `transactions` table does not contain a product identifier, and the current model has no reliable transaction-to-product bridge. Consequently, cart activity is not treated as realized product revenue.

### Product Profit Margin

Product price, cost, and margin metrics describe the product catalogue. They do not represent realized profit margins calculated from transaction line items.

### Currency Assumption

The source dataset does not specify a currency. USD ($) is used as an illustrative reporting assumption. Monetary values are not verified real-world financial amounts.

## 8. Project Documentation

The `02_Documentation` folder contains the project documentation workbook, including:

- Project overview
- Business questions
- Data inventory
- Data-quality documentation
- Issue log
- Metric definitions

These materials document the project scope, analytical definitions, and known limitations.

## 9. Project Structure

```text
Cart_Abandonment_Analysis/
│
├── 01_Data/
│   ├── cleaned/
│   │    ├── cart_items_clean.csv
│   │    ├── events_clean.csv
│   │    ├── products_clean.csv
│   │    ├── sessions_clean.csv
│   │    ├── transactions_clean.csv
│   │    └── visitors_clean.csv
│   └── raw/
│       ├── cart_items.csv
│       ├── data_dictionary.csv
│       ├── events.csv
│       ├── products.csv
│       ├── sessions.csv
│       ├── transactions.csv
│       └── visitors.csv
│
├── 02_Documentation/
│   └── Project_Documentation.xlsx
│
├── 03_SQL/
│   └── cart_abandonment_analysis.sql
│
├── 04_Reports/
│   └── cart_abandonment_analysis.pbix
│
└── README.md
```

*Adjust the folder names above if your actual project directory uses different names.*

## 10. Skills Demonstrated

This project demonstrates practical skills in:

- Relational database analysis
- SQL joins, aggregations, CTEs, and window functions
- Data-quality assessment and issue documentation
- Business metric definition and calculation
- Power BI data modelling and DAX
- Interactive dashboard development
- KPI reconciliation between SQL and Power BI
- Analytical reasoning and communication of limitations

---

*Created as a Data Analyst portfolio project to demonstrate SQL, data modelling, business analysis, and Power BI reporting skills.*
