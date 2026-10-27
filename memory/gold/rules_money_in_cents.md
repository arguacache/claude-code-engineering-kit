---
name: rules_money_in_cents
description: All Inkwell money columns are integer cents; divide by 100.0 once, in SQL.
triggers: [revenue, price, total_cents, amount, how much did we sell]
pin: true
---
# Money is stored in cents
`orders.total_cents`, `books.price_cents` and `order_items.unit_price` are integer cents.
Divide once in SQL. Never report a raw column as dollars.
