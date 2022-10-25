import 'package:flutter/material.dart';
import 'package:profilecenter/core/services/local_storage_service.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _appLocale = Locale("fr");
  Locale get appLocale => _appLocale ?? Locale("fr");

  fetchLocale() async {
    String lang = await LocalStorageService().getAppLanguage();
    if (lang == null) {
      LocalStorageService().setAppLanguage('fr');
      _appLocale = Locale('fr');
      return Null;
    }
    _appLocale = Locale(lang);
    return Null;
  }

  void changeLanguage(String type) async {
    if (_appLocale.languageCode == type) {
      return;
    }
    if (type == "en") {
      _appLocale = Locale("en");
      LocalStorageService().setAppLanguage('en');
    } else if (type == "fr") {
      _appLocale = Locale("fr");
      LocalStorageService().setAppLanguage('fr');
    } else if (type == "da") {
      _appLocale = Locale("da");
      LocalStorageService().setAppLanguage('da');
    }
    notifyListeners();
  }
}
