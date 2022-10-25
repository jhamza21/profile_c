import 'package:flutter/material.dart';
import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/core/services/message_service.dart';

class ChatRoomProvider extends ChangeNotifier {
  List<ChatRoom> _chatRooms;
  bool _isError;
  bool _isLoading;

  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;
  List<ChatRoom> get chatRooms => _chatRooms ?? [];

  void initialize() {
    _chatRooms = [];
    _isError = false;
    _isLoading = false;
  }

  fetchChatRooms(int idUser) async {
    return MessageService().getChatRooms(idUser);
  }
}
