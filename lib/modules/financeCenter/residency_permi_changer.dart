import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class ResidencyPermitChanger extends StatefulWidget {
  static const routeName = '/residencyPermitChanger';

  @override
  _ResidencyPermitChangerState createState() => _ResidencyPermitChangerState();
}

class _ResidencyPermitChangerState extends State<ResidencyPermitChanger> {
  String _selectedPermit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _selectedPermit = userProvider.user.residencyPermit;
  }

  Widget buildSaveBtn(UserProvider userProvider) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SAVE'),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                var res = await UserService().updateResidencyPermit(
                    userProvider.user.id, _selectedPermit);
                if (res.statusCode == 401) return sessionExpired(context);
                if (res.statusCode != 200) throw "ERROR_SERVER";
                userProvider.setresidencyPermit(_selectedPermit);
                Navigator.of(context).pop();
                showSnackbar(
                    context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "RESIDENCE_PERMIS")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30.0),
            Text(
              getTranslate(context, "RESIDENCY_PERMIT_NOTICE"),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30.0),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPermit = "a";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedPermit == "a" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                "A",
                style: TextStyle(
                    color: _selectedPermit == "a"
                        ? Colors.grey[800]
                        : Colors.white),
              ),
              trailing: Radio(
                value: "a",
                groupValue: _selectedPermit,
                onChanged: (value) {
                  setState(() {
                    _selectedPermit = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPermit = "b";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedPermit == "b" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                "B",
                style: TextStyle(
                    color: _selectedPermit == "b"
                        ? Colors.grey[800]
                        : Colors.white),
              ),
              trailing: Radio(
                value: "b",
                groupValue: _selectedPermit,
                onChanged: (value) {
                  setState(() {
                    _selectedPermit = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPermit = "c";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedPermit == "c" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                "C",
                style: TextStyle(
                    color: _selectedPermit == "c"
                        ? Colors.grey[800]
                        : Colors.white),
              ),
              trailing: Radio(
                value: "c",
                groupValue: _selectedPermit,
                onChanged: (value) {
                  setState(() {
                    _selectedPermit = value;
                  });
                },
              ),
            ),
            SizedBox(height: 100.0),
            buildSaveBtn(userProvider),
          ],
        ),
      ),
    );
  }
}
