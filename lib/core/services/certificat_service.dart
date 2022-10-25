import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class CertificatService {
  Future<http.Response> getCertificats() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/certification";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> createCertificat(String title, String delivered,
      String validity, Company company, String companyName) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/certification/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": title,
          "taken_date": delivered,
          "validity": validity,
          "entreprise_id": company == null || company.name != companyName
              ? null
              : company.id,
          "entreprise_name": company == null || company.name != companyName
              ? companyName
              : null
        }));
  }

  Future<http.Response> updateCertificat(
      int certificatId,
      String title,
      String delivered,
      String validity,
      Company company,
      String companyName) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/certification/edit/$certificatId";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": title,
          "taken_date": delivered,
          "validity": validity,
          "entreprise_id": company == null || company.name != companyName
              ? null
              : company.id,
          "entreprise_name": company == null || company.name != companyName
              ? companyName
              : null
        }));
  }

  Future<http.Response> deleteCertificat(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/certification/delete/" + id.toString();
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}
