import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/auth_service.dart';

class DescriptionProvider extends ChangeNotifier {
  String _description;
  bool _isLoading;
  bool _isFetched;
  bool _isError;

  String get description => _description ?? '';
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void fetchDescription(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await AuthService().getCgu();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        _description = json.decode(res.body);
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
}
