import 'package:flutter/material.dart';
import 'package:profilecenter/models/message.dart';

class MessageProvider extends ChangeNotifier {
  List<Message> _messages;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<Message> get messages => _messages ?? [];

  void initialize() {
    _messages = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchMessages(int chatroomId) {
    // PusherOptions options = PusherOptions(
    //     cluster: 'mt1', host: '193.46.198.127', port: 6001, encrypted: false);
    // FlutterPusher pusher = FlutterPusher('9e6c03f29d405d236820', options,
    //     enableLogging: false, onError: (e) async {
    //   _isError = true;
    //   notifyListeners();
    // });

    // Echo echo = new Echo({
    //   'broadcaster': 'pusher',
    //   'client': pusher,
    // });

    // echo.channel('room-$chatroomId').listen('SendMessage', (e) {
    //   _messages = e;
    //   notifyListeners();
    // });
  }
}
