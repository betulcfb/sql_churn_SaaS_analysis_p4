# Customer Churn Analysis SQL Project

## Project Overview

**Project Title:** Customer Churn Analysis  
**Database:** Subscription system data

This project demonstrates how to identify and classify different types of customer churn in a subscription-based system using SQL. It simulates a real-world data analyst scenario where understanding user behavior is crucial to improving retention.

## Objectives

- **Identify Financial Churn:** Customers who have not made payments in the last 90 days.  
- **Identify Engagement Churn:** Customers who have not logged in during the last 90 days.  
- **Identify Silent Churn:** Customers who are still paying but have stopped logging in.  
- **Classify Customers:** Assign each customer a churn type or label them as Active.

## Database Schema

- `customers`: Customer details (ID, name, email, signup date, country).  
- `subscriptions`: Subscription plan details (plan type, start/end date, status).  
- `transactions`: Payment records with transaction dates.  
- `user_activity`: User events including login activities.

## SQL Code and Explanation

### 1. Identify Financial Churn  
Customers who have not made a payment in the last 90 days:
```sql
WITH financial_churn AS (
    SELECT customer_id
    FROM transactions
    GROUP BY customer_id
    HAVING MAX(transaction_date) < CURRENT_DATE - INTERVAL '90 days'
)
```

### 2. Identify Engagement Churn  
Customers who have not logged in during the last 90 days:
```sql
, engagement_churn AS (
    SELECT customer_id
    FROM user_activity
    WHERE event_type = 'Login'
    GROUP BY customer_id
    HAVING MAX(event_date) < CURRENT_DATE - INTERVAL '90 days'
)
```

### 3. Identify Silent Churn  
Customers who still make payments but have not logged in during the last 90 days:
```sql
, silent_churn AS (
    SELECT t.customer_id
    FROM transactions t
    LEFT JOIN user_activity ua ON t.customer_id = ua.customer_id
    GROUP BY t.customer_id
    HAVING MAX(t.transaction_date) >= CURRENT_DATE - INTERVAL '90 days'
       AND MAX(ua.event_date) < CURRENT_DATE - INTERVAL '90 days'
)
```

### 4. Combine and Assign Churn Type  
```sql
SELECT
    c.customer_id,
    c.name,
    c.email,

    CASE
        WHEN sc.customer_id IS NOT NULL THEN 'silent_churn'        -- Priority 1: Paying but not logging in
        WHEN fc.customer_id IS NOT NULL THEN 'financial_churn'     -- Priority 2: Not paid in last 90 days
        WHEN ec.customer_id IS NOT NULL THEN 'engagement_churn'    -- Priority 3: Not logged in last 90 days
        ELSE 'Active'                                              -- Otherwise active customer
    END AS churn_type,

    -- Boolean flags to indicate multi-churn membership if applicable
    fc.customer_id IS NOT NULL AS is_financial_churn,
    ec.customer_id IS NOT NULL AS is_engagement_churn,
    sc.customer_id IS NOT NULL AS is_silent_churn

FROM customers c
LEFT JOIN financial_churn fc ON c.customer_id = fc.customer_id
LEFT JOIN engagement_churn ec ON c.customer_id = ec.customer_id
LEFT JOIN silent_churn sc ON c.customer_id = sc.customer_id;
```

## Output

The output table provides customer details along with their churn classification and boolean indicators for each churn category. This facilitates deeper analysis and targeted retention strategies.

## Use Cases

- Customer retention analysis for SaaS and subscription-based services.  
- Creating churn metrics for business intelligence and reporting dashboards.  
- Showcasing SQL skills and data analysis expertise for portfolios or interviews.  
- Foundation for churn prediction models or interactive BI reports.

## How to Use

1. Load your data into the `customers`, `transactions`, and `user_activity` tables.  
2. Run the SQL queries step-by-step or as a whole to classify customer churn.  
3. Analyze results or export for further BI or data science projects.
