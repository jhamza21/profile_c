import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/get_user_avatar.dart';
import 'package:profilecenter/models/chat_room.dart';

Widget getChatRoomAvatar(int userId, ChatRoom chatRoom) {
  try {
    if (chatRoom.name != '')
      return CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text("${chatRoom.name[0].toUpperCase()}"),
        radius: 22.0,
      );
    if (chatRoom.members.length == 1) {
      return getUserAvatar(chatRoom.members[0], Colors.blueGrey, 22);
    }
    if (chatRoom.members.length == 2) {
      if (chatRoom.members[0].id == userId)
        return getUserAvatar(chatRoom.members[1], Colors.blueGrey, 22);
      else
        return getUserAvatar(chatRoom.members[0], Colors.blueGrey, 22);
    } else
      return CircleAvatar(
        child: Text("${chatRoom.id}}"),
        radius: 22.0,
      );
  } catch (e) {
    return CircleAvatar(
      child: Text("${chatRoom.id}"),
      backgroundColor: Colors.blueGrey,
      radius: 22.0,
    );
  }
}
