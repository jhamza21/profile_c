import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';

class PlatformToolsProvider extends ChangeNotifier {
  List<Skill> _tools;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  List<Skill> get tools => _tools ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _tools = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchTools(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await OfferService().getTools();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _tools = Skill.listFromJson(jsonData["outils"]);
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

  void setTools(List<Skill> value) {
    _tools = value;
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
