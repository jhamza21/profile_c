import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';

class JobOffersProvider extends ChangeNotifier {
  List<Offer> _jobOffers;
  bool _isLoading;
  bool _isFetched;
  bool _isError;

  bool get isLoading => _isLoading ?? false;
  bool get isFetched => _isFetched ?? false;
  bool get isError => _isError ?? false;
  List<Offer> get jobOffers => _jobOffers ?? [];

  void initialize() {
    _jobOffers = [];
    _isFetched = false;
    _isError = false;
    _isLoading = false;
  }

  void fetchJobOffers(context) async {
    try {
      if ((!isFetched || isError) && !isLoading) {
        _isLoading = true;
        final res = await OfferService().getJobOffers();
        if (res.statusCode == 401) return sessionExpired(context);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _jobOffers = Offer.listFromJson(jsonData["offres"]);
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

  void setJobOffers(List<Offer> value) {
    _jobOffers = value;
    notifyListeners();
  }

  void addJobOffer(Offer value) {
    _jobOffers.removeWhere((element) => element.id == value.id);
    _jobOffers.add(value);
    notifyListeners();
  }

  void remove(Offer value) {
    _jobOffers.removeWhere((element) => element.id == value.id);
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
