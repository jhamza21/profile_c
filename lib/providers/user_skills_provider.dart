import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/skill_service.dart';

class UserSkillsProvider extends ChangeNotifier {
  List<Skill> _skills;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  List<Skill> get skills => _skills ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;

  void initialize() {
    _skills = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchSkills(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await SkillService().getUserSkills();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _skills = Skill.listFromJson(jsonData["data"]);
        _isError = false;
        _isFetched = true;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  bool contains(String skill) {
    for (int i = 0; i < _skills.length; i++)
      if (skill.trim().toLowerCase() == _skills[i].title.trim().toLowerCase())
        return true;
    return false;
  }

  void addSkill(Skill value) {
    _skills.removeWhere((element) => element.id == value.id);
    _skills.add(value);
    notifyListeners();
  }

  void remove(Skill value) {
    _skills.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }
}
