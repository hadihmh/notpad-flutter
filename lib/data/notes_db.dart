import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'note.dart';

enum Section { notes, archive, trash }

class NotesDb {
  NotesDb._();
  static final instance = NotesDb._();

  Database? _db;

  // Same file name and schema as v1.x, so updating from Bazaar keeps every note.
  Future<Database> get _database async => _db ??= await openDatabase(
        join(await getDatabasesPath(), 'notes.db'),
        version: 1,
        onCreate: (db, _) => db.execute('CREATE TABLE IF NOT EXISTS notes('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, title BLOB, content BLOB, '
            'date_created INTEGER, date_last_edited INTEGER, note_color INTEGER, '
            'is_archived INTEGER, is_deleted INTEGER)'),
      );

  Future<List<Note>> list(Section section) async {
    final where = switch (section) {
      Section.notes => 'is_archived = 0 AND is_deleted = 0',
      Section.archive => 'is_archived = 1 AND is_deleted = 0',
      Section.trash => 'is_deleted = 1',
    };
    final rows = await (await _database)
        .query('notes', where: where, orderBy: 'date_last_edited DESC');
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

  Future<void> emptyTrash() async =>
      (await _database).delete('notes', where: 'is_deleted = 1');
}
