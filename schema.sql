CREATE DATABASE IF NOT EXISTS courier_project;
USE courier_project;

CREATE TABLE zones (
    zone_id INT PRIMARY KEY,
    zone_name VARCHAR(50),
    city VARCHAR(100),
    avg_traffic_level VARCHAR(20)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_type VARCHAR(20),
    city VARCHAR(100),
    pincode VARCHAR(20)
);

CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100),
    zone_id INT,
    join_date DATE,
    is_active BOOLEAN,
    FOREIGN KEY (zone_id) REFERENCES zones(zone_id)
);

CREATE TABLE failure_reasons (
    failure_reason_id INT PRIMARY KEY,
    reason_desc VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    agent_id INT,
    zone_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    delivery_attempts INT,
    delivery_status VARCHAR(20),
    failure_reason_id INT,
    return_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (zone_id) REFERENCES zones(zone_id),
    FOREIGN KEY (failure_reason_id) REFERENCES failure_reasons(failure_reason_id)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    return_reason VARCHAR(100),
    return_cost DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);