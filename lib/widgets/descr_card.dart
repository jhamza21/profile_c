import 'package:flutter/material.dart';

class DescrCard extends StatelessWidget {
  final Icon icon;
  final String title;
  final Color color;
  DescrCard(this.icon, this.title, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: color),
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon != null ? Center(child: icon) : SizedBox.shrink(),
            SizedBox(width: 5.0),
            title != null
                ? Text(
                    title,
                    style: TextStyle(color: Colors.white),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
