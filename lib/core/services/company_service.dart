import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class CompanyService {
  //return company name suggestions
  Future<List<Company>> getSuggetions(String text) async {
    try {
      String token = await SecureStorageService.readToken();

      if (text != "") {
        var url = URL_BACKEND + "api/entreprise/suggestion?text=" + text;
        var res = await http.get(
          Uri.parse(url),
          headers: {
            "content-type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        if (res.statusCode != 200) throw "ERROR_SERVER";
        return Company.listFromJson(json.decode(res.body)["entreprises"]);
      } else
        return [];
    } catch (e) {
      return [];
    }
  }

  //update user mobile
  Future<http.Response> updateMobile(int id, String mobile) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/" + id.toString();
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"phone": mobile}));
  }

  Future<http.Response> updateName(int id, String name) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/" + id.toString();
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"name_company": name}));
  }

  //update ulogo
  Future<http.StreamedResponse> updatePhoto(int id, File img) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/" + id.toString();
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath('logo_company', img.path));

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }
}
