# database/

Data layer for Sanaa.co: schema, migrations, seeds, and model conventions.

## Role

- Define tables and relationships for all business domains
- Version schema changes via migrations
- Provide demo / reference seeds
- Enforce shared conventions (soft delete, naming, money precision)

The `api/` is the only runtime consumer of this layer; `web/` and `admin/` never access it directly.

## Layout

```text
database/
├── schema.sql      # Full MySQL schema (UUID + soft delete, English)
├── migrations/     # Versioned changes (upcoming)
├── seeds/          # Demo / initial data (upcoming)
└── README.md
```

### Load the schema

```bash
mysql -u root -p < database/schema.sql
```

Creates / reloads the `sanaa` database (utf8mb4) and all tables.  
**MySQL 8.0.13+** required (`DEFAULT (UUID())`, functional unique indexes).

The script is **idempotent**: it drops existing tables first, then recreates them.

All table and column names are in **English**.

## Global conventions

| Rule | Detail |
|------|--------|
| Primary key | `id CHAR(36)` UUID, default `UUID()` |
| Soft delete | `deleted_at` on mutable business tables |
| Soft-delete uniqueness | Functional unique indexes so deleted rows free email/slug/code |
| Money | `DECIMAL(14,2)` |
| Quantities | `DECIMAL(14,3)` or `DECIMAL(14,4)` (BOM) |
| Timezone | Session `time_zone = '+00:00'` (store UTC) |
| Audit / histories | Append-only (`audit_logs`, `*_status_histories`) — no `deleted_at` |
| Integrity | Explicit FKs + `CHECK` constraints where useful |

Typical reads filter with `WHERE deleted_at IS NULL`.

---

## Tables by domain

### Security & Audit

`users`, `audit_logs`, `addresses`

### Sales & Catalog

`categories`, `subcategories`, `products`, `product_variants`, `product_media`, `customer_reviews`, `carts`, `cart_items`, `orders`, `order_items`, `order_status_histories`, `payments`, `shipments`

### Dynamic attributes

`product_attributes`, `attribute_values`

### Pricing & Promotions

`price_lists`, `promotion_rules`, `promotion_rule_targets`, `promotion_redemptions`

### CRM & Quotes

`customer_segments`, `customer_segment_members`, `quotes`, `quote_items`, `customer_interactions`

### Customization

`customer_measurements`, `pattern_models`, `customization_requests`, `embroidery_files`

### Materials & Suppliers

`suppliers`, `raw_materials`, `bills_of_materials`, `supplier_orders`, `supplier_order_items`, `supplier_receipts`, `supplier_receipt_items`

### Logistics & Stock

`warehouses`, `material_stock`, `finished_goods_stock`, `inventory_counts`, `inventory_count_items`, `stock_reservations`, `stock_transfers`

### Production & Workshop (MES)

`employees`, `workstations`, `production_steps`, `production_plans`, `work_orders`, `work_order_status_histories`, `production_tracking`, `workstation_assignments`, `operation_times`, `quality_checks`, `production_reworks`

### Finance & Accounting

`customer_invoices`, `customer_invoice_items`, `supplier_invoices`, `expenses`

### After-sales

`return_requests`

---

## What this schema improves vs. the first draft

| Improvement | Why |
|-------------|-----|
| `cart_items` | Carts are usable (lines were missing) |
| `addresses` | Reusable shipping/billing + order snapshots |
| `product_media` | Images / videos for catalog |
| `finished_goods_stock` | Variant qty **per warehouse** (not a single column on variant) |
| `material_stock.reserved_qty` | Distinguish on-hand vs reserved |
| `supplier_receipt_items` | Receipts have line-level quantities |
| `customer_segment_members` | Explicit segment membership |
| `promotion_redemptions` | Coupon / promo usage tracking |
| `customer_invoice_items` | Invoice line detail |
| `order_status_histories` / `work_order_status_histories` | Traceability of status changes |
| Functional unique indexes | Soft-deleted email/slug/code can be reused |
| `CHECK` constraints | Quantities / amounts / ratings guarded in DB |
| Idempotent `DROP` | Safe re-import of `schema.sql` |
| UTC session timezone | Consistent timestamps |

---

## Cross-domain links (examples)

```text
carts ─► cart_items ─► products / product_variants
                │
                ▼
orders ─► order_items ─► payments, shipments, order_status_histories
    │
    ├──► customization_requests ─► measurements, embroidery_files
    └──► work_orders ─► tracking / quality / reworks
              │
              └──► bills_of_materials ─► raw_materials / material_stock

quotes ──► (conversion) ──► orders
supplier_orders ──► receipts (+ items) ──► material_stock
warehouses ──► finished_goods_stock (variants)
```

## Next steps

1. Add seeds (demo warehouse, roles, sample catalog)
2. Introduce a migration tool if the schema evolves often
3. Optional: password-reset tokens / refresh sessions tables when auth is implemented
