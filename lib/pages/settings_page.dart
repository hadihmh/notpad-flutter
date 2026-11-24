import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _links = [
    (Icons.star_outline, 'Rate on Cafe Bazaar', 'https://cafebazaar.ir/app/com.hmh.note'),
    (Icons.mail_outline, 'Send feedback', 'mailto:hmhnexus5x@gmail.com?subject=Note%20app'),
    (Icons.code, 'Source code on GitHub', 'https://github.com/hadihmh/notpad-flutter'),
  ];

  @override
  Widget build(BuildContext context) {
    final header = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary);
    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: header),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(children: [
          section('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('System')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ),
          section('Theme color'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              for (var i = 0; i < AppSettings.themeSeeds.length; i++)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: AppSettings.themeSeeds[i]),
                  label: Text(AppSettings.themeNames[i]),
                  selected: settings.themeIndex == i,
                  onSelected: (_) => settings.setTheme(i),
                ),
            ]),
          ),
          section('Note font size'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                for (var i = 0; i < AppSettings.fontNames.length; i++)
                  ButtonSegment(value: i, label: Text(AppSettings.fontNames[i])),
              ],
              selected: {settings.fontIndex},
              onSelectionChanged: (s) => settings.setFont(s.first),
            ),
          ),
          section('About'),
          ListTile(
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(8), child: Image.asset('Assets/logo-grey.png', width: 40)),
            title: const Text('Note'),
            subtitle: const Text('A simple, fast notebook · v2.0'),
          ),
          for (final (icon, label, url) in _links)
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            ),
        ]),
      ),
    );
  }
}
