# Sanaa.co

**Sanaa.co** est une plateforme métier qui relie la **vente en ligne**, la **personnalisation sur-mesure** et la **production atelier** (GPAO) dans un même système.

Elle permet de vendre des produits textiles (catalogue, variantes, promotions), de collecter les mesures et fichiers de broderie d’un client, de planifier et fabriquer en atelier, de gérer les matières et fournisseurs, puis d’assurer la livraison, la facturation et le SAV — le tout avec une traçabilité complète.

---

## Pour qui ?

| Rôle | Ce que le système apporte |
|------|---------------------------|
| **Client final** | Boutique, panier, paiement, personnalisation, suivi de commande, retours |
| **Commercial / CRM** | Devis, segments clients, interactions, historique |
| **Atelier / production** | Ordres de fabrication, postes, planning, qualité, reprises |
| **Achats / stocks** | Fournisseurs, matières, nomenclatures, dépôts, inventaires |
| **Admin / finance** | Tarifs, factures, dépenses, utilisateurs, journaux d’audit |

---

## Comment fonctionne le système ?

Le parcours type d’une commande (notamment sur-mesure) :

```text
Catalogue / devis
        ↓
Panier → paiement
        ↓
Personnalisation (mesures, patron, broderie)
        ↓
Ordre de fabrication (atelier)
        ↓
Consommation matières + contrôle qualité
        ↓
Expédition / facturation
        ↓
SAV éventuel (retour)
```

En boutique standard, l’étape personnalisation peut être courte ou absente ; en sur-mesure, elle alimente directement la production.

Les **pôles** ci-dessous sont les briques métier. Ils ne sont pas isolés : une commande client déclenche souvent réservation de stock, ordre de fabrication, consommation de matières et facturation.

---

## Architecture logicielle

Monorepo **pnpm** avec NestJS (API) et Next.js (fronts) :

| Dossier | Package | Stack | Port |
|---------|---------|-------|------|
| `apps/web` | `@sanaa/web` | Next.js 15 — boutique | `3000` |
| `apps/admin` | `@sanaa/admin` | Next.js 15 — back-office | `3001` |
| `apps/api` | `@sanaa/api` | NestJS — API métier | `4000` |
| `packages/tsconfig` | `@sanaa/tsconfig` | Configs TypeScript partagées | — |
| `database/` | — | Schéma MySQL (`schema.sql`) | — |

```text
[ Client ] ──► apps/web    ──┐
                             ├──► apps/api ──► database/
[ Staff ]  ──► apps/admin  ──┘
```

### Démarrage rapide

```bash
pnpm install
pnpm dev          # API + web + admin en parallèle
# ou séparément :
pnpm dev:api      # http://localhost:4000/api
pnpm dev:web      # http://localhost:3000
pnpm dev:admin    # http://localhost:3001
```

