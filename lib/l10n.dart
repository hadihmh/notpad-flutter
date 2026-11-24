import 'data/settings.dart';

/// Translates an English UI string; English is the key, so a missing entry falls back to English.
String tr(String en, [Map<String, Object> args = const {}]) {
  var s = settings.isFa ? (fa[en] ?? en) : en;
  args.forEach((k, v) => s = s.replaceAll('{$k}', localDigits('$v')));
  return s;
}

/// Persian digits in the Persian UI.
String localDigits(String s) => settings.isFa
    ? s.replaceAllMapped(RegExp('[0-9]'), (m) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(m[0]!)])
    : s;

const fa = {
  'Note': 'یادداشت',
  'Notes': 'یادداشت‌ها',
  'Archive': 'بایگانی',
  'Unarchive': 'خروج از بایگانی',
  'Trash': 'سطل زباله',
  'Settings': 'تنظیمات',
  'Search your notes': 'جستجو در یادداشت‌ها',
  'List view': 'نمای فهرستی',
  'Grid view': 'نمای شبکه‌ای',
  'Empty trash': 'خالی کردن سطل زباله',
  'New note': 'یادداشت جدید',
  'Note archived': 'یادداشت بایگانی شد',
  'Note unarchived': 'یادداشت از بایگانی خارج شد',
  'Note moved to trash': 'یادداشت به سطل زباله رفت',
  'Note restored': 'یادداشت بازگردانده شد',
  'Undo': 'واگرد',
  'Delete this note forever?': 'این یادداشت برای همیشه حذف شود؟',
  'Delete all {n} notes in trash forever?': 'هر {n} یادداشت سطل زباله برای همیشه حذف شوند؟',
  'Cancel': 'انصراف',
  'Delete': 'حذف',
  'Restore': 'بازگردانی',
  'Delete forever': 'حذف همیشگی',
  'Share': 'اشتراک‌گذاری',
  'Copy': 'کپی',
  'Move to trash': 'انتقال به سطل زباله',
  'Copied to clipboard': 'کپی شد',
  'No matching notes': 'یادداشتی پیدا نشد',
  'Notes you add appear here': 'یادداشت‌هایتان اینجا نمایش داده می‌شوند',
  'Archived notes appear here': 'یادداشت‌های بایگانی‌شده اینجا هستند',
  'Trash is empty': 'سطل زباله خالی است',
  'Color': 'رنگ',
  'Default color': 'رنگ پیش‌فرض',
  'Undo changes': 'لغو تغییرات',
  'Title': 'عنوان',
  'Appearance': 'ظاهر',
  'Light': 'روشن',
  'System': 'سیستم',
  'Dark': 'تیره',
  'Theme color': 'رنگ تم',
  'Grey': 'خاکستری',
  'Blue Grey': 'آبی خاکستری',
  'Blue': 'آبی',
  'Green': 'سبز',
  'Note font size': 'اندازه متن یادداشت',
  'Small': 'کوچک',
  'Medium': 'متوسط',
  'Large': 'بزرگ',
  'Language': 'زبان',
  'About': 'درباره',
  'A simple, fast notebook · v{v}': 'دفترچه یادداشت ساده و سریع · نسخه {v}',
  'Rate on Cafe Bazaar': 'امتیاز در کافه‌بازار',
  'Send feedback': 'ارسال نظر',
  'Source code on GitHub': 'کد منبع در گیت‌هاب',
  'Edited {time}': 'ویرایش: {time}',
  'Edited yesterday, {time}': 'ویرایش: دیروز، {time}',
  'Edited {date}': 'ویرایش: {date}',
};

const _jalaliMonths = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', //
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
];

/// Gregorian → Jalali (Solar Hijri) date as (year, month, day).
(int, int, int) toJalali(DateTime d) {
  const gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  final gy2 = d.month > 2 ? d.year + 1 : d.year;
  var days = 355666 + 365 * d.year + (gy2 + 3) ~/ 4 - (gy2 + 99) ~/ 100 + (gy2 + 399) ~/ 400 + d.day + gdm[d.month - 1];
  var jy = -1595 + 33 * (days ~/ 12053);
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }
  return days < 186
      ? (jy, 1 + days ~/ 31, 1 + days % 31)
      : (jy, 7 + (days - 186) ~/ 30, 1 + (days - 186) % 30);
}

/// "3 Azar" or "3 Azar 1404" in Persian.
String jalaliLabel(DateTime d, {required bool withYear}) {
  final (y, m, day) = toJalali(d);
  return localDigits(withYear ? '$day ${_jalaliMonths[m - 1]} $y' : '$day ${_jalaliMonths[m - 1]}');
}
