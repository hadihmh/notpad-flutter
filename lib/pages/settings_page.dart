import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

import '../data/backup.dart';
import '../data/notes_db.dart';
import '../data/settings.dart';
import '../utils.dart';
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
                ButtonSegment(
                    value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text(tr('System'))),
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
          section('Backup'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(tr('Export backup')),
            subtitle: Text(tr('Save all notes to a file')),
            onTap: () => _export(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore_page_outlined),
            title: Text(tr('Restore from backup')),
            subtitle: Text(tr('Notes already in the app are not duplicated')),
            onTap: () => _restore(context),
          ),
          section('About'),
          ListTile(
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(8), child: Image.asset('Assets/logo-grey.png', width: 40)),
            title: Text(tr('Note')),
            subtitle: Text(tr('A simple, fast notebook · v{v}', {'v': '2.4'})),
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

void _toast(BuildContext context, String message) {
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _export(BuildContext context) async {
  final notes = await NotesDb.instance.all();
  final name = 'note-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
  try {
    final saved = await platform.invokeMethod<bool>('saveFile', {'name': name, 'text': exportBackup(notes)});
    if (saved == true && context.mounted) _toast(context, tr('Backup saved ({n} notes)', {'n': notes.length}));
  } on Exception {
    // shortcut: file picker is Android-only (MissingPluginException elsewhere); add iOS if it ships there.
    if (context.mounted) _toast(context, tr('Could not save the file'));
  }
}

Future<void> _restore(BuildContext context) async {
  try {
    final text = await platform.invokeMethod<String>('openFile');
    if (text == null) return; // cancelled
    final db = NotesDb.instance;
    final fresh = notesToRestore(await db.all(), parseBackup(text));
    for (final n in fresh) {
      await db.save(n);
    }
    if (context.mounted) _toast(context, tr('{n} notes restored', {'n': fresh.length}));
  } on FormatException {
    if (context.mounted) _toast(context, tr('Not a valid backup file'));
  } on PlatformException {
    if (context.mounted) _toast(context, tr('Could not open the file'));
  } on MissingPluginException {
    if (context.mounted) _toast(context, tr('Could not open the file'));
  }
}
