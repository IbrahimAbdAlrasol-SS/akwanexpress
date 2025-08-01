import 'package:intl/intl.dart';

class DateGroupingHelper {
  static String getDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return "اليوم";
    } else if (inputDate == yesterday) {
      return "أمس";
    } else if (inputDate == dayBeforeYesterday) {
      return "قبل يومين";
    } else {
      // Format the date in Arabic
      return _formatArabicDate(date);
    }
  }

  static String _formatArabicDate(DateTime date) {
    final arabicMonths = [
      'كانون الثاني', // January
      'شباط', // February
      'آذار', // March
      'نيسان', // April
      'أيار', // May
      'حزيران', // June
      'تموز', // July
      'آب', // August
      'أيلول', // September
      'تشرين الأول', // October
      'تشرين الثاني', // November
      'كانون الأول', // December
    ];

    final month = arabicMonths[date.month - 1];
    return '$month ${date.day}';
  }

  static Map<String, List<T>> groupByDate<T>(
    List<T> items,
    DateTime Function(T) getDate,
  ) {
    final Map<String, List<T>> grouped = {};

    for (final item in items) {
      final date = getDate(item);
      final label = getDateGroupLabel(date);

      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(item);
    }

    // Sort groups by date (most recent first)
    final sortedEntries = grouped.entries.toList();
    sortedEntries.sort((a, b) {
      // Get the first item from each group to compare dates
      final aDate = getDate(a.value.first);
      final bDate = getDate(b.value.first);
      return bDate.compareTo(aDate); // Descending order
    });

    return Map.fromEntries(sortedEntries);
  }

  static int getDaysDifference(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);

    return today.difference(inputDate).inDays;
  }
}
