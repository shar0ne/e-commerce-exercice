import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _keyFavorites = 'user_favorite_product_ids';
  final SharedPreferences _prefs;

  FavoritesStorage(this._prefs);

  Set<String> loadFavoriteIds() {
    final list = _prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  Future<bool> saveFavoriteIds(Set<String> ids) async {
    return await _prefs.setStringList(_keyFavorites, ids.toList());
  }

  Future<bool> clearFavorites() async {
    return await _prefs.remove(_keyFavorites);
  }
}
