import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

class StatisticItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  StatisticItem(this.icon, this.title, this.subtitle);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: BLUE_LIGHT,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Text(title,
            style: TextStyle(
              color: Colors.white,
            )),
        subtitle: subtitle == null
            ? SizedBox.shrink()
            : Text(subtitle,
                style: TextStyle(
                  color: GREY_LIGHt,
                )),
        leading: SizedBox(height: 50, width: 50, child: icon));
  }
}
