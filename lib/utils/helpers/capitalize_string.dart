String capitalizeString(String value) {
  if (value.isEmpty)
    return null;
  else
    return "${value.trim()[0].toUpperCase()}${value.trim().substring(1)}";
}
