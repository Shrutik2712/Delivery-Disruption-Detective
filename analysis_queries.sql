USE courier_project;

SELECT * FROM agents;
SELECT * FROM customers;
SELECT * FROM failure_reasons;
SELECT * FROM orders;
SELECT * FROM returns;
SELECT * FROM zones;

-- 1. Total Revenue Lost from Failed Deliveries
SELECT 
	COUNT(*) AS failed_deliveries, 
    SUM(amount) AS revenue_lost
FROM orders
WHERE delivery_status = 'Failed';

-- 2. Revenue Lost by Failure Reason
SELECT 
	COUNT(*) AS failed_deliveries, 
	fr.reason_desc AS failure_reason, 
    SUM(o.amount) AS revenue_lost
FROM failure_reasons fr
JOIN orders o
ON fr.failure_reason_id = o.failure_reason_id
WHERE delivery_status = 'Failed'
GROUP BY failure_reason
ORDER BY revenue_lost DESC;

-- 3. Top 5 Zones with Highest Delivery Failures
SELECT 
	COUNT(*) AS failure_deliveries, z.zone_name, 
	SUM(o.amount) AS revenue_lost
FROM zones z
JOIN orders o
ON z.zone_id = o.zone_id
WHERE delivery_status = 'Failed'
GROUP BY z.zone_name
ORDER BY revenue_lost DESC
LIMIT 5;

-- 4. Agent-wise Failure Rate
SELECT
	a.agent_name,
	COUNT(o.order_id) AS total_deliveries,
    SUM(CASE WHEN o.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_deliveries,
    ROUND(100*SUM(CASE WHEN o.delivery_status = 'Failed' THEN 1 ELSE 0 END)/COUNT(o.order_id),2) AS failure_rate
FROM agents a 
JOIN orders o
ON a.agent_id = o.agent_id
GROUP BY agent_name
ORDER BY failure_rate DESC;

-- 5. Monthly Trends in Revenue Loss
SELECT 
	DATE_FORMAT(order_date, '%Y-%m') AS month, 
	COUNT(*) AS failed_orders, 
    SUM(amount) AS revenue_lost
FROM orders
WHERE delivery_status = 'Failed'
GROUP BY month
ORDER BY month;

-- 6. Return Orders and Total Cost Incurred
SELECT
	COUNT(*) AS returned_orders,
    SUM(return_cost) AS total_return_cost
FROM returns;

-- 7. Which Customer Type Fails More Often
SELECT 
	c.customer_type,
    COUNT(*) AS failed_orders,
    SUM(o.amount) AS revenue_lost
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
WHERE delivery_status = 'Failed'
GROUP BY customer_type
ORDER BY revenue_lost DESC;

-- 8. Zones with High Returns and Revenue Impact
SELECT 
	z.zone_name,
    COUNT(r.return_id) AS returned_orders,
    SUM(r.return_cost) AS revenue_impact
FROM zones z
JOIN orders o
ON o.zone_id = z.zone_id
JOIN returns r
ON o.order_id = r.order_id
GROUP BY zone_name
ORDER BY revenue_impact DESC
LIMIT 5;

-- 9. Most Frequent Failure Reasons Per Zone
SELECT zone_name, failure_reason, failures
FROM (
	SELECT 
		z.zone_name,
		fr.reason_desc AS failure_reason,
		COUNT(*) AS failures,
		ROW_NUMBER() OVER(PARTITION BY z.zone_name ORDER BY COUNT(*) DESC) AS rn
	FROM orders o
	JOIN failure_reasons fr
	ON o.failure_reason_id = fr.failure_reason_id
	JOIN zones z
	ON o.zone_id = z.zone_id
    WHERE delivery_status = 'Failed'
	GROUP BY z.zone_name, fr.reason_desc) sub
WHERE rn=1;

-- 10. Flagging High-Risk Agents (Failure Rate > 30%)
SELECT
	a.agent_name,
	COUNT(o.order_id) AS total_deliveries,
    SUM(CASE WHEN o.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_deliveries,
    ROUND(100*SUM(CASE WHEN o.delivery_status = 'Failed' THEN 1 ELSE 0 END)/COUNT(o.order_id),2) AS failure_rate
FROM agents a 
JOIN orders o
ON a.agent_id = o.agent_id
GROUP BY agent_name
HAVING failure_rate >30
ORDER BY failure_rate DESC;

