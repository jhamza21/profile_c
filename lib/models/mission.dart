import 'package:flutter/material.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/models/offer.dart';

class Mission {
  final int id;
  final Offer offer;
  final Company company;
  final Devis devis;
  final bool inProgress;
  final double turnover;
  final int note;
  final String comment;

  Mission({
    @required this.id,
    @required this.offer,
    @required this.company,
    @required this.devis,
    @required this.inProgress,
    @required this.turnover,
    @required this.note,
    @required this.comment,
  });

  Mission.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        offer = Offer.fromJson(json['project']),
        company = Company.fromJson(json['entreprise']),
        devis = Devis.fromJson(json['devis']),
        inProgress = json['status'] == 0 ? true : false,
        turnover = json['chiffre_affaire'].toDouble(),
        note = json['note'] ?? null,
        comment = json['commentaire'];
  static List<Mission> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Mission.fromJson(value)).toList();
  }
}
