import 'package:flutter/material.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/modules/companyOffers/language_model.dart';

class Offer {
  final int id;
  final String title;
  final String description;
  List<Skill> skills;
  List<Skill> tools;
  final List<Language> languages;
  final String mobility;
  final Company company;
  final User companyRh;
  final double distance;
  final double note;
  final String createdAt;
  String offerType;
  final String duration;
  bool isAvailable;
  bool isPropositionSent;
  bool status;
  bool typeOffre;
  final String link;

  Offer(
      {@required this.id,
      @required this.title,
      @required this.description,
      this.skills,
      this.tools,
      this.languages,
      this.mobility,
      this.company,
      this.companyRh,
      this.distance,
      this.note,
      this.createdAt,
      this.offerType,
      this.duration,
      this.isAvailable,
      this.isPropositionSent,
      this.status,
      this.typeOffre,
      this.link});

  Offer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        skills = Skill.listFromJson(json["skills"]),
        tools = Skill.listFromJson(json["tools"]),
        languages = Language.listFromJson(json['languages']),
        mobility = json['mobilite'] ?? '',
        company = json["user"] != null
            ? Company.fromJson(json["user"]["entreprise"])
            : null,
        companyRh = json["user"] != null ? User.fromJson(json["user"]) : null,
        distance =
            json['eloignement'] != null ? json['eloignement'].toDouble() : null,
        note = json['sum'] != null ? json['sum'].toDouble() : null,
        createdAt = json['created_at'].substring(0, 10) ?? null,
        offerType = json['type'] ?? null,
        duration = json['duration'] ?? null,
        isAvailable = json['offre_id'] != null ? false : true,
        isPropositionSent = json['proposal_id'] != null ? true : false,
        status = json['status'] == 0 ? false : true,
        typeOffre = json['type_offre'] == 0 ? false : true,
        link = json['link'] ?? null;

  static List<Offer> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Offer.fromJson(value)).toList();
  }
}
