# admin/

Back-office de Sanaa.co : interface réservée au **personnel** (commercial, atelier, stocks, finance, admin).

## Rôle

Piloter l’activité au quotidien :

- Catalogue, tarifs, promotions
- Commandes clients, devis, CRM
- Atelier (OF, planning, postes, qualité)
- Matières, fournisseurs, stocks et inventaires
- Facturation, dépenses
- Utilisateurs et consultation des journaux d’audit

Comme `web/`, `admin/` s’appuie exclusivement sur l’`api/`.

## Public cible

| Profil | Usages typiques |
|--------|-----------------|
| Commercial / CRM | Devis, clients, segments, interactions |
| Production | Ordres de fabrication, affectations, suivi, contrôles |
| Achats / stock | Fournisseurs, matières, dépôts, inventaires, transferts |
| Finance | Factures clients / fournisseurs, dépenses |
| Admin système | Utilisateurs, droits, audit |

## Modules prévus

| Module | Contenu |
|--------|---------|
| Catalogue | Produits, variantes, catégories, attributs |
| Ventes | Commandes, paiements, expéditions |
| Personnalisation | Demandes, mesures, patrons, fichiers broderie |
| GPAO | OF, étapes, planning, postes, temps, reprises |
| Achats | Fournisseurs, commandes, réceptions, nomenclatures |
| Stocks | Dépôts, inventaires, réservations, transferts |
| Tarifs | Grilles de prix, règles de promotions |
| CRM | Devis, segments, interactions |
| Finance | Factures, dépenses |
| SAV | Demandes de retour |
| Sécurité | Utilisateurs, journaux d’audit |

## Relation avec le reste du monorepo

```text
Staff → admin/ → api/ → database/
```

- Couvre **tous les pôles métier** (vue interne)
- Droits d’accès gérés via `users` (et futurs rôles / permissions)
- Les actions sensibles doivent être traçables dans `audit_logs` (côté API)

## Convention

Documenter ici la stack front admin dès qu’elle sera choisie (elle peut différer de `web/`).
