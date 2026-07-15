# web/ — Next.js (boutique)

Front **boutique client** de Sanaa.co (Next.js App Router).

## Stack

- **Next.js 15** + React 19 + TypeScript
- **Tailwind CSS v4**
- Polices : Syne (titres) + DM Sans (texte)
- Port : `3000`
- Package : `@sanaa/web`

## Design (accueil)

Inspiré d’une manufacture textile professionnelle (header 2 niveaux, hero vert pastel plein cadre, bandeau métiers) :

- `SiteHeader` — barre utilitaire + nav + panier
- `Hero` — carrousel marque / promesse / CTA / visuel
- `CategoryStrip` — accès rapide par secteur

## Scripts

```bash
pnpm dev:web
```

## Variables

| Variable | Défaut | Rôle |
|----------|--------|------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:4000/api` | Base URL de l’API |
