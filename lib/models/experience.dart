import 'package:flutter/material.dart';
import 'package:profilecenter/models/company.dart';

class Experience {
  final int id;
  final String title;
  final String jobTime;
  final String startDate;
  final String endDate;
  final Company company;
  final String companyName;
  final String type;

  Experience({
    @required this.id,
    @required this.title,
    @required this.jobTime,
    @required this.startDate,
    @required this.endDate,
    @required this.company,
    @required this.companyName,
    @required this.type,
  });

  Experience.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        startDate = json['start_date'] ?? '',
        endDate = json['end_date'] ?? null,
        jobTime = json['work_type'] ?? '',
        type = json['type'] ?? null,
        companyName = json['entreprise_name'] ?? null,
        company = json['entreprise'] != null
            ? Company.fromJson(json['entreprise'])
            : null;
  static List<Experience> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Experience.fromJson(value)).toList();
  }
}
