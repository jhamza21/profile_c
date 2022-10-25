import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/user.dart';

String getSenderName(User user) {
  try {
    if (user.civility == COMPANY_ROLE)
      return user.company.name;
    else
      return user.firstName + " " + user.lastName;
  } catch (e) {
    return "";
  }
}
