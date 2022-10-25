import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/devise.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/devise_service.dart';

class DeviseProvider extends ChangeNotifier {
  List<Devise> _devises = [];
  bool _isLoading;
  bool _isFetched;
  bool _isError;

  List<Devise> get devises => _devises ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _devises = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchDevises(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await DeviseService().getDevises();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _devises = Devise.listFromJson(jsonData["devises"]);
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

  void setDevises(List<Devise> devises) {
    _devises = devises;
    notifyListeners();
  }
}
