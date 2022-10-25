import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class AuthService {
  //check password
  Future<http.Response> checkPassword(String password) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/checkPassword";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"password": password}));
  }

//login
  Future<http.Response> signIn(String email, String password) async {
    var url = URL_BACKEND + "api/login";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({"email": email, "password": password}));
  }

//sign up
  Future<http.Response> signUp(
      String email, String password, String role, String gender) async {
    var url = URL_BACKEND + "api/r";

    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "email": email,
          "password": password,
          "password_confirmation": password,
          "role": role == null ? "entreprise" : role,
          "gender": gender
        }));
  }

  //forgot password
  Future<http.Response> forgotPassword(String email) async {
    var url = URL_BACKEND + "api/sendPasswordResetLink";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({"email": email}));
  }

//resend link activation account
  Future<http.Response> resendLink(String email) async {
    var url = URL_BACKEND + "api/resend?email=" + email;
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json"
      },
    );
  }

  //check if user token is valid
  Future<http.Response> checkToken() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/tokenIsValid";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  // Otp
  Future<http.Response> validateOtp(String code) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/2fa";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "code": code,
        }));
  }

  //Resend Otp
  Future<http.Response> sendOtpEmail() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/resend";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({}));
  }

  Future<http.Response> getCgu() async {
    var url = URL_BACKEND + "api/gcu";
    final res = await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
    });
    return res;
  }
}
