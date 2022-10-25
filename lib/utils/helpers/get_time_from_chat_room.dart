import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/models/chat_room.dart';

String getChatRoomTime(ChatRoom chatRoom, BuildContext context) {
  String _time;
  String _date;
  if (chatRoom.lastMessage == null) {
    _date = chatRoom.date;
    _time = chatRoom.time;
  } else {
    _date = chatRoom.lastMessage.date;
    _time = chatRoom.lastMessage.time;
  }
  String res;
  if (DateFormat('yyyy-MM-dd').format(DateTime.now()) == _date) {
    res = _time.substring(0, 5);
  } else {
    res = DateTime.now()
            .difference(DateTime.parse(_date.replaceAll('/', "-")))
            .inDays
            .toString() +
        getTranslate(context, "DAYS");
  }
  return res;
}
