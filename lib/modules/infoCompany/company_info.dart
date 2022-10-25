import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_formated_mobile_number.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_address.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_email.dart';
import 'package:profilecenter/modules/infoCompany/add_update_company_logo.dart';
import 'package:profilecenter/modules/infoCompany/add_update_company_mobile.dart';
import 'package:profilecenter/modules/infoCompany/add_update_company_name.dart';
import 'package:profilecenter/modules/infoCompany/add_update_rh_name.dart';
import 'package:profilecenter/widgets/complete_profile_item.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class CompanyInfo extends StatefulWidget {
  static const routeName = '/companyInfo';

  @override
  _CompanyInfoState createState() => _CompanyInfoState();
}

class _CompanyInfoState extends State<CompanyInfo> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "COMPANY_INFO"),
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
                        getTranslate(context, "NAME_RH"),
                        userProvider.user.firstName +
                            " " +
                            userProvider.user.lastName,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateRhName.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.email != '',
                        getTranslate(context, 'EMAIL'),
                        userProvider.user.email,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateEmail.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.company != null &&
                            userProvider.user.company.name != '',
                        getTranslate(context, "COMPANY_NAME"),
                        userProvider.user.company != null &&
                                userProvider.user.company.name != ''
                            ? userProvider.user.company.name
                            : '',
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateCompanyName.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.address != null,
                        getTranslate(context, "COMPANY_ADDRESS"),
                        userProvider.user.address != null
                            ? userProvider.user.address.description
                            : '',
                        () => Navigator.of(context).pushNamed(
                            AddUpdateAddress.routeName,
                            arguments: userProvider.user.address)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.company != null &&
                            userProvider.user.company.mobile != '',
                        getTranslate(context, "COMPANY_MOBILE"),
                        getFormattedMobileNumber(
                            userProvider.user.company.mobile),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateCompanyMobile.routeName)),
                    CompleteProfileItem(
                        false,
                        userProvider.user.company != null &&
                            userProvider.user.company.image != '',
                        getTranslate(context, "COMPANY_LOGO"),
                        userProvider.user.company != null &&
                                userProvider.user.company.image != ''
                            ? userProvider.user.company.image
                                .replaceFirst("uploads/profile/", "")
                            : null,
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateCompanyLogo.routeName)),
                  ],
                ),
              ),
            ),
    );
  }
}
