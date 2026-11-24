import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/settings.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Note',
        locale: Locale(settings.lang),
        supportedLocales: const [Locale('fa'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        themeMode: settings.themeMode,
        theme: ThemeData(colorSchemeSeed: settings.seed, brightness: Brightness.light, fontFamily: 'Vazirmatn'),
        darkTheme: ThemeData(colorSchemeSeed: settings.seed, brightness: Brightness.dark, fontFamily: 'Vazirmatn'),
        home: const HomePage(),
      ),
    );
  }
}
