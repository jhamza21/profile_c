import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class DeviseService {
  //get platform available devise
  Future<http.Response> getDevises() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/devise";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //update user devise
  Future<http.Response> updateDevise(int id, int deviseId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/" + id.toString();
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"devise_id": deviseId}));
  }
}
