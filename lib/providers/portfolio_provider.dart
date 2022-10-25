import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/document_service.dart';

class PortfolioProvider extends ChangeNotifier {
  List<Document> _documents;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  List<Document> get documents => _documents ?? [];
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;

  void initialize() {
    _documents = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchDocuments(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await DocumentService().getDocuments(PORTFOLIO_DOC);
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _documents = Document.listFromJson(jsonData["documents"]);
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

  void remove(Document value) {
    _documents.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }

  void addDocument(Document value) {
    _documents.removeWhere((element) => element.id == value.id);
    _documents.add(value);
    notifyListeners();
  }
}
