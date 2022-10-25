import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';

class ProjectOffersProvider extends ChangeNotifier {
  List<Offer> _projectOffers;
  bool _isFetched;
  bool _isError;
  bool _isLoading;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<Offer> get projectOffers => _projectOffers ?? [];

  void initialize() {
    _projectOffers = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchProjectOffers(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await OfferService().getProjectOffers();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _projectOffers = Offer.listFromJson(jsonData["projects"]);
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

  void setProjectOffers(List<Offer> value) {
    _projectOffers = value;
    notifyListeners();
  }

  void addProjectOffer(Offer value) {
    _projectOffers.removeWhere((element) => element.id == value.id);
    _projectOffers.add(value);
    notifyListeners();
  }

  void remove(Offer value) {
    _projectOffers.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }

  void setIsLoading(bool value) {
    _isLoading = value;
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
