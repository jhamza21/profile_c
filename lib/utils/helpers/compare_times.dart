bool isTimeBigger(String startTime, String endTime) {
  try {
    int startHours = int.parse(startTime.split(":")[0]);
    int endHours = int.parse(endTime.split(":")[0]);
    if (startHours > endHours)
      return false;
    else if (startHours < endHours)
      return true;
    else {
      int startMins = int.parse(startTime.split(":")[1]);
      int endMins = int.parse(endTime.split(":")[1]);
      if (startMins > endMins || startMins == endMins)
        return false;
      else
        return true;
    }
  } catch (e) {
    return false;
  }
}
