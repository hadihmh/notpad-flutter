import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note/checklist.dart';
import 'package:note/data/note.dart';

void main() {
  test('detects, converts and previews checklists', () {
    expect(isChecklist('[ ] milk\n[x] bread'), isTrue);
    expect(isChecklist('[ ] milk\nplain line'), isFalse);
    expect(isChecklist(''), isFalse);
    expect(isChecklist('[ ]'), isTrue); // empty item

    expect(toChecklist('شیر\n\nنان'), '[ ] شیر\n[ ] نان');
    expect(toChecklist(''), '[ ] ');
    expect(fromChecklist('[ ] milk\n[x] bread'), 'milk\nbread');
    expect(parseChecklist('[x] a\n[ ] b'), [(checked: true, text: 'a'), (checked: false, text: 'b')]);
    expect(checklistPreview('[ ] milk\n[x] bread'), '☐ milk\n☑ bread');
    expect(checklistPreview('just text [ ]'), 'just text [ ]');
  });

  test('an empty checklist counts as an empty note', () {
    expect(Note(content: '[ ] \n[ ] ').isEmpty, isTrue);
    expect(Note(content: '[ ] x').isEmpty, isFalse);
    expect(Note(content: '[x] a').shareText, '☑ a');
  });

  testWidgets('editor checks, adds and removes items', (t) async {
    var out = '';
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: ChecklistEditor(text: '[ ] milk\n[x] bread', onChanged: (s) => out = s)),
    ));
    await t.tap(find.byType(Checkbox).first);
    expect(out, '[x] milk\n[x] bread');

    await t.tap(find.byIcon(Icons.add));
    await t.pump();
    await t.enterText(find.byType(TextField).last, 'eggs');
    expect(out, '[x] milk\n[x] bread\n[ ] eggs');

    await t.tap(find.byIcon(Icons.close).first);
    await t.pump();
    expect(out, '[x] bread\n[ ] eggs');
  });
}
