CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    signup_date DATE,
    country VARCHAR(100)
);

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    plan_type VARCHAR(20),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

CREATE TABLE user_activity (
    activity_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    event_type VARCHAR(50),
    event_date DATE
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    amount NUMERIC(10,2),
    transaction_date DATE
);


SELECT * FROM user_activity;
SELECT * FROM customers;
SELECT * FROM transactions;
SELECT * FROM subscriptions;

--------------------------------------
--Find Financial Churn (who stopped paying) --LAST payment date for each customer
SELECT customer_id,
MAX(transaction_date) AS last_payment_date
FROM transactions
GROUP BY customer_id;

--Filter out these customers who haven't made a payment in the last 90 days
SELECT customer_id,
MAX(transaction_date) AS last_payment_date
FROM transactions
GROUP BY customer_id
HAVING MAX(transaction_date) < CURRENT_DATE - INTERVAL '90 days';

--Finding engagement Churn (who stopped logging in )
SELECT customer_id,
MAX(event_date) AS last_login_date
FROM user_activity
WHERE event_type='Login'
GROUP BY customer_id;

--filter users who haven't logged in for 90+ days
SELECT customer_id,
MAX(event_date) AS last_login_date
FROM user_activity
WHERE event_type='Login'
GROUP BY customer_id
HAVING MAX(event_date) < CURRENT_DATE - INTERVAL '90 Days';


--silent churn folks(who pays but doesn't log in)
SELECT t.customer_id,
MAX(t.transaction_date) as last_payment_date,
MAX(event_date) AS last_login_date
FROM transactions t
LEFT JOIN user_activity ua ON t.customer_id =  ua.customer_id
GROUP BY t.customer_id;

--filter these by those who still pay but don't log in
SELECT t.customer_id,
MAX(t.transaction_date) as last_payment_date,
MAX(event_date) AS last_login_date
FROM transactions t
LEFT JOIN user_activity ua ON t.customer_id =  ua.customer_id
GROUP BY t.customer_id
HAVING MAX(t.transaction_date)>= CURRENT_DATE - INTERVAL '90 days'
AND MAX(ua.event_date) < CURRENT_DATE - INTERVAL '90 days';


--COMBINE EVERYTHING

	SELECT c.customer_id,
	c.name,
	c.email,
	CASE
		WHEN fc.customer_id IS NOT NULL THEN 'financial_churn'
		WHEN ec.customer_id IS NOT NULL THEN'engagement_churn'
		WHEN sc.customer_id IS NOT NULL THEN 'silent_churn'
		ELSE 'Active'
	END AS churn_type
from customers c
LEFT JOIN (
SELECT customer_id
FROM transactions
GROUP BY customer_id
HAVING MAX(transaction_date) < CURRENT_DATE - INTERVAL '90 days') fc 
ON c.customer_id = fc.customer_id
LEFT JOIN (
	SELECT customer_id
	from  user_activity
	where event_type = 'Login'
	GROUP BY customer_id
	HAVING MAX(event_date) < CURRENT_DATE - INTERVAL '90 days')
	ec ON c.customer_id = ec.customer_id 
LEFT JOIN (
select t.customer_id
from transactions t
left join user_activity ua ON t.customer_id = ua.customer_id
GROUP BY t.customer_id
HAVING MAX(t.transaction_date) >= CURRENT_DATE - INTERVAL '90 days'
AND MAX(ua.event_date) < CURRENT_DATE - INTERVAL '90 days'
) sc ON c.customer_id = sc.customer_id;
