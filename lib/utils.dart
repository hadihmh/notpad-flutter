import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

/// RTL for Persian/Arabic text, LTR otherwise (based on the first strong character).
TextDirection directionOf(String text) =>
    intl.Bidi.startsWithRtl(text) ? TextDirection.rtl : TextDirection.ltr;

String editedLabel(DateTime dt, [DateTime? now]) {
  now ??= DateTime.now();
  final day = DateTime(dt.year, dt.month, dt.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(day).inDays;
  final time = intl.DateFormat('h:mm a').format(dt);
  if (days == 0) return 'Edited $time';
  if (days == 1) return 'Edited yesterday, $time';
  if (dt.year == now.year) return 'Edited ${intl.DateFormat('MMM d').format(dt)}';
  return 'Edited ${intl.DateFormat('MMM d, y').format(dt)}';
}

const _shareChannel = MethodChannel('com.hmh.note/share');

/// Opens the Android share sheet; copies to clipboard where the channel is missing.
Future<void> shareText(BuildContext context, String text) async {
  try {
    await _shareChannel.invokeMethod('share', {'text': text});
  } on MissingPluginException {
    // shortcut: share is Android-only (Bazaar build); add an iOS handler if the app ships on iOS.
    if (context.mounted) await copyText(context, text);
  }
}

Future<void> copyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
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
