# web/

Front **boutique client** de Sanaa.co : l’interface publique utilisée par les clients finaux.

## Rôle

- Présenter le catalogue (produits, variantes, catégories, avis)
- Gérer panier, commande et paiement
- Collecter la personnalisation (mesures, broderie) quand le produit est sur-mesure
- Afficher le suivi de commande / expédition
- Permettre les demandes de retour (SAV)

Ce dossier ne parle jamais directement à la base : tout passe par l’`api/`.

## Public cible

Clients finaux (B2C) et, éventuellement, parcours simplifiés pour clients commerciaux.

## Fonctionnalités prévues

| Domaine | Exemples d’écrans |
|---------|-------------------|
| Catalogue | Accueil, listing, fiche produit, recherche |
| Achat | Panier, checkout, confirmation de paiement |
| Personnalisation | Saisie mesures, upload fichier broderie |
| Compte | Historique commandes, devis, retours |
| Suivi | Statut commande / expédition |

## Pôles métier couverts

Principalement : **Vente & Catalogue**, **Personnalisation**, **Tarifs & Promotions**, **SAV** (côté client).  
Lecture partielle : CRM (devis) et suivi d’expédition.

## Relation avec le reste du monorepo

```text
Client → web/ → api/ → database/
```

- Consomme les endpoints exposés par `api/`
- Ne contient pas de logique métier lourde (prix, stocks, GPAO) : celle-ci reste côté API
- Le personnel interne utilise `admin/`, pas cette interface

## Convention

Documenter ici la stack front (framework, bundler, design system) dès qu’elle sera choisie.
