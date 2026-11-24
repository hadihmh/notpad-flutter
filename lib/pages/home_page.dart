import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../checklist.dart';
import '../data/note.dart';
import '../data/notes_db.dart';
import '../data/settings.dart';
import '../l10n.dart';
import '../theme.dart';
import '../utils.dart';
import 'note_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = NotesDb.instance;
  final _scaffold = GlobalKey<ScaffoldState>();
  Section _section = Section.notes;
  List<Note> _notes = [];
  String _query = '';
  bool _loading = true;

  static const _titles = {Section.notes: 'Notes', Section.archive: 'Archive', Section.trash: 'Trash'};
  static const _icons = {
    Section.notes: Icons.sticky_note_2_outlined,
    Section.archive: Icons.archive_outlined,
    Section.trash: Icons.delete_outline,
  };

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final notes = await _db.list(_section);
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  List<Note> get _visible => _query.isEmpty ? _notes : _notes.where((n) => n.matches(_query)).toList();

  Future<void> _open(Note note) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => NotePage(note: note)));
    _reload();
  }

  Future<void> _update(Note note, void Function() change, String message, void Function() undo) async {
    change();
    await _db.save(note);
    _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(tr(message)),
        action: SnackBarAction(
            label: tr('Undo'),
            onPressed: () async {
              undo();
              await _db.save(note);
              _reload();
            }),
      ));
  }

  void _toggleArchive(Note n) {
    final wasPinned = n.pinned;
    _update(
        n,
        () {
          n.archived = !n.archived;
          n.pinned = false; // archived notes are never pinned
        },
        n.archived ? 'Note unarchived' : 'Note archived',
        () {
          n.archived = !n.archived;
          n.pinned = wasPinned;
        });
  }

  Future<void> _togglePin(Note n) async {
    n.pinned = !n.pinned;
    await _db.save(n);
    _reload();
  }

  void _trash(Note n) => _update(n, () => n.deleted = true, 'Note moved to trash', () => n.deleted = false);

  void _restore(Note n) => _update(n, () => n.deleted = false, 'Note restored', () => n.deleted = true);

  Future<void> _deleteForever(Note n) async {
    if (await _confirm(tr('Delete this note forever?'))) {
      await _db.deleteForever(n);
      _reload();
    }
  }

  Future<void> _emptyTrash() async {
    if (_notes.isNotEmpty && await _confirm(tr('Delete all {n} notes in trash forever?', {'n': _notes.length}))) {
      await _db.emptyTrash();
      _reload();
    }
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('Cancel'))),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error,
                foregroundColor: Theme.of(c).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: Text(tr('Delete')),
            ),
          ],
        ),
      ) ??
      false;

  void _showActions(Note n) {
    final trash = _section == Section.trash;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) {
        Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
              leading: Icon(icon),
              title: Text(tr(label)),
              onTap: () {
                Navigator.pop(c);
                onTap();
              },
            );
        return SafeArea(
          minimum: const EdgeInsets.only(bottom: Space.s),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (trash) ...[
              item(Icons.restore_from_trash_outlined, 'Restore', () => _restore(n)),
              item(Icons.delete_forever_outlined, 'Delete forever', () => _deleteForever(n)),
            ] else ...[
              if (!n.archived)
                item(n.pinned ? Icons.push_pin : Icons.push_pin_outlined, n.pinned ? 'Unpin' : 'Pin',
                    () => _togglePin(n)),
              item(n.archived ? Icons.unarchive_outlined : Icons.archive_outlined, n.archived ? 'Unarchive' : 'Archive',
                  () => _toggleArchive(n)),
              item(Icons.share_outlined, 'Share', () => shareText(context, n.shareText)),
              item(Icons.copy_outlined, 'Copy', () => copyText(context, n.shareText)),
              item(Icons.delete_outline, 'Move to trash', () => _trash(n)),
            ],
          ]),
        );
      },
    );
  }

  void _select(Section s) {
    Navigator.pop(context); // close drawer
    setState(() {
      _section = s;
      _loading = true;
    });
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _visible;
    final scheme = Theme.of(context).colorScheme;
    final viewToggle = IconButton(
      tooltip: settings.gridView ? tr('List view') : tr('Grid view'),
      icon: Icon(settings.gridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
      onPressed: () => setState(settings.toggleGrid),
    );
    return Scaffold(
      key: _scaffold,
      drawer: NavigationDrawer(
        selectedIndex: _section.index,
        onDestinationSelected: (i) {
          if (i < Section.values.length) return _select(Section.values[i]);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())).then((_) => _reload());
        },
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, Space.xl, Space.l, Space.l),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Space.s),
                child: Image.asset('Assets/logo-grey.png', width: 36, height: 36),
              ),
              const SizedBox(width: Space.m),
              Text(tr('Note'), style: Theme.of(context).textTheme.titleLarge),
            ]),
          ),
          for (final s in Section.values)
            NavigationDrawerDestination(icon: Icon(_icons[s]), label: Text(tr(_titles[s]!))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: Space.s),
            child: Divider(),
          ),
          NavigationDrawerDestination(icon: const Icon(Icons.settings_outlined), label: Text(tr('Settings'))),
        ],
      ),
      appBar: _section == Section.notes
          // Floating search pill holding the menu and view toggle, like a single toolbar.
          ? AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
              titleSpacing: Space.page,
              title: SearchBar(
                hintText: tr('Search your notes'),
                leading: IconButton(
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffold.currentState?.openDrawer(),
                ),
                trailing: [viewToggle],
                onChanged: (q) => setState(() => _query = q.trim()),
              ),
            )
          : AppBar(
              title: Text(tr(_titles[_section]!)),
              actions: [
                viewToggle,
                if (_section == Section.trash)
                  IconButton(
                    tooltip: tr('Empty trash'),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: _emptyTrash,
                  ),
                const SizedBox(width: Space.xs),
              ],
            ),
      floatingActionButton: _section == Section.notes
          ? FloatingActionButton.extended(
              onPressed: () => _open(Note()),
              icon: const Icon(Icons.edit_outlined),
              label: Text(tr('New note')),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? _empty()
              : LayoutBuilder(
                  // Columns follow the available width (phone 2, tablet 3-4), not the device.
                  builder: (context, box) => MasonryGridView.count(
                    padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, 96),
                    crossAxisCount: settings.gridView ? (box.maxWidth / 220).floor().clamp(2, 5) : 1,
                    mainAxisSpacing: Space.m,
                    crossAxisSpacing: Space.m,
                    itemCount: notes.length,
                    itemBuilder: (_, i) => NoteCard(
                      note: notes[i],
                      maxLines: settings.gridView ? 10 : 4,
                      onTap: () => _section == Section.trash ? _showActions(notes[i]) : _open(notes[i]),
                      onLongPress: () => _showActions(notes[i]),
                    ),
                  ),
                ),
      backgroundColor: scheme.surface,
    );
  }

  Widget _empty() {
    final text = _query.isNotEmpty
        ? 'No matching notes'
        : switch (_section) {
            Section.notes => 'Notes you add appear here',
            Section.archive => 'Archived notes appear here',
            Section.trash => 'Trash is empty',
          };
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: scheme.surfaceContainerHigh,
            child: Icon(_icons[_section], size: 44, color: scheme.primary),
          ),
          const SizedBox(height: Space.l),
          Text(tr(text),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.maxLines, this.onTap, this.onLongPress});

  final Note note;
  final int maxLines;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = noteBackground(note.color, theme.brightness);
    final fg = noteForeground(note.color, theme.brightness);
    final text = theme.textTheme;
    final hasTitle = note.title.trim().isNotEmpty, hasBody = note.content.trim().isNotEmpty;
    return Card(
      color: bg,
      // Tinted notes need no outline; default notes keep the theme's hairline border.
      shape: bg == null ? null : RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (hasTitle || note.pinned)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: directionOf(note.title),
                      style: text.titleMedium?.copyWith(color: fg)),
                ),
                if (note.pinned) ...[
                  const SizedBox(width: Space.s),
                  Icon(Icons.push_pin, size: 18, color: fg ?? theme.colorScheme.primary, semanticLabel: tr('Pinned')),
                ],
              ]),
            if ((hasTitle || note.pinned) && hasBody) const SizedBox(height: Space.s),
            if (hasBody)
              Text(checklistPreview(note.content).trim(),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  textDirection: directionOf(note.content),
                  style: text.bodyMedium?.copyWith(color: fg ?? theme.colorScheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}
