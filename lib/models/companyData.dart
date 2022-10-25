import 'package:profilecenter/models/document.dart';

class CompanyData {
  int id;
  String companyName;
  String address;
  String legalForm;
  String firstName;
  String lastName;
  String birthday;
  String region;
  String nationality;
  Document kbisDocument;

  CompanyData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        companyName = json["name_company"] ?? '',
        address = json["adress"] ?? '',
        legalForm = json["sas"] ?? '',
        firstName = json["prenom_representant"] ?? '',
        lastName = json["nom_representant"] ?? '',
        birthday = json["date_naissance"] ?? '',
        region = json["ville"] ?? '',
        nationality = json["nationalite"] ?? '',
        kbisDocument = Document.fromJson(json["kbis_document"]);
}
