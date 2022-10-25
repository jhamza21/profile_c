import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/skill_service.dart';

class PlatformSkillsProvider extends ChangeNotifier {
  List<Skill> _skills;
  List<String> _subSkills;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  List<Skill> get skills => _skills ?? [];
  //contains all sub skills string
  List<String> get subSkills => _subSkills ?? [];

  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _skills = [];
    _subSkills = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchSkills(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await SkillService().getPlatformSkills();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _skills = Skill.listFromJson(jsonData["competences"]);
        _subSkills = [];
        _skills.forEach((skill) => skill.subSkills.forEach((element) {
              _subSkills.add(element.title);
            }));
        _isError = false;
        _isLoading = false;
        _isFetched = true;
        notifyListeners();
      }
    } catch (e) {
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSkills(List<Skill> value) {
    _skills = value;
    notifyListeners();
  }

  void setIsError(bool value) {
    _isError = value;
    notifyListeners();
  }

  void setIsFetched(bool value) {
    _isFetched = value;
    notifyListeners();
  }
}
