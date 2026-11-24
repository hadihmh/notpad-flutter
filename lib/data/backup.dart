import 'dart:convert';

import 'note.dart';

/// JSON backup of all notes (including archive and trash). Plain text, so it survives app reinstalls.
String exportBackup(List<Note> notes) => const JsonEncoder.withIndent(' ').convert({
      'app': 'com.hmh.note',
      'format': 1,
      'notes': [
        for (final n in notes)
          {
            'title': n.title,
            'content': n.content,
            'created': n.created.millisecondsSinceEpoch,
            'edited': n.edited.millisecondsSinceEpoch,
            'color': n.color,
            'archived': n.archived,
            'deleted': n.deleted,
            'pinned': n.pinned,
          },
      ],
    });

/// Parses a backup file; throws [FormatException] for anything that isn't one.
List<Note> parseBackup(String text) {
  final Object? data;
  try {
    data = jsonDecode(text);
  } on FormatException {
    throw const FormatException('not json');
  }
  if (data is! Map || data['app'] != 'com.hmh.note' || data['notes'] is! List) {
    throw const FormatException('not a note backup');
  }
  return [
    for (final m in data['notes'] as List)
      if (m is Map)
        Note(
          title: m['title'] is String ? m['title'] as String : '',
          content: m['content'] is String ? m['content'] as String : '',
          created: _date(m['created']),
          edited: _date(m['edited']),
          color: m['color'] is int ? m['color'] as int : Note.white,
          archived: m['archived'] == true,
          deleted: m['deleted'] == true,
          pinned: m['pinned'] == true,
        ),
  ].where((n) => !n.isEmpty).toList();
}

/// Notes from [incoming] that aren't already in [existing], so restoring twice adds nothing.
List<Note> notesToRestore(List<Note> existing, List<Note> incoming) {
  String key(Note n) => '${n.created.millisecondsSinceEpoch ~/ 1000}|${n.title}|${n.content}';
  final seen = existing.map(key).toSet();
  return [
    for (final n in incoming)
      if (seen.add(key(n))) n
  ];
}

DateTime _date(Object? v) => v is int ? DateTime.fromMillisecondsSinceEpoch(v) : DateTime.now();
