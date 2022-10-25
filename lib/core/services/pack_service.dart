import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class PackService {
  Future<http.Response> getPacks() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/package";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //update user pack
  Future<http.Response> updatePack(int id, int packId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/package/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"package_id": packId}));
  }
}
