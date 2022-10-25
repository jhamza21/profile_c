import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/app_language_provider.dart';
import 'package:profilecenter/modules/settings/language_changer.dart';
import 'package:provider/provider.dart';

class LanguageSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLanguageProvider appLanguageProvider =
        Provider.of<AppLanguageProvider>(context);
    String languageCode = appLanguageProvider.appLocale.languageCode;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(LanguageChanger.routeName),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: BLUE_LIGHT,
        ),
        padding: EdgeInsets.all(8.0),
        height: 35.0,
        width: 120.0,
        child: Row(
          children: [
            CircleAvatar(
              radius: 15.0,
              backgroundImage: AssetImage(languageCode == 'fr'
                  ? FRENCH_LANGUAGE_FLAG
                  : languageCode == 'en'
                      ? ENGLISH_LANGUAGE_FLAG
                      : languageCode == 'da'
                          ? DEUTSH_LANGUAGE_FLAG
                          : SPAIN_LANGUAGE_FLAG),
            ),
            SizedBox(width: 10.0),
            Text(
              languageCode == 'fr'
                  ? "Français"
                  : languageCode == 'en'
                      ? "English"
                      : languageCode == 'da'
                          ? 'Deutsch'
                          : 'Espanol',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
