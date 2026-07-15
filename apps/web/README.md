# web/ — Next.js (boutique)

Front **boutique client** de Sanaa.co (Next.js App Router).

## Stack

- **Next.js 15** + React 19 + TypeScript
- Port : `3000`
- Package : `@sanaa/web`

## Rôle

- Catalogue (produits, variantes, catégories, avis)
- Panier, commande et paiement
- Personnalisation (mesures, broderie)
- Suivi de commande / expédition
- Demandes de retour (SAV)

Tout passe par `@sanaa/api` — jamais d’accès direct à MySQL.

## Scripts

```bash
pnpm dev:web
```

## Variables

| Variable | Défaut | Rôle |
|----------|--------|------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:4000/api` | Base URL de l’API |
