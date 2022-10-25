import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

SizedBox circularProgress = SizedBox(
    height: 15.0,
    width: 15.0,
    child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(RED_LIGHT)));
