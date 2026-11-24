import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings. Keeps the v1 preference keys ("theme" = t1..t4, "fontsize" = f1..f3).
class AppSettings extends ChangeNotifier {
  static const themeNames = ['Grey', 'Blue Grey', 'Blue', 'Green'];
  static const themeSeeds = [Color(0xff9e9e9e), Color(0xff607d8b), Color(0xff2196f3), Color(0xff4caf50)];
  static const fontNames = ['Small', 'Medium', 'Large'];
  static const fontSizes = [14.0, 17.0, 21.0];

  SharedPreferences? _prefs;
  int themeIndex = 1;
  int fontIndex = 1;
  ThemeMode themeMode = ThemeMode.system;
  bool gridView = true;

  Color get seed => themeSeeds[themeIndex];
  double get fontSize => fontSizes[fontIndex];

  Future<void> load() async {
    final p = _prefs = await SharedPreferences.getInstance();
    themeIndex = _index(p.getString('theme'), 't', 4, 1);
    fontIndex = _index(p.getString('fontsize'), 'f', 3, 1);
    themeMode = ThemeMode.values.firstWhere((m) => m.name == p.getString('theme_mode'),
        orElse: () => ThemeMode.system);
    gridView = p.getBool('grid_view') ?? true;
  }

  void setTheme(int i) => _set(() => themeIndex = i, () => _prefs?.setString('theme', 't${i + 1}'));
  void setFont(int i) => _set(() => fontIndex = i, () => _prefs?.setString('fontsize', 'f${i + 1}'));
  void setThemeMode(ThemeMode m) => _set(() => themeMode = m, () => _prefs?.setString('theme_mode', m.name));
  void toggleGrid() => _set(() => gridView = !gridView, () => _prefs?.setBool('grid_view', gridView));

  void _set(void Function() change, void Function() persist) {
    change();
    persist();
    notifyListeners();
  }

  static int _index(String? v, String prefix, int count, int fallback) {
    final i = int.tryParse(v?.replaceFirst(prefix, '') ?? '');
    return i != null && i >= 1 && i <= count ? i - 1 : fallback;
  }
}

final settings = AppSettings();
