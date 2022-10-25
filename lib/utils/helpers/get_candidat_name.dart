String getCandidatName(String firstName, String lastName, bool hide) {
  if (hide) return "XXXXX XXXXX";
  return "$firstName $lastName";
}
