import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/stripe_service.dart';

class SupportedCountriesProvider extends ChangeNotifier {
  List<Country> _countries = [];
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _countries = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchCountries(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await StripeServices.getSupportedCountries();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _countries = Country.listFromJson(jsonData["data"]);
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

  bool isSupported(String name) {
    int index =
        _countries.indexWhere((element) => element.name.trim() == name.trim());
    return index == -1 ? false : true;
  }

  String getCountryCode(String name) {
    Country res =
        _countries.firstWhere((element) => element.name.trim() == name.trim());
    if (res != null) return res.code.trim();
    return null;
  }
}

class Country {
  final String name;
  final String code;
  Country(this.name, this.code);
  Country.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        code = json['code'];

  static List<Country> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Country.fromJson(value)).toList();
  }
}
