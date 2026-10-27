---
name: lesson_stock_is_not_available
description: books.stock includes units reserved by pending orders; do not report it as sellable.
triggers: [low stock, available units, inventory report, sellable]
---
# Stock is not availability
A low-stock report built on `books.stock` alone over-reports availability, because pending
orders reserve units without decrementing it. Subtract pending quantities first.
