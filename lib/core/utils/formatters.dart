import 'package:intl/intl.dart';

String formatMoney(num amount) {
  final f = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  return f.format(amount);
}

String formatPerKg(num price) => '${NumberFormat('#,###', 'vi_VN').format(price)} ₫/kg';

String formatQty(num kg) {
  if (kg >= 1000) {
    return '${(kg / 1000).toStringAsFixed(1).replaceAll('.0', '')} tấn';
  }
  return '${NumberFormat('#,###', 'vi_VN').format(kg)} kg';
}

String formatDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
String formatDateTime(DateTime dt) => DateFormat('dd/MM/yyyy · HH:mm').format(dt);
