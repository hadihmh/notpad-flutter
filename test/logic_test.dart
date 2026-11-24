import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/note.dart';
import 'package:note/data/settings.dart';
import 'package:note/l10n.dart';
import 'package:note/utils.dart';

void main() {
  tearDown(() => settings.lang = 'fa');

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

  test('text direction follows the dominant language', () {
    expect(directionOf('سلام hello'), TextDirection.rtl);
    expect(directionOf('iPhone 15 قیمت چنده؟'), TextDirection.rtl); // English first word, Persian sentence
    expect(directionOf('Flutter خیلی خوبه'), TextDirection.rtl);
    expect(directionOf('Shopping:\nنان\nشیر\nپنیر'), TextDirection.rtl);
    expect(directionOf('Meeting with Ali فردا'), TextDirection.ltr); // mostly English
    expect(directionOf('hello world'), TextDirection.ltr);
    expect(directionOf('(سلام)'), TextDirection.rtl);
    expect(directionOf(''), isNull);
    expect(directionOf('123 !'), isNull); // digits alone don't flip the field
    expect(directionOf('۱۲۳'), TextDirection.rtl); // Persian digits signal Persian text
    expect(directionOf('1. نان'), TextDirection.rtl);
  });

  test('gregorian to jalali', () {
    expect(toJalali(DateTime(2026, 3, 21)), (1405, 1, 1));
    expect(toJalali(DateTime(2026, 3, 20)), (1404, 12, 29));
    expect(toJalali(DateTime(2026, 11, 24)), (1405, 9, 3));
    expect(toJalali(DateTime(2025, 3, 20)), (1403, 12, 30)); // leap Esfand
  });

  test('edited label in English compares full dates', () {
    settings.lang = 'en';
    final now = DateTime(2026, 11, 24, 12);
    expect(editedLabel(DateTime(2026, 11, 24, 9, 5), now), 'Edited 9:05 AM');
    expect(editedLabel(DateTime(2026, 11, 23, 22), now), 'Edited yesterday, 10:00 PM');
    expect(editedLabel(DateTime(2026, 10, 24, 9), now), 'Edited Oct 24'); // same day-of-month, other month
    expect(editedLabel(DateTime(2025, 11, 24, 9), now), 'Edited Nov 24, 2025');
  });

  test('edited label in Persian uses Jalali dates and Persian digits', () {
    settings.lang = 'fa';
    final now = DateTime(2026, 11, 24, 12);
    expect(editedLabel(DateTime(2026, 11, 24, 9, 5), now), 'ویرایش: ۹:۰۵');
    expect(editedLabel(DateTime(2026, 11, 23, 22), now), 'ویرایش: دیروز، ۲۲:۰۰');
    expect(editedLabel(DateTime(2026, 4, 1), now), 'ویرایش: ۱۲ فروردین');
    expect(editedLabel(DateTime(2026, 3, 1), now), 'ویرایش: ۱۰ اسفند ۱۴۰۴'); // previous Jalali year
    expect(tr('Delete all {n} notes in trash forever?', {'n': 12}), 'هر ۱۲ یادداشت سطل زباله برای همیشه حذف شوند؟');
  });

  test('every UI string has a Persian translation', () {
    final used = <String>{
      ...AppSettings.themeNames,
      ...AppSettings.fontNames,
      'Notes', 'Archive', 'Trash', // section titles
    };
    final literal = RegExp(r"""(?:tr|_update\(n, [^,]+,|item\(Icons\.\w+,|section|_confirm)\(?'([^']+)'""");
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      used.addAll(literal.allMatches(f.readAsStringSync()).map((m) => m[1]!));
    }
    expect(used.where((s) => !fa.containsKey(s)), isEmpty);
  });
}
