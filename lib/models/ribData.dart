import 'package:profilecenter/models/document.dart';

class RibData {
  int id;
  String name;
  String address;
  String postal;
  String region;
  String country;
  Document ribDocument;

  RibData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json["full_name"] ?? '',
        address = json["adress"] ?? '',
        postal = json["code_postal"] ?? '',
        region = json["ville"] ?? '',
        country = json["pays"] ?? '',
        ribDocument = Document.fromJson(json["rib_document"]);
}
