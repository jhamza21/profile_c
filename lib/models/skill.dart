import 'package:flutter/material.dart';

class Skill {
  final int id;
  final String title;
  final List<Skill> subSkills;

  Skill({
    @required this.id,
    @required this.title,
    @required this.subSkills,
  });

  Skill.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] != null ? json['title'] : json['name'],
        subSkills = Skill.listFromJson(json['sub_competences']);

  static List<Skill> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Skill.fromJson(value)).toList();
  }
}
