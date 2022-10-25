import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/modules/infoCompany/company_info.dart';
import 'package:provider/provider.dart';

class CompleteProfileNoticeCompany extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return userProvider.profileProgress == 100
        ? SizedBox.shrink()
        : Container(
            decoration: BoxDecoration(
                color: RED_LIGHT, borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(NOTIFICATION_ICON),
                  SizedBox(height: 10.0),
                  Text(getTranslate(context, 'COMPLETE_PROFILE_NOTICE_COMPANY'),
                      style: TextStyle(
                        color: RED_BURGUNDY,
                      )),
                  SizedBox(height: 10.0),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(CompanyInfo.routeName);
                      },
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                              Size(double.infinity, 30)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.red))),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          foregroundColor: MaterialStateProperty.all(RED_DARK)),
                      child: Text(getTranslate(context, "COMPLETE_PROFILE")))
                ],
              ),
            ),
          );
  }
}
