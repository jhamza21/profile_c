import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset(
              ERROR_IMAGE,
              color: RED_DARK,
            ),
          ),
          SizedBox(height: 30),
          Text(
            getTranslate(context, "ERROR_MSG"),
            style: TextStyle(color: GREY_LIGHt),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
