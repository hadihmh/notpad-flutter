import 'package:flutter/material.dart';

import 'l10n.dart';
import 'utils.dart';

// A checklist is stored as plain note text, one item per line: "[ ] milk" / "[x] bread".
// No schema change, and backups/old versions still see readable text.
final _marker = RegExp(r'^\[([ x])\](?: |$)');

typedef ChecklistItem = ({bool checked, String text});

bool isChecklist(String text) {
  final lines = text.split('\n').where((l) => l.isNotEmpty);
  return lines.isNotEmpty && lines.every(_marker.hasMatch);
}

List<ChecklistItem> parseChecklist(String text) => [
      for (final line in text.split('\n'))
        if (_marker.firstMatch(line) case final m?)
          (checked: m[1] == 'x', text: line.substring(m.end))
        else if (line.trim().isNotEmpty)
          (checked: false, text: line),
    ];

String serializeChecklist(Iterable<ChecklistItem> items) =>
    items.map((i) => '${i.checked ? '[x]' : '[ ]'} ${i.text}').join('\n');

String toChecklist(String text) {
  final items = parseChecklist(text);
  return serializeChecklist(items.isEmpty ? [(checked: false, text: '')] : items);
}

String fromChecklist(String text) => parseChecklist(text).map((i) => i.text).join('\n');

/// Text with ☐/☑ instead of markers, for cards and sharing.
String checklistPreview(String text) =>
    isChecklist(text) ? parseChecklist(text).map((i) => '${i.checked ? '☑' : '☐'} ${i.text}').join('\n') : text;

class _Item {
  _Item(this.checked, String text) : controller = TextEditingController(text: text);
  bool checked;
  final TextEditingController controller;
  final focus = FocusNode();

  void dispose() {
    controller.dispose();
    focus.dispose();
  }
}

/// Editable checklist. Reads [text] once; rebuild with a new key to reset it.
class ChecklistEditor extends StatefulWidget {
  const ChecklistEditor({super.key, required this.text, required this.onChanged, this.style, this.color});

  final String text;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final Color? color;

  @override
  State<ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<ChecklistEditor> {
  late final List<_Item> _items = [
    for (final i in parseChecklist(widget.text)) _Item(i.checked, i.text),
    if (parseChecklist(widget.text).isEmpty) _Item(false, ''),
  ];

  @override
  void dispose() {
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  void _emit() => widget.onChanged(serializeChecklist([
        for (final i in _items) (checked: i.checked, text: i.controller.text),
      ]));

  void _insertAfter(int index) {
    final item = _Item(false, '');
    setState(() => _items.insert(index + 1, item));
    WidgetsBinding.instance.addPostFrameCallback((_) => item.focus.requestFocus());
    _emit();
  }

  void _remove(int index) {
    setState(() {
      _items.removeAt(index).dispose();
      if (_items.isEmpty) _items.add(_Item(false, ''));
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.color?.withValues(alpha: 0.5);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (index, item) in _items.indexed)
        Row(key: ObjectKey(item), children: [
          Checkbox(
            value: item.checked,
            side: widget.color == null ? null : BorderSide(color: widget.color!, width: 2),
            onChanged: (v) {
              setState(() => item.checked = v ?? false);
              _emit();
            },
          ),
          Expanded(
            child: TextField(
              controller: item.controller,
              focusNode: item.focus,
              textDirection: directionOf(item.controller.text),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                setState(() {}); // refresh direction
                _emit();
              },
              onSubmitted: (_) => _insertAfter(index),
              style: widget.style?.copyWith(
                decoration: item.checked ? TextDecoration.lineThrough : null,
                color: item.checked ? hint ?? Theme.of(context).colorScheme.outline : widget.color,
              ),
              decoration: InputDecoration(
                  hintText: tr('List item'), border: InputBorder.none, hintStyle: TextStyle(color: hint)),
            ),
          ),
          IconButton(
            tooltip: tr('Remove item'),
            icon: Icon(Icons.close, size: 18, color: widget.color),
            onPressed: () => _remove(index),
          ),
        ]),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: widget.color),
          icon: const Icon(Icons.add),
          label: Text(tr('Add item')),
          onPressed: () => _insertAfter(_items.length - 1),
        ),
      ),
    ]);
  }
}
