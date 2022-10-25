//input text with search icon
import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

inputTextDecoration(double radius, Icon prefixIcon, String hintText,
    String errorText, Widget suffixIcon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(10),
    //  fillColor: BLUE_LIGHT,
    hintText: hintText,
    hintStyle: TextStyle(color: GREY_DARK),
    errorMaxLines: 3,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    errorText: errorText,
    filled: true,
    errorStyle: TextStyle(color: Colors.deepOrange[200]),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: RED_DARK, width: 2.0),
        borderRadius: BorderRadius.circular(radius)),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 1.5, color: RED_LIGHT),
        borderRadius: BorderRadius.circular(radius)),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(radius)),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(radius)),
  );
}
