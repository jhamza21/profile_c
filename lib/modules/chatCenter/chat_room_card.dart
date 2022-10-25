import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_chat_room_avatar.dart';
import 'package:profilecenter/utils/helpers/get_chat_room_name.dart';
import 'package:profilecenter/utils/helpers/get_time_from_chat_room.dart';
import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/chatCenter/chat_screen.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:provider/provider.dart';

class ChatRoomCard extends StatefulWidget {
  final ChatRoom chatRoom;
  ChatRoomCard(this.chatRoom);
  @override
  _ChatRoomCardState createState() => _ChatRoomCardState();
}

class _ChatRoomCardState extends State<ChatRoomCard> {
  String getLastMessageLabel(Message lastMessage, UserProvider userProvider) {
    if (lastMessage == null) return 'Pas de messages';
    bool isMe = lastMessage.sender.id == userProvider.user.id ? true : false;
    if (lastMessage.type == QCM_REQUEST)
      return getTranslate(context, "QCM_REQUEST");
    else if (lastMessage.type == QCM_RESPONSE)
      return getTranslate(context, "QCM_RESPONSE");
    else if ([CV_DOC, COVER_LETTER_DOC].contains(lastMessage.type))
      return getTranslate(context, "APPLY_MSG");
    else if (lastMessage.type == PROJECT_PROPOSAL)
      return getTranslate(context, "SERVICES_PROPOSITIONS_MSG");
    else if (lastMessage.type == PROJECT_PROPOSAL_RESPONSE)
      return getTranslate(context, "SERVICES_PROPOSITIONS_MSG");
    else if (lastMessage.type == DEVIS_REQUEST)
      return getTranslate(context, "DEVIS_PROPOSITION");
    else if (lastMessage.type == DEVIS_RESPONSE)
      return getTranslate(context, "DEVIS_PROPOSITION");
    else if (lastMessage.type == SUPPLY_REQUEST)
      return isMe
          ? getTranslate(context, "SUPPLY_REQUEST")
          : getTranslate(context, "DEVIS_PROPOSITION");
    else if (lastMessage.type == STRIPE_SUBSCRIPTION_REQUEST)
      return isMe
          ? getTranslate(context, "SUPPLY_REQUEST")
          : getTranslate(context, "INVIT_SUBSCRIBE_STRIPE");
    else if (lastMessage.type == PAY_PROPOSAL)
      return getTranslate(context, "PAY_REQUEST");
    else if (lastMessage.type == PAY_REQUEST)
      return getTranslate(context, "PAY_REQUEST");
    else if (lastMessage.type == PAY_RESPONSE)
      return getTranslate(context, "PAY_REQUEST");
    else if (lastMessage.type == RAITING_RESPONSE)
      return getTranslate(context, "PROJECT_END_MSG");
    else
      return lastMessage.text;
  }

  bool isMessageSeen(Message message) {
    if (message == null) return true;
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    if (message.sender.id == userProvider.user.id) return true;
    return message.isSeen;
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ListTile(
        onTap: () async {
          Navigator.of(context)
              .pushNamed(ChatScreen.routeName, arguments: widget.chatRoom);
        },
        tileColor: BLUE_LIGHT,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          getChatRoomName(userProvider.user.id, widget.chatRoom),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
        subtitle: Text(
            getLastMessageLabel(widget.chatRoom.lastMessage, userProvider),
            style: TextStyle(
                color: isMessageSeen(widget.chatRoom.lastMessage)
                    ? Colors.blueGrey[100]
                    : BLUE_SKY,
                fontSize: 13.0),
            overflow: TextOverflow.ellipsis),
        leading: getChatRoomAvatar(userProvider.user.id, widget.chatRoom),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: widget.chatRoom.name != '' ? 20 : 0,
              width: 60,
              decoration: BoxDecoration(
                  color: widget.chatRoom.name != ''
                      ? RED_LIGHT
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: widget.chatRoom.name != ''
                  ? Center(
                      child: Text(
                        getTranslate(context, "MEETING"),
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            Text(
              getChatRoomTime(widget.chatRoom, context),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // widget.chatRoom.lastMessage == null ||
            //         widget.chatRoom.lastMessage.isSeen
            //     ? SizedBox.shrink()
            //     : Icon(
            //         Icons.circle,
            //         size: 10,
            //         color: Colors.red,
            //       )
          ],
        ));
  }
}
