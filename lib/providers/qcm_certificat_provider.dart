import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/utils/helpers/generate_user_qcm_certifications.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/qcm_service.dart';

class QcmCertificationProvider extends ChangeNotifier {
  List<QcmCertification> _qcmCertifs = [];
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<QcmCertification> get certifications => _qcmCertifs ?? [];

  void initialize() {
    _qcmCertifs = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchCertificats(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await QcmService().getCertifications();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _qcmCertifs = QcmCertification.listFromJson(jsonData["data"]);

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

  void add(QcmCertification qcmCertification) {
    List<QcmCertification> _certifs = _qcmCertifs;
    _certifs.add(qcmCertification);
    _qcmCertifs = generateUserCertifications(_certifs);
    notifyListeners();
  }
}
