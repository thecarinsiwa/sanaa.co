# database/

Data layer for Sanaa.co: schema, migrations, seeds, and model conventions.

## Role

- Define tables and relationships for all business domains
- Version schema changes via migrations
- Provide demo / reference seeds
- Enforce shared conventions (soft delete, naming)

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

Creates the `sanaa` database (utf8mb4) and all tables. **MySQL 8.0.13+** required (`DEFAULT (UUID())`).

All table and column names are in **English**.

## Global conventions

| Rule | Detail |
|------|--------|
| Primary key | `id CHAR(36)` UUID, default `UUID()` |
| Soft delete | `deleted_at` on all main tables |
| Naming | `snake_case`, plural table names (English) |
| Integrity | Explicit foreign keys between related domains |
| Audit | Sensitive actions logged in `audit_logs` (via API) |

Typical reads filter with `WHERE deleted_at IS NULL`.

---

## Tables by domain

### Sales & Catalog

`products`, `product_variants`, `categories`, `subcategories`, `customer_reviews`, `carts`, `orders`, `order_items`, `payments`, `shipments`

### Production & Workshop (MES)

`work_orders`, `production_steps`, `production_tracking`, `employees`, `workstations`, `production_plans`, `workstation_assignments`, `operation_times`, `quality_checks`, `production_reworks`

### Materials & Suppliers

`raw_materials`, `material_stock`, `suppliers`, `supplier_orders`, `supplier_order_items`, `bills_of_materials`, `supplier_receipts`

### Customization & Made-to-measure

`customer_measurements`, `pattern_models`, `customization_requests`, `embroidery_files`

### Logistics & Stock

`warehouses`, `inventory_counts`, `inventory_count_items`, `stock_reservations`, `stock_transfers`

### Pricing & Promotions

`promotion_rules`, `promotion_rule_targets`, `price_lists`

### CRM & Quotes

`quotes`, `quote_items`, `customer_interactions`, `customer_segments`

### Finance & Accounting

`customer_invoices`, `supplier_invoices`, `expenses`

### Dynamic attributes

`product_attributes`, `attribute_values`

### Security & Audit

`users`, `audit_logs`

### After-sales (returns)

`return_requests`

---

## Cross-domain links (examples)

```text
orders ────────► order_items ──► products / product_variants
    │
    ├──► payments, shipments
    ├──► customization_requests ──► customer_measurements, embroidery_files
    └──► work_orders ──► steps / tracking / quality
              │
              └──► bills_of_materials ──► raw_materials / material_stock

quotes ──► (conversion) ──► orders
supplier_orders ──► supplier_receipts ──► material_stock
```

## Next steps

1. Validate / adjust columns against business needs
2. Introduce a migration tool on top of `schema.sql`
3. Add demo seeds