Swagger (API) : [http://localhost:4000/api/docs](http://localhost:4000/api/docs)

Prérequis : **Node ≥ 20**, **pnpm**, **MySQL 8.0.13+** (voir `database/`).

---

## Les pôles métier

### 1. Vente & Catalogue

Gère la **boutique en ligne** : produits et variantes (taille, couleur, etc.), arborescence catégories / sous-catégories, avis clients, paniers, commandes, paiements et expéditions.

C’est le point d’entrée commercial. Une commande validée peut ensuite alimenter l’atelier, les stocks et la facturation.

**Tables :** `products`, `product_variants`, `categories`, `subcategories`, `customer_reviews`, `carts`, `orders`, `order_items`, `payments`, `shipments`

---

### 2. Personnalisation & Sur-Mesure

Couvre les produits qui ne sont pas 100 % catalogue : mesures client, modèles / patrons, demandes de personnalisation et fichiers de broderie.

Ce pôle fait le lien entre le **souhait client** et l’**ordre de fabrication** : sans mesures ni fichiers, l’atelier ne peut pas produire correctement.

**Tables :** `customer_measurements`, `pattern_models`, `customization_requests`, `embroidery_files`

---

### 3. Production & Atelier (GPAO)

Pilote la **fabrication** : ordres de fabrication, étapes, suivi en temps réel, employés, postes / machines, plans de production, affectations, temps d’opération, contrôles qualité et reprises.

Objectif : savoir **quoi** fabriquer, **où**, **par qui**, **en combien de temps**, et avec quel niveau de **qualité**.

**Tables :** `work_orders`, `production_steps`, `production_tracking`, `employees`, `workstations`, `production_plans`, `workstation_assignments`, `operation_times`, `quality_checks`, `production_reworks`

---

### 4. Matières & Fournisseurs

Gère l’amont industriel : matières premières, stock matière, fournisseurs, commandes fournisseurs, lignes de commande, nomenclatures (composition d’un produit) et réceptions.

Les **bills of materials** relient un produit (ou une variante) à la liste des matières nécessaires — indispensable pour lancer une production sans rupture.

**Tables :** `raw_materials`, `material_stock`, `suppliers`, `supplier_orders`, `supplier_order_items`, `bills_of_materials`, `supplier_receipts`

---

### 5. Logistique & Stocks

Gère les **dépôts**, inventaires (et lignes), réservations (stock alloué à une commande / OF) et transferts entre lieux.

Complète le stock matière côté produits finis / semi-finis : savoir où se trouve chaque article et ce qui est déjà réservé.

**Tables :** `warehouses`, `inventory_counts`, `inventory_count_items`, `stock_reservations`, `stock_transfers`

---

### 6. Tarifs & Promotions

Définit comment le prix est calculé : grilles de prix et règles de promotions (avec cibles : produit, catégorie, segment client, etc.).

Évite de coder les prix « en dur » : le catalogue et le panier s’appuient sur ces règles.

**Tables :** `promotion_rules`, `promotion_rule_targets`, `price_lists`

---

### 7. CRM & Devis

Suit la **relation client** hors ou avant la commande : devis et lignes de devis, interactions, segments clients.

Utile pour le B2B, les commandes sur-mesure complexes, ou le suivi commercial avant conversion en commande.

**Tables :** `quotes`, `quote_items`, `customer_interactions`, `customer_segments`

---

### 8. Financier & Comptable

Trace les flux d’argent liés à l’activité : factures clients, factures fournisseurs et dépenses.

Complète paiements (côté commande) et commandes fournisseurs (côté achats) par une vue comptable / administrative.

**Tables :** `customer_invoices`, `supplier_invoices`, `expenses`

---

### 9. Service Après-Vente (SAV)

Gère les **demandes de retour** après livraison : litiges, échanges, remboursements, retours atelier.

**Tables :** `return_requests`

---

### 10. Technique — attributs dynamiques

Permet d’enrichir les produits sans rigidifier le schéma : attributs libres et valeurs associées (ex. type de tissu, motif, finition).

**Tables :** `product_attributes`, `attribute_values`

---

### 11. Sécurité & Audit

Gère les comptes **utilisateurs** (accès admin / atelier) et les **journaux d’audit** (qui a fait quoi, quand).

Indispensable pour la traçabilité des actions sensibles (prix, stocks, validation qualité, facturation).

**Tables :** `users`, `audit_logs`

---

## Vue d’ensemble des tables

Schéma MySQL en anglais (`database/schema.sql`).

| Pôle | Tables |
|------|--------|
| Vente & Catalogue | `products`, `product_variants`, `product_media`, `categories`, `subcategories`, `customer_reviews`, `carts`, `cart_items`, `orders`, `order_items`, `order_status_histories`, `payments`, `shipments` |
| Production & Atelier | `work_orders`, `work_order_status_histories`, `production_steps`, `production_tracking`, `employees`, `workstations`, `production_plans`, `workstation_assignments`, `operation_times`, `quality_checks`, `production_reworks` |
| Matières & Fournisseurs | `raw_materials`, `material_stock`, `suppliers`, `supplier_orders`, `supplier_order_items`, `bills_of_materials`, `supplier_receipts`, `supplier_receipt_items` |
| Personnalisation | `customer_measurements`, `pattern_models`, `customization_requests`, `embroidery_files` |
| Logistique & Stocks | `warehouses`, `finished_goods_stock`, `inventory_counts`, `inventory_count_items`, `stock_reservations`, `stock_transfers` |
| Tarifs & Promotions | `promotion_rules`, `promotion_rule_targets`, `promotion_redemptions`, `price_lists` |
| CRM & Devis | `quotes`, `quote_items`, `customer_interactions`, `customer_segments`, `customer_segment_members` |
| Financier | `customer_invoices`, `customer_invoice_items`, `supplier_invoices`, `expenses` |
| Attributs dynamiques | `product_attributes`, `attribute_values` |
| Sécurité & Audit | `users`, `audit_logs`, `addresses` |
| SAV | `return_requests` |

---

## Conventions

- **Schéma en anglais** : tables et colonnes en `snake_case` anglais.
- **Primary key** : `id` UUID (`CHAR(36)`).
- **Soft delete** : `deleted_at` sur les tables principales ; les lectures métier filtrent sur `deleted_at IS NULL`.
- Détail du schéma : [`database/schema.sql`](database/schema.sql).

---

## Licence

MIT — voir [LICENSE](LICENSE).
