# ShopFlux — Application E-Commerce Flutter avec Riverpod

Application mobile e-commerce moderne et réactive développée avec **Flutter** et **Riverpod** comme solution de gestion d'état centralisée.

---

## 🌟 Fonctionnalités Principales

1. **Catalogue de Produits (Liste & Détail)** :
   - Affichage en grille adaptative avec badges de réduction, notes étoiles et statut de stock.
   - Page de détail complète avec galerie d'images interactive, sélection de variantes (couleur, taille), sélecteur de quantité et fiche technique.
   - Animations Hero fluides entre la liste et le détail.

2. **Panier d'Achat Réactif** :
   - Ajout au panier avec gestion automatique des quantités et variantes.
   - Modification de la quantité (+ / -), suppression unitaire ou par glissement (*Swipe-to-Dismiss*).
   - Calcul automatique du sous-total, de la TVA (20%), et de la livraison offerte dès 100 €.
   - Système de code promo instantané (`RIVERPOD20` pour -20%, `WELCOME10` pour -10 €).
   - Processus de commande avec confirmation animée et mise à jour de l'historique utilisateur.

3. **Système de Favoris Persistant** :
   - Ajout et retrait instantané en un clic.
   - **Persistance locale sur le terminal** via `SharedPreferences`.
   - Bouton d'action rapide *Tout ajouter au panier*.

4. **Filtrage et Tri Avancés** :
   - Recherche en temps réel (titre, catégorie, description).
   - Sélecteur de catégories par filtres horizontaux.
   - Feuille de filtres modale (*Bottom Sheet*) : tri par prix, popularité, note, ordre alphabétique, slider de fourchette de prix, filtres *En stock* et *En promotion*.

5. **Écran Profil & Outils Développeur** :
   - Informations utilisateur, solde du portefeuille et points de fidélité.
   - Historique complet des commandes avec statuts interactifs.
   - **Bascule Thème Sombre / Thème Clair** en temps réel.
   - **Simulateur d'erreur serveur** pour tester le comportement de `AsyncValue.error` et le bouton de rechargement (*Retry*).

6. **Bonus & Animations** :
   - Animation de rebond (*bounce/pulse*) sur le badge du panier lors de l'ajout de produit.
   - Snackbars animés contextuels.

---

## 🏗️ Architecture & Gestion d'État avec Riverpod

L'application suit une architecture propre en 4 couches distinctes (*Clean Layered Architecture*) :

```
lib/
├── main.dart                          # Point d'entrée & ProviderScope avec overrides SharedPreferences
└── src/
    ├── models/                        # Modèles de données immuables
    │   ├── product.dart               # Modèle Produit
    │   ├── cart_item.dart             # Article du panier
    │   ├── filter_state.dart          # État des filtres et options de tri
    │   └── user_profile.dart          # Profil utilisateur et commandes
    ├── data/                          # Couche données & persistance
    │   ├── mock_products.dart         # Données simulées riches
    │   ├── favorites_storage.dart     # Persistance locale (SharedPreferences)
    │   └── product_repository.dart    # Repository de données asynchrones
    ├── providers/                     # Providers Riverpod
    │   └── providers.dart             # Providers (FutureProvider, StateNotifierProvider, etc.)
    └── presentation/                  # Couche interface utilisateur (UI)
        ├── theme/app_theme.dart       # Thèmes Material 3 (Clair / Sombre)
        ├── widgets/                   # Composants UI réutilisables
        └── screens/                   # Écrans principaux de l'application
```

### Providers Riverpod Déployés :

1. `productsFutureProvider` : `FutureProvider` pour la récupération asynchrone des produits.
2. `categoriesProvider` : `FutureProvider` pour l'extraction dynamique des catégories.
3. `filterNotifierProvider` : `StateNotifierProvider` gérant les critères de filtre, recherche et tri.
4. `filteredProductsProvider` : `Provider` dérivé appliquant les filtres et le tri de manière réactive sur les `AsyncValue<List<Product>>`.
5. `favoritesNotifierProvider` : `StateNotifierProvider` gérant les IDs favoris avec écriture automatique dans `SharedPreferences`.
6. `favoriteProductsProvider` : `Provider` dérivé reliant le catalogue et les favoris.
7. `cartNotifierProvider` : `StateNotifierProvider` gérant la collection d'articles du panier.
8. `cartSummaryProvider` : `Provider` calculant les totaux, taxes, remises et frais de port.
9. `themeModeProvider` : `StateNotifierProvider` pour le basculement dynamique du thème.
10. `userProfileProvider` : `StateNotifierProvider` pour les données du compte et les commandes.
11. `simulateErrorProvider` : `StateProvider` pour simuler des erreurs réseau et valider la résilience de l'UI.

---

## 🚀 Installation & Exécution

1. **Cloner ou ouvrir le dossier du projet** :
   ```bash
   cd /home/sharone/ecommerce_riverpod
   ```

2. **Récupérer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Lancer l'analyse statique et les tests unitaires / widgets** :
   ```bash
   flutter test
   flutter analyze
   ```

4. **Lancer l'application** :
   ```bash
   flutter run
   ```

---

## 🧪 Tests Unitaires et Widgets

Des tests complets sont fournis dans [`test/widget_test.dart`](file:///home/sharone/ecommerce_riverpod/test/widget_test.dart) pour valider :
- L'ajout d'articles, la mise à jour des quantités, l'application de code promo et le calcul du panier.
- Le fonctionnement des filtres et du tri.
- Le rendu complet des composants et de la barre de navigation.
