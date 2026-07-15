# api/ — NestJS

Backend métier de Sanaa.co : **point unique** entre les interfaces Next.js (`apps/web`, `apps/admin`) et MySQL (`database/`).

## Stack

- **NestJS** + **TypeORM** + **MySQL**
- Validation : `class-validator` / `class-transformer`
- Docs : Swagger UI
- Port : `4000` — préfixe `/api`

## Endpoints

| Ressource | Base path |
|-----------|-----------|
| Health | `GET /api/health` |
| Users | `/api/users` |
| Addresses | `/api/addresses` |
| Categories | `/api/categories` |
| Subcategories | `/api/subcategories` |
| Products | `/api/products` |
| Product variants | `/api/product-variants` |
| Carts | `/api/carts` |
| Cart items | `/api/cart-items` |
| Orders | `/api/orders` |
| Order items | `/api/order-items` |
| Payments | `/api/payments` |
| Shipments | `/api/shipments` |
| Quotes | `/api/quotes` |
| Suppliers | `/api/suppliers` |
| Raw materials | `/api/raw-materials` |
| Warehouses | `/api/warehouses` |

Chaque ressource expose le CRUD standard :

- `GET /` — liste paginée (`?page=&limit=&search=`)
- `GET /:id` — détail
- `POST /` — création
- `PATCH /:id` — mise à jour
- `DELETE /:id` — **soft delete** (`deleted_at`)

Swagger : [http://localhost:4000/api/docs](http://localhost:4000/api/docs)

## Prérequis base de données

1. MySQL 8.0.13+
2. Charger le schéma :

```bash
mysql -u root -p < database/schema.sql
```

3. Copier l’env API :

```bash
cp apps/api/.env.example apps/api/.env
# éditer DB_HOST, DB_USER, DB_PASSWORD, DB_NAME
```

## Scripts

```bash
pnpm dev:api
```

## Architecture

```text
src/
  common/          # BaseEntity, CrudService, pagination
  database/        # TypeORM config
  modules/*        # CRUD par ressource
  health/
```

`synchronize` est **désactivé** : le schéma source de vérité est `database/schema.sql`.
