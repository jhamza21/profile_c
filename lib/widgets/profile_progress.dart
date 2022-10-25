import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/modules/infoCandidate/candidate_info.dart';

class ProfileProgress extends StatelessWidget {
  final int value;
  ProfileProgress(this.value);
  @override
  Widget build(BuildContext context) {
    return value == 100
        ? SizedBox.shrink()
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed(CandidateInfo.routeName),
                    child: Text(
                      getTranslate(context, "COMPLETE_PROFILE"),
                      style: TextStyle(color: GREY_LIGHt),
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Container(
                    height: 21.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: GREEN_LIGHT, width: 0.1),
                        borderRadius: BorderRadius.circular(20.0),
                        color: GREEN_DARK),
                    child: Center(
                      child: Text(
                        (value ~/ 5).toString() + "/20",
                        style: TextStyle(color: GREEN_LIGHT),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: BLUE_LIGHT,
                  minHeight: 8,
                  valueColor: new AlwaysStoppedAnimation<Color>(GREEN_LIGHT),
                ),
              ),
            ],
          );
  }
}
