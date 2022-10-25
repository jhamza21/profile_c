import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/devis_service.dart';

class DeviseProvider extends ChangeNotifier {
  List<Devis> _devis = [];
  bool _isLoading;
  bool _isFetched;
  bool _isError;

  List<Devis> get devises => _devis ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;

  void initialize() {
    _devis = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchDevis(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await DevisService().getDevis();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _devis = Devis.listFromJson(jsonData["devis"]);
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

  void setDevises(List<Devis> devis) {
    _devis = devis;
    notifyListeners();
  }
}
