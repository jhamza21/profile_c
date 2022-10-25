import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

class EmptyDataCard extends StatelessWidget {
  final String title;
  EmptyDataCard(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: GREY_LIGHt),
            ),
          ],
        ));
  }
}
