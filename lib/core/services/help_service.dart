import 'dart:io';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:http/http.dart' as http;

class CallApi {
  //help us
  Future<http.StreamedResponse> sendReclam(
      {String contactName,
      String contactEmail,
      String contactSubject,
      String contactMessage,
      File file}) async {
    String url = URL_BACKEND + "api/contact";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('document', file.path));
    request.fields.addAll({
      'name': contactName,
      'email': contactEmail,
      'subject': contactSubject,
      'message': contactMessage
    });

    return request.send();
  }
}
