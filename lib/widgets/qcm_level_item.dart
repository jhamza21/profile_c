import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

class QcmLevelItem extends StatelessWidget {
  final String title;
  QcmLevelItem(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: RED_LIGHT,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: GREY_DARK,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
                child: Text(
              title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )),
          ),
        ),
      ),
    );
  }
}
