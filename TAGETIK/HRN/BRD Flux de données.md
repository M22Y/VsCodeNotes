🔷 Flux de données – Workflow et Vues dans CCH Tagetik
Les données issues de fichiers sources sont intégrées dans un Data Hub, puis exploitées dans CCH Tagetik à travers plusieurs vues analytiques :

Vue 1.1 : pour les balances cumulées (P&L et bilan) et les volumes cumulés.
Vue 1.2 : pour les statistiques mensuelles liées aux revenus et marges.
Vue 2 : pour les données intercompagnies.
Vue 3 : pour les transactions détaillées.
Chaque vue est structurée autour d’un ensemble cohérent de dimensions, permettant une analyse transversale des données financières et opérationnelles.

-----------------------------------------------------------------------------------






🔷 Sources de données (dans le Data Hub)
Vue 1.1 (JDE / DataHub)

Balances de vérification (P&L, bilan)
Statistiques : volumes, CPL, par unité d’affaires, modèle d’affaires, département, produit
Vue 1.2 (JDE / DataHub)

Statistiques mensuelles : volumes, CPL, par unité d’affaires, modèle d’affaires, ligne d’affaires, type de clientèle, représentant, secteur, produit
BV Filiales (TB) (fichier Excel)

Balances de vérification des filiales
Déclarations intercos (saisie manuelle)

Données intercompagnies (IC)
🔷 Table de correspondance – Unité d’affaires
Appliquée à Vue 1.1, Vue 1.2 et BV Filiales
Génère dynamiquement l’unité d’affaires à partir des dimensions :
Scénario, Période, Entité, Compte, Produit, Département / Type de clientèle
Exception : les comptes de type VOLUME contiennent déjà l’unité d’affaires
🔷 Destinations dans CCH Tagetik
Les données sont intégrées dans deux modules principaux :

Financial Workspace (FW)

Pour les soldes financiers (P&L, bilan)
Utilise les dimensions : scénario, période, entité, compte, site, ligne d’affaires, département, modèle d’affaires, unité d’affaires
Analytical Information Hub (AIH)

Pour les statistiques (volumes, CPL, marges)
Dimensions enrichies : produit, secteur, représentant, comparabilité, etc.