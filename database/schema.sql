-- =============================================================================
-- Sanaa.co — MySQL schema (English)
-- Primary keys : UUID CHAR(36) DEFAULT (UUID())
-- Soft delete  : deleted_at on mutable business tables
-- Requires     : MySQL 8.0.13+ (expression defaults + functional indexes)
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS sanaa
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sanaa;

-- -----------------------------------------------------------------------------
-- Idempotent reload: drop in reverse dependency order
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS return_requests;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS customer_invoice_items;
DROP TABLE IF EXISTS customer_invoices;
DROP TABLE IF EXISTS supplier_invoices;
DROP TABLE IF EXISTS production_reworks;
DROP TABLE IF EXISTS quality_checks;
DROP TABLE IF EXISTS operation_times;
DROP TABLE IF EXISTS workstation_assignments;
DROP TABLE IF EXISTS production_tracking;
DROP TABLE IF EXISTS work_order_status_histories;
DROP TABLE IF EXISTS work_orders;
DROP TABLE IF EXISTS production_plans;
DROP TABLE IF EXISTS production_steps;
DROP TABLE IF EXISTS workstations;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS stock_transfers;
DROP TABLE IF EXISTS stock_reservations;
DROP TABLE IF EXISTS inventory_count_items;
DROP TABLE IF EXISTS inventory_counts;
DROP TABLE IF EXISTS finished_goods_stock;
DROP TABLE IF EXISTS material_stock;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS supplier_receipt_items;
DROP TABLE IF EXISTS supplier_receipts;
DROP TABLE IF EXISTS supplier_order_items;
DROP TABLE IF EXISTS supplier_orders;
DROP TABLE IF EXISTS bills_of_materials;
DROP TABLE IF EXISTS raw_materials;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS embroidery_files;
DROP TABLE IF EXISTS customization_requests;
DROP TABLE IF EXISTS pattern_models;
DROP TABLE IF EXISTS customer_measurements;
DROP TABLE IF EXISTS customer_interactions;
DROP TABLE IF EXISTS quote_items;
DROP TABLE IF EXISTS quotes;
DROP TABLE IF EXISTS customer_segment_members;
DROP TABLE IF EXISTS customer_segments;
DROP TABLE IF EXISTS promotion_redemptions;
DROP TABLE IF EXISTS promotion_rule_targets;
DROP TABLE IF EXISTS promotion_rules;
DROP TABLE IF EXISTS price_lists;
DROP TABLE IF EXISTS attribute_values;
DROP TABLE IF EXISTS product_attributes;
DROP TABLE IF EXISTS order_status_histories;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS customer_reviews;
DROP TABLE IF EXISTS product_media;
DROP TABLE IF EXISTS product_variants;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS subcategories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS users;


-- #############################################################################
-- Security & Audit
-- #############################################################################

