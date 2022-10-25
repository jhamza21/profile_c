import 'package:flutter/material.dart';

class Language {
  final int id;
  final String title;
  final List<Language> levels;
  String selectedLevel;
  Language({
    @required this.id,
    @required this.title,
    @required this.levels,
  });

  Language.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        levels = Language.listFromJson(json['levels']),
        selectedLevel =
            json["pivot"] != null ? json["pivot"]["level_name"] : '';

  static List<Language> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Language.fromJson(value)).toList();
  }
}
