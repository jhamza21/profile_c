import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CompareItem extends StatelessWidget {
  final String candidatA;
  final String candidatB;
  final Widget iconCompare;
  CompareItem(this.candidatA, this.iconCompare, this.candidatB);
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Stack(
            children: [
              Container(
                  width: width * 0.40,
                  child:
                      Center(child: Text(candidatA != null ? candidatA : ''))),
              if (userProvider.user.pack.notAllowed
                  .contains(COMPARATOR_DATA_PRIVILEGE))
                ClipRect(
                  child: new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                        width: width * 0.40,
                        color: BLUE_DARK.withOpacity(0.6),
                        child: Center(
                            child: Text(
                          candidatA != null ? candidatA : '',
                          style: TextStyle(color: BLUE_DARK.withOpacity(0.1)),
                        ))),
                  ),
                ),
            ],
          ),
          iconCompare,
          Stack(
            children: [
              Container(
                  width: width * 0.40,
                  child:
                      Center(child: Text(candidatB != null ? candidatB : ''))),
              if (userProvider.user.pack.notAllowed
                  .contains(COMPARATOR_DATA_PRIVILEGE))
                ClipRect(
                  child: new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                        width: width * 0.40,
                        color: BLUE_DARK.withOpacity(0.6),
                        child: Center(
                            child: Text(
                          candidatB != null ? candidatB : '',
                          style: TextStyle(color: BLUE_DARK.withOpacity(0.1)),
                        ))),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
