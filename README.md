# Flutter E-Commerce Application with Riverpod

A high-performance, modular, and reactive Flutter e-commerce application developed using **Riverpod** as the state management solution.

---

## 📋 Project Overview & Features

This project implements all required and bonus features specified in the requirements:

1. **Product Catalog (List + Detail Views)**:
   - Responsive product grid with discount badges, star ratings, review counters, and real-time stock indicators.
   - Dedicated Product Detail screen with interactive image gallery, color/size variant selection, quantity steppers, and specifications.
   - Smooth `Hero` animations transitioning between the catalog and product detail pages.

2. **Shopping Cart (Add, Remove, Quantity)**:
   - Add items with variant selection (color, size) and custom quantity.
   - Update quantity (`+` / `-`), remove individual items, or swipe-to-dismiss items.
   - Dynamic real-time calculation of subtotal, VAT (20%), free shipping threshold (> 100 €), and promo code discounts (`RIVERPOD20` for -20%, `WELCOME10` for -10 €).
   - Checkout flow with animated confirmation modal and order history recording.

3. **Favorites System with Local Persistence**:
   - One-tap toggle for favoriting products across cards and detail screens.
   - **Local persistence on device** using `SharedPreferences` (data survives app restarts).
   - Instant "Add all favorites to cart" shortcut.

4. **Product Filtering and Sorting**:
   - Real-time instant search bar matching title, category, and description.
   - Horizontal category filter chips.
   - Modal Filter Bottom Sheet offering:
     - Sorting: Popular/Featured, Price Low-to-High, Price High-to-Low, Highest Rated, Alphabetical (A-Z).
     - Price range slider ($0 - $1000).
     - "In Stock only" and "On Sale only" toggles.

5. **User Profile Screen (Mock)**:
   - Complete user account details, wallet balance, and loyalty points.
   - Interactive order history tracking past purchases and statuses.
   - Dark Mode / Light Mode real-time theme switcher.
   - Developer server-error simulator to test `AsyncValue.error` and UI retry mechanism.

6. **Bonus (Cart Add Animations)**:
   - Animated scale bounce badge (`AnimatedCartBadge`) on cart additions.
   - Contextual floating Snackbars confirming cart actions.

---

## 🏗️ Architecture & Layered Structure

The project strictly separates business logic from widgets following Clean Layered Architecture:

```
lib/
├── main.dart                          # App entry point, ProviderScope initialization & SharedPreferences override
├── models/                            # Immutable Domain Data Models
│   ├── product.dart                   # Product model (with JSON serialization, copyWith, equality)
│   ├── cart_item.dart                 # CartItem model with quantity, variants and price calculations
│   ├── filter_state.dart              # FilterState and ProductSortOption enum
│   └── user_profile.dart              # UserProfile and OrderSummary models
├── repositories/                      # Data Access & Repository Layer
│   ├── product_repository.dart        # IProductRepository and MockProductRepository (JSON/Async)
│   └── mock_products.dart             # Rich curated catalog mock dataset
├── services/                          # Device Services & Persistence
│   └── favorites_storage.dart         # SharedPreferences local storage wrapper for favorites
├── providers/                         # Riverpod State Management Providers
│   ├── product_provider.dart          # Product catalog & category providers
│   ├── cart_provider.dart             # Shopping cart StateNotifier & summary providers
│   ├── favorites_provider.dart        # Favorites StateNotifier & persistent storage provider
│   ├── filter_provider.dart           # Filter & sorting StateNotifier & derived filtered products
│   ├── theme_provider.dart            # ThemeMode StateNotifier provider (Dark/Light mode)
│   ├── user_provider.dart             # User profile and order history StateNotifier provider
│   └── providers.dart                 # Unified barrel export of all providers and notifiers
├── screens/                           # Presentation Layer - UI Screens
│   ├── home_catalog_screen.dart       # Main product catalog with search and category filters
│   ├── product_detail_screen.dart     # Product detail screen with gallery and variant selector
│   ├── cart_screen.dart               # Shopping cart screen with promo codes & checkout
│   ├── favorites_screen.dart          # Wishlist / Favorites screen
│   ├── profile_screen.dart            # User profile and developer tools screen
│   └── main_navigation_screen.dart    # Bottom Navigation bar shell with badge counts
├── widgets/                           # Reusable UI Components
│   ├── async_value_widget.dart        # Generic widget handling AsyncValue (Loading, Error, Data)
│   ├── product_card.dart              # Product card widget with discount and favorite buttons
│   ├── filter_bottom_sheet.dart       # Filter and sorting modal bottom sheet
│   └── animated_cart_badge.dart       # Animated bouncing cart badge widget
└── theme/                             # Theming Layer
    └── app_theme.dart                 # Material 3 Light & Dark themes
```

