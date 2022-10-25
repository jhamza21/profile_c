import 'package:flutter/material.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/company_service.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateCompanyName extends StatefulWidget {
  static const routeName = '/addUpdateCompanyName';

  @override
  _AddUpdateCompanyNameState createState() => _AddUpdateCompanyNameState();
}

class _AddUpdateCompanyNameState extends State<AddUpdateCompanyName> {
  final _formKey = new GlobalKey<FormState>();
  String _name;
  bool _isLoading = false;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildNameInput(previousName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        initialValue: previousName,
        keyboardType: TextInputType.text,
        decoration: inputTextDecoration(
            30.0,
            Icon(Icons.account_box, color: Colors.white),
            getTranslate(context, "COMPANY_NAME"),
            null,
            null),
        validator: (value) =>
            value.isEmpty ? getTranslate(context, 'FILL_IN_FIELD') : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
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
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var res = await CompanyService()
                      .updateName(userProvider.user.id, _name);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  userProvider.setCompanyName(_name);
                  Navigator.of(context).pop();
                  showSnackbar(
                      context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                }
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
        title: Text(getTranslate(context, "COMPANY_NAME")),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              Text(
                getTranslate(context, "COMPANY_NAME_NOTICE"),
                style: TextStyle(color: GREY_LIGHt),
              ),
              SizedBox(height: 20.0),
              buildNameInput(userProvider.user.company.name),
              SizedBox(height: 60.0),
              buildSaveBtn(userProvider),
            ],
          ),
        ),
      ),
    );
  }
}
