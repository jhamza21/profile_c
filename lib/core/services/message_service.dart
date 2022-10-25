import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class MessageService {
  Future<http.Response> getChatRoom(int receiverId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chatroom?receiver_id=$receiverId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.StreamedResponse> getChatRooms(int idUser) async {
    String token = await SecureStorageService.readToken();
    var client = http.Client();
    var url = URL_BACKEND + "api/chat/room?user_id=$idUser";
    var request = http.Request('GET', Uri.parse(url));
    final defaultHeaders = <String, String>{
      "content-type": "application/json",
      "Accept": "*",
      "Authorization": "Bearer $token",
    };
    request.headers.addAll(defaultHeaders);
    return await client.send(request);
  }

  Future<http.Response> getMessages(int roomId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/message?chat_room_id=$roomId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> sendTextMessage(
      int roomId, int receiverId, String text) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/text";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "receiver_id": receiverId,
          "chat_room_id": roomId,
          "message": text,
        }));
  }

  Future<http.Response> deleteMessage(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/message/delete/" + id.toString();
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}
