import 'dart:convert';

/// A note. Maps 1:1 to the `notes` table created by v1.x so existing data keeps working.
class Note {
  int? id;
  String title;
  String content;
  DateTime created;
  DateTime edited;
  int color; // ARGB
  bool archived;
  bool deleted;

  static const white = 0xffffffff;

  Note({
    this.id,
    this.title = '',
    this.content = '',
    DateTime? created,
    DateTime? edited,
    this.color = white,
    this.archived = false,
    this.deleted = false,
  })  : created = created ?? DateTime.now(),
        edited = edited ?? DateTime.now();

  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;

  String get shareText => [title, content].where((s) => s.trim().isNotEmpty).join('\n\n');

  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) || content.toLowerCase().contains(q);
  }

  // v1 stored title/content as UTF-8 BLOBs and dates as epoch seconds; keep that format.
  factory Note.fromMap(Map<String, Object?> m) => Note(
        id: m['id'] as int?,
        title: _text(m['title']),
        content: _text(m['content']),
        created: _date(m['date_created']),
        edited: _date(m['date_last_edited']),
        color: (m['note_color'] as int?) ?? white,
        archived: m['is_archived'] == 1,
        deleted: m['is_deleted'] == 1,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': utf8.encode(title),
        'content': utf8.encode(content),
        'date_created': created.millisecondsSinceEpoch ~/ 1000,
        'date_last_edited': edited.millisecondsSinceEpoch ~/ 1000,
        'note_color': color,
        'is_archived': archived ? 1 : 0,
        'is_deleted': deleted ? 1 : 0,
      };

  static String _text(Object? v) => switch (v) {
        null => '',
        String s => s,
        List<int> bytes => utf8.decode(bytes, allowMalformed: true),
        _ => v.toString(),
      };

  static DateTime _date(Object? v) =>
      v is int ? DateTime.fromMillisecondsSinceEpoch(v * 1000) : DateTime.now();
}
