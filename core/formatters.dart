import 'package:intl/intl.dart';

String money(num v, String currency) =>
    '$currency${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(2)}' ;

String formatDateTime(DateTime? d) =>
    d == null ? '' : DateFormat('dd MM YYYY, hh:mm a').format(d);