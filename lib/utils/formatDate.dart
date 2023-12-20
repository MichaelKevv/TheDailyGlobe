import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp createdAt) {
  if (createdAt != null) {
    DateTime createdAtDate = DateTime.fromMillisecondsSinceEpoch(
        createdAt.seconds * 1000 + createdAt.nanoseconds ~/ 1000000);

    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    int year = createdAtDate.year;
    String month = months[createdAtDate.month - 1];
    int day = createdAtDate.day;

    return '$month $day, $year';
  } else {
    return '';
  }
}
