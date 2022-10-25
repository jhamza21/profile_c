import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/app_language_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/core/services/local_storage_service.dart';
import 'package:provider/provider.dart';

class LanguageChanger extends StatefulWidget {
  static const routeName = '/languageChanger';

  @override
  _LanguageChangerState createState() => _LanguageChangerState();
}

class _LanguageChangerState extends State<LanguageChanger> {
  String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _getCurrentLanguage();
  }

  void _getCurrentLanguage() async {
    var lang = await LocalStorageService().getAppLanguage();
    setState(() {
      _selectedLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLanguageProvider appLanguageProvider =
        Provider.of<AppLanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "LANGUAGE")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30.0),
            Text(
              getTranslate(context, "LANGUAGE_NOTICE"),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30.0),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedLanguage = "fr";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedLanguage == "fr" ? RED_LIGHT : BLUE_LIGHT,
              leading: CircleAvatar(
                radius: 15.0,
                backgroundImage: AssetImage(FRENCH_LANGUAGE_FLAG),
              ),
              title: Text(
                "Français",
                style: TextStyle(
                    color: _selectedLanguage == "fr"
                        ? Colors.grey[800]
                        : Colors.white),
              ),
              trailing: Radio(
                value: "fr",
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10.0),
            //english
            ListTile(
              onTap: () {
                setState(() {
                  _selectedLanguage = "en";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedLanguage == "en" ? RED_LIGHT : BLUE_LIGHT,
              leading: CircleAvatar(
                radius: 15.0,
                backgroundImage: AssetImage(ENGLISH_LANGUAGE_FLAG),
              ),
              title: Text(
                "English",
                style: TextStyle(
                    color: _selectedLanguage == "en"
                        ? Colors.grey[800]
                        : Colors.white),
              ),
              trailing: Radio(
                value: "en",
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10.0),
            //deutsch
            ListTile(
              onTap: () {
                setState(() {
                  _selectedLanguage = "da";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedLanguage == "da" ? RED_LIGHT : BLUE_LIGHT,
              leading: CircleAvatar(
                radius: 15.0,
                backgroundImage: AssetImage(DEUTSH_LANGUAGE_FLAG),
              ),
              title: Text(
                "Deutsch",
                style: TextStyle(
                    color: _selectedLanguage == "da"
                        ? Colors.grey[800]
                        : Colors.white),
              ),
              trailing: Radio(
                value: "da",
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
            ),
            // SizedBox(height: 10.0),
            // //spain
            // ListTile(
            //   onTap: () {
            //     setState(() {
            //       _selectedLanguage = "es";
            //     });
            //   },
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   tileColor: _selectedLanguage == "es" ? RED_LIGHT : BLUE_LIGHT,
            //   leading: CircleAvatar(
            //     radius: 15.0,
            //     backgroundImage: AssetImage(SPAIN_LANGUAGE_FLAG),
            //   ),
            //   title: Text(
            //     "Espanol",
            //     style: TextStyle(
            //         color: _selectedLanguage == "es"
            //             ? Colors.grey[800]
            //             : Colors.white),
            //   ),
            //   trailing: Radio(
            //     value: "es",
            //     groupValue: _selectedLanguage,
            //     onChanged: (value) {
            //       setState(() {
            //         _selectedLanguage = value;
            //       });
            //     },
            //   ),
            // ),
            SizedBox(height: 100.0),
            TextButton(
                onPressed: () {
                  appLanguageProvider.changeLanguage(_selectedLanguage);
                  Navigator.of(context).pop();
                },
                child: Text(getTranslate(context, "VALIDATE")))
          ],
        ),
      ),
    );
  }
}
