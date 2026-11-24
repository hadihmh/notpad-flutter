import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'data/settings.dart';
import 'l10n.dart';

/// Direction of the language most words are in (RTL from 40% Persian words, like intl's estimate),
/// so "iPhone 15 قیمت چنده؟" is RTL. Null (follow the UI) when there are no letters,
/// e.g. empty or only digits, so typing "1" doesn't flip a Persian field to LTR.
TextDirection? directionOf(String text) {
  var rtl = 0, words = 0;
  for (final word in text.split(_space)) {
    if (intl.Bidi.startsWithRtl(word)) {
      rtl++;
      words++;
    } else if (intl.Bidi.hasAnyLtr(word)) {
      words++;
    }
  }
  if (words == 0) return null;
  return rtl > 0.4 * words ? TextDirection.rtl : TextDirection.ltr;
}

final _space = RegExp(r'\s+');

String editedLabel(DateTime dt, [DateTime? now]) {
  now ??= DateTime.now();
  // UTC midnights so a DST change can't turn "yesterday" into "today".
  final days = DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(dt.year, dt.month, dt.day)).inDays;
  final fa = settings.isFa;
  final time = intl.DateFormat(fa ? 'H:mm' : 'h:mm a').format(dt);
  if (days == 0) return tr('Edited {time}', {'time': time});
  if (days == 1) return tr('Edited yesterday, {time}', {'time': time});
  final String date;
  if (fa) {
    date = jalaliLabel(dt, withYear: toJalali(dt).$1 != toJalali(now).$1);
  } else {
    date = intl.DateFormat(dt.year == now.year ? 'MMM d' : 'MMM d, y').format(dt);
  }
  return tr('Edited {date}', {'date': date});
}

const platform = MethodChannel('com.hmh.note/platform');

/// Opens the Android share sheet; copies to clipboard where the channel is missing.
Future<void> shareText(BuildContext context, String text) async {
  try {
    await platform.invokeMethod('share', {'text': text});
  } on MissingPluginException {
    // shortcut: share is Android-only (Bazaar build); add an iOS handler if the app ships on iOS.
    if (context.mounted) await copyText(context, text);
  }
}

Future<void> copyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Copied to clipboard'))));
  }
}

const noteColors = [
  0xffffffff, 0xfff28b81, 0xfff7bd02, 0xfffbf476, 0xffcdff90, 0xffa7feeb, //
  0xffcbf0f8, 0xffafcbfa, 0xffd7aefc, 0xfffbcfe9, 0xffe6c9a9, 0xffe9eaee,
];

/// Background for a note: white follows the theme surface (so dark mode works), others are pastel.
Color? noteBackground(int color) => color == 0xffffffff ? null : Color(color);

/// Pastel backgrounds always need dark text, even in dark mode.
Color? noteForeground(int color) => color == 0xffffffff ? null : Colors.black87;
