import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/mentionLegalData.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/document_service.dart';

class MentionLegalDataProvider extends ChangeNotifier {
  MentionLegalData _mentionLegalData;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  MentionLegalData get mentionLegalData => _mentionLegalData ?? null;
  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;

  void initialize() {
    _mentionLegalData = null;
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchLegalMention(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await DocumentService().getMentionLegal();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        if (jsonData["message"] == 'NO_DATA') {
          _isError = false;
          _isFetched = true;
          _isLoading = false;
          notifyListeners();
          return;
        }
        _mentionLegalData = MentionLegalData.fromJson(jsonData["data"]);
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

  void set(MentionLegalData data) {
    _mentionLegalData = data;
    notifyListeners();
  }
}
