import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/home/home_root.dart';
import 'package:profilecenter/modules/settings/pack_changer_company.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/providers/app_language_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/modules/settings/devise_changer.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_password.dart';
import 'package:profilecenter/modules/settings/language_changer.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  static const routeName = '/appSettings';

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  void logoutUser(UserProvider userProvider) async {
    try {
      Navigator.of(context).pushNamedAndRemoveUntil(
          HomeRoot.routeName, (Route<dynamic> route) => false);
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      userProvider.logoutUser();
    } catch (e) {}
  }

  void toggleNotif(bool value, UserProvider userProvider) async {
    try {
      userProvider.setNotification(value);
      var res = await UserService().toggleNotif();
      if (res.statusCode == 401 || res.statusCode == 403)
        return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
    } catch (e) {
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    AppLanguageProvider appLanguageProvider =
        Provider.of<AppLanguageProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "SETTINGS")),
      ),
      body: userProvider.user == null
          ? Center(child: circularProgress)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    tileColor: BLUE_LIGHT,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed(LanguageChanger.routeName),
                    leading: Icon(
                      Icons.language,
                      color: GREY_LIGHt,
                    ),
                    trailing: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                    ),
                    title: Text(
                      appLanguageProvider.appLocale.languageCode == "fr"
                          ? "Français"
                          : appLanguageProvider.appLocale.languageCode == "en"
                              ? "English"
                              : appLanguageProvider.appLocale.languageCode ==
                                      "da"
                                  ? "Allemand"
                                  : "Espagnol",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    tileColor: BLUE_LIGHT,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AddUpdatePassword.routeName),
                    leading: Icon(
                      Icons.lock,
                      color: GREY_LIGHt,
                    ),
                    trailing: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                    ),
                    title: Text(
                      getTranslate(context, 'PASSWORD'),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (userProvider.user.role == FREELANCE_ROLE)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListTile(
                        tileColor: BLUE_LIGHT,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => Navigator.of(context)
                            .pushNamed(PackChangerCandidat.routeName),
                        leading: Icon(
                          Icons.star_border,
                          color: GREY_LIGHt,
                        ),
                        trailing: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                        ),
                        title: Text(
                          userProvider.user.pack.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (userProvider.user.role == COMPANY_ROLE)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListTile(
                        tileColor: BLUE_LIGHT,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => Navigator.of(context)
                            .pushNamed(PackChangerCompany.routeName),
                        leading: Icon(
                          Icons.star_border,
                          color: GREY_LIGHt,
                        ),
                        trailing: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                        ),
                        title: Text(
                          userProvider.user.pack.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  SizedBox(height: 10.0),
                  ListTile(
                    tileColor: BLUE_LIGHT,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed(DeviseChanger.routeName),
                    leading: Icon(
                      Icons.money,
                      color: GREY_LIGHt,
                    ),
                    trailing: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                    ),
                    title: Text(
                      userProvider.user.devise.name,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 16.0, right: 0),
                    tileColor: BLUE_LIGHT,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {},
                    leading: Icon(
                      Icons.notifications,
                      color: GREY_LIGHt,
                    ),
                    trailing: Switch(
                      value: userProvider.user != null
                          ? userProvider.user.notification
                          : false,
                      onChanged: (value) => toggleNotif(value, userProvider),
                    ),
                    title: Text(
                      getTranslate(context, "NOTIFICATIONS"),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    tileColor: BLUE_LIGHT,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => logoutUser(userProvider),
                    leading: Icon(
                      Icons.logout,
                      color: GREY_LIGHt,
                    ),
                    title: Text(
                      getTranslate(context, "LOGOUT"),
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
