---
name: reference_order_status
description: Order status values and which count toward revenue.
triggers: [order status, cancelled orders, revenue filter, shipped]
---
# Order statuses
`pending` -> `paid` -> `shipped`; `cancelled` can happen from pending or paid.
Revenue counts `paid` and `shipped` only.
