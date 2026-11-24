import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/notes_db.dart';
import 'package:note/data/note.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('a v1.x database upgrades to v2 without losing notes, and pinned notes sort first', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final path = join(await getDatabasesPath(), 'notes.db');
    await deleteDatabase(path);

    // Exactly what the 2019 app created.
    final old = await openDatabase(path, version: 1, onCreate: (db, _) => db.execute(
        'CREATE TABLE IF NOT EXISTS notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title BLOB, content BLOB, '
        'date_created INTEGER, date_last_edited INTEGER, note_color INTEGER, is_archived INTEGER, is_deleted INTEGER )'));
    for (final (t, edited, archived, deleted) in [('old', 100, 0, 0), ('newer', 200, 0, 0), ('arch', 300, 1, 0), ('bin', 400, 0, 1)]) {
      await old.insert('notes', {
        'title': utf8.encode(t), 'content': utf8.encode('متن $t'), 'date_created': 1, 'date_last_edited': edited,
        'note_color': 0xffffffff, 'is_archived': archived, 'is_deleted': deleted,
      });
    }
    await old.close();

    final db = NotesDb.instance;
    var notes = await db.list(Section.notes);
    expect(notes.map((n) => n.title), ['newer', 'old']);
    expect(notes.last.content, 'متن old');
    expect(notes.any((n) => n.pinned), isFalse);
    expect((await db.list(Section.archive)).single.title, 'arch');
    expect((await db.list(Section.trash)).single.title, 'bin');

    final oldNote = notes.last..pinned = true;
    await db.save(oldNote);
    await db.save(Note(title: 'brand new'));
    notes = await db.list(Section.notes);
    expect(notes.map((n) => n.title), ['old', 'brand new', 'newer']);
  });
}
