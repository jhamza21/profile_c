import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class MissionService {
  Future<http.Response> getMissions() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/mission";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> createMission(String title, String startDate,
      String endDate, Company company, String companyName) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": title,
          "start_date": startDate,
          "end_date": endDate,
          "type": MISSION_TYPE,
          "entreprise_id": company == null || company.name != companyName
              ? null
              : company.id,
          "entreprise_name": company == null || company.name != companyName
              ? companyName
              : null
        }));
  }

  Future<http.Response> updateMission(
      int missionId,
      String title,
      String startDate,
      String endDate,
      Company company,
      String companyName) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience/edit/$missionId";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": title,
          "start_date": startDate,
          "end_date": endDate,
          "type": MISSION_TYPE,
          "entreprise_id": company == null || company.name != companyName
              ? null
              : company.id,
          "entreprise_name": company == null || company.name != companyName
              ? companyName
              : null
        }));
  }

  Future<http.Response> deleteMission(
    int id,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience/delete/" + id.toString();
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}
