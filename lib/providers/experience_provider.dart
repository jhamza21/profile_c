import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/experience_service.dart';

class ExperienceProvider extends ChangeNotifier {
  List<Experience> _experiences;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  List<Experience> get experiences => _experiences;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;

  void initialize() {
    _experiences = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchExperiences(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await ExperienceService().getExperiences();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _experiences = Experience.listFromJson(jsonData["experiences"]);
        sortExperiences();
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

  Experience get lastExperience {
    if (_experiences == null || _experiences.length == 0) return null;
    return _experiences.last;
  }

  void sortExperiences() {
    _experiences.sort((a, b) => getDays(b.startDate, a.startDate));
  }

  void addExperience(Experience value) {
    _experiences.removeWhere((element) => element.id == value.id);
    _experiences.add(value);
    sortExperiences();
    notifyListeners();
  }

  void remove(Experience value) {
    _experiences.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }
}
