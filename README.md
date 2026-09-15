# Target E-Commerce Data Analysis

## 📊 Project Overview

This project analyzes Brazilian e-commerce order data using **SQL in Google BigQuery** to understand customer behavior, sales trends, geographical performance, freight costs, delivery efficiency, and payment patterns.

The objective is to transform raw e-commerce data into meaningful business insights that can support decisions related to **sales growth, customer targeting, logistics, delivery performance, and payment strategy**.

---

## 🎯 Project Objective

The analysis focuses on answering key business questions such as:

* How has the number of orders changed over time?
* Is there a monthly or seasonal pattern in order volume?
* During which time of the day do customers place most orders?
* Which states and cities contribute the most customers and sales?
* Which cities consistently perform strongly?
* Which states generate the highest sales?
* Which states have the highest and lowest freight costs?
* How long does it take to deliver orders?
* Which states have the fastest and slowest delivery performance?
* Are orders generally delivered before or after the estimated delivery date?
* Which payment methods are most commonly used?
* What is the distribution of orders across payment installments?

---

## 🛠️ Tools & Technologies

* **SQL**
* Google BigQuery
* **GitHub**
* **Data Analysis**
* **Window Functions**
* **CTEs**
* **Aggregate Functions**
* **Date & Time Functions**
* **Joins**

### SQL techniques used

* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `JOIN`
* `LEFT JOIN`
* `COUNT`
* `COUNT DISTINCT`
* `SUM`
* `AVG`
* `ROUND`
* `CASE`
* `COUNTIF`
* `EXTRACT`
* `FORMAT_DATE`
* `DATE_DIFF`
* `LAG`
* `DENSE_RANK`
* Common Table Expressions (`WITH`)

---

## 📁 Dataset

<a href=https://drive.google.com/drive/folders/1TGEc66YKbD443nslRi1bWgVd238gJCnb> Target_Dataset </a>
The project uses the Brazilian e-commerce dataset containing information related to:

* Customers
* Orders
* Order items
* Payments
* Products
* Sellers
* Reviews
* Geographical information

The analysis primarily uses the following tables:

| Table         | Purpose                                          |
| ------------- | ------------------------------------------------ |
| `customers`   | Customer location and customer-level information |
| `orders`      | Order dates, status and delivery information     |
| `order_items` | Product-level order and freight information      |
| `payments`    | Payment methods, values and installments         |

---

# 🔍 Business Questions & Analysis

## 1. Dataset Understanding

The analysis begins by examining the structure of the customer table and identifying the period covered by the order data.

This establishes the scope of the analysis before moving into customer, sales and logistics metrics.

---

## 2. Customer & Geographic Analysis

The project analyzes the geographical distribution of customers across Brazilian cities and states.

Key metrics include:

* Number of unique cities
* Number of unique states
* Total customers
* Active customers
* State-wise customer distribution
* City-wise customer distribution

This helps identify the geographical concentration of the customer base.

---

## 3. Order Growth Analysis

Year-wise order volumes are analyzed to identify the overall growth trend.

The analysis indicates **strong growth in order volume during 2017**, while the available 2018 data shows continued order activity.

Because the dataset does not contain a complete 2018 calendar year, comparisons between 2017 and 2018 should be made using equivalent periods rather than comparing full-year totals.

---

## 4. Monthly Seasonality

Monthly order volumes are analyzed across years to identify recurring seasonal patterns.

The analysis shows that order activity varies across months, with particularly strong growth during 2017.

A month-by-month comparison between 2017 and 2018 provides a better understanding of whether demand patterns are seasonal or part of the overall growth trend.

### Business implication

The company can use monthly order patterns to:

* Plan inventory
* Prepare logistics capacity
* Schedule marketing campaigns
* Anticipate high-demand periods
* Allocate operational resources

---

## 5. Customer Order Timing

Orders are grouped into four time periods:

| Period    | Time        |
| --------- | ----------- |
| Dawn      | 00:00–06:59 |
| Morning   | 07:00–12:59 |
| Afternoon | 13:00–18:59 |
| Night     | 19:00–23:59 |

The analysis indicates that **Afternoon is the strongest order-placement period**, while Dawn represents the lowest order activity.

### Business implication

Marketing campaigns, promotional notifications and customer engagement activities could be strategically timed around periods with higher ordering activity.

---

## 6. Geographic Sales & Customer Concentration

The analysis examines order volume at both state and city level.

A ranking approach is used to identify cities that repeatedly achieve strong monthly order performance rather than simply identifying the highest-selling city in a single month.

This provides a more reliable view of consistently high-performing markets.

---

## 7. Sales & Payment Value Analysis

Payment values are analyzed to understand the monetary contribution of different states.

The analysis includes:

* Total sales/payment value
* Average order value
* State-wise sales contribution
* January–August year-over-year growth

### Key observation

**São Paulo (SP)** is the strongest contributor in terms of total sales/payment value in the analysis.

This is consistent with the high concentration of customers and economic activity in the state.

---

## 8. Freight Analysis

Freight costs are analyzed at state level using:

* Total freight value
* Average freight per order
* Highest average freight states
* Lowest average freight states

The analysis shows that **SP contributes the highest total freight value**, while certain states have significantly higher average freight per order.

### Business implication

High-freight states should not automatically be treated as candidates for new warehouses.

Instead, the company should evaluate a combination of:

* Order volume
* Sales value
* Average freight
* Delivery time
* Customer density
* Geographic distance
* Expected future demand

States with **high demand + high freight + long delivery times** would be stronger candidates for evaluating regional fulfillment or logistics hubs.

---

## 9. Delivery Performance Analysis

