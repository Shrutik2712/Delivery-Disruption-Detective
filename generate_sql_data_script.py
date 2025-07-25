#pip install pandas numpy faker

import pandas as pd
import numpy as np
import random
from faker import Faker

fake = Faker()
random.seed(0)
np.random.seed(0)

# Table configurations
NUM_ORDERS = 10000
NUM_CUSTOMERS = 1000
NUM_AGENTS = 150
NUM_ZONES = 20
NUM_FAILURE_REASONS = 6

def format_value(val):
    if pd.isna(val): return "NULL"
    if isinstance(val, str): return "'" + val.replace("'", "''") + "'"
    if isinstance(val, (float, np.float64)): return f"{val:.2f}"
    if isinstance(val, (int, np.int64)): return str(val)
    if isinstance(val, pd.Timestamp): return f"'{val.date()}'"
    if isinstance(val, bool): return '1' if val else '0'
    return f"'{val}'"

def write_insert(table, df, file):
    for _, row in df.iterrows():
        values = ', '.join(format_value(val) for val in row)
        file.write(f"INSERT INTO {table} VALUES ({values});\n")

# Generate Zones
zones = pd.DataFrame({
    "zone_id": range(1, NUM_ZONES + 1),
    "zone_name": [f"Zone-{i}" for i in range(1, NUM_ZONES + 1)],
    "city": [fake.city() for _ in range(NUM_ZONES)],
    "avg_traffic_level": random.choices(["Low", "Medium", "High"], k=NUM_ZONES)
})

# Generate Customers
customers = pd.DataFrame({
    "customer_id": range(1, NUM_CUSTOMERS + 1),
    "customer_name": [fake.name() for _ in range(NUM_CUSTOMERS)],
    "customer_type": random.choices(["Regular", "First-time", "Bulk"], k=NUM_CUSTOMERS),
    "city": [fake.city() for _ in range(NUM_CUSTOMERS)],
    "pincode": [fake.postcode() for _ in range(NUM_CUSTOMERS)]
})

# Generate Agents
agents = pd.DataFrame({
    "agent_id": range(1, NUM_AGENTS + 1),
    "agent_name": [fake.name() for _ in range(NUM_AGENTS)],
    "zone_id": random.choices(range(1, NUM_ZONES + 1), k=NUM_AGENTS),
    "join_date": [fake.date_between(start_date='-3y', end_date='today') for _ in range(NUM_AGENTS)],
    "is_active": random.choices([True, False], weights=[0.8, 0.2], k=NUM_AGENTS)
})

# Failure reasons
failure_reasons = pd.DataFrame({
    "failure_reason_id": range(1, NUM_FAILURE_REASONS + 1),
    "reason_desc": [
        "Address not found", "Refused by customer", "No one at home",
        "Incorrect phone number", "Package damaged", "Weather delay"
    ]
})

# Orders
orders = []
for i in range(1, NUM_ORDERS + 1):
    status = random.choices(["Delivered", "Failed", "Returned"], weights=[0.75, 0.2, 0.05])[0]
    fail_id = random.choice(range(1, NUM_FAILURE_REASONS + 1)) if status != "Delivered" else None
    orders.append({
        "order_id": i,
        "customer_id": random.randint(1, NUM_CUSTOMERS),
        "agent_id": random.randint(1, NUM_AGENTS),
        "zone_id": random.randint(1, NUM_ZONES),
        "order_date": fake.date_between(start_date='-1y', end_date='today'),
        "amount": round(random.uniform(100, 1000), 2),
        "delivery_attempts": random.randint(1, 3) if status != "Delivered" else 1,
        "delivery_status": status,
        "failure_reason_id": fail_id,
        "return_date": fake.date_between(start_date='-1y', end_date='today') if status == "Returned" else None
    })

orders_df = pd.DataFrame(orders)

# Returns
returns_df = orders_df[orders_df["delivery_status"] == "Returned"].copy()
returns_df["return_id"] = range(1, len(returns_df) + 1)
returns_df["return_reason"] = random.choices(
    ["Customer refused", "Wrong item", "Late delivery", "Damaged on arrival"],
    k=len(returns_df)
)
returns_df["return_cost"] = returns_df["amount"] * np.random.uniform(0.05, 0.25, size=len(returns_df))

# Export to SQL file
with open("data.sql", "w") as f:
    write_insert("zones", zones, f)
    write_insert("customers", customers, f)
    write_insert("agents", agents, f)
    write_insert("failure_reasons", failure_reasons, f)
    write_insert("orders", orders_df, f)
    write_insert("returns", returns_df[["return_id", "order_id", "return_reason", "return_cost"]], f)
