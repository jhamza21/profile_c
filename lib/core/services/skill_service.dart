import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class SkillService {
//create skill
  Future<http.Response> createSkill(String skill) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/skills/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "name": skill,
        }));
  }

  //get user skills
  Future<http.Response> getUserSkills() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/skills";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get all skills
  Future<http.Response> getPlatformSkills() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/competence";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //create skill
  Future<http.Response> deleteSkill(
    int id,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/skills/delete/" + id.toString();
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<List<Skill>> getSuggetions(String text) async {
    try {
      String token = await SecureStorageService.readToken();
      if (text != "") {
        var url = URL_BACKEND + "api/skills/filtredSkills?text=" + text;
        var res = await http.get(
          Uri.parse(url),
          headers: {
            "content-type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        if (res.statusCode != 200) throw "ERROR_SERVER";
        return Skill.listFromJson(json.decode(res.body)["skills"]);
      } else
        return [];
    } catch (e) {
      return [];
    }
  }
}
