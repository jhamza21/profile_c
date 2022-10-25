import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/user.dart';

Widget getUserAvatar(User user, Color backgroundColor, double size) {
  return CircleAvatar(
    radius: size,
    backgroundColor: backgroundColor,
    child: user.image != ''
        ? SizedBox.shrink()
        : user.firstName != ''
            ? Text(user.firstName[0] + user.lastName[0])
            : user.role != null && user.role.isNotEmpty
                ? Text(
                    user.role[0].toUpperCase(),
                    style: TextStyle(fontSize: 12),
                  )
                : SizedBox.shrink(),
    backgroundImage:
        user.image != '' ? NetworkImage(URL_BACKEND + user.image) : null,
  );
}
