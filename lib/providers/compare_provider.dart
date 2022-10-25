import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/core/services/activity_service.dart';
import 'package:profilecenter/core/services/user_service.dart';

class CompareProvider extends ChangeNotifier {
  List<User> _usersToCompare = [];
  List<String> _tags = [];

  List<User> get usersToCompare => _usersToCompare ?? [];
  List<String> get tags => _tags ?? [];

  void intialize(List<String> tags, List<User> _users) {
    _tags = tags;
    _usersToCompare = _users;
  }

  void setUsersToCompare(List<User> users) {
    _usersToCompare = users;
    notifyListeners();
  }

  bool contains(User user) {
    for (int i = 0; i < _usersToCompare.length; i++)
      if (_usersToCompare[i].id == user.id) return true;
    return false;
  }

  void remove(User user) {
    _usersToCompare.removeWhere((element) => element.id == user.id);
    notifyListeners();
  }

  bool add(User user) {
    if (_usersToCompare.length == 2) return false;
    _usersToCompare.add(user);
    fetchNote(_usersToCompare.length - 1);
    incrementUserComparaison(user.id);
    notifyListeners();
    return true;
  }

  void fetchNote(int index) async {
    try {
      final res = await UserService().getUserNote(_usersToCompare[index].id);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _usersToCompare[index].stars = jsonData["data"];
      notifyListeners();
    } catch (e) {
      _usersToCompare[index].stars = 0;
      notifyListeners();
    }
  }

  void incrementUserComparaison(int id) async {
    try {
      await ActivityService().addComparaison(id);
    } catch (e) {}
  }

  void setTags(List<String> tags) {
    _tags = tags;
    notifyListeners();
  }
}
