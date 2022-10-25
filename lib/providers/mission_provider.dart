import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/models/mission.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/experience_service.dart';
import 'package:profilecenter/core/services/mission_service.dart';

class MissionProvider extends ChangeNotifier {
  List<Mission> _missionsInProgress = [];
  List<Mission> _missionsCompleted = [];
  List<Experience> _oldMissions = [];
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  void initialize() {
    _missionsInProgress = [];
    _missionsCompleted = [];
    _oldMissions = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<Mission> get missionsInProgress => _missionsInProgress;
  List<Mission> get missionsCompleted => _missionsCompleted;
  List<Experience> get oldMissions => _oldMissions;

  void fetchMissions(context) async {
    try {
      if (!isLoading) {
        _missionsInProgress = [];
        _missionsCompleted = [];
        _oldMissions = [];
        _isLoading = true;
        final res = await MissionService().getMissions();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        List<Mission> _missions = Mission.listFromJson(jsonData["data"]);
        _missions.forEach((element) {
          if (element.inProgress)
            _missionsInProgress.add(element);
          else
            _missionsCompleted.add(element);
        });
        sortMissionInProgress();
        sortMissionsDone();
        final res2 = await ExperienceService().getExperiences();
        if (res2.statusCode != 200) throw "ERROR_SERVER";
        final jsonData2 = json.decode(res2.body);
        _oldMissions = Experience.listFromJson(jsonData2["missions"]);
        sortOldMissions();
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

  double get turnover {
    double _moy = 0;
    _missionsCompleted.forEach(((element) => _moy += element.turnover));
    return _moy;
  }

  double get globalAverageStarts {
    if (_missionsCompleted.length == 0) return 0;
    int _moy = 0;
    _missionsCompleted.forEach(((element) => _moy += element.note));
    return _moy / _missionsCompleted.length;
  }

  double averageStarts(int companyId) {
    if (_missionsCompleted.length == 0) return 0;
    int _moy = 0;
    _missionsCompleted.forEach(((element) {
      if (element.company.id == companyId) _moy += element.note;
    }));
    return _moy / _missionsCompleted.length;
  }

  void sortOldMissions() {
    _oldMissions.sort((a, b) => getDays(b.startDate, a.startDate));
  }

  void sortMissionInProgress() {
    _missionsInProgress
        .sort((a, b) => getDays(b.devis.startDate, a.devis.startDate));
  }

  void sortMissionsDone() {
    _missionsCompleted
        .sort((a, b) => getDays(b.devis.startDate, a.devis.startDate));
  }

  void addMission(Experience value) {
    _oldMissions.removeWhere((element) => element.id == value.id);
    _oldMissions.add(value);
    sortOldMissions();
    notifyListeners();
  }

  void remove(Experience value) {
    _oldMissions.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }
}
