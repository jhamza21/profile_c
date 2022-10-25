import 'dart:convert';

import 'package:flutter/material.dart';

class SearchSuggestion {
  final String title;
  List<String> skills;
  String role;
  String experience;
  String salary;

  String distance;
  String mobility;
  String language;
  String offerType;

  SearchSuggestion({
    @required this.title,
    @required this.skills,
    @required this.role,
    @required this.experience,
    @required this.salary,
    @required this.distance,
    @required this.mobility,
    @required this.offerType,
    @required this.language,
  });

  SearchSuggestion.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        skills = json["skills"].cast<String>(),
        role = json['role'] ?? null,
        experience = json['experience'] ?? null,
        salary = json['salary'] ?? null,
        distance = json['distance'] ?? null,
        mobility = json['mobility'] ?? null,
        language = json['language'] ?? null,
        offerType = json['offerType'] ?? null;

  static Map<String, dynamic> toMap(SearchSuggestion searchSuggestion) => {
        'title': searchSuggestion.title,
        'skills': searchSuggestion.skills,
        'role': searchSuggestion.role,
        'experience': searchSuggestion.experience,
        'salary': searchSuggestion.salary,
        'distance': searchSuggestion.distance,
        'mobility': searchSuggestion.mobility,
        'language': searchSuggestion.language,
        'offerType': searchSuggestion.offerType,
      };

  static String encode(List<SearchSuggestion> searchSuggestions) => json.encode(
        searchSuggestions
            .map<Map<String, dynamic>>((music) => SearchSuggestion.toMap(music))
            .toList(),
      );

  static List<SearchSuggestion> decode(String searchSuggestions) =>
      (json.decode(searchSuggestions) as List<dynamic>)
          .map<SearchSuggestion>((item) => SearchSuggestion.fromJson(item))
          .toList();
}
