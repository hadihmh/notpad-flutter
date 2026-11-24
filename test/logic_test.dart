import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/note.dart';
import 'package:note/utils.dart';

void main() {
  test('note round-trips through the v1 table format (UTF-8 blobs, epoch seconds)', () {
    final n = Note(id: 7, title: 'سلام', content: 'متن ✓', color: 0xfff28b81, archived: true,
        created: DateTime(2020, 1, 2, 3, 4, 5), edited: DateTime(2024, 5, 6, 7, 8, 9));
    final m = n.toMap();
    expect(m['title'], isA<List<int>>());
    final back = Note.fromMap(m);
    expect([back.id, back.title, back.content, back.color, back.archived, back.deleted, back.edited],
        [7, 'سلام', 'متن ✓', 0xfff28b81, true, false, DateTime(2024, 5, 6, 7, 8, 9)]);
    expect(Note().toMap().containsKey('id'), isFalse); // new notes get autoincrement id
  });

  test('detects Persian text direction', () {
    expect(directionOf('سلام hello'), TextDirection.rtl);
    expect(directionOf('  hello سلام'), TextDirection.ltr);
    expect(directionOf(''), TextDirection.ltr);
  });

  test('edited label compares full dates, not only day of month', () {
    final now = DateTime(2026, 11, 24, 12);
    expect(editedLabel(DateTime(2026, 11, 24, 9, 5), now), 'Edited 9:05 AM');
    expect(editedLabel(DateTime(2026, 11, 23, 22), now), 'Edited yesterday, 10:00 PM');
    expect(editedLabel(DateTime(2026, 10, 24, 9), now), 'Edited Oct 24'); // same day-of-month, other month
    expect(editedLabel(DateTime(2025, 11, 24, 9), now), 'Edited Nov 24, 2025');
  });
}
