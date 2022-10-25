import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';

class IntershipOffersProvider extends ChangeNotifier {
  List<Offer> _intershipOffers;
  bool _isLoading;
  bool _isFetched;
  bool _isError;

  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  bool get isLoading => _isLoading ?? false;
  List<Offer> get intershipOffers => _intershipOffers ?? [];

  void initialize() {
    _intershipOffers = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchIntershipOffers(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await OfferService().getIntershipOffers();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _intershipOffers = Offer.listFromJson(jsonData["stages"]);
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

  void setIntershipOffers(List<Offer> value) {
    _intershipOffers = value;
    notifyListeners();
  }

  void addIntershipOffer(Offer value) {
    _intershipOffers.removeWhere((element) => element.id == value.id);
    _intershipOffers.add(value);
    notifyListeners();
  }

  void remove(Offer value) {
    _intershipOffers.removeWhere((element) => element.id == value.id);
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
