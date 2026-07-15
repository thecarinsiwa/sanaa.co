# api/ — NestJS

Backend métier de Sanaa.co : **point unique** entre les interfaces Next.js (`apps/web`, `apps/admin`) et les données (`database/`).

## Stack

- **NestJS** (TypeScript)
- Port par défaut : `4000`
- Préfixe global : `/api`
- Health check : `GET /api/health`
- **Swagger UI** : [`http://localhost:4000/api/docs`](http://localhost:4000/api/docs)
- OpenAPI JSON : `GET /api/docs-json`
- **Swagger UI** : [http://localhost:4000/api/docs](http://localhost:4000/api/docs)
- OpenAPI JSON : [http://localhost:4000/api/docs-json](http://localhost:4000/api/docs-json)

## Rôle

- Exposer les endpoints HTTP pour la boutique et le back-office
- Appliquer les règles métier (prix, stocks, OF, qualité, etc.)
- Authentifier / autoriser les utilisateurs
- Orchestrer les flux transverses (commande → personnalisation → production → facturation)
- Écrire dans `audit_logs` pour les actions sensibles

## Qui l’appelle ?

| Client | Besoin |
|--------|--------|
| `@sanaa/web` | Catalogue, panier, paiement, personnalisation, suivi, retours |
| `@sanaa/admin` | CRUD métier, atelier, stocks, CRM, finance, utilisateurs |

```text
apps/web   ──┐
             ├──► apps/api ──► database/
apps/admin ──┘
```

## Scripts

```bash
# depuis la racine
pnpm dev:api

# ou depuis ce dossier
pnpm dev
```

## Variables d’environnement

| Variable | Défaut | Rôle |
|----------|--------|------|
| `PORT` | `4000` | Port HTTP |
| `WEB_ORIGIN` | `http://localhost:3000` | CORS boutique |
| `ADMIN_ORIGIN` | `http://localhost:3001` | CORS admin |

## Principes

- Une seule source de vérité métier (pas de duplication dans les fronts)
- Soft delete (`deleted_at`) sur les lectures / écritures
- Schéma MySQL dans `database/schema.sql`
