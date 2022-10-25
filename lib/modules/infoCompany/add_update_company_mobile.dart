import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/company_service.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateCompanyMobile extends StatefulWidget {
  static const routeName = '/addUpdateCompanyMobile';

  @override
  _AddUpdateCompanyMobileState createState() => _AddUpdateCompanyMobileState();
}

class _AddUpdateCompanyMobileState extends State<AddUpdateCompanyMobile> {
  final _formKey = new GlobalKey<FormState>();
  String _mobile;
  bool _isLoading = false;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildMobileInput(String previousMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new IntlPhoneField(
        style: TextStyle(color: Colors.white),
        dropDownArrowColor: Colors.white,
        countryCodeTextColor: Colors.white,
        autoValidate: false,
        initialCountryCode:
            previousMobile != '' ? previousMobile.split('/')[0] : 'FR',
        initialValue:
            previousMobile != '' ? previousMobile.split('/')[2] : null,
        keyboardType: TextInputType.phone,
        decoration: inputTextDecoration(
            30.0,
            Icon(
              Icons.mobile_friendly,
              color: Colors.transparent,
            ),
            getTranslate(context, 'COMPANY_MOBILE'),
            null,
            null),
        validator: (value) => value.isEmpty
            ? getTranslate(context, "FILL_IN_FIELD")
            : value.length < 8 || value.length > 12
                ? getTranslate(context, "INVALID_MOBILE_LENGTH")
                : null,
        onChanged: (PhoneNumber value) => setState(() {
          _mobile = value.countryISOCode +
              "/" +
              value.countryCode +
              "/" +
              value.number;
        }),
      ),
    );
  }

  Widget buildSaveBtn(UserProvider userProvider) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SAVE'),
      ),
      onPressed: _isLoading || _mobile == null
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var res = await CompanyService()
                      .updateMobile(userProvider.user.id, _mobile);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  userProvider.setCompanyMobile(_mobile);
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
        title: Text(
          getTranslate(context, "COMPANY_MOBILE"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              Text(
                getTranslate(context, "MOBILE_NUMBER_COMPANY_NOTICE"),
                style: TextStyle(color: GREY_LIGHt),
              ),
              SizedBox(height: 20.0),
              buildMobileInput(userProvider.user.company.mobile),
              SizedBox(height: 60.0),
              buildSaveBtn(userProvider),
            ],
          ),
        ),
      ),
    );
  }
}
