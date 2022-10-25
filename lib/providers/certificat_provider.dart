import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/certificat.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/certificat_service.dart';

class CertificatProvider extends ChangeNotifier {
  List<Certificat> _certificats;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<Certificat> get certificats => _certificats ?? [];

  void initialize() {
    _certificats = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchCertificats(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await CertificatService().getCertificats();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _certificats = Certificat.listFromJson(jsonData["data"]);
        sortCertificats();
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

  void sortCertificats() {
    _certificats.sort((a, b) => getDays(b.delivered, a.delivered));
  }

  void addCertificat(Certificat value) {
    _certificats.removeWhere((element) => element.id == value.id);
    _certificats.add(value);
    sortCertificats();
    notifyListeners();
  }

  void remove(Certificat value) {
    _certificats.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }
}
