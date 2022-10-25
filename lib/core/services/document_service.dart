import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class DocumentService {
//add document
  Future<http.StreamedResponse> addDocument(
      File file, String type, bool primary) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/create";
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('document', file.path));
    request.fields.addAll(
        {'type': type, 'primary': primary == null || !primary ? "0" : "1"});

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }

  //get documents by type
  Future<http.Response> getDocuments(String type) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/documents?type=" + type;
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get documents by id
  Future<http.Response> getDocumentById(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/doc/$id";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //download document
  Future<http.Response> downloadDocument(int documentId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/decryptFile?file_id=$documentId";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //delete document
  Future<http.Response> deleteDocument(int documentId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/delete/$documentId";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //delete document
  Future<http.Response> switchDocument() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/switchCvDocuments";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //send mention legal
  Future<http.StreamedResponse> sendLegalMention(
      Document kbis,
      Document status,
      String capital,
      String siret,
      String rcs,
      String naf,
      String tva,
      String factureDatePay,
      String taxe) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/create/mentionLegal";
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(
        await http.MultipartFile.fromPath('kbis_document', kbis.file.path));
    if (status != null)
      request.files.add(await http.MultipartFile.fromPath(
          'status_document', status.file.path));
    request.fields.addAll({
      'capital': capital,
      'siret': siret,
      'rcs': rcs,
      'naf': naf,
      'numero_tva': tva,
      'facture_payable_sous': factureDatePay,
      'taxe': taxe,
    });

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }

  //update mention legal
  Future<http.StreamedResponse> updateLegalMention(
      Document kbis,
      Document status,
      bool deleteStatusDoc,
      String capital,
      String siret,
      String rcs,
      String naf,
      String tva,
      String factureDatePay,
      String taxe) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/update/mentionLegal";
    var request = http.MultipartRequest("POST", Uri.parse(url));
    if (kbis != null)
      request.files.add(
          await http.MultipartFile.fromPath('kbis_document', kbis.file.path));
    if (status != null)
      request.files.add(await http.MultipartFile.fromPath(
          'status_document', status.file.path));
    request.fields.addAll({
      'deleteStatusDoc': deleteStatusDoc ? "1" : "0",
      'capital': capital,
      'siret': siret,
      'rcs': rcs,
      'naf': naf,
      'numero_tva': tva,
      'facture_payable_sous': factureDatePay,
      'taxe': taxe,
    });

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }

//get mention legal
  Future<http.Response> getMentionLegal() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/mentionLegal";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //send company data
  Future<http.StreamedResponse> sendCompanyData(
      Document kbis,
      String companyName,
      String address,
      String legal,
      String firstName,
      String lastName,
      String birthday,
      String region,
      String nationality) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/create/dataCompany";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(
        await http.MultipartFile.fromPath('kbis_document', kbis.file.path));
    request.fields.addAll({
      'name_company': companyName,
      'adress': address,
      'sas': legal,
      'prenom_representant': firstName,
      'nom_representant': lastName,
      'date_naissance': birthday,
      'ville': region,
      'nationalite': nationality
    });

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }

  //update company data
  Future<http.StreamedResponse> updateCompanyData(
      Document kbis,
      String companyName,
      String address,
      String legal,
      String firstName,
      String lastName,
      String birthday,
      String region,
      String nationality) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/update/dataCompany";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    if (kbis != null)
      request.files.add(
          await http.MultipartFile.fromPath('kbis_document', kbis.file.path));
    request.fields.addAll({
      'name_company': companyName,
      'adress': address,
      'sas': legal,
      'prenom_representant': firstName,
      'nom_representant': lastName,
      'date_naissance': birthday,
      'ville': region,
      'nationalite': nationality
    });

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }

//get company data
  Future<http.Response> getCompanyData() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/dataCompany";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get candidat portfolio
  Future<http.Response> getCandidatPortfolio(int userId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/cv/$userId";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get candidat cover letter
  Future<http.Response> getCandidatVideoPresentation(int userId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/video/$userId";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.StreamedResponse> extractDataFromKbis(File file) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/document/parser";
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('pdf_file', file.path));
    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    });
    return await request.send();
  }
}
