import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_formated_mobile_number.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_address.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_birthday.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_email.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_mobile.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_name.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_photo.dart';
import 'package:profilecenter/widgets/complete_profile_item.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class CandidateInfo extends StatefulWidget {
  static const routeName = '/candidateInfo';

  @override
  _CandidateInfoState createState() => _CandidateInfoState();
}

class _CandidateInfoState extends State<CandidateInfo> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "PERSONAL_INFOS"),
        ),
      ),
      body: userProvider.user == null
          ? ErrorScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      getTranslate(context, "PERSONAL_INFOS_NOTICE"),
                      style: TextStyle(color: GREY_LIGHt),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    CompleteProfileItem(
                        false,
                        userProvider.user.firstName != '',
                        getTranslate(context, "FIRST_AND_LAST_NAME"),
                        userProvider.user.firstName +
                            " " +
                            userProvider.user.lastName,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateName.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.address != null,
                        getTranslate(context, "ADDRESS"),
                        userProvider.user.address != null
                            ? userProvider.user.address.description
                            : '',
                        () => Navigator.of(context).pushNamed(
                            AddUpdateAddress.routeName,
                            arguments: userProvider.user.address)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.email != '',
                        getTranslate(context, 'EMAIL'),
                        userProvider.user.email,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateEmail.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.mobile != '',
                        getTranslate(context, "MOBILE_NUMBER"),
                        getFormattedMobileNumber(userProvider.user.mobile),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateMobile.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.birthday != '',
                        getTranslate(context, "BIRTHDAY"),
                        userProvider.user.birthday != ''
                            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                userProvider.user.birthday.substring(0, 10)))
                            : null,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateBirthday.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.image != '',
                        getTranslate(context, "PROFESSIONAL_PHOTO"),
                        userProvider.user.image != ''
                            ? userProvider.user.image
                                .replaceFirst("uploads/profile/", "")
                            : null,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdatePhoto.routeName)),
                  ],
                ),
              ),
            ),
    );
  }
}