CREATE TABLE users (
  id                CHAR(36)     NOT NULL DEFAULT (UUID()),
  email             VARCHAR(255) NOT NULL,
  password_hash     VARCHAR(255) NOT NULL,
  last_name         VARCHAR(120) NULL,
  first_name        VARCHAR(120) NULL,
  phone             VARCHAR(40)  NULL,
  role              ENUM('customer', 'sales', 'workshop', 'purchasing', 'finance', 'admin')
                    NOT NULL DEFAULT 'customer',
  is_active         TINYINT(1)   NOT NULL DEFAULT 1,
  email_verified_at DATETIME(6)  NULL,
  last_login_at     DATETIME(6)  NULL,
  created_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)  NULL,
  PRIMARY KEY (id),
  -- Soft-delete-safe uniqueness: only active rows compete on email
  UNIQUE KEY uq_users_email_active ((CASE WHEN deleted_at IS NULL THEN email ELSE NULL END)),
  KEY idx_users_role (role),
  KEY idx_users_active (is_active, deleted_at),
  KEY idx_users_deleted_at (deleted_at),
  CONSTRAINT chk_users_email_format CHECK (email LIKE '%_@_%.__%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Staff and customer accounts';

CREATE TABLE audit_logs (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NULL,
  action          VARCHAR(100) NOT NULL,
  target_table    VARCHAR(100) NULL,
  record_id       CHAR(36)     NULL,
  details         JSON         NULL,
  ip_address      VARCHAR(45)  NULL,
  user_agent      VARCHAR(500) NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  KEY idx_audit_logs_user (user_id),
  KEY idx_audit_logs_target (target_table, record_id),
  KEY idx_audit_logs_action (action),
  KEY idx_audit_logs_created (created_at),
  CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Append-only audit trail (no soft delete)';

CREATE TABLE addresses (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NOT NULL,
  label           VARCHAR(80)  NULL COMMENT 'home, work, billing…',
  recipient_name  VARCHAR(200) NULL,
  phone           VARCHAR(40)  NULL,
  line1           VARCHAR(255) NOT NULL,
  line2           VARCHAR(255) NULL,
  city            VARCHAR(120) NOT NULL,
  state_province  VARCHAR(120) NULL,
  postal_code     VARCHAR(30)  NULL,
  country_code    CHAR(2)      NOT NULL DEFAULT 'CD',
  is_default_shipping TINYINT(1) NOT NULL DEFAULT 0,
  is_default_billing  TINYINT(1) NOT NULL DEFAULT 0,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_addresses_user (user_id, deleted_at),
  CONSTRAINT fk_addresses_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Reusable customer shipping/billing addresses';


-- #############################################################################
-- Sales & Catalog
-- #############################################################################

CREATE TABLE categories (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  name            VARCHAR(150) NOT NULL,
  slug            VARCHAR(180) NOT NULL,
  description     TEXT         NULL,
  image_url       VARCHAR(500) NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug_active ((CASE WHEN deleted_at IS NULL THEN slug ELSE NULL END)),
  KEY idx_categories_active (is_active, deleted_at, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subcategories (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  category_id     CHAR(36)     NOT NULL,
  name            VARCHAR(150) NOT NULL,
  slug            VARCHAR(180) NOT NULL,
  description     TEXT         NULL,
  image_url       VARCHAR(500) NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_subcategories_slug_active ((CASE WHEN deleted_at IS NULL THEN slug ELSE NULL END)),
  KEY idx_subcategories_category (category_id, deleted_at, sort_order),
  CONSTRAINT fk_subcategories_category
    FOREIGN KEY (category_id) REFERENCES categories (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  category_id       CHAR(36)      NULL,
  subcategory_id    CHAR(36)      NULL,
  sku               VARCHAR(80)   NULL,
  name              VARCHAR(255)  NOT NULL,
  slug              VARCHAR(280)  NOT NULL,
  description       TEXT          NULL,
  short_description VARCHAR(500)  NULL,
  product_type      ENUM('standard', 'custom', 'semi_custom')
                    NOT NULL DEFAULT 'standard',
  base_price        DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  compare_at_price  DECIMAL(14,2) NULL COMMENT 'MSRP / strikethrough price',
  currency          CHAR(3)       NOT NULL DEFAULT 'USD',
  weight_grams      DECIMAL(12,3) NULL,
  is_featured       TINYINT(1)    NOT NULL DEFAULT 0,
  is_active         TINYINT(1)    NOT NULL DEFAULT 1,
  metadata          JSON          NULL,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug_active ((CASE WHEN deleted_at IS NULL THEN slug ELSE NULL END)),
  UNIQUE KEY uq_products_sku_active ((CASE WHEN deleted_at IS NULL THEN sku ELSE NULL END)),
  KEY idx_products_category (category_id),
  KEY idx_products_subcategory (subcategory_id),
  KEY idx_products_type (product_type),
  KEY idx_products_listing (is_active, deleted_at, is_featured),
  KEY idx_products_name (name),
  CONSTRAINT chk_products_base_price CHECK (base_price >= 0),
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_products_subcategory
    FOREIGN KEY (subcategory_id) REFERENCES subcategories (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_variants (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)      NOT NULL,
  sku             VARCHAR(80)   NULL,
  name            VARCHAR(150)  NOT NULL,
  size            VARCHAR(40)   NULL,
  color           VARCHAR(80)   NULL,
  barcode         VARCHAR(64)   NULL,
  price           DECIMAL(14,2) NULL,
  weight_grams    DECIMAL(12,3) NULL,
  is_default      TINYINT(1)    NOT NULL DEFAULT 0,
  is_active       TINYINT(1)    NOT NULL DEFAULT 1,
  metadata        JSON          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_variants_sku_active ((CASE WHEN deleted_at IS NULL THEN sku ELSE NULL END)),
  KEY idx_product_variants_product (product_id, deleted_at),
  KEY idx_product_variants_barcode (barcode),
  CONSTRAINT chk_product_variants_price CHECK (price IS NULL OR price >= 0),
  CONSTRAINT fk_product_variants_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Sellable SKUs; warehouse qty lives in finished_goods_stock';

CREATE TABLE product_media (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)     NOT NULL,
  variant_id      CHAR(36)     NULL,
  media_type      ENUM('image', 'video', 'document') NOT NULL DEFAULT 'image',
  url             VARCHAR(500) NOT NULL,
  alt_text        VARCHAR(255) NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  is_primary      TINYINT(1)   NOT NULL DEFAULT 0,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_product_media_product (product_id, sort_order),
  KEY idx_product_media_variant (variant_id),
  CONSTRAINT fk_product_media_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_media_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customer_reviews (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)     NOT NULL,
  user_id         CHAR(36)     NULL,
  order_id        CHAR(36)     NULL,
  rating          TINYINT      NOT NULL,
  title           VARCHAR(200) NULL,
  comment         TEXT         NULL,
  is_approved     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customer_reviews_product (product_id, is_approved, deleted_at),
  KEY idx_customer_reviews_user (user_id),
  CONSTRAINT chk_customer_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_customer_reviews_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_customer_reviews_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE carts (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NULL,
  session_token   VARCHAR(100) NULL,
  currency        CHAR(3)      NOT NULL DEFAULT 'USD',
  status          ENUM('open', 'converted', 'abandoned') NOT NULL DEFAULT 'open',
  expires_at      DATETIME(6)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_carts_user_status (user_id, status, deleted_at),
  KEY idx_carts_session (session_token),
  KEY idx_carts_expires (expires_at),
  CONSTRAINT fk_carts_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cart_items (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  cart_id         CHAR(36)      NOT NULL,
  product_id      CHAR(36)      NOT NULL,
  variant_id      CHAR(36)      NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 1,
  unit_price      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_items_line_active (
    (CASE WHEN deleted_at IS NULL THEN cart_id ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN product_id ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN COALESCE(variant_id, '') ELSE NULL END)
  ),
  KEY idx_cart_items_cart (cart_id, deleted_at),
  CONSTRAINT chk_cart_items_qty CHECK (quantity > 0),
  CONSTRAINT chk_cart_items_price CHECK (unit_price >= 0),
  CONSTRAINT fk_cart_items_cart
    FOREIGN KEY (cart_id) REFERENCES carts (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_cart_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cart_items_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orders (
  id                   CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_number         VARCHAR(40)   NOT NULL,
  user_id              CHAR(36)      NULL,
  cart_id              CHAR(36)      NULL,
  quote_id             CHAR(36)      NULL,
  shipping_address_id  CHAR(36)      NULL,
  billing_address_id   CHAR(36)      NULL,
  status               ENUM(
                         'draft', 'pending', 'paid', 'in_production',
                         'shipped', 'delivered', 'cancelled', 'refunded'
                       ) NOT NULL DEFAULT 'draft',
  amount_excl_tax      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax_amount           DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  shipping_amount      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  discount_amount      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  currency             CHAR(3)       NOT NULL DEFAULT 'USD',
  shipping_address_snapshot JSON     NULL,
  billing_address_snapshot  JSON     NULL,
  notes                TEXT          NULL,
  placed_at            DATETIME(6)   NULL,
  created_at           DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at           DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at           DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_number (order_number),
  KEY idx_orders_user_status (user_id, status, deleted_at),
  KEY idx_orders_status_placed (status, placed_at),
  KEY idx_orders_created (created_at),
  CONSTRAINT chk_orders_amounts CHECK (
    amount_excl_tax >= 0 AND tax_amount >= 0
    AND shipping_amount >= 0 AND discount_amount >= 0 AND amount_incl_tax >= 0
  ),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_cart
    FOREIGN KEY (cart_id) REFERENCES carts (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_shipping_address
    FOREIGN KEY (shipping_address_id) REFERENCES addresses (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_billing_address
    FOREIGN KEY (billing_address_id) REFERENCES addresses (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)      NOT NULL,
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  sku_snapshot    VARCHAR(80)   NULL,
  label           VARCHAR(255)  NOT NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 1,
  unit_price      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax_rate        DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
  discount_amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  line_total      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id, deleted_at),
  KEY idx_order_items_product (product_id),
  KEY idx_order_items_variant (variant_id),
  CONSTRAINT chk_order_items_qty CHECK (quantity > 0),
  CONSTRAINT chk_order_items_amounts CHECK (
    unit_price >= 0 AND tax_rate >= 0 AND discount_amount >= 0 AND line_total >= 0
  ),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_status_histories (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)     NOT NULL,
  from_status     VARCHAR(40)  NULL,
  to_status       VARCHAR(40)  NOT NULL,
  changed_by      CHAR(36)     NULL,
  note            TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  KEY idx_order_status_histories_order (order_id, created_at),
  CONSTRAINT fk_order_status_histories_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_status_histories_user
    FOREIGN KEY (changed_by) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Append-only order status timeline';

ALTER TABLE customer_reviews
  ADD CONSTRAINT fk_customer_reviews_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE payments (
  id                  CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_id            CHAR(36)      NOT NULL,
  amount              DECIMAL(14,2) NOT NULL,
  currency            CHAR(3)       NOT NULL DEFAULT 'USD',
  method              ENUM('card', 'mobile_money', 'bank_transfer', 'cash', 'other')
                      NOT NULL DEFAULT 'card',
  status              ENUM('pending', 'succeeded', 'failed', 'refunded')
                      NOT NULL DEFAULT 'pending',
  provider            VARCHAR(80)   NULL,
  external_reference  VARCHAR(120)  NULL,
  failure_reason      VARCHAR(255)  NULL,
  paid_at             DATETIME(6)   NULL,
  created_at          DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at          DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at          DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_payments_order (order_id, status),
  KEY idx_payments_external (external_reference),
  UNIQUE KEY uq_payments_external_active (
    (CASE WHEN deleted_at IS NULL AND external_reference IS NOT NULL THEN external_reference ELSE NULL END)
  ),
  CONSTRAINT chk_payments_amount CHECK (amount >= 0),
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipments (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)     NOT NULL,
  carrier         VARCHAR(120) NULL,
  tracking_number VARCHAR(120) NULL,
  status          ENUM('prepared', 'in_transit', 'delivered', 'failed', 'returned')
                  NOT NULL DEFAULT 'prepared',
  shipped_at      DATETIME(6)  NULL,
  delivered_at    DATETIME(6)  NULL,
  shipping_address_snapshot JSON NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_shipments_order (order_id, status),
  KEY idx_shipments_tracking (tracking_number),
  CONSTRAINT fk_shipments_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Dynamic attributes
-- #############################################################################

CREATE TABLE product_attributes (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  code            VARCHAR(80)  NOT NULL,
  label           VARCHAR(150) NOT NULL,
  value_type      ENUM('text', 'number', 'boolean', 'list', 'color')
                  NOT NULL DEFAULT 'text',
  is_filterable   TINYINT(1)   NOT NULL DEFAULT 0,
  is_variant_axis TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'Used as size/color axis',
  sort_order      INT          NOT NULL DEFAULT 0,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_attributes_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attribute_values (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  attribute_id    CHAR(36)     NOT NULL,
  product_id      CHAR(36)     NULL,
  variant_id      CHAR(36)     NULL,
  value           VARCHAR(500) NOT NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_attribute_values_attribute (attribute_id),
  KEY idx_attribute_values_product (product_id),
  KEY idx_attribute_values_variant (variant_id),
  CONSTRAINT fk_attribute_values_attribute
    FOREIGN KEY (attribute_id) REFERENCES product_attributes (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_attribute_values_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_attribute_values_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Pricing & Promotions
-- #############################################################################

CREATE TABLE price_lists (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  name            VARCHAR(150)  NOT NULL,
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  price           DECIMAL(14,2) NOT NULL,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  min_quantity    DECIMAL(14,3) NOT NULL DEFAULT 1,
  starts_at       DATETIME(6)   NULL,
  ends_at         DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_price_lists_product (product_id, starts_at, ends_at),
  KEY idx_price_lists_variant (variant_id, starts_at, ends_at),
  CONSTRAINT chk_price_lists_price CHECK (price >= 0 AND min_quantity > 0),
  CONSTRAINT fk_price_lists_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_price_lists_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promotion_rules (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  code            VARCHAR(80)   NULL,
  name            VARCHAR(150)  NOT NULL,
  discount_type   ENUM('percentage', 'fixed_amount', 'free_shipping')
                  NOT NULL DEFAULT 'percentage',
  discount_value  DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  min_order_amount DECIMAL(14,2) NULL,
  usage_limit     INT           NULL,
  usage_count     INT           NOT NULL DEFAULT 0,
  per_user_limit  INT           NULL,
  starts_at       DATETIME(6)   NULL,
  ends_at         DATETIME(6)   NULL,
  is_active       TINYINT(1)    NOT NULL DEFAULT 1,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_promotion_rules_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END)),
  KEY idx_promotion_rules_window (is_active, starts_at, ends_at, deleted_at),
  CONSTRAINT chk_promotion_rules_value CHECK (discount_value >= 0),
  CONSTRAINT chk_promotion_rules_usage CHECK (usage_count >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promotion_rule_targets (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  rule_id         CHAR(36)     NOT NULL,
  target_type     ENUM('product', 'category', 'variant', 'segment', 'global')
                  NOT NULL DEFAULT 'global',
  target_id       CHAR(36)     NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_promo_targets_rule (rule_id, deleted_at),
  KEY idx_promo_targets_target (target_type, target_id),
  CONSTRAINT fk_promo_targets_rule
    FOREIGN KEY (rule_id) REFERENCES promotion_rules (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promotion_redemptions (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  rule_id         CHAR(36)     NOT NULL,
  user_id         CHAR(36)     NULL,
  order_id        CHAR(36)     NULL,
  discount_applied DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  redeemed_at     DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_promo_redemptions_rule (rule_id),
  KEY idx_promo_redemptions_user (user_id),
  KEY idx_promo_redemptions_order (order_id),
  CONSTRAINT fk_promo_redemptions_rule
    FOREIGN KEY (rule_id) REFERENCES promotion_rules (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_promo_redemptions_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_promo_redemptions_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- CRM & Quotes
-- #############################################################################

CREATE TABLE customer_segments (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  name            VARCHAR(150) NOT NULL,
  description     TEXT         NULL,
  criteria        JSON         NULL COMMENT 'Rule definition for dynamic segments',
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customer_segment_members (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  segment_id      CHAR(36)     NOT NULL,
  user_id         CHAR(36)     NOT NULL,
  added_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_segment_members_active (
    (CASE WHEN deleted_at IS NULL THEN segment_id ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN user_id ELSE NULL END)
  ),
  KEY idx_segment_members_user (user_id),
  CONSTRAINT fk_segment_members_segment
    FOREIGN KEY (segment_id) REFERENCES customer_segments (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_segment_members_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quotes (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  quote_number    VARCHAR(40)   NOT NULL,
  user_id         CHAR(36)      NULL,
  sales_rep_id    CHAR(36)      NULL,
  status          ENUM('draft', 'sent', 'accepted', 'rejected', 'expired', 'converted')
                  NOT NULL DEFAULT 'draft',
  amount_excl_tax DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax_amount      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  valid_until     DATE          NULL,
  notes           TEXT          NULL,
  converted_order_id CHAR(36)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_quotes_number (quote_number),
  KEY idx_quotes_user (user_id, status),
  KEY idx_quotes_sales_rep (sales_rep_id),
  CONSTRAINT chk_quotes_amounts CHECK (
    amount_excl_tax >= 0 AND tax_amount >= 0 AND amount_incl_tax >= 0
  ),
  CONSTRAINT fk_quotes_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_quotes_sales_rep
    FOREIGN KEY (sales_rep_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quote_items (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  quote_id        CHAR(36)      NOT NULL,
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  label           VARCHAR(255)  NOT NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 1,
  unit_price      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  line_total      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_quote_items_quote (quote_id, deleted_at),
  CONSTRAINT chk_quote_items_qty CHECK (quantity > 0),
  CONSTRAINT fk_quote_items_quote
    FOREIGN KEY (quote_id) REFERENCES quotes (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_quote_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_quote_items_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customer_interactions (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NOT NULL,
  author_id       CHAR(36)     NULL,
  interaction_type ENUM('call', 'email', 'visit', 'message', 'other')
                   NOT NULL DEFAULT 'other',
  subject         VARCHAR(255) NULL,
  body            TEXT         NULL,
  interacted_at   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customer_interactions_user (user_id, interacted_at),
  KEY idx_customer_interactions_author (author_id),
  CONSTRAINT fk_customer_interactions_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_customer_interactions_author
    FOREIGN KEY (author_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE orders
  ADD CONSTRAINT fk_orders_quote
    FOREIGN KEY (quote_id) REFERENCES quotes (id)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE quotes
  ADD CONSTRAINT fk_quotes_converted_order
    FOREIGN KEY (converted_order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE;


-- #############################################################################
-- Customization & Made-to-measure
-- #############################################################################

CREATE TABLE customer_measurements (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NOT NULL,
  label           VARCHAR(120) NULL,
  measurements    JSON         NOT NULL,
  unit            ENUM('cm', 'in') NOT NULL DEFAULT 'cm',
  is_default      TINYINT(1)   NOT NULL DEFAULT 0,
  notes           TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customer_measurements_user (user_id, deleted_at),
  CONSTRAINT fk_customer_measurements_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pattern_models (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)     NULL,
  code            VARCHAR(80)  NOT NULL,
  name            VARCHAR(150) NOT NULL,
  description     TEXT         NULL,
  file_url        VARCHAR(500) NULL,
  version         VARCHAR(40)  NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pattern_models_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END)),
  KEY idx_pattern_models_product (product_id),
  CONSTRAINT fk_pattern_models_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customization_requests (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)     NULL,
  order_item_id   CHAR(36)     NULL,
  user_id         CHAR(36)     NULL,
  measurement_id  CHAR(36)     NULL,
  pattern_id      CHAR(36)     NULL,
  status          ENUM('received', 'under_review', 'approved', 'rejected', 'in_production')
                  NOT NULL DEFAULT 'received',
  instructions    TEXT         NULL,
  reviewed_by     CHAR(36)     NULL,
  reviewed_at     DATETIME(6)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customization_requests_order (order_id),
  KEY idx_customization_requests_user (user_id),
  KEY idx_customization_requests_status (status, deleted_at),
  CONSTRAINT fk_customization_requests_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customization_requests_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customization_requests_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customization_requests_measurement
    FOREIGN KEY (measurement_id) REFERENCES customer_measurements (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customization_requests_pattern
    FOREIGN KEY (pattern_id) REFERENCES pattern_models (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customization_requests_reviewer
    FOREIGN KEY (reviewed_by) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE embroidery_files (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  request_id      CHAR(36)     NOT NULL,
  file_name       VARCHAR(255) NOT NULL,
  url             VARCHAR(500) NOT NULL,
  mime_type       VARCHAR(120) NULL,
  size_bytes      BIGINT       NULL,
  checksum_sha256 CHAR(64)     NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_embroidery_files_request (request_id),
  CONSTRAINT chk_embroidery_files_size CHECK (size_bytes IS NULL OR size_bytes >= 0),
  CONSTRAINT fk_embroidery_files_request
    FOREIGN KEY (request_id) REFERENCES customization_requests (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Materials & Suppliers
-- #############################################################################

CREATE TABLE suppliers (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  company_name    VARCHAR(255) NOT NULL,
  contact_name    VARCHAR(150) NULL,
  email           VARCHAR(255) NULL,
  phone           VARCHAR(40)  NULL,
  address         TEXT         NULL,
  country_code    CHAR(2)      NULL,
  payment_terms   VARCHAR(120) NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_suppliers_active (is_active, deleted_at),
  KEY idx_suppliers_name (company_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE raw_materials (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  code            VARCHAR(80)   NOT NULL,
  name            VARCHAR(200)  NOT NULL,
  unit            VARCHAR(20)   NOT NULL DEFAULT 'm',
  description     TEXT          NULL,
  reorder_level   DECIMAL(14,3) NOT NULL DEFAULT 0,
  default_supplier_id CHAR(36)  NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_raw_materials_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END)),
  KEY idx_raw_materials_supplier (default_supplier_id),
  CONSTRAINT chk_raw_materials_reorder CHECK (reorder_level >= 0),
  CONSTRAINT fk_raw_materials_supplier
    FOREIGN KEY (default_supplier_id) REFERENCES suppliers (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bills_of_materials (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  material_id     CHAR(36)      NOT NULL,
  quantity        DECIMAL(14,4) NOT NULL DEFAULT 1,
  unit            VARCHAR(20)   NULL,
  scrap_percent   DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_bom_product (product_id),
  KEY idx_bom_variant (variant_id),
  KEY idx_bom_material (material_id),
  UNIQUE KEY uq_bom_line_active (
    (CASE WHEN deleted_at IS NULL THEN COALESCE(product_id, '') ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN COALESCE(variant_id, '') ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN material_id ELSE NULL END)
  ),
  CONSTRAINT chk_bom_quantity CHECK (quantity > 0 AND scrap_percent >= 0),
  CONSTRAINT fk_bom_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_bom_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_bom_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='BOM / product composition';

CREATE TABLE supplier_orders (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_number    VARCHAR(40)   NOT NULL,
  supplier_id     CHAR(36)      NOT NULL,
  status          ENUM('draft', 'sent', 'partial', 'received', 'cancelled')
                  NOT NULL DEFAULT 'draft',
  total_amount    DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  ordered_at      DATETIME(6)   NULL,
  expected_at     DATETIME(6)   NULL,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_supplier_orders_number (order_number),
  KEY idx_supplier_orders_supplier (supplier_id, status),
  CONSTRAINT chk_supplier_orders_total CHECK (total_amount >= 0),
  CONSTRAINT fk_supplier_orders_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_order_items (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  supplier_order_id CHAR(36)      NOT NULL,
  material_id       CHAR(36)      NOT NULL,
  quantity_ordered  DECIMAL(14,3) NOT NULL,
  quantity_received DECIMAL(14,3) NOT NULL DEFAULT 0,
  unit_price        DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_supplier_order_items_order (supplier_order_id, deleted_at),
  KEY idx_supplier_order_items_material (material_id),
  CONSTRAINT chk_supplier_order_items_qty CHECK (
    quantity_ordered > 0 AND quantity_received >= 0 AND unit_price >= 0
  ),
  CONSTRAINT fk_supplier_order_items_order
    FOREIGN KEY (supplier_order_id) REFERENCES supplier_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_supplier_order_items_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_receipts (
  id                CHAR(36)     NOT NULL DEFAULT (UUID()),
  supplier_order_id CHAR(36)     NOT NULL,
  warehouse_id      CHAR(36)     NULL,
  receipt_number    VARCHAR(40)  NULL,
  received_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  received_by       CHAR(36)     NULL,
  notes             TEXT         NULL,
  created_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_supplier_receipts_order (supplier_order_id),
  UNIQUE KEY uq_supplier_receipts_number_active (
    (CASE WHEN deleted_at IS NULL THEN receipt_number ELSE NULL END)
  ),
  CONSTRAINT fk_supplier_receipts_order
    FOREIGN KEY (supplier_order_id) REFERENCES supplier_orders (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_supplier_receipts_receiver
    FOREIGN KEY (received_by) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_receipt_items (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  receipt_id        CHAR(36)      NOT NULL,
  supplier_order_item_id CHAR(36) NULL,
  material_id       CHAR(36)      NOT NULL,
  quantity_received DECIMAL(14,3) NOT NULL,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_supplier_receipt_items_receipt (receipt_id),
  CONSTRAINT chk_supplier_receipt_items_qty CHECK (quantity_received > 0),
  CONSTRAINT fk_supplier_receipt_items_receipt
    FOREIGN KEY (receipt_id) REFERENCES supplier_receipts (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_supplier_receipt_items_order_item
    FOREIGN KEY (supplier_order_item_id) REFERENCES supplier_order_items (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_supplier_receipt_items_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Logistics & Stock
-- #############################################################################

CREATE TABLE warehouses (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  code            VARCHAR(40)  NOT NULL,
  name            VARCHAR(150) NOT NULL,
  address         TEXT         NULL,
  is_default      TINYINT(1)   NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_warehouses_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE supplier_receipts
  ADD CONSTRAINT fk_supplier_receipts_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE material_stock (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  material_id     CHAR(36)      NOT NULL,
  warehouse_id    CHAR(36)      NOT NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 0,
  reserved_qty    DECIMAL(14,3) NOT NULL DEFAULT 0,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_material_stock_active (
    (CASE WHEN deleted_at IS NULL THEN material_id ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN warehouse_id ELSE NULL END)
  ),
  CONSTRAINT chk_material_stock_qty CHECK (quantity >= 0 AND reserved_qty >= 0),
  CONSTRAINT fk_material_stock_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_material_stock_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE finished_goods_stock (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  variant_id      CHAR(36)      NOT NULL,
  warehouse_id    CHAR(36)      NOT NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 0,
  reserved_qty    DECIMAL(14,3) NOT NULL DEFAULT 0,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_finished_goods_stock_active (
    (CASE WHEN deleted_at IS NULL THEN variant_id ELSE NULL END),
    (CASE WHEN deleted_at IS NULL THEN warehouse_id ELSE NULL END)
  ),
  CONSTRAINT chk_finished_goods_stock_qty CHECK (quantity >= 0 AND reserved_qty >= 0),
  CONSTRAINT fk_finished_goods_stock_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_finished_goods_stock_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-warehouse finished goods qty for variants';

CREATE TABLE inventory_counts (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  warehouse_id    CHAR(36)     NOT NULL,
  reference       VARCHAR(40)  NOT NULL,
  status          ENUM('draft', 'in_progress', 'validated', 'cancelled')
                  NOT NULL DEFAULT 'draft',
  counted_at      DATETIME(6)  NULL,
  counted_by      CHAR(36)     NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inventory_counts_reference (reference),
  KEY idx_inventory_counts_warehouse (warehouse_id, status),
  CONSTRAINT fk_inventory_counts_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_counts_user
    FOREIGN KEY (counted_by) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_count_items (
  id                 CHAR(36)      NOT NULL DEFAULT (UUID()),
  inventory_count_id CHAR(36)      NOT NULL,
  material_id        CHAR(36)      NULL,
  variant_id         CHAR(36)      NULL,
  expected_qty       DECIMAL(14,3) NOT NULL DEFAULT 0,
  counted_qty        DECIMAL(14,3) NOT NULL DEFAULT 0,
  variance           DECIMAL(14,3) GENERATED ALWAYS AS (counted_qty - expected_qty) STORED,
  created_at         DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at         DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at         DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_inventory_count_items_count (inventory_count_id),
  CONSTRAINT fk_inventory_count_items_count
    FOREIGN KEY (inventory_count_id) REFERENCES inventory_counts (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_count_items_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_count_items_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE stock_reservations (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  warehouse_id    CHAR(36)      NOT NULL,
  material_id     CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  order_id        CHAR(36)      NULL,
  work_order_id   CHAR(36)      NULL,
  quantity        DECIMAL(14,3) NOT NULL,
  status          ENUM('active', 'consumed', 'cancelled') NOT NULL DEFAULT 'active',
  expires_at      DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_stock_reservations_warehouse (warehouse_id, status),
  KEY idx_stock_reservations_order (order_id),
  KEY idx_stock_reservations_expires (expires_at, status),
  CONSTRAINT chk_stock_reservations_qty CHECK (quantity > 0),
  CONSTRAINT chk_stock_reservations_target CHECK (
    material_id IS NOT NULL OR variant_id IS NOT NULL
  ),
  CONSTRAINT fk_stock_reservations_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_stock_reservations_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_stock_reservations_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_stock_reservations_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE stock_transfers (
  id                  CHAR(36)      NOT NULL DEFAULT (UUID()),
  transfer_number     VARCHAR(40)   NULL,
  source_warehouse_id CHAR(36)      NOT NULL,
  dest_warehouse_id   CHAR(36)      NOT NULL,
  material_id         CHAR(36)      NULL,
  variant_id          CHAR(36)      NULL,
  quantity            DECIMAL(14,3) NOT NULL,
  status              ENUM('draft', 'in_transit', 'received', 'cancelled')
                      NOT NULL DEFAULT 'draft',
  transferred_at      DATETIME(6)   NULL,
  notes               TEXT          NULL,
  created_at          DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at          DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at          DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_stock_transfers_source (source_warehouse_id, status),
  KEY idx_stock_transfers_dest (dest_warehouse_id),
  UNIQUE KEY uq_stock_transfers_number_active (
    (CASE WHEN deleted_at IS NULL THEN transfer_number ELSE NULL END)
  ),
  CONSTRAINT chk_stock_transfers_qty CHECK (quantity > 0),
  CONSTRAINT chk_stock_transfers_warehouses CHECK (source_warehouse_id <> dest_warehouse_id),
  CONSTRAINT chk_stock_transfers_target CHECK (
    material_id IS NOT NULL OR variant_id IS NOT NULL
  ),
  CONSTRAINT fk_stock_transfers_source
    FOREIGN KEY (source_warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_stock_transfers_dest
    FOREIGN KEY (dest_warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_stock_transfers_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_stock_transfers_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Production & Workshop (MES)
-- #############################################################################

CREATE TABLE employees (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NULL,
  employee_number VARCHAR(40)  NOT NULL,
  last_name       VARCHAR(120) NOT NULL,
  first_name      VARCHAR(120) NULL,
  job_title       VARCHAR(120) NULL,
  hire_date       DATE         NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_employees_number_active ((CASE WHEN deleted_at IS NULL THEN employee_number ELSE NULL END)),
  KEY idx_employees_user (user_id),
  CONSTRAINT fk_employees_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE workstations (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  code            VARCHAR(40)  NOT NULL,
  name            VARCHAR(150) NOT NULL,
  station_type    VARCHAR(80)  NULL,
  daily_capacity  DECIMAL(14,2) NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_workstations_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE production_steps (
  id                    CHAR(36)     NOT NULL DEFAULT (UUID()),
  code                  VARCHAR(40)  NOT NULL,
  name                  VARCHAR(150) NOT NULL,
  sort_order            INT          NOT NULL DEFAULT 0,
  standard_duration_min INT          NULL,
  description           TEXT         NULL,
  created_at            DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at            DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at            DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_production_steps_code_active ((CASE WHEN deleted_at IS NULL THEN code ELSE NULL END)),
  KEY idx_production_steps_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE production_plans (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  reference       VARCHAR(40)  NOT NULL,
  name            VARCHAR(150) NOT NULL,
  starts_at       DATETIME(6)  NULL,
  ends_at         DATETIME(6)  NULL,
  status          ENUM('draft', 'published', 'closed', 'cancelled')
                  NOT NULL DEFAULT 'draft',
  notes           TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_production_plans_reference (reference),
  KEY idx_production_plans_window (starts_at, ends_at, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE work_orders (
  id                       CHAR(36)      NOT NULL DEFAULT (UUID()),
  work_order_number        VARCHAR(40)   NOT NULL,
  order_id                 CHAR(36)      NULL,
  order_item_id            CHAR(36)      NULL,
  product_id               CHAR(36)      NULL,
  variant_id               CHAR(36)      NULL,
  customization_request_id CHAR(36)      NULL,
  plan_id                  CHAR(36)      NULL,
  quantity                 DECIMAL(14,3) NOT NULL DEFAULT 1,
  status                   ENUM(
                             'draft', 'planned', 'in_progress', 'on_hold',
                             'completed', 'cancelled', 'rework'
                           ) NOT NULL DEFAULT 'draft',
  priority                 TINYINT       NOT NULL DEFAULT 3,
  planned_start_at         DATETIME(6)   NULL,
  planned_end_at           DATETIME(6)   NULL,
  actual_start_at          DATETIME(6)   NULL,
  actual_end_at            DATETIME(6)   NULL,
  notes                    TEXT          NULL,
  created_at               DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at               DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at               DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_work_orders_number (work_order_number),
  KEY idx_work_orders_order (order_id),
  KEY idx_work_orders_status_priority (status, priority, planned_start_at),
  KEY idx_work_orders_plan (plan_id),
  CONSTRAINT chk_work_orders_qty CHECK (quantity > 0),
  CONSTRAINT chk_work_orders_priority CHECK (priority BETWEEN 1 AND 5),
  CONSTRAINT fk_work_orders_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_work_orders_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_work_orders_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_work_orders_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_work_orders_customization
    FOREIGN KEY (customization_request_id) REFERENCES customization_requests (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_work_orders_plan
    FOREIGN KEY (plan_id) REFERENCES production_plans (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE stock_reservations
  ADD CONSTRAINT fk_stock_reservations_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE work_order_status_histories (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id   CHAR(36)     NOT NULL,
  from_status     VARCHAR(40)  NULL,
  to_status       VARCHAR(40)  NOT NULL,
  changed_by      CHAR(36)     NULL,
  note            TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  KEY idx_wo_status_histories_wo (work_order_id, created_at),
  CONSTRAINT fk_wo_status_histories_wo
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_wo_status_histories_user
    FOREIGN KEY (changed_by) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Append-only work-order status timeline';

CREATE TABLE production_tracking (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id   CHAR(36)     NOT NULL,
  step_id         CHAR(36)     NULL,
  status          ENUM('todo', 'in_progress', 'done', 'blocked')
                  NOT NULL DEFAULT 'todo',
  comment         TEXT         NULL,
  started_at      DATETIME(6)  NULL,
  finished_at     DATETIME(6)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_production_tracking_work_order (work_order_id, status),
  KEY idx_production_tracking_step (step_id),
  CONSTRAINT fk_production_tracking_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_production_tracking_step
    FOREIGN KEY (step_id) REFERENCES production_steps (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE workstation_assignments (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id   CHAR(36)     NOT NULL,
  workstation_id  CHAR(36)     NOT NULL,
  employee_id     CHAR(36)     NULL,
  step_id         CHAR(36)     NULL,
  started_at      DATETIME(6)  NULL,
  finished_at     DATETIME(6)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_ws_assignments_work_order (work_order_id),
  KEY idx_ws_assignments_workstation (workstation_id, started_at),
  KEY idx_ws_assignments_employee (employee_id),
  CONSTRAINT fk_ws_assignments_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ws_assignments_workstation
    FOREIGN KEY (workstation_id) REFERENCES workstations (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ws_assignments_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_ws_assignments_step
    FOREIGN KEY (step_id) REFERENCES production_steps (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE operation_times (
  id               CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id    CHAR(36)     NOT NULL,
  step_id          CHAR(36)     NULL,
  employee_id      CHAR(36)     NULL,
  duration_minutes INT          NOT NULL DEFAULT 0,
  started_at       DATETIME(6)  NULL,
  finished_at      DATETIME(6)  NULL,
  notes            TEXT         NULL,
  created_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at       DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_operation_times_work_order (work_order_id),
  KEY idx_operation_times_employee (employee_id, started_at),
  CONSTRAINT chk_operation_times_duration CHECK (duration_minutes >= 0),
  CONSTRAINT fk_operation_times_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_operation_times_step
    FOREIGN KEY (step_id) REFERENCES production_steps (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_operation_times_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quality_checks (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id   CHAR(36)     NOT NULL,
  inspector_id    CHAR(36)     NULL,
  result          ENUM('pass', 'fail', 'rework')
                  NOT NULL DEFAULT 'pass',
  criteria        JSON         NULL,
  comment         TEXT         NULL,
  checked_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_quality_checks_work_order (work_order_id, result),
  CONSTRAINT fk_quality_checks_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_quality_checks_inspector
    FOREIGN KEY (inspector_id) REFERENCES employees (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE production_reworks (
  id               CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id    CHAR(36)     NOT NULL,
  quality_check_id CHAR(36)     NULL,
  reason           TEXT         NOT NULL,
  status           ENUM('open', 'in_progress', 'completed', 'cancelled')
                   NOT NULL DEFAULT 'open',
  created_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at       DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_production_reworks_work_order (work_order_id, status),
  CONSTRAINT fk_production_reworks_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_production_reworks_quality_check
    FOREIGN KEY (quality_check_id) REFERENCES quality_checks (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Finance & Accounting
-- #############################################################################

CREATE TABLE customer_invoices (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  invoice_number  VARCHAR(40)   NOT NULL,
  order_id        CHAR(36)      NULL,
  user_id         CHAR(36)      NULL,
  status          ENUM('draft', 'issued', 'paid', 'cancelled', 'credit_note')
                  NOT NULL DEFAULT 'draft',
  amount_excl_tax DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax_amount      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  issued_at       DATETIME(6)   NULL,
  due_at          DATETIME(6)   NULL,
  paid_at         DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customer_invoices_number (invoice_number),
  KEY idx_customer_invoices_order (order_id),
  KEY idx_customer_invoices_user_status (user_id, status),
  CONSTRAINT chk_customer_invoices_amounts CHECK (
    amount_excl_tax >= 0 AND tax_amount >= 0 AND amount_incl_tax >= 0
  ),
  CONSTRAINT fk_customer_invoices_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customer_invoices_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customer_invoice_items (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  invoice_id      CHAR(36)      NOT NULL,
  order_item_id   CHAR(36)      NULL,
  label           VARCHAR(255)  NOT NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 1,
  unit_price      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax_rate        DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
  line_total      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_customer_invoice_items_invoice (invoice_id),
  CONSTRAINT chk_customer_invoice_items_qty CHECK (quantity > 0),
  CONSTRAINT fk_customer_invoice_items_invoice
    FOREIGN KEY (invoice_id) REFERENCES customer_invoices (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_customer_invoice_items_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_invoices (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  invoice_number    VARCHAR(40)   NOT NULL,
  supplier_id       CHAR(36)      NOT NULL,
  supplier_order_id CHAR(36)      NULL,
  status            ENUM('received', 'to_pay', 'paid', 'cancelled')
                    NOT NULL DEFAULT 'received',
  amount_excl_tax   DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax_amount        DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax   DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  currency          CHAR(3)       NOT NULL DEFAULT 'USD',
  invoice_date      DATETIME(6)   NULL,
  due_at            DATETIME(6)   NULL,
  paid_at           DATETIME(6)   NULL,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_supplier_invoices_number (invoice_number),
  KEY idx_supplier_invoices_supplier (supplier_id, status),
  CONSTRAINT chk_supplier_invoices_amounts CHECK (
    amount_excl_tax >= 0 AND tax_amount >= 0 AND amount_incl_tax >= 0
  ),
  CONSTRAINT fk_supplier_invoices_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_supplier_invoices_order
    FOREIGN KEY (supplier_order_id) REFERENCES supplier_orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE expenses (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  label           VARCHAR(255)  NOT NULL,
  category        VARCHAR(120)  NULL,
  amount          DECIMAL(14,2) NOT NULL,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  expense_date    DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  supplier_id     CHAR(36)      NULL,
  payment_method  VARCHAR(40)   NULL,
  reference       VARCHAR(80)   NULL,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_expenses_supplier (supplier_id),
  KEY idx_expenses_date (expense_date),
  CONSTRAINT chk_expenses_amount CHECK (amount >= 0),
  CONSTRAINT fk_expenses_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- After-sales (returns)
-- #############################################################################

CREATE TABLE return_requests (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)     NOT NULL,
  order_item_id   CHAR(36)     NULL,
  user_id         CHAR(36)     NULL,
  reason          TEXT         NOT NULL,
  quantity        DECIMAL(14,3) NOT NULL DEFAULT 1,
  status          ENUM(
                    'open', 'accepted', 'rejected',
                    'returning', 'refunded', 'exchanged', 'closed'
                  ) NOT NULL DEFAULT 'open',
  resolution      TEXT         NULL,
  refund_amount   DECIMAL(14,2) NULL,
  processed_by    CHAR(36)     NULL,
  processed_at    DATETIME(6)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_return_requests_order (order_id, status),
  KEY idx_return_requests_user (user_id),
  CONSTRAINT chk_return_requests_qty CHECK (quantity > 0),
  CONSTRAINT fk_return_requests_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_return_requests_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_return_requests_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_return_requests_processor
    FOREIGN KEY (processed_by) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- End of Sanaa.co schema
-- =============================================================================
