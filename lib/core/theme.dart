// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
        scaffoldBackgroundColor: BLUE_DARK,
        primaryColor: RED_DARK,
        accentColor: RED_DARK,
        hintColor: GREY_LIGHt,
        unselectedWidgetColor: GREY_LIGHt,
        dividerColor: GREY_LIGHt,
        disabledColor: GREY_LIGHt,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: Colors.white,
              padding: EdgeInsets.all(15.0),
              backgroundColor: RED_DARK,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              )),
        ));
  }
}
