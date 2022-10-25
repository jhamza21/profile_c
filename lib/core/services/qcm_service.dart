import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/qcm_question.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class QcmService {
  //get qcm certifications
  Future<http.Response> getCertifications() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/qcm/user/certification";
    final res = await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    return res;
  }

  //get qcm modules
  Future<http.Response> getModules() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/qcm/modules";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

//create skill
  Future<http.Response> getQuestion(
    int idModule,
    int idLevel,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND +
        "api/qcm/question?module_id=" +
        idModule.toString() +
        "&qcm_level_id=" +
        idLevel.toString();
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //create skill
  Future<http.Response> sendResponses(
      int moduleId, int levelId, List<QcmQuestion> questions) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/qcm/user/answers";
    List<int> answersId = [];
    questions.forEach((element) {
      if (element.responseId != null) answersId.add(element.responseId);
    });
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "answer_id": answersId,
          "module_id": moduleId,
          "qcm_level_id": levelId
        }));
  }

  //get qcm time
  Future<http.Response> getQcmTime(int idModule, int idLevel) async {
    String token = await SecureStorageService.readToken();
    var url =
        URL_BACKEND + "api/qcm/time?module_id=$idModule&level_id=$idLevel";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get latest qcm request
  Future<http.Response> getLatestQcmRequest(int idModule, int idLevel) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND +
        "api/chat/getLatestQcmRequest?module_id=$idModule&level_id=$idLevel";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> sendQcmEvaluationRequest(
      int receiverId, int moduleId, int levelId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/qcm";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "receiver_id": receiverId,
          "module_id": moduleId,
          "level_id": levelId
        }));
  }

  Future<http.Response> refuseQcmEvaluationRequest(int messageid) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/qcm/refuse/$messageid";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.Response> acceptQcmEvaluationRequest(
      int messageid, int note) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/qcm/accept/$messageid";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "note": note,
        }));
  }
}
