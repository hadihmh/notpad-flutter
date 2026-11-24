import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'note.dart';

enum Section { notes, archive, trash }

class NotesDb {
  NotesDb._();
  static final instance = NotesDb._();

  Database? _db;

  // Same file name and table as v1.x, so updating from Bazaar keeps every note.
  // Schema v2 adds is_pinned.
  Future<Database> get _database async => _db ??= await openDatabase(
        join(await getDatabasesPath(), 'notes.db'),
        version: 2,
        onCreate: (db, _) => db.execute('CREATE TABLE IF NOT EXISTS notes('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, title BLOB, content BLOB, '
            'date_created INTEGER, date_last_edited INTEGER, note_color INTEGER, '
            'is_archived INTEGER, is_deleted INTEGER, is_pinned INTEGER NOT NULL DEFAULT 0)'),
        onUpgrade: (db, from, _) async {
          if (from < 2) await db.execute('ALTER TABLE notes ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0');
        },
      );

  Future<List<Note>> list(Section section) async {
    final where = switch (section) {
      Section.notes => 'is_archived = 0 AND is_deleted = 0',
      Section.archive => 'is_archived = 1 AND is_deleted = 0',
      Section.trash => 'is_deleted = 1',
    };
    final rows = await (await _database)
        .query('notes', where: where, orderBy: 'is_pinned DESC, date_last_edited DESC');
    return rows.map(Note.fromMap).toList();
  }

  /// Inserts or updates; fills in [note.id] for new notes.
  Future<void> save(Note note) async {
    final db = await _database;
    if (note.id == null) {
      note.id = await db.insert('notes', note.toMap());
    } else {
      await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
    }
  }

  Future<void> deleteForever(Note note) async {
    if (note.id == null) return;
    await (await _database).delete('notes', where: 'id = ?', whereArgs: [note.id]);
  }

  Future<List<Note>> all() async => (await (await _database).query('notes')).map(Note.fromMap).toList();

  Future<void> emptyTrash() async =>
      (await _database).delete('notes', where: 'is_deleted = 1');
}
