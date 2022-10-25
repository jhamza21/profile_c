import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class ExperienceService {
  Future<http.Response> getExperiences() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> getExperiencesByUserId(int userId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience/user/$userId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> createExperience(
      String title,
      String startDate,
      String endDate,
      String jobTime,
      Company company,
      String companyName) async {
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
          "work_type": jobTime,
          "type": EXPERIENCE_TYPE,
          "entreprise_id": company == null || company.name != companyName
              ? null
              : company.id,
          "entreprise_name": company == null || company.name != companyName
              ? companyName
              : null
        }));
  }

  Future<http.Response> updateExperience(
      int experienceId,
      String title,
      String startDate,
      String endDate,
      String jobTime,
      Company company,
      String companyName) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience/edit/$experienceId";
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
          "work_type": jobTime,
          "type": EXPERIENCE_TYPE,
          "entreprise_id": company == null || company.name != companyName
              ? null
              : company.id,
          "entreprise_name": company == null || company.name != companyName
              ? companyName
              : null
        }));
  }

  Future<http.Response> deleteExperience(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/experience/delete/" + id.toString();
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}
