import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

class FinanceItem extends StatelessWidget {
  final String value;
  final String text;
  FinanceItem({this.text, this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70.0,
        decoration: BoxDecoration(
          color: BLUE_LIGHT,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21.0,
                  color: Colors.white),
            ),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold, color: GREY_LIGHt),
            )
          ],
        ),
      ),
    );
  }
}
