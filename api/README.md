# api/

API métier de Sanaa.co : **point unique** entre les interfaces (`web/`, `admin/`) et les données (`database/`).

## Rôle

- Exposer les endpoints HTTP pour la boutique et le back-office
- Appliquer les **règles métier** (prix, stocks, lancement OF, qualité, etc.)
- Authentifier / autoriser les utilisateurs
- Orchestrer les flux transverses (commande → personnalisation → production → facturation)
- Écrire dans les journaux d’audit pour les actions sensibles

Aucune UI ici : uniquement services, contrôleurs / routes, et accès données.

## Qui l’appelle ?

| Client | Besoin |
|--------|--------|
| `web/` | Catalogue, panier, paiement, personnalisation, suivi, retours |
| `admin/` | CRUD métier, atelier, stocks, CRM, finance, utilisateurs |

```text
web/ ──┐
       ├──► api/ ──► database/
admin/ ┘
```

## Domaines API (par pôle)

| Domaine | Exemples de responsabilités |
|---------|------------------------------|
| Catalogue & vente | Produits, paniers, commandes, paiements, expéditions |
| Personnalisation | Mesures, patrons, demandes, fichiers broderie |
| GPAO | OF, étapes, affectations, temps, contrôles, reprises |
| Achats & matières | Fournisseurs, commandes, réceptions, nomenclatures |
| Stocks | Dépôts, inventaires, réservations, transferts |
| Tarifs | Calcul prix, promotions, grilles |
| CRM | Devis, segments, interactions |
| Finance | Factures, dépenses |
| SAV | Demandes de retour |
| Auth & audit | Users, sessions, `audit_logs` |

## Principes

- **Une seule source de vérité métier** : pas de duplication des règles critiques dans `web/` ou `admin/`
- Respect du **soft delete** (`deleted_at`) sur les lectures / écritures
- Transactions pour les flux multi-tables (ex. order + payment + stock reservation)
- Séparation claire routes publiques (boutique) / routes authentifiées (admin & compte client)

## Convention

Documenter ici la stack (runtime, framework, ORM) et le mode d’auth dès qu’ils seront choisis.  
Les migrations et le schéma vivent dans `database/` ; l’API les consomme, elle ne les redéfinit pas.
