import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores favorite stock symbols locally on-device.
/// Kept simple (no auth/user accounts requested), so favorites live in
/// SharedPreferences rather than a Firestore per-user collection.
class FavoritesService extends ChangeNotifier {
  static const _prefsKey = 'favorite_symbols';
  Set<String> _favorites = {};
  bool _loaded = false;

  Set<String> get favorites => _favorites;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = (prefs.getStringList(_prefsKey) ?? []).toSet();
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(String symbol) => _favorites.contains(symbol);

  Future<void> toggle(String symbol) async {
    if (_favorites.contains(symbol)) {
      _favorites.remove(symbol);
    } else {
      _favorites.add(symbol);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favorites.toList());
  }
}