---

## ⚙️ Riverpod State Management & Providers Breakdown

The application exclusively uses **Riverpod** for state management, deploying **12 distinct providers**:

| Provider Name | Riverpod Type | State Managed | Description |
| :--- | :--- | :--- | :--- |
| `productsFutureProvider` / `productsProvider` | `FutureProvider.autoDispose<List<Product>>` | `AsyncValue<List<Product>>` | Asynchronously fetches products with latency and error simulation support. |
| `productDetailProvider` | `FutureProvider.family.autoDispose<Product?, String>` | `AsyncValue<Product?>` | Family provider retrieving a specific product by its ID. |
| `categoriesProvider` | `FutureProvider.autoDispose<List<String>>` | `AsyncValue<List<String>>` | Extracts all distinct product categories dynamically. |
| `cartNotifierProvider` / `cartProvider` | `StateNotifierProvider<CartNotifier, List<CartItem>>` | `List<CartItem>` | Manages cart state: adding, updating quantities, incrementing, decrementing, and removing items. |
| `cartSummaryProvider` / `cartTotalProvider` | `Provider<CartSummary>` | `CartSummary` | Computes subtotal, 20% VAT, free shipping rules, promo discounts, and grand total. |
| `favoritesNotifierProvider` / `favoritesProvider` | `StateNotifierProvider<FavoritesNotifier, Set<String>>` | `Set<String>` | Manages favorited product IDs and automatically persists changes to `SharedPreferences`. |
| `favoriteProductsProvider` | `Provider.autoDispose<AsyncValue<List<Product>>>` | `AsyncValue<List<Product>>` | Derived provider mapping active favorite IDs to full `Product` objects. |
| `filterNotifierProvider` / `filterProvider` | `StateNotifierProvider<FilterNotifier, FilterState>` | `FilterState` | Manages query string, selected category, price range, stock flags, and sorting criteria. |
| `filteredProductsProvider` | `Provider.autoDispose<AsyncValue<List<Product>>>` | `AsyncValue<List<Product>>` | Derived provider reactively filtering and sorting products based on `FilterState`. |
| `themeModeProvider` / `themeProvider` | `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` | `ThemeMode` | Controls dynamic Light Mode / Dark Mode switching across the app. |
| `userProfileProvider` / `userProvider` | `StateNotifierProvider<UserProfileNotifier, UserProfile>` | `UserProfile` | Manages user profile information, loyalty points, and purchase history. |
| `simulateErrorProvider` | `StateProvider<bool>` | `bool` | Toggles simulated network failure to demonstrate UI error handling and retry mechanisms. |

---

## 🛡️ Handling Loading & Error States with `AsyncValue`

All asynchronous data operations are managed using Riverpod's `AsyncValue`:

- **Loading State**: Displays customizable loading indicators (`CircularProgressIndicator` / `LinearProgressIndicator`).
- **Error State**: Displays friendly error messages with an interactive **"Réessayer" (Retry)** button that invalidates the provider (`ref.invalidate(productsFutureProvider)`).
- **Data State**: Renders content dynamically with support for empty list states and pull-to-refresh.

---

## 🧪 Automated Unit & Widget Tests

Comprehensive test coverage is provided with **100% passing tests**:

```bash
flutter test
```

### Test Suites:
- `test/models_test.dart`: Validates JSON serialization, `copyWith`, getters, and value equality on models.
- `test/cart_test.dart`: Validates cart operations (add, remove, quantity update, totals, discounts).
- `test/favorites_test.dart`: Validates favorite toggling and `SharedPreferences` disk persistence.
- `test/filter_test.dart`: Validates multi-criteria search, category filtering, and sorting.
- `test/widget_test.dart`: Validates UI rendering, `AsyncValueWidget` states, and navigation.

---

## 🚀 How to Run the App

1. **Clone the repository**:
   ```bash
   git clone https://github.com/shar0ne/e-commerce-exercice.git
   cd e-commerce-exercice
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests**:
   ```bash
   flutter test
   flutter analyze
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```
