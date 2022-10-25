import 'package:profilecenter/models/document.dart';

class MentionLegalData {
  int id;
  String capital;
  String siret;
  String rcs;
  String naf;
  String tva;
  String facture;
  String taxe;
  Document kbisDocument;
  Document statusDocument;

  MentionLegalData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        capital = json["capital"].toString() ?? '',
        siret = json["siret"].toString() ?? '',
        rcs = json["rcs"] ?? '',
        naf = json["naf"] ?? '',
        tva = json["numero_tva"] ?? '',
        facture = json["facture_payable_sous"].toString() ?? '',
        taxe = json["taxe"].toString() ?? '',
        kbisDocument = Document.fromJson(json["kbis_document"]),
        statusDocument = json["status_document"] != null
            ? Document.fromJson(json["status_document"])
            : null;
}
