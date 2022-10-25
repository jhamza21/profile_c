import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/models/activity.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/activity_service.dart';

class StatisticProvider extends ChangeNotifier {
  List<Activity> _profileViews = [];
  List<Activity> _profileAppearance = [];

  int _nbApparitionW = 0;
  int _nbCompareW = 0;
  int _nbDiscussionW = 0;
  int _nbViewProfileW = 0;
  int _nbFavoriteW = 0;

  int _nbApparitionM = 0;
  int _nbCompareM = 0;
  int _nbDiscussionM = 0;
  int _nbViewProfileM = 0;
  int _nbFavoriteM = 0;

  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<Activity> get profileViews => _profileViews;
  List<Activity> get profileAppearance => _profileAppearance;

  int get nbApparitionW => _nbApparitionW ?? 0;
  int get nbComparisionW => _nbCompareW ?? 0;
  int get nbDiscussionW => _nbDiscussionW ?? 0;
  int get nbProfileViewsW => _nbViewProfileW ?? 0;
  int get nbFavoriteW => _nbFavoriteW ?? 0;

  int get nbApparitionM => _nbApparitionM ?? 0;
  int get nbComparisionM => _nbCompareM ?? 0;
  int get nbDiscussionM => _nbDiscussionM ?? 0;
  int get nbProfileViewsM => _nbViewProfileM ?? 0;
  int get nbFavoriteM => _nbFavoriteM ?? 0;

  void initialize() {
    _profileViews = [];
    _profileAppearance = [];

    _nbApparitionW = 0;
    _nbCompareW = 0;
    _nbDiscussionW = 0;
    _nbViewProfileW = 0;
    _nbFavoriteW = 0;

    _nbApparitionM = 0;
    _nbCompareM = 0;
    _nbDiscussionM = 0;
    _nbViewProfileM = 0;
    _nbFavoriteM = 0;
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchStatistics(context) async {
    try {
      _nbApparitionW = 0;
      _nbCompareW = 0;
      _nbDiscussionW = 0;
      _nbViewProfileW = 0;
      _nbFavoriteM = 0;
      _nbApparitionM = 0;
      _nbCompareM = 0;
      _nbDiscussionM = 0;
      _nbViewProfileM = 0;
      _nbFavoriteM = 0;
      _profileViews = [];
      _profileAppearance = [];
      _isLoading = true;
      final res = await ActivityService().getActivity();
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      List<Activity> _activities =
          Activity.listFromJson(jsonData["activities"]);
      String todayDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
      for (int i = _activities.length - 1; i >= 0; i--) {
        int _period = getDays(_activities[i].date, todayDate);
        if (_period > 60) break;
        if (_period < 60 && _activities[i].nbProfileView == 1)
          _profileViews.add(_activities[i]);
        if (_period < 60 && _activities[i].nbAppearance == 1)
          _profileAppearance.add(_activities[i]);

        if (_activities[i].nbProfileView == 1 && _period <= 7)
          _nbViewProfileW++;
        if (_activities[i].nbAppearance == 1 && _period <= 7) _nbApparitionW++;
        if (_activities[i].nbCompare == 1 && _period <= 7) _nbCompareW++;
        if (_activities[i].nbDiscussion == 1 && _period <= 7) _nbDiscussionW++;
        if (_activities[i].nbFavorite == 1 && _period <= 7) _nbFavoriteW++;

        if (_activities[i].nbProfileView == 1 && _period <= 31)
          _nbViewProfileM++;
        if (_activities[i].nbAppearance == 1 && _period <= 31) _nbApparitionM++;
        if (_activities[i].nbCompare == 1 && _period <= 31) _nbCompareM++;
        if (_activities[i].nbDiscussion == 1 && _period <= 31) _nbDiscussionM++;
        if (_activities[i].nbFavorite == 1 && _period <= 31) _nbFavoriteM++;
      }
      _isError = false;
      _isLoading = false;
      _isFetched = true;
      notifyListeners();
    } catch (e) {
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void setIsLoading(bool value) {
    _isLoading = true;
    notifyListeners();
  }
}
