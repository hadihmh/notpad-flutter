import 'dart:async';

import 'package:flutter/material.dart';

import '../data/note.dart';
import '../data/notes_db.dart';
import '../data/settings.dart';
import '../l10n.dart';
import '../utils.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key, required this.note});

  final Note note;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with WidgetsBindingObserver {
  late final _title = TextEditingController(text: widget.note.title);
  late final _content = TextEditingController(text: widget.note.content);
  late final _originalTitle = widget.note.title;
  late final _originalContent = widget.note.content;
  Note get _note => widget.note;
  Timer? _debounce;
  final _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _title.addListener(_changed);
    _content.addListener(_changed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _title.dispose();
    _content.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  // Save when the app goes to background, so a killed app never loses the note.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) _save();
  }

  void _changed() {
    setState(() {}); // refresh text direction
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _save);
  }

  Future<void> _save({bool force = false}) async {
    _debounce?.cancel();
    final changed = _title.text != _note.title || _content.text != _note.content;
    if (!changed && !force) return;
    _note
      ..title = _title.text
      ..content = _content.text;
    if (changed) _note.edited = DateTime.now();
    if (_note.id == null && _note.isEmpty) return; // never store blank new notes
    await NotesDb.instance.save(_note);
  }

  Future<void> _close() async {
    await _save();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _setColor(int color) async {
    setState(() => _note.color = color);
    await _save(force: true);
  }

  Future<void> _togglePin() async {
    setState(() => _note.pinned = !_note.pinned);
    await _save(force: true);
  }

  Future<void> _toggleArchive() async {
    _note.archived = !_note.archived;
    _note.pinned = false;
    await _save(force: true);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _trash() async {
    _note.deleted = true;
    if (_note.id != null) await _save(force: true);
    if (mounted) Navigator.pop(context);
  }

  void _undoChanges() {
    _title.text = _originalTitle;
    _content.text = _originalContent;
  }

  void _pickColor() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            for (final color in noteColors)
              Semantics(
                button: true,
                selected: color == _note.color,
                label: color == Note.white ? tr('Default color') : tr('Color'),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.pop(c);
                    _setColor(color);
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(c).colorScheme.outlineVariant,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: color == Note.white ? Theme.of(c).colorScheme.surface : Color(color),
                      child: color == _note.color ? const Icon(Icons.check, color: Colors.black54) : null,
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = noteBackground(_note.color);
    final fg = noteForeground(_note.color);
    final text = Theme.of(context).textTheme;
    final hint = fg?.withValues(alpha: 0.5);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          foregroundColor: fg,
          actions: [
            if (!_note.archived)
              IconButton(
                tooltip: _note.pinned ? tr('Unpin') : tr('Pin'),
                icon: Icon(_note.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                onPressed: _togglePin,
              ),
            IconButton(tooltip: tr('Color'), icon: const Icon(Icons.palette_outlined), onPressed: _pickColor),
            IconButton(
              tooltip: _note.archived ? tr('Unarchive') : tr('Archive'),
              icon: Icon(_note.archived ? Icons.unarchive_outlined : Icons.archive_outlined),
              onPressed: _toggleArchive,
            ),
            PopupMenuButton<VoidCallback>(
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: () => shareText(context, [_title.text, _content.text].join('\n\n').trim()),
                    child: ListTile(leading: const Icon(Icons.share_outlined), title: Text(tr('Share')))),
                PopupMenuItem(
                    value: () => copyText(context, [_title.text, _content.text].join('\n\n').trim()),
                    child: ListTile(leading: const Icon(Icons.copy_outlined), title: Text(tr('Copy')))),
                PopupMenuItem(
                    value: _undoChanges,
                    child: ListTile(leading: const Icon(Icons.undo), title: Text(tr('Undo changes')))),
                PopupMenuItem(
                    value: _trash,
                    child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(tr('Move to trash')))),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              // Tapping blank space below the text starts typing at the end of the note.
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _contentFocus.requestFocus,
                child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
                  TextField(
                    controller: _title,
                    textDirection: directionOf(_title.text),
                    textCapitalization: TextCapitalization.sentences,
                    style: text.headlineSmall?.copyWith(color: fg),
                    decoration: InputDecoration(
                        hintText: tr('Title'), border: InputBorder.none, hintStyle: TextStyle(color: hint)),
                    maxLines: null,
                  ),
                  TextField(
                    controller: _content,
                    focusNode: _contentFocus,
                    autofocus: _note.id == null,
                    textDirection: directionOf(_content.text),
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: settings.fontSize, height: 1.5, color: fg),
                    decoration: InputDecoration(
                        hintText: tr('Note'), border: InputBorder.none, hintStyle: TextStyle(color: hint)),
                    maxLines: null,
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(editedLabel(_note.edited), style: text.bodySmall?.copyWith(color: fg)),
            ),
          ]),
        ),
      ),
    );
  }
}
