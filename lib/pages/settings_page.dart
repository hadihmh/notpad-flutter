import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

import '../data/backup.dart';
import '../data/notes_db.dart';
import '../data/settings.dart';
import '../utils.dart';
import '../l10n.dart';
import '../theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _links = [
    (Icons.star_outline, 'Rate on Cafe Bazaar', 'https://cafebazaar.ir/app/com.hmh.note'),
    (Icons.mail_outline, 'Send feedback', 'mailto:hmhnexus5x@gmail.com?subject=Note%20app'),
    (Icons.code, 'Source code on GitHub', 'https://github.com/hadihmh/notpad-flutter'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A titled group of settings inside one rounded surface.
    Widget group(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.xl, Space.page, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Space.xs, bottom: Space.s),
              child: Text(tr(title), style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.group)),
              color: theme.colorScheme.surfaceContainer,
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ]),
        );
    // Label sits 8 from its control and 16 from the previous control, so pairs read as pairs.
    Widget padded(Widget child) =>
        Padding(padding: const EdgeInsets.fromLTRB(Space.l, Space.s, Space.l, 0), child: child);
    Widget label(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.l, Space.l, Space.l, 0),
          child: Text(tr(text), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(tr('Settings'))),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(padding: const EdgeInsets.only(bottom: Space.xxl), children: [
          group('Appearance', [
            label('Language'),
            padded(SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'fa', label: Text('فارسی')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {settings.lang},
              onSelectionChanged: (s) => settings.setLang(s.first),
            )),
            label('Theme'),
            padded(SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(tr('Light'))),
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(tr('System'))),
                ButtonSegment(
                    value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(tr('Dark'))),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            )),
            label('Theme color'),
            padded(Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              for (var i = 0; i < AppSettings.themeSeeds.length; i++)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: AppSettings.themeSeeds[i]),
                  label: Text(tr(AppSettings.themeNames[i])),
                  selected: settings.themeIndex == i,
                  showCheckmark: false,
                  onSelected: (_) => settings.setTheme(i),
                ),
            ])),
            label('Note font size'),
            padded(SegmentedButton<int>(
              segments: [
                for (var i = 0; i < AppSettings.fontNames.length; i++)
                  ButtonSegment(value: i, label: Text(tr(AppSettings.fontNames[i]))),
              ],
              selected: {settings.fontIndex},
              onSelectionChanged: (s) => settings.setFont(s.first),
            )),
            const SizedBox(height: Space.l),
          ]),
          group('Backup', [
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(tr('Export backup')),
              subtitle: Text(tr('Save all notes to a file')),
              onTap: () => _export(context),
            ),
            const Divider(height: 1, indent: Space.l, endIndent: Space.l),
            ListTile(
              leading: const Icon(Icons.restore_page_outlined),
              title: Text(tr('Restore from backup')),
              subtitle: Text(tr('Notes already in the app are not duplicated')),
              onTap: () => _restore(context),
            ),
          ]),
          group('About', [
            ListTile(
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(Space.s), child: Image.asset('Assets/logo-grey.png', width: 40)),
              title: Text(tr('Note')),
              subtitle: Text(tr('A simple, fast notebook · v{v}', {'v': '2.5'})),
            ),
            for (final (icon, text, url) in _links) ...[
              const Divider(height: 1, indent: Space.l, endIndent: Space.l),
              ListTile(
                leading: Icon(icon),
                title: Text(tr(text)),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              ),
            ],
          ]),
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
