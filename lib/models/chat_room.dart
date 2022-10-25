import 'package:flutter/material.dart';
import 'package:profilecenter/models/message.dart';

import 'user.dart';

class ChatRoom {
  int id;
  String name;
  List<User> members;
  Message lastMessage;
  String date;
  String time;
  bool isLocked;

  ChatRoom({
    @required this.id,
    @required this.members,
    @required this.lastMessage,
    @required this.date,
    @required this.time,
    @required this.isLocked,
  });

  ChatRoom.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        members = User.listFromJson(json['users']),
        lastMessage = json['latest_message'] != null
            ? Message.fromJson(json['latest_message'])
            : null,
        date = json['created_at'].substring(0, 10),
        time = json['created_at'].substring(11, 16),
        isLocked = json['locked'] == 0 ? false : true;

  static List<ChatRoom> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => ChatRoom.fromJson(value)).toList();
  }
}
