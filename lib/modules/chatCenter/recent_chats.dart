import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/chat_room_provider.dart';
import 'package:profilecenter/modules/chatCenter/chat_room_card.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/core/services/message_service.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class RecentChats extends StatefulWidget {
  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  @override
  void initState() {
    super.initState();
    getChatrooms();
  }

  getChatrooms() async {
    int idUser = Provider.of<UserProvider>(context, listen: false).user.id;
    await MessageService().getChatRooms(idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Center"),
        leading: SizedBox.shrink(),
        backgroundColor: BLUE_DARK,
      ),
      // body: chatRoomProvider.isError
      //     ? ErrorScreen()
      //     : chatRoomProvider.chatRooms.length == 0
      //         ? Center(child: Text(getTranslate(context, "NO_RECENT_CHATS")))
      //         : Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: ListView.separated(
      //                 itemCount: chatRoomProvider.chatRooms.length,
      //                 separatorBuilder: (context, index) {
      //                   return SizedBox(height: 5.0);
      //                 },
      //                 itemBuilder: (BuildContext context, int index) {
      //                   return ChatRoomCard(chatRoomProvider.chatRooms[index]);
      //                 }),
      //           ),
    );
  }
}
