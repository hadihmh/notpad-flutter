import 'dart:async';

import 'package:flutter/material.dart';

import '../data/note.dart';
import '../data/notes_db.dart';
import '../data/settings.dart';
import '../l10n.dart';
import '../theme.dart';
import '../checklist.dart';
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
  late bool _checklist = isChecklist(widget.note.content);
  int _checklistKey = 0; // bump to rebuild the checklist editor from _content

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
    setState(() {
      _checklist = isChecklist(_originalContent);
      _checklistKey++;
    });
  }

  void _toggleChecklist() {
    final text = _checklist ? fromChecklist(_content.text) : toChecklist(_content.text);
    setState(() {
      _checklist = !_checklist;
      _checklistKey++;
    });
    _content.text = text;
  }

  void _pickColor() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.xl),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(tr('Color'), style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: Space.l),
            Wrap(spacing: Space.m, runSpacing: Space.m, children: [
              for (final tint in noteTints)
                _Swatch(
                  tint: tint,
                  selected: tint.key == _note.color,
                  onTap: () {
                    Navigator.pop(c);
                    _setColor(tint.key);
                  },
                ),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = noteBackground(_note.color, brightness);
    final fg = noteForeground(_note.color, brightness);
    final text = Theme.of(context).textTheme;
    final hint = fg?.withValues(alpha: 0.6);
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
                    value: _toggleChecklist,
                    child: ListTile(
                        leading: Icon(_checklist ? Icons.notes : Icons.checklist),
                        title: Text(_checklist ? tr('Hide checkboxes') : tr('Show checkboxes')))),
                PopupMenuItem(
                    value: () => shareText(context, [_title.text, checklistPreview(_content.text)].join('\n\n').trim()),
                    child: ListTile(leading: const Icon(Icons.share_outlined), title: Text(tr('Share')))),
                PopupMenuItem(
                    value: () => copyText(context, [_title.text, checklistPreview(_content.text)].join('\n\n').trim()),
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
                onTap: _checklist ? null : _contentFocus.requestFocus,
                child: ListView(padding: const EdgeInsets.fromLTRB(Space.xl, Space.s, Space.xl, Space.xl), children: [
                  TextField(
                    controller: _title,
                    textDirection: directionOf(_title.text),
                    textCapitalization: TextCapitalization.sentences,
                    style: text.headlineSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                        hintText: tr('Title'), border: InputBorder.none, hintStyle: TextStyle(color: hint)),
                    maxLines: null,
                  ),
                  const SizedBox(height: Space.xs),
                  if (_checklist)
                    ChecklistEditor(
                      key: ValueKey(_checklistKey),
                      text: _content.text,
                      onChanged: (t) => _content.text = t,
                      style: TextStyle(fontSize: settings.fontSize, color: fg),
                      color: fg,
                    )
                  else
                    TextField(
                      controller: _content,
                      focusNode: _contentFocus,
                      autofocus: _note.id == null,
                      textDirection: directionOf(_content.text),
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: settings.fontSize, height: 1.75, color: fg),
                      decoration: InputDecoration(
                          hintText: tr('Note'), border: InputBorder.none, hintStyle: TextStyle(color: hint)),
                      maxLines: null,
                    ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.m),
              child: Text(editedLabel(_note.edited),
                  style: text.bodySmall?.copyWith(color: hint ?? Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A 48px color circle (above the 44px touch minimum), ringed and checked when selected.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.tint, required this.selected, required this.onTap});

  final NoteTint tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fill = noteBackground(tint.key, theme.brightness) ?? scheme.surface;
    final mark = noteForeground(tint.key, theme.brightness) ?? scheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: tr(tint.name),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2.5 : 1),
          ),
          child: selected
              ? Icon(Icons.check, color: mark)
              : tint.key == Note.white
                  ? Icon(Icons.format_color_reset_outlined, size: 20, color: scheme.onSurfaceVariant)
                  : null,
        ),
      ),
    );
  }
}
