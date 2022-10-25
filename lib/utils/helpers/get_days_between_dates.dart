int getDays(String startDate, String endDate) {
  DateTime start = DateTime.parse(startDate);
  DateTime end = DateTime.parse(endDate);
  int days = end.difference(start).inDays;
  return days;
}
