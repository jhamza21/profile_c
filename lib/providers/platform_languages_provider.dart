import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/modules/companyOffers/language_model.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';

class PlatformLanguagesProvider extends ChangeNotifier {
  List<Language> _languages;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  List<Language> get languages => _languages ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _languages = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchLanguages(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await OfferService().getLanguages();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _languages = Language.listFromJson(jsonData["languages"]);
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

  void setLanguages(List<Language> value) {
    _languages = value;
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
