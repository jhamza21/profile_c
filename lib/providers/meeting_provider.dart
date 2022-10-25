import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/meeting.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/meeting_service.dart';

class MeetingProvider extends ChangeNotifier {
  List<Meeting> _meetings;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  List<Meeting> get meetings => _meetings ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _meetings = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchMeetings(context) async {
    if (!isLoading) {
      try {
        _isLoading = true;
        final res = await MeetingService().getMeetings();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _meetings = Meeting.listFromJson(jsonData["meetings"]);
        sortMeetings();
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
  }

  void sortMeetings() {
    _meetings.sort((a, b) => getDays(b.startDate, a.startDate));
  }

  void addMeeting(Meeting value) {
    _meetings.removeWhere((element) => element.id == value.id);
    _meetings.add(value);
    sortMeetings();
    notifyListeners();
  }

  void remove(Meeting value) {
    _meetings.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }

  void setIsLoading(bool value) {
    _isLoading = true;
    notifyListeners();
  }
}
