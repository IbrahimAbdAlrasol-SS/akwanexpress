import 'package:intl/intl.dart';

String formatArabicDate(DateTime date) {
  final dayName = DateFormat.EEEE('ar').format(date); // يوم الأسبوع
  final datePart = DateFormat('dd/MM/yyyy', 'ar').format(date); // التاريخ
  final timePart = DateFormat('h:mm a', 'ar').format(date); // الوقت بصيغة ص/م
  return '$datePart، $dayName، $timePart';
}
