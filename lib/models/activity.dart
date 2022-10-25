import 'package:flutter/material.dart';

class Activity {
  final int id;
  final int nbAppearance;
  final int nbCompare;
  final int nbProfileView;
  final int nbFavorite;
  final int nbDiscussion;
  final String date;

  Activity({
    @required this.id,
    @required this.nbAppearance,
    @required this.nbCompare,
    @required this.nbProfileView,
    @required this.nbFavorite,
    @required this.nbDiscussion,
    @required this.date,

  });

  Activity.fromJson(Map<String, dynamic> json)
  
      : id = json['id'],
        nbAppearance = json['apparition'] ?? 0,
        nbCompare = json['comparaison'] ?? 0,
        nbProfileView = json['vue_profile'] ?? 0,
        nbFavorite = json['favoris'] ?? 0,
        nbDiscussion = json['discussion'] ?? 0,
        date = json['created_at'].substring(0, 10) ?? null;

  static List<Activity> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Activity.fromJson(value)).toList();
  }
}
