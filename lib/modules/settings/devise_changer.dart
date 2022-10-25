import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/devise.dart';
import 'package:profilecenter/providers/devise_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/devise_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class DeviseChanger extends StatefulWidget {
  static const routeName = '/deviseChanger';

  @override
  _DeviseChangerState createState() => _DeviseChangerState();
}

class _DeviseChangerState extends State<DeviseChanger> {
  Devise _selectedDevise;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _getPlatformDevises();
    _initializeData();
  }

  void _getPlatformDevises() async {
    DeviseProvider deviseProvider =
        Provider.of<DeviseProvider>(context, listen: false);
    deviseProvider.fetchDevises(context);
  }

  void _initializeData() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _selectedDevise = userProvider.user.devise;
  }

  void updateDevise(UserProvider userProvider) async {
    try {
      setState(() {
        _isSaving = true;
      });
      var res = await DeviseService()
          .updateDevise(userProvider.user.id, _selectedDevise.id);
      if (res.statusCode == 401 || res.statusCode == 403)
        return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      userProvider.setDevise(_selectedDevise);
      Navigator.of(context).pop();
      showSnackbar(context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    DeviseProvider deviseProvider =
        Provider.of<DeviseProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "CURRENCIES")),
      ),
      body: deviseProvider.isLoading
          ? Center(child: circularProgress)
          : deviseProvider.isError
              ? ErrorScreen()
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30.0),
                      Text(
                        getTranslate(context, "CURRENCY_NOTICE"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      ...deviseProvider.devises.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedDevise = e;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: _selectedDevise.id == e.id
                                ? RED_LIGHT
                                : BLUE_LIGHT,
                            title: Text(
                              e.name,
                              style: TextStyle(
                                  color: _selectedDevise.id == e.id
                                      ? Colors.grey[800]
                                      : Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.0),
                      TextButton.icon(
                          icon:
                              _isSaving ? circularProgress : SizedBox.shrink(),
                          onPressed: _isSaving ||
                                  userProvider.user.devise.id ==
                                      _selectedDevise.id
                              ? null
                              : () {
                                  updateDevise(userProvider);
                                },
                          label: Text(getTranslate(context, "VALIDATE"))),
                    ],
                  ),
                ),
    );
  }
}
