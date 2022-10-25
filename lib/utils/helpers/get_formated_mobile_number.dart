//example input : TN / +216 / 55589087
//output +216 55589087
String getFormattedMobileNumber(String mobile) {
  if (mobile == '' || mobile == null)
    return '';
  else {
    List<String> res = mobile.split("/");
    return res[1] + " " + res[2];
  }
}