Delivery performance is evaluated using two important metrics.

### Delivery time

Measures the number of days between:

**Order Purchase → Actual Delivery**

### Delivery-date performance

Measures the difference between:

**Estimated Delivery Date → Actual Delivery Date**

This helps identify states with:

* Longer delivery times
* Shorter delivery times
* Orders delivered earlier than estimated
* Potential logistics bottlenecks

### Business implication

States with consistently longer delivery times can be investigated further for:

* Logistics bottlenecks
* Carrier performance
* Geographic challenges
* Distribution-center placement
* Shipping route optimization

---

## 10. Payment Analysis

The project analyzes:

* Payment types
* Monthly payment-type usage
* Payment installments
* Percentage contribution of each payment method

The analysis shows that **single-installment payments are the dominant payment pattern** in the dataset.

### Business implication

Understanding payment preferences can help the company:

* Optimize checkout options
* Design installment-based promotions
* Improve customer conversion
* Understand purchasing behavior

---

# 📌 Key Insights

Based on the SQL analysis, the major findings are:

### 📈 Sales & Orders

* Order volume experienced strong growth during **2017**.
* The available 2018 data continues to show substantial order activity.
* Year-over-year comparisons should account for the fact that the 2018 dataset is a partial year.

### 📅 Seasonality

* Monthly order volumes fluctuate throughout the year.
* Comparing the same months across years provides a better measure of seasonal behavior.
* The business appears to maintain demand across multiple months rather than depending entirely on a single season.

### 👥 Customers

* Customers are distributed across a large number of Brazilian cities and states.
* **São Paulo (SP)** has the strongest customer and sales presence in the analysis.
* Customer concentration provides opportunities for targeted regional marketing and logistics planning.

### 🛒 Order Timing

* **Afternoon** has the highest order activity among the four defined time periods.
* **Dawn** has the lowest order activity.

### 💰 Sales

* **SP contributes the highest total sales/payment value** among the states.
* Average order value varies significantly between states.

### 🚚 Freight

* **SP contributes the highest total freight value**, largely reflecting its high order volume.
* Some states have substantially higher average freight per order.
* High freight alone is insufficient to justify opening a warehouse; demand and delivery performance should also be considered.

### 📦 Delivery

* Delivery time varies across states.
* Comparing actual delivery dates against estimated dates helps identify regions with stronger or weaker delivery performance.
* States with longer delivery times can be investigated for logistics optimization.

### 💳 Payments

* Single-installment payments represent the dominant installment pattern.
* Payment-method analysis can help the business understand customer preferences and optimize its checkout strategy.

---

# 💡 Business Recommendations

## 1. Focus on high-demand markets

Since São Paulo and other major markets contribute significantly to customer and sales volume, the company should consider:

* Regional marketing campaigns
* Customer retention programs
* Localized promotions
* Inventory prioritization

---

## 2. Investigate high-freight regions

Rather than opening warehouses solely based on freight cost, identify regions where **high freight costs coincide with significant order volume and long delivery times**.

These regions can then be evaluated for:

* Regional fulfillment centers
* Local logistics partnerships
* Alternative carriers
* Inventory positioning

---

## 3. Optimize marketing around customer activity

Since afternoon represents the strongest order-placement period, promotional campaigns and customer notifications can be tested during high-activity periods.

A/B testing can be used to determine whether timing improves conversion.

---

## 4. Improve delivery performance

States with higher average delivery times should be investigated for operational bottlenecks.

Possible areas of investigation include:

* Carrier performance
* Shipping routes
* Warehouse distance
* Order processing time
* Regional demand patterns

---

## 5. Use seasonal demand for inventory planning

Monthly order trends can help the business anticipate periods of increased demand.

Inventory and logistics capacity should be aligned with historical demand patterns to reduce:

* Stockouts
* Excess inventory
* Delivery delays

---

## 6. Optimize payment strategy

Since single-installment payments are dominant, the company can analyze whether installment options influence:

* Average order value
* Customer conversion
* Product category preference
* Repeat purchases

This could help determine whether installment-based promotions can increase revenue.

---

# 📊 Potential Dashboard Ideas

The SQL analysis can be further converted into a **Power BI or Tableau dashboard** containing:

### Executive Overview

* Total Orders
* Total Sales
* Average Order Value
* Total Freight
* Average Delivery Time

### Sales Analysis

* Yearly order trend
* Monthly order trend
* State-wise sales
* Top cities

### Customer Analysis

* Customers by state
* Customers by city
* Active vs total customers

### Logistics Analysis

* Average freight by state
* Average delivery time by state
* Estimated vs actual delivery
* Top/bottom performing states

### Payment Analysis

* Payment method distribution
* Monthly payment trends
* Installment distribution

---

# 📂 Project Structure

```text
Target_Ecommerce_Analysis/
│
├── Target_Ecommerce_Analysis.sql
│
├── README.md
│
└── images/
    ├── yearly_order_trend.png
    ├── monthly_sales_trend.png
    ├── state_sales.png
    ├── state_sales_yearwise.png
    ├── freight_analysis.png
    └── delivery_analysis.png
```

---

# 🚀 Skills Demonstrated

This project demonstrates practical experience in:

* SQL data analysis
* Data exploration
* Business problem solving
* Data aggregation
* CTEs
* Window functions
* Date/time analysis
* Customer segmentation
* Geographic analysis
* Sales analysis
* Freight analysis
* Delivery performance analysis
* Payment analysis
* Business insight generation
* Data-driven recommendations


👤 Author
Raja Kula Thilak
Aspiring Data Analyst | Python | SQL | Excel | Tableau | Data Analytics
