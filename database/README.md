# database/

Pôle **données** de Sanaa.co : schéma, migrations, seeds et conventions de modèle.

## Rôle

- Définir les tables et relations de tous les pôles métier
- Versionner les évolutions via migrations
- Fournir des seeds de démonstration / référentiels
- Garantir les conventions communes (soft delete, naming)

L’`api/` est le seul consommateur runtime de cette couche ; `web/` et `admin/` n’y accèdent jamais directement.

## Organisation prévue

```text
database/
├── migrations/     # Évolutions versionnées du schéma
├── seeds/          # Données initiales ou de démo
└── README.md       # Ce fichier
```

(La structure exacte sera alignée sur l’outil de migration choisi.)

## Convention globale

| Règle | Détail |
|-------|--------|
| Soft delete | Colonne `deleted_at` sur **toutes** les tables principales |
| Naming | Tables en `snake_case`, au pluriel |
| Intégrité | Clés étrangères explicites entre pôles liés |
| Audit | Les actions métier sensibles sont journalisées côté API dans `journaux_audit` |

Lecture métier typique : filtrer `WHERE deleted_at IS NULL`.

---

## Tables par pôle

### Vente & Catalogue

`produits`, `variantes_produits`, `categories`, `sous_categories`, `avis_clients`, `paniers`, `commandes`, `lignes_commandes`, `paiements`, `expeditions`

### Production & Atelier (GPAO)

`ordres_fabrication`, `etapes_production`, `suivi_production`, `employes`, `postes_machines`, `plans_production`, `affectations_postes`, `temps_operation`, `controles_qualite`, `productions_reprise`

### Matières & Fournisseurs

`matieres_premieres`, `stock_matiere`, `fournisseurs`, `commandes_fournisseurs`, `lignes_commande_fournisseur`, `nomenclatures`, `receptions_fournisseurs`

> Alias possible : `nomenclatures` ↔ `compositions_produits`.

### Personnalisation & Sur-Mesure

`clients_mesures`, `modeles_patrons`, `demandes_personnalisation`, `fichiers_broderie`

### Logistique & Stocks

`depots`, `inventaires`, `lignes_inventaire`, `reservations_stock`, `transferts_stock`

### Tarifs & Promotions

`regles_promotions`, `regles_promotion_cibles`, `grilles_prix`

### CRM & Devis

`devis`, `lignes_devis`, `interactions_clients`, `segments_clients`

### Financier & Comptable

`factures_clients`, `factures_fournisseurs`, `depenses`

### Attributs dynamiques

`attributs_produits`, `valeurs_attributs`

### Sécurité & Audit

`utilisateurs`, `journaux_audit`

### SAV

`demandes_retour`

---

## Liens entre pôles (exemples)

Ces relations guideront les clés étrangères :

```text
commandes ────────► lignes_commandes ──► produits / variantes
    │
    ├──► paiements, expeditions
    ├──► demandes_personnalisation ──► clients_mesures, fichiers_broderie
    └──► ordres_fabrication ──► etapes / suivi / qualité
              │
              └──► nomenclatures ──► matieres_premieres / stock_matiere

devis ──► (conversion) ──► commandes
commandes_fournisseurs ──► receptions ──► stock_matiere
```

## Suite

1. Choisir le SGBD et l’outil de migration
2. Créer les migrations table par table (ou par pôle)
3. Documenter colonnes et contraintes dans les fichiers de migration / un schéma dédié
