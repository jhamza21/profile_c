import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/models/invoice.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/models/qcm_level.dart';
import 'package:profilecenter/models/qcm_module.dart';
import 'package:profilecenter/models/user.dart';

class Message {
  int id;
  User sender;
  String text;
  String time;
  String date;
  String type;
  bool response;
  bool isSeen;
  Document document;
  QcmModule qcmModule;
  QcmLevel qcmLevel;
  Offer offer;
  Devis devis;
  Invoice invoice;
  bool isSending;
  bool isError;

  Message(
      {this.id,
      this.text,
      this.time,
      this.date,
      this.sender,
      this.isSeen,
      this.document,
      this.type,
      this.qcmModule,
      this.qcmLevel,
      this.response,
      this.offer,
      this.devis,
      this.invoice,
      this.isSending,
      this.isError});

  static Message fromEvent(Map<String, dynamic> e) {
    return Message(
        id: e["message"]["id"],
        date: e["message"]["created_at"].substring(0, 10),
        text: e["message"]["message"] ?? '',
        time: e["message"]["created_at"].substring(11, 19),
        sender: User.fromJson(e["user"]),
        qcmModule: e['module'] != null ? QcmModule.fromJson(e['module']) : null,
        qcmLevel: e['level'] != null ? QcmLevel.fromJson(e['level']) : null,
        document:
            e['document'] != null ? Document.fromJson(e['document']) : null,
        isSeen: e["message"]["seen"] == 0 ? false : true,
        response: e["message"]["response"] == null
            ? null
            : e["message"]["response"] == 1
                ? true
                : false,
        type: e["message"]["type"],
        offer: e['offre'] != null
            ? Offer.fromJson(e['offre'])
            : e['stage'] != null
                ? Offer.fromJson(e['stage'])
                : e['project'] != null
                    ? Offer.fromJson(e['project'])
                    : null,
        devis: e['devis'] != null ? Devis.fromJson(e['devis']) : null,
        invoice: e['invoice'] != null ? Invoice.fromJson(e['invoice']) : null,
        isSending: false,
        isError: false);
  }

  static Message fromJson(Map<String, dynamic> json) {
    Offer _offer;
    if (json["offre"] != null) {
      _offer = Offer.fromJson(json["offre"]);
      _offer.offerType = JOB_OFFER;
    } else if (json["stage"] != null) {
      _offer = Offer.fromJson(json["stage"]);
      _offer.offerType = INTERSHIP_OFFER;
    } else if (json["project"] != null) {
      _offer = Offer.fromJson(json["project"]);
      _offer.offerType = PROJECT_OFFER;
    }
    return Message(
        id: json['id'],
        sender: User.fromJson(json['user']),
        text: json['message'] ?? '',
        isSeen: json['seen'] == 0 ? false : true,
        time: json['created_at'].substring(11, 16) ?? '',
        date: json['created_at'].substring(0, 10),
        type: json['type'] ?? null,
        qcmModule:
            json['module'] != null ? QcmModule.fromJson(json['module']) : null,
        qcmLevel:
            json['level'] != null ? QcmLevel.fromJson(json['level']) : null,
        document: json['document'] != null
            ? Document.fromJson(json['document'])
            : null,
        response: json['response'] == null
            ? null
            : json['response'] == 0
                ? false
                : true,
        offer: _offer,
        devis: json['devis'] != null ? Devis.fromJson(json['devis']) : null,
        invoice:
            json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null,
        isSending: false,isError: false);
  }

  static List<Message> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Message.fromJson(value)).toList();
  }
}
