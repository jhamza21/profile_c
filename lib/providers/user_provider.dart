import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:profilecenter/models/address.dart';
import 'package:profilecenter/models/devise.dart';
import 'package:profilecenter/models/pack.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/auth_service.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/core/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  User _user;
  bool _isLoggedIn;
  int _profileProgress;
  bool _isLoading;

  int get profileProgress => _profileProgress ?? 0;
  User get user => _user ?? null;
  bool get isLoggedIn => _isLoggedIn ?? false;
  bool get isLoading => _isLoading ?? false;

  Future<bool> checkLoggedInUser() async {
    try {
      _isLoading = true;
      String _token = await SecureStorageService.readToken();
      if (_token == null) {
        _isLoggedIn = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final response = await AuthService().checkToken();
      if (response.statusCode == 401 || response.statusCode == 403)
        throw sessionExpired;
      if (response.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(response.body);
      _user = User.fromJson(jsonData["user"]);
      checkFirebaseToken();
      _isLoggedIn = true;
      _isLoading = false;
      calculateProfileProgress();
      notifyListeners();
      return false;
    } catch (error) {
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void checkFirebaseToken() async {
    try {
      String token = await FirebaseMessaging.instance.getToken();
      if (token != _user.fcmToken) {
        await UserService().setFirebaseToken(_user.id, token);
      }
    } catch (e) {}
  }

  void calculateProfileProgress() {
    int _progress = 0;
    if (_user.role == "entreprise" && _user.company.name != "") _progress += 16;
    if (_user.firstName != "") _progress += 20;
    if (_user.address != null) _progress += 16;
    if (_user.email != "") _progress += 16;
    if (_user.role != "entreprise" && _user.mobile != "") _progress += 16;
    if (_user.role == "entreprise" && _user.company.mobile != "")
      _progress += 16;
    if (_user.role != "entreprise" && _user.birthday != "") _progress += 16;
    if (_user.role != "entreprise" && _user.image != "") _progress += 16;
    if (_user.role == "entreprise" && _user.company.image != "")
      _progress += 16;

    _profileProgress = _progress;
  }

  void logoutUser() async {
    SecureStorageService.deleteToken();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  void setQcmCertifications(List<QcmCertification> qcmCertifs) {
    _user.qcmCertifications = qcmCertifs;
    notifyListeners();
  }

  void setNotification(bool l) {
    _user.notification = l;
    notifyListeners();
  }

  void setStripeId(String l) {
    _user.stripeId = l;
    notifyListeners();
  }

  void setAddress(Address l) {
    _user.address = l;
    calculateProfileProgress();
    notifyListeners();
  }

  void setCompanyName(String l) {
    _user.company.name = l;
    calculateProfileProgress();
    notifyListeners();
  }

  void setCompanyLogo(String l) {
    _user.company.image = l;
    calculateProfileProgress();
    notifyListeners();
  }

  void setCompanyMobile(String l) {
    _user.company.mobile = l;
    calculateProfileProgress();
    notifyListeners();
  }

  void setIsLoggedIn(bool l) {
    _isLoggedIn = l;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    calculateProfileProgress();
    notifyListeners();
  }

  void setUserName(String firstName, String lastName) {
    _user.firstName = firstName;
    _user.lastName = lastName;
    calculateProfileProgress();
    notifyListeners();
  }

  void setBirthday(String birthday) {
    _user.birthday = birthday;
    calculateProfileProgress();
    notifyListeners();
  }

  void setEmail(String email) {
    _user.email = email;
    notifyListeners();
  }

  void setSalary(double salary) {
    _user.salary = salary;
    notifyListeners();
  }

  void setDisponibility(int disponibility) {
    _user.disponibility = disponibility;
    notifyListeners();
  }

  void setresidencyPermit(String residencyPermit) {
    _user.residencyPermit = residencyPermit;
    notifyListeners();
  }

  void setReturnToJobDate(String returnDate) {
    _user.returnToJobDate = returnDate;
    notifyListeners();
  }

  void setUserIsDiponible(bool value) {
    _user.isDisponible = value;
    notifyListeners();
  }

  void setMobility(String mobility) {
    _user.mobility = mobility;
    notifyListeners();
  }

  void setMobile(String mobile) {
    _user.mobile = mobile;
    calculateProfileProgress();
    notifyListeners();
  }

  void setDevise(Devise devise) {
    _user.devise = devise;
    notifyListeners();
  }

  void setPack(Pack pack) {
    _user.pack = pack;
    notifyListeners();
  }

  void setPhoto(String path) {
    _user.image = path;
    calculateProfileProgress();
    notifyListeners();
  }

  void setStars(int value) {
    _user.stars = value;
  }
}
