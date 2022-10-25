import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/matching_service.dart';

class CandidatSuggestionsProvider extends ChangeNotifier {
  List<User> _suggestions = [];
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<User> get suggestions => _suggestions ?? [];

  void initialize() {
    _suggestions = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchSuggestions(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await MatchingService().getCandidatSuggestions(
            [FREELANCE_ROLE, STAGIAIRE_ROLE, APPRENTI_ROLE, SALARIEE_ROLE], []);
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        int _max = jsonData["data"].length;
        if (_max > 10) _max = 10;
        for (int i = 0; i < _max; i++)
          _suggestions.add(User.fromJson(jsonData["data"][i]));
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
}
