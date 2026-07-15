-- =============================================================================
-- Sanaa.co — MySQL schema (English)
-- Primary keys : UUID (CHAR(36)), via UUID()
-- Soft delete  : deleted_at on main tables
-- Requires     : MySQL 8.0.13+ (DEFAULT (UUID()))
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS sanaa
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sanaa;

-- -----------------------------------------------------------------------------
-- Conventions:
--   id          CHAR(36) NOT NULL DEFAULT (UUID())
--   deleted_at  DATETIME(6) NULL
--   created_at  DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
--   updated_at  DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
--                 ON UPDATE CURRENT_TIMESTAMP(6)
-- -----------------------------------------------------------------------------


-- #############################################################################
-- Security & Audit
-- #############################################################################

CREATE TABLE users (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  email           VARCHAR(255) NOT NULL,
  password_hash   VARCHAR(255) NOT NULL,
  last_name       VARCHAR(120) NULL,
  first_name      VARCHAR(120) NULL,
  phone           VARCHAR(40)  NULL,
  role            ENUM('customer', 'sales', 'workshop', 'purchasing', 'finance', 'admin')
                  NOT NULL DEFAULT 'customer',
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_role (role),
  KEY idx_users_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NULL,
  action          VARCHAR(100) NOT NULL,
  target_table    VARCHAR(100) NULL,
  record_id       CHAR(36)     NULL,
  details         JSON         NULL,
  ip_address      VARCHAR(45)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_audit_logs_user (user_id),
  KEY idx_audit_logs_table (target_table),
  KEY idx_audit_logs_created (created_at),
  CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- Sales & Catalog
-- #############################################################################

CREATE TABLE categories (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  name            VARCHAR(150) NOT NULL,
  slug            VARCHAR(180) NOT NULL,
  description     TEXT         NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug (slug),
  KEY idx_categories_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subcategories (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  category_id     CHAR(36)     NOT NULL,
  name            VARCHAR(150) NOT NULL,
  slug            VARCHAR(180) NOT NULL,
  description     TEXT         NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_subcategories_slug (slug),
  KEY idx_subcategories_category (category_id),
  CONSTRAINT fk_subcategories_category
    FOREIGN KEY (category_id) REFERENCES categories (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  id                CHAR(36)     NOT NULL DEFAULT (UUID()),
  category_id       CHAR(36)     NULL,
  subcategory_id    CHAR(36)     NULL,
  sku               VARCHAR(80)  NULL,
  name              VARCHAR(255) NOT NULL,
  slug              VARCHAR(280) NOT NULL,
  description       TEXT         NULL,
  short_description VARCHAR(500) NULL,
  product_type      ENUM('standard', 'custom', 'semi_custom')
                    NOT NULL DEFAULT 'standard',
  base_price        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  currency          CHAR(3)      NOT NULL DEFAULT 'USD',
  is_active         TINYINT(1)   NOT NULL DEFAULT 1,
  created_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_category (category_id),
  KEY idx_products_subcategory (subcategory_id),
  KEY idx_products_type (product_type),
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
  price           DECIMAL(12,2) NULL,
  stock_available DECIMAL(12,3) NOT NULL DEFAULT 0,
  is_active       TINYINT(1)    NOT NULL DEFAULT 1,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_variants_sku (sku),
  KEY idx_product_variants_product (product_id),
  CONSTRAINT fk_product_variants_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customer_reviews (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)     NOT NULL,
  user_id         CHAR(36)     NULL,
  rating          TINYINT      NOT NULL,
  title           VARCHAR(200) NULL,
  comment         TEXT         NULL,
  is_approved     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customer_reviews_product (product_id),
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
  status          ENUM('open', 'converted', 'abandoned') NOT NULL DEFAULT 'open',
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_carts_user (user_id),
  KEY idx_carts_session (session_token),
  CONSTRAINT fk_carts_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orders (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_number    VARCHAR(40)   NOT NULL,
  user_id         CHAR(36)      NULL,
  cart_id         CHAR(36)      NULL,
  quote_id        CHAR(36)      NULL,
  status          ENUM(
                    'draft', 'pending', 'paid', 'in_production',
                    'shipped', 'delivered', 'cancelled', 'refunded'
                  ) NOT NULL DEFAULT 'draft',
  amount_excl_tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_amount      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  shipping_address JSON         NULL,
  billing_address  JSON         NULL,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_number (order_number),
  KEY idx_orders_user (user_id),
  KEY idx_orders_status (status),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_cart
    FOREIGN KEY (cart_id) REFERENCES carts (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)      NOT NULL,
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  label           VARCHAR(255)  NOT NULL,
  quantity        DECIMAL(12,3) NOT NULL DEFAULT 1,
  unit_price      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  line_total      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  KEY idx_order_items_product (product_id),
  KEY idx_order_items_variant (variant_id),
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

CREATE TABLE payments (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_id        CHAR(36)      NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  method          ENUM('card', 'mobile_money', 'bank_transfer', 'cash', 'other')
                  NOT NULL DEFAULT 'card',
  status          ENUM('pending', 'succeeded', 'failed', 'refunded')
                  NOT NULL DEFAULT 'pending',
  external_reference VARCHAR(120) NULL,
  paid_at         DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_payments_order (order_id),
  KEY idx_payments_status (status),
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
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_shipments_order (order_id),
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
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_attributes_code (code)
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
  price           DECIMAL(12,2) NOT NULL,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  min_quantity    DECIMAL(12,3) NOT NULL DEFAULT 1,
  starts_at       DATETIME(6)   NULL,
  ends_at         DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_price_lists_product (product_id),
  KEY idx_price_lists_variant (variant_id),
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
  discount_value  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  starts_at       DATETIME(6)   NULL,
  ends_at         DATETIME(6)   NULL,
  is_active       TINYINT(1)    NOT NULL DEFAULT 1,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_promotion_rules_code (code)
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
  KEY idx_promo_targets_rule (rule_id),
  KEY idx_promo_targets_target (target_type, target_id),
  CONSTRAINT fk_promo_targets_rule
    FOREIGN KEY (rule_id) REFERENCES promotion_rules (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- #############################################################################
-- CRM & Quotes
-- #############################################################################

CREATE TABLE customer_segments (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  name            VARCHAR(150) NOT NULL,
  description     TEXT         NULL,
  criteria        JSON         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quotes (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  quote_number    VARCHAR(40)   NOT NULL,
  user_id         CHAR(36)      NULL,
  sales_rep_id    CHAR(36)      NULL,
  status          ENUM('draft', 'sent', 'accepted', 'rejected', 'expired', 'converted')
                  NOT NULL DEFAULT 'draft',
  amount_excl_tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  valid_until     DATE          NULL,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_quotes_number (quote_number),
  KEY idx_quotes_user (user_id),
  KEY idx_quotes_sales_rep (sales_rep_id),
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
  quantity        DECIMAL(12,3) NOT NULL DEFAULT 1,
  unit_price      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  line_total      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_quote_items_quote (quote_id),
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
  KEY idx_customer_interactions_user (user_id),
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


-- #############################################################################
-- Customization & Made-to-measure
-- #############################################################################

CREATE TABLE customer_measurements (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NOT NULL,
  label           VARCHAR(120) NULL,
  measurements    JSON         NOT NULL,
  notes           TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customer_measurements_user (user_id),
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
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pattern_models_code (code),
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
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_customization_requests_order (order_id),
  KEY idx_customization_requests_user (user_id),
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
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE embroidery_files (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  request_id      CHAR(36)     NOT NULL,
  file_name       VARCHAR(255) NOT NULL,
  url             VARCHAR(500) NOT NULL,
  mime_type       VARCHAR(120) NULL,
  size_bytes      BIGINT       NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_embroidery_files_request (request_id),
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
  email           VARCHAR(255) NULL,
  phone           VARCHAR(40)  NULL,
  address         TEXT         NULL,
  country         VARCHAR(80)  NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE raw_materials (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  code            VARCHAR(80)   NOT NULL,
  name            VARCHAR(200)  NOT NULL,
  unit            VARCHAR(20)   NOT NULL DEFAULT 'm',
  description     TEXT          NULL,
  reorder_level   DECIMAL(12,3) NOT NULL DEFAULT 0,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_raw_materials_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bills_of_materials (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  material_id     CHAR(36)      NOT NULL,
  quantity        DECIMAL(12,4) NOT NULL DEFAULT 1,
  unit            VARCHAR(20)   NULL,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_bom_product (product_id),
  KEY idx_bom_variant (variant_id),
  KEY idx_bom_material (material_id),
  CONSTRAINT fk_bom_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_bom_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_bom_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_orders (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  order_number    VARCHAR(40)   NOT NULL,
  supplier_id     CHAR(36)      NOT NULL,
  status          ENUM('draft', 'sent', 'partial', 'received', 'cancelled')
                  NOT NULL DEFAULT 'draft',
  total_amount    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  ordered_at      DATETIME(6)   NULL,
  expected_at     DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_supplier_orders_number (order_number),
  KEY idx_supplier_orders_supplier (supplier_id),
  CONSTRAINT fk_supplier_orders_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_order_items (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  supplier_order_id CHAR(36)      NOT NULL,
  material_id       CHAR(36)      NOT NULL,
  quantity_ordered  DECIMAL(12,3) NOT NULL,
  quantity_received DECIMAL(12,3) NOT NULL DEFAULT 0,
  unit_price        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_supplier_order_items_order (supplier_order_id),
  KEY idx_supplier_order_items_material (material_id),
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
  receipt_number    VARCHAR(40)  NULL,
  received_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  notes             TEXT         NULL,
  created_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_supplier_receipts_order (supplier_order_id),
  CONSTRAINT fk_supplier_receipts_order
    FOREIGN KEY (supplier_order_id) REFERENCES supplier_orders (id)
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
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_warehouses_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE material_stock (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  material_id     CHAR(36)      NOT NULL,
  warehouse_id    CHAR(36)      NOT NULL,
  quantity        DECIMAL(12,3) NOT NULL DEFAULT 0,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_material_stock_warehouse (material_id, warehouse_id),
  CONSTRAINT fk_material_stock_material
    FOREIGN KEY (material_id) REFERENCES raw_materials (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_material_stock_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_counts (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  warehouse_id    CHAR(36)     NOT NULL,
  reference       VARCHAR(40)  NOT NULL,
  status          ENUM('draft', 'in_progress', 'validated', 'cancelled')
                  NOT NULL DEFAULT 'draft',
  counted_at      DATETIME(6)  NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inventory_counts_reference (reference),
  KEY idx_inventory_counts_warehouse (warehouse_id),
  CONSTRAINT fk_inventory_counts_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_count_items (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  inventory_count_id CHAR(36)     NOT NULL,
  material_id       CHAR(36)      NULL,
  variant_id        CHAR(36)      NULL,
  expected_qty      DECIMAL(12,3) NOT NULL DEFAULT 0,
  counted_qty       DECIMAL(12,3) NOT NULL DEFAULT 0,
  variance          DECIMAL(12,3) GENERATED ALWAYS AS (counted_qty - expected_qty) STORED,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
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
  quantity        DECIMAL(12,3) NOT NULL,
  status          ENUM('active', 'consumed', 'cancelled') NOT NULL DEFAULT 'active',
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_stock_reservations_warehouse (warehouse_id),
  KEY idx_stock_reservations_order (order_id),
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
  source_warehouse_id CHAR(36)      NOT NULL,
  dest_warehouse_id   CHAR(36)      NOT NULL,
  material_id         CHAR(36)      NULL,
  variant_id          CHAR(36)      NULL,
  quantity            DECIMAL(12,3) NOT NULL,
  status              ENUM('draft', 'in_transit', 'received', 'cancelled')
                      NOT NULL DEFAULT 'draft',
  transferred_at      DATETIME(6)   NULL,
  notes               TEXT          NULL,
  created_at          DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at          DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at          DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_stock_transfers_source (source_warehouse_id),
  KEY idx_stock_transfers_dest (dest_warehouse_id),
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
-- Production & Workshop (MES / GPAO)
-- #############################################################################

CREATE TABLE employees (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id         CHAR(36)     NULL,
  employee_number VARCHAR(40)  NOT NULL,
  last_name       VARCHAR(120) NOT NULL,
  first_name      VARCHAR(120) NULL,
  job_title       VARCHAR(120) NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_employees_number (employee_number),
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
  daily_capacity  DECIMAL(12,2) NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_workstations_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE production_steps (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  code            VARCHAR(40)  NOT NULL,
  name            VARCHAR(150) NOT NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  standard_duration_min INT    NULL,
  description     TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_production_steps_code (code)
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
  UNIQUE KEY uq_production_plans_reference (reference)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE work_orders (
  id              CHAR(36)      NOT NULL DEFAULT (UUID()),
  work_order_number VARCHAR(40) NOT NULL,
  order_id        CHAR(36)      NULL,
  order_item_id   CHAR(36)      NULL,
  product_id      CHAR(36)      NULL,
  variant_id      CHAR(36)      NULL,
  customization_request_id CHAR(36) NULL,
  plan_id         CHAR(36)      NULL,
  quantity        DECIMAL(12,3) NOT NULL DEFAULT 1,
  status          ENUM(
                    'draft', 'planned', 'in_progress', 'on_hold',
                    'completed', 'cancelled', 'rework'
                  ) NOT NULL DEFAULT 'draft',
  priority        TINYINT       NOT NULL DEFAULT 3,
  planned_start_at DATETIME(6)  NULL,
  planned_end_at  DATETIME(6)   NULL,
  actual_start_at DATETIME(6)   NULL,
  actual_end_at   DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_work_orders_number (work_order_number),
  KEY idx_work_orders_order (order_id),
  KEY idx_work_orders_status (status),
  KEY idx_work_orders_plan (plan_id),
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
  KEY idx_production_tracking_work_order (work_order_id),
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
  KEY idx_ws_assignments_workstation (workstation_id),
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
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id   CHAR(36)     NOT NULL,
  step_id         CHAR(36)     NULL,
  employee_id     CHAR(36)     NULL,
  duration_minutes INT         NOT NULL DEFAULT 0,
  started_at      DATETIME(6)  NULL,
  finished_at     DATETIME(6)  NULL,
  notes           TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_operation_times_work_order (work_order_id),
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
  KEY idx_quality_checks_work_order (work_order_id),
  CONSTRAINT fk_quality_checks_work_order
    FOREIGN KEY (work_order_id) REFERENCES work_orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_quality_checks_inspector
    FOREIGN KEY (inspector_id) REFERENCES employees (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE production_reworks (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  work_order_id   CHAR(36)     NOT NULL,
  quality_check_id CHAR(36)    NULL,
  reason          TEXT         NOT NULL,
  status          ENUM('open', 'in_progress', 'completed', 'cancelled')
                  NOT NULL DEFAULT 'open',
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_production_reworks_work_order (work_order_id),
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
  amount_excl_tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_amount      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  amount_incl_tax DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  issued_at       DATETIME(6)   NULL,
  due_at          DATETIME(6)   NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customer_invoices_number (invoice_number),
  KEY idx_customer_invoices_order (order_id),
  CONSTRAINT fk_customer_invoices_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_customer_invoices_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE supplier_invoices (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  invoice_number    VARCHAR(40)   NOT NULL,
  supplier_id       CHAR(36)      NOT NULL,
  supplier_order_id CHAR(36)      NULL,
  status            ENUM('received', 'to_pay', 'paid', 'cancelled')
                    NOT NULL DEFAULT 'received',
  amount_incl_tax   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  currency          CHAR(3)       NOT NULL DEFAULT 'USD',
  invoice_date      DATETIME(6)   NULL,
  due_at            DATETIME(6)   NULL,
  created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at        DATETIME(6)   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_supplier_invoices_number (invoice_number),
  KEY idx_supplier_invoices_supplier (supplier_id),
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
  amount          DECIMAL(12,2) NOT NULL,
  currency        CHAR(3)       NOT NULL DEFAULT 'USD',
  expense_date    DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  supplier_id     CHAR(36)      NULL,
  notes           TEXT          NULL,
  created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)   NULL,
  PRIMARY KEY (id),
  KEY idx_expenses_supplier (supplier_id),
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
  status          ENUM(
                    'open', 'accepted', 'rejected',
                    'returning', 'refunded', 'exchanged', 'closed'
                  ) NOT NULL DEFAULT 'open',
  resolution      TEXT         NULL,
  created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6)  NULL,
  PRIMARY KEY (id),
  KEY idx_return_requests_order (order_id),
  KEY idx_return_requests_user (user_id),
  CONSTRAINT fk_return_requests_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_return_requests_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_return_requests_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- End of Sanaa.co schema
-- =============================================================================
