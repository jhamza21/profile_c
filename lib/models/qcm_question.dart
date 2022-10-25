import 'package:flutter/material.dart';

class QcmQuestion {
  final int id;
  final String title;
  final List<Suggestion> suggestions;
  int responseId;

  QcmQuestion({
    @required this.id,
    @required this.title,
    @required this.suggestions,
    @required this.responseId,
  });
  QcmQuestion.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        suggestions = Suggestion.listFromJson(json["answers"]);
  static List<QcmQuestion> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => QcmQuestion.fromJson(value)).toList();
  }
}

class Suggestion {
  final int id;
  final String title;

  Suggestion({
    @required this.id,
    @required this.title,
  });

  Suggestion.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['name'];
  static List<Suggestion> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Suggestion.fromJson(value)).toList();
  }
}
