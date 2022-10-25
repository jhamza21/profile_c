import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/models/message.dart';

String getMessageTime(Message message, BuildContext context) {
  String time;
  if (DateFormat('yyyy-MM-dd').format(DateTime.now()) == message.date) {
    time = message.time.substring(0, 5);
  } else {
    time = DateTime.now()
            .difference(DateTime.parse(message.date.replaceAll('/', "-")))
            .inDays
            .toString() +
        getTranslate(context, "DAYS");
  }
  return time;
}
