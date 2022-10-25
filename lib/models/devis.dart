import 'package:flutter/material.dart';

class Devis {
  final int id;
  final String devisNumber;
  final int freelancerId;
  final int companyId;
  final int projectId;
  final String description;
  final String emissionDate;
  final String startDate;
  final String endDate;
  final double tjm;
  final int projectPeriod;
  final int meetingDays;
  final int teleworkDays;
  final int workDaysPerMonth;
  final bool forfaitType;
  final double tva;
  final double commisionPc;
  final int devisDocId;
  final int deviseId;

  bool status;

  Devis({
    @required this.id,
    @required this.devisNumber,
    @required this.freelancerId,
    @required this.companyId,
    @required this.projectId,
    @required this.description,
    @required this.emissionDate,
    @required this.startDate,
    @required this.endDate,
    @required this.tjm,
    @required this.projectPeriod,
    @required this.meetingDays,
    @required this.teleworkDays,
    @required this.workDaysPerMonth,
    @required this.forfaitType,
    @required this.tva,
    @required this.commisionPc,
    @required this.devisDocId,
    @required this.deviseId,
    @required this.status,
  });

  Devis.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        devisNumber = json['devis_number'] ?? '',
        freelancerId = json['freelancer_id'] ?? null,
        companyId = json['company_id'] ?? null,
        projectId = json['project_id'] ?? null,
        description = json['description'] ?? '',
        emissionDate = json['emission_date'] ?? '',
        startDate = json['debut_mission'] ?? '',
        endDate = json['fin_mission'] ?? '',
        tjm = json['tjm'] != null ? json['tjm'].toDouble() : null,
        projectPeriod = json['project_period'] ?? null,
        meetingDays = json['reunion_hebdomadaire'] ?? null,
        teleworkDays = json['nbre_jrs_teletravail'] ?? null,
        workDaysPerMonth = json['nb_jrs_travail'] ?? null,
        forfaitType = json['mission_forfait'] == 1 ? true : false,
        tva = json['tva'].toDouble(),
        commisionPc = json['commission_pc'].toDouble(),
        devisDocId = json['devis_doc_id'] ?? null,
        deviseId = json["devise_id"] ?? null,
        status = json['status'] == 0 ? false : true;

  static List<Devis> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Devis.fromJson(value)).toList();
  }
}
