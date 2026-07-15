# web/ — Next.js (boutique)

Front **boutique client** de Sanaa.co (Next.js App Router).

## Stack

- **Next.js 15** + React 19 + TypeScript
- **Tailwind CSS v4**
- Polices : Syne (titres) + DM Sans (texte)
- Port : `3000`
- Package : `@sanaa/web`

## Design (accueil)

Inspiré d’une manufacture textile professionnelle (header 2 niveaux, hero vert pastel plein cadre, bandeau métiers) — **routes et libellés en anglais** :

| Route | Page |
|-------|------|
| `/` | Home |
| `/about` | About us |
| `/contact` | Contact |
| `/search` | Search |
| `/account` | Sign in |
| `/cart` | Cart |
| `/collections/health` | Health — Wellness |
| `/collections/safety` | Safety |
| `/collections/hospitality` | Hotel and catering |
| `/collections/industry` | Industry — crafts |

## Scripts

```bash
pnpm dev:web
```

## Variables

| Variable | Défaut | Rôle |
|----------|--------|------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:4000/api` | Base URL de l’API |
