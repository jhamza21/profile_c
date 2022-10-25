import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

class SearchSkillCard extends StatelessWidget {
  final String title;
  final void Function(String) callback;
  SearchSkillCard(this.title, this.callback);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback(title),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0), color: RED_BURGUNDY),
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            children: [
              Icon(
                Icons.remove_circle,
                color: RED_LIGHT,
                size: 18,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
