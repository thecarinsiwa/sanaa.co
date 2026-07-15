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

Monorepo découpé en quatre espaces :

| Dossier | Rôle |
|---------|------|
| `web/` | Front boutique (expérience client) |
| `admin/` | Back-office (catalogue, atelier, stocks, CRM, finance) |
| `api/` | API métier (règles métier, accès données) |
| `database/` | Schéma, migrations et seeds |

```text
[ Client ] ──► web/ ──┐
                      ├──► api/ ──► database/
[ Staff ]  ──► admin/ ┘
```

---

## Les pôles métier

### 1. Vente & Catalogue

Gère la **boutique en ligne** : produits et variantes (taille, couleur, etc.), arborescence catégories / sous-catégories, avis clients, paniers, commandes, paiements et expéditions.

C’est le point d’entrée commercial. Une commande validée peut ensuite alimenter l’atelier, les stocks et la facturation.

**Tables :** `produits`, `variantes_produits`, `categories`, `sous_categories`, `avis_clients`, `paniers`, `commandes`, `lignes_commandes`, `paiements`, `expeditions`

---

### 2. Personnalisation & Sur-Mesure

Couvre les produits qui ne sont pas 100 % catalogue : mesures client, modèles / patrons, demandes de personnalisation et fichiers de broderie.

Ce pôle fait le lien entre le **souhait client** et l’**ordre de fabrication** : sans mesures ni fichiers, l’atelier ne peut pas produire correctement.

**Tables :** `clients_mesures`, `modeles_patrons`, `demandes_personnalisation`, `fichiers_broderie`

---

### 3. Production & Atelier (GPAO)

Pilote la **fabrication** : ordres de fabrication, étapes, suivi en temps réel, employés, postes / machines, plans de production, affectations, temps d’opération, contrôles qualité et reprises.

Objectif : savoir **quoi** fabriquer, **où**, **par qui**, **en combien de temps**, et avec quel niveau de **qualité**.

**Tables :** `ordres_fabrication`, `etapes_production`, `suivi_production`, `employes`, `postes_machines`, `plans_production`, `affectations_postes`, `temps_operation`, `controles_qualite`, `productions_reprise`

---

### 4. Matières & Fournisseurs

Gère l’amont industriel : matières premières, stock matière, fournisseurs, commandes fournisseurs, lignes de commande, nomenclatures (composition d’un produit) et réceptions.

Les **nomenclatures** relient un produit (ou une variante) à la liste des matières nécessaires — indispensable pour lancer une production sans rupture.

**Tables :** `matieres_premieres`, `stock_matiere`, `fournisseurs`, `commandes_fournisseurs`, `lignes_commande_fournisseur`, `nomenclatures`, `receptions_fournisseurs`

> Alias possible : `nomenclatures` ↔ `compositions_produits`.

---

### 5. Logistique & Stocks

Gère les **dépôts**, inventaires (et lignes), réservations (stock alloué à une commande / OF) et transferts entre lieux.

Complète le stock matière côté produits finis / semi-finis : savoir où se trouve chaque article et ce qui est déjà réservé.

**Tables :** `depots`, `inventaires`, `lignes_inventaire`, `reservations_stock`, `transferts_stock`

---

### 6. Tarifs & Promotions

Définit comment le prix est calculé : grilles de prix et règles de promotions (avec cibles : produit, catégorie, segment client, etc.).

Évite de coder les prix « en dur » : le catalogue et le panier s’appuient sur ces règles.

**Tables :** `regles_promotions`, `regles_promotion_cibles`, `grilles_prix`

---

### 7. CRM & Devis

Suit la **relation client** hors ou avant la commande : devis et lignes de devis, interactions, segments clients.

Utile pour le B2B, les commandes sur-mesure complexes, ou le suivi commercial avant conversion en commande.

**Tables :** `devis`, `lignes_devis`, `interactions_clients`, `segments_clients`

---

### 8. Financier & Comptable

Trace les flux d’argent liés à l’activité : factures clients, factures fournisseurs et dépenses.

Complète paiements (côté commande) et commandes fournisseurs (côté achats) par une vue comptable / administrative.

**Tables :** `factures_clients`, `factures_fournisseurs`, `depenses`

---

### 9. Service Après-Vente (SAV)

Gère les **demandes de retour** après livraison : litiges, échanges, remboursements, retours atelier.

**Tables :** `demandes_retour`

---

### 10. Technique — attributs dynamiques

Permet d’enrichir les produits sans rigidifier le schéma : attributs libres et valeurs associées (ex. type de tissu, motif, finition).

**Tables :** `attributs_produits`, `valeurs_attributs`

---

### 11. Sécurité & Audit

Gère les comptes **utilisateurs** (accès admin / atelier) et les **journaux d’audit** (qui a fait quoi, quand).

Indispensable pour la traçabilité des actions sensibles (prix, stocks, validation qualité, facturation).

**Tables :** `utilisateurs`, `journaux_audit`

---

## Vue d’ensemble des tables

| Pôle | Tables |
|------|--------|
| Vente & Catalogue | `produits`, `variantes_produits`, `categories`, `sous_categories`, `avis_clients`, `paniers`, `commandes`, `lignes_commandes`, `paiements`, `expeditions` |
| Production & Atelier | `ordres_fabrication`, `etapes_production`, `suivi_production`, `employes`, `postes_machines`, `plans_production`, `affectations_postes`, `temps_operation`, `controles_qualite`, `productions_reprise` |
| Matières & Fournisseurs | `matieres_premieres`, `stock_matiere`, `fournisseurs`, `commandes_fournisseurs`, `lignes_commande_fournisseur`, `nomenclatures`, `receptions_fournisseurs` |
| Personnalisation | `clients_mesures`, `modeles_patrons`, `demandes_personnalisation`, `fichiers_broderie` |
| Logistique & Stocks | `depots`, `inventaires`, `lignes_inventaire`, `reservations_stock`, `transferts_stock` |
| Tarifs & Promotions | `regles_promotions`, `regles_promotion_cibles`, `grilles_prix` |
| CRM & Devis | `devis`, `lignes_devis`, `interactions_clients`, `segments_clients` |
| Financier | `factures_clients`, `factures_fournisseurs`, `depenses` |
| Attributs dynamiques | `attributs_produits`, `valeurs_attributs` |
| Sécurité & Audit | `utilisateurs`, `journaux_audit` |
| SAV | `demandes_retour` |

---

## Conventions

- **Soft delete** : colonne `deleted_at` sur toutes les tables principales. Une entité « supprimée » reste en base tant que `deleted_at` est renseigné ; les requêtes métier filtrent en général sur `deleted_at IS NULL`.
- Noms de tables en **snake_case**, au pluriel.
- Colonnes, clés étrangères et migrations : à définir dans `database/`.

---

## Licence

MIT — voir [LICENSE](LICENSE).
