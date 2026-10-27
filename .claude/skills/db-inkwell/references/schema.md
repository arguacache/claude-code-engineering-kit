# Inkwell Books schema (fictional)

Database `inkwell`, schema `public`. All money is integer cents.

## customers
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| full_name | text | |
| email | text unique | |
| created_at | timestamptz | |

## books
| column | type | notes |
|---|---|---|
| isbn | text PK | 13 digits, no dashes |
| title | text | |
| author | text | |
| price_cents | integer | **cents** |
| stock | integer | units on hand |

## orders
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| customer_id | uuid FK customers.id | |
| status | text | `pending`, `paid`, `shipped`, `cancelled` |
| total_cents | integer | **cents**, equals sum of item lines |
| placed_at | timestamptz | |

## order_items
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| order_id | uuid FK orders.id | |
| isbn | text FK books.isbn | |
| quantity | integer | |
| unit_price | integer | **cents**, price at time of sale (may differ from books.price_cents) |

## Example: revenue by month, in dollars
```sql
SELECT date_trunc('month', placed_at) AS month,
       SUM(total_cents) / 100.0       AS revenue_usd
FROM orders
WHERE status <> 'cancelled'
GROUP BY 1 ORDER BY 1;
```
