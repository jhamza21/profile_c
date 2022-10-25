import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';

// ignore: must_be_immutable
class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: isActive ? 10 : 8,
      width: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : BLUE_LIGHT,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
