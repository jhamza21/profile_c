import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/company.dart';

Widget getCompanyAvatar(
    String companyName, Company company, Color backgroundColor, double size) {
    
  if (companyName != null)
    return CircleAvatar(
        radius: size,
        backgroundColor: backgroundColor,
        child: Text(companyName[0].toUpperCase()));
  return CircleAvatar(
    radius: size,
    backgroundColor: backgroundColor,
    child: company.image != ''
        ? SizedBox.shrink()
        : company.name != ''
            ? Text(company.name[0].toUpperCase())
            : SizedBox.shrink(),
    backgroundImage: company.image != ''
        ? NetworkImage(URL_BACKEND + company.image)
        : null,
  );
}
