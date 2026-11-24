import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../data/note.dart';
import '../data/notes_db.dart';
import '../data/settings.dart';
import '../l10n.dart';
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
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('Delete'))),
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
    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: _section.index,
        onDestinationSelected: (i) {
          if (i < Section.values.length) return _select(Section.values[i]);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())).then((_) => _reload());
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 12),
            child: Text(tr('Note'), style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final s in Section.values)
            NavigationDrawerDestination(icon: Icon(_icons[s]), label: Text(tr(_titles[s]!))),
          const Divider(indent: 28, endIndent: 28),
          NavigationDrawerDestination(icon: const Icon(Icons.settings_outlined), label: Text(tr('Settings'))),
        ],
      ),
      appBar: AppBar(
        title: _section == Section.notes
            ? SearchBar(
                hintText: tr('Search your notes'),
                elevation: const WidgetStatePropertyAll(0),
                leading: const Icon(Icons.search),
                onChanged: (q) => setState(() => _query = q.trim()),
              )
            : Text(tr(_titles[_section]!)),
        actions: [
          IconButton(
            tooltip: settings.gridView ? tr('List view') : tr('Grid view'),
            icon: Icon(settings.gridView ? Icons.view_agenda_outlined : Icons.grid_view),
            onPressed: () => setState(settings.toggleGrid),
          ),
          if (_section == Section.trash)
            IconButton(
                tooltip: tr('Empty trash'), icon: const Icon(Icons.delete_sweep_outlined), onPressed: _emptyTrash),
        ],
      ),
      floatingActionButton: _section == Section.notes
          ? FloatingActionButton(
              tooltip: tr('New note'),
              onPressed: () => _open(Note()),
              child: const Icon(Icons.edit_outlined),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? _empty()
              : MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  crossAxisCount: settings.gridView ? 2 : 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: notes.length,
                  itemBuilder: (_, i) => NoteCard(
                    note: notes[i],
                    maxLines: settings.gridView ? 10 : 4,
                    onTap: () => _section == Section.trash ? _showActions(notes[i]) : _open(notes[i]),
                    onLongPress: () => _showActions(notes[i]),
                  ),
                ),
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
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icons[_section], size: 72, color: color),
        const SizedBox(height: 12),
        Text(tr(text), style: TextStyle(color: color)),
      ]),
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
    final fg = noteForeground(note.color);
    final text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      color: noteBackground(note.color),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(children: [
          if (note.pinned)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: Icon(Icons.push_pin, size: 16, color: fg, semanticLabel: tr('Pinned')),
            ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14, 14, note.pinned ? 28 : 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (note.title.trim().isNotEmpty)
                Text(note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: directionOf(note.title),
                    style: text.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w600)),
              if (note.title.trim().isNotEmpty && note.content.trim().isNotEmpty) const SizedBox(height: 6),
              if (note.content.trim().isNotEmpty)
                Text(note.content.trim(),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    textDirection: directionOf(note.content),
                    style: text.bodyMedium?.copyWith(color: fg)),
            ]),
          ),
        ]),
      ),
    );
  }
}
