# admin/ — Next.js (back-office)

Back-office Sanaa.co pour le personnel (Next.js App Router).

## Stack

- **Next.js 15** + React 19 + TypeScript
- Port : `3001`
- Package : `@sanaa/admin`

## Rôle

- Catalogue, tarifs, promotions
- Commandes, devis, CRM
- Atelier (OF, planning, qualité)
- Matières, fournisseurs, stocks
- Facturation, dépenses
- Utilisateurs & `audit_logs`

Comme `@sanaa/web`, s’appuie exclusivement sur `@sanaa/api`.

## Scripts

```bash
pnpm dev:admin
```

## Variables

| Variable | Défaut | Rôle |
|----------|--------|------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:4000/api` | Base URL de l’API |
