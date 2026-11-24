import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/backup.dart';
import 'package:note/data/note.dart';

void main() {
  final notes = [
    Note(title: 'خرید', content: 'نان\nشیر', color: 0xfff28b81, pinned: true, created: DateTime(2024, 1, 1, 10)),
    Note(content: 'archived', archived: true, created: DateTime(2024, 2, 1)),
    Note(title: 'bin', deleted: true, created: DateTime(2024, 3, 1)),
  ];

  test('export then parse keeps every field', () {
    final back = parseBackup(exportBackup(notes));
    expect(back.map((n) => [n.title, n.content, n.color, n.archived, n.deleted, n.pinned, n.created, n.id]).toList(), [
      ['خرید', 'نان\nشیر', 0xfff28b81, false, false, true, DateTime(2024, 1, 1, 10), null],
      ['', 'archived', Note.white, true, false, false, DateTime(2024, 2, 1), null],
      ['bin', '', Note.white, false, true, false, DateTime(2024, 3, 1), null],
    ]);
  });

  test('restoring the same backup twice adds nothing', () {
    final incoming = parseBackup(exportBackup(notes));
    expect(notesToRestore([], incoming), hasLength(3));
    expect(notesToRestore(notes, incoming), isEmpty);
    expect(notesToRestore(notes.sublist(1), incoming).single.title, 'خرید');
    expect(notesToRestore([], [...incoming, ...incoming]), hasLength(3)); // duplicates inside the file too
  });

  test('rejects files that are not backups, tolerates bad fields', () {
    expect(() => parseBackup('hello'), throwsFormatException);
    expect(() => parseBackup('{"notes": []}'), throwsFormatException);
    expect(() => parseBackup('[1,2]'), throwsFormatException);
    final odd = parseBackup('{"app":"com.hmh.note","notes":[1, {"title": 5, "content": "ok", "color": "red"}, {"title": ""}]}');
    expect(odd.single.content, 'ok');
    expect(odd.single.color, Note.white);
  });
}
