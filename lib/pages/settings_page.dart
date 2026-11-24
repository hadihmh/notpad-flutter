import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/settings.dart';
import '../l10n.dart';

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
          child: Text(tr(title), style: header),
        );

    return Scaffold(
      appBar: AppBar(title: Text(tr('Settings'))),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(children: [
          section('Language'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'fa', label: Text('فارسی')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {settings.lang},
              onSelectionChanged: (s) => settings.setLang(s.first),
            ),
          ),
          section('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text(tr('Light'))),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text(tr('System'))),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text(tr('Dark'))),
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
                  label: Text(tr(AppSettings.themeNames[i])),
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
                  ButtonSegment(value: i, label: Text(tr(AppSettings.fontNames[i]))),
              ],
              selected: {settings.fontIndex},
              onSelectionChanged: (s) => settings.setFont(s.first),
            ),
          ),
          section('About'),
          ListTile(
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(8), child: Image.asset('Assets/logo-grey.png', width: 40)),
            title: Text(tr('Note')),
            subtitle: Text(tr('A simple, fast notebook · v{v}', {'v': '2.2'})),
          ),
          for (final (icon, label, url) in _links)
            ListTile(
              leading: Icon(icon),
              title: Text(tr(label)),
              onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            ),
        ]),
      ),
    );
  }
}
