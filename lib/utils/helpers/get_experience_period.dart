import 'package:profilecenter/models/experience.dart';

String getExperiencePeriod(Experience experience) {
  DateTime start = DateTime.parse(experience.startDate);
  DateTime end = experience.endDate != null
      ? DateTime.parse(experience.endDate)
      : DateTime.now();
  int days = end.difference(start).inDays;
  int years = (days / 365).round();
  if (years != 0) return years.toString() + " an(s)";
  int months = (days / 30).round();
  if (months != 0) return months.toString() + " mois";
  return "1 mois";
}

String getExperiencesPeriod(List<Experience> experiences) {
  int days = 0;
  experiences.forEach((experience) {
    DateTime start = DateTime.parse(experience.startDate);
    DateTime end = experience.endDate != null
        ? DateTime.parse(experience.endDate)
        : DateTime.now();
    days += end.difference(start).inDays;
  });

  int years = (days / 365).round();
  if (years != 0) return years.toString() + " an(s)";
  int months = (days / 30).round();
  if (months != 0) return months.toString() + " mois";
  return "1 mois";
}
