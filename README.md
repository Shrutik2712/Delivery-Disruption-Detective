# Delivery-Disruption-Detective

# Using SQL to Reduce Revenue Loss from Failed Courier Deliveries 🚚📉

This SQL project analyzes courier delivery data to uncover patterns behind failed deliveries and their financial impact. It was built using MySQL and contains over 10,000 records of synthetic courier operations.

## 🔍 Objective

To identify zones, agents, and customer types contributing to failed deliveries — and calculate the total revenue loss due to those failures and returns.

## 🗃️ Dataset Summary

The dataset was generated using Python and includes:

| Table              | Description                                      |
|-------------------|--------------------------------------------------|
| `zones`           | Zone-level delivery area and traffic data        |
| `customers`       | Customer details with type and location          |
| `agents`          | Delivery agent details                           |
| `failure_reasons` | Possible failure causes                          |
| `orders`          | 10,000 courier order records                     |
| `returns`         | Returned orders with cost impact                 |

## 🛠️ Tools Used
- MySQL (Data Storage + Querying)
- Python (Synthetic Data Generator)

## 📊 Key Questions Answered

- What is the total revenue lost due to failed deliveries?
- Which zones are most responsible for failed or returned orders?
- What are the top failure reasons?
- Which delivery agents have high failure rates?
- How much cost is incurred due to returned orders?
  

