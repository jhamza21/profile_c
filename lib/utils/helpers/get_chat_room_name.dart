import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/chat_room.dart';

String getChatRoomName(int userId, ChatRoom chatRoom) {
  try {
    if (chatRoom.name != '') return chatRoom.name;
    if (chatRoom.members.length == 1) {
      return chatRoom.members[0].civility == COMPANY_ROLE
          ? chatRoom.members[0].company.name
          : "${chatRoom.members[0].firstName} ${chatRoom.members[0].lastName}";
    }
    if (chatRoom.members.length == 2) {
      if (chatRoom.members[0].id == userId)
        return chatRoom.members[1].civility == COMPANY_ROLE
            ? chatRoom.members[1].company.name
            : "${chatRoom.members[1].firstName} ${chatRoom.members[1].lastName}";
      else
        return chatRoom.members[0].civility == COMPANY_ROLE
            ? chatRoom.members[0].company.name
            : "${chatRoom.members[0].firstName} ${chatRoom.members[0].lastName}";
    } else
      return "ChatRoom ${chatRoom.id}";
  } catch (e) {
    return "ChatRoom ${chatRoom.id}";
  }
}
