import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdatePassword extends StatefulWidget {
  static const routeName = '/addUpdatePassword';

  @override
  _AddUpdatePasswordState createState() => _AddUpdatePasswordState();
}

class _AddUpdatePasswordState extends State<AddUpdatePassword> {
  final _formKey = new GlobalKey<FormState>();
  String _oldPassword, _newPassword, _error;
  bool _showOldPassword = false, _showNewPassword = false, _isLoading = false;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildOldPasswordInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: !_showOldPassword,
      decoration: inputTextDecoration(
        30.0,
        Icon(
          Icons.lock_outline,
          color: RED_LIGHT,
        ),
        getTranslate(context, "OLD_PASSWORD"),
        _error != null ? getTranslate(context, "INVALID_PASSWORD") : null,
        GestureDetector(
            child: Icon(
              !_showOldPassword ? Icons.visibility_off : Icons.visibility,
              color: RED_LIGHT,
            ),
            onTap: () {
              setState(() {
                _showOldPassword = !_showOldPassword;
              });
            }),
      ),
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : value.length < 8 ||
                  !value.contains(new RegExp(r'[A-Z]')) ||
                  !value.contains(new RegExp(r'[0-9]')) ||
                  !value.contains(new RegExp(r'[a-z]')) ||
                  !value.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))
              ? getTranslate(context, 'INVALID_PASSWORD_LENGTH')
              : null,
      onChanged: (value) => _oldPassword = value.trim(),
    );
  }

  Widget buildNewPasswordInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: !_showNewPassword,
      decoration: inputTextDecoration(
        30.0,
        Icon(
          Icons.lock_outline,
          color: RED_LIGHT,
        ),
        getTranslate(context, "NEW_PASSWORD"),
        null,
        GestureDetector(
            child: Icon(
              !_showNewPassword ? Icons.visibility_off : Icons.visibility,
              color: RED_LIGHT,
            ),
            onTap: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            }),
      ),
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : value.length < 8 ||
                  !value.contains(new RegExp(r'[A-Z]')) ||
                  !value.contains(new RegExp(r'[0-9]')) ||
                  !value.contains(new RegExp(r'[a-z]')) ||
                  !value.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))
              ? getTranslate(context, 'INVALID_PASSWORD_LENGTH')
              : null,
      onChanged: (value) => _newPassword = value.trim(),
    );
  }

  Widget buildNewPasswordConfirmationInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: !_showNewPassword,
      decoration: inputTextDecoration(
        30.0,
        Icon(
          Icons.lock,
          color: RED_LIGHT,
        ),
        getTranslate(context, 'PASSWORD_CONFIRMATION'),
        null,
        GestureDetector(
            child: Icon(
              !_showNewPassword ? Icons.visibility_off : Icons.visibility,
              color: RED_LIGHT,
            ),
            onTap: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            }),
      ),
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : value != _newPassword
              ? getTranslate(context, 'INVALID_PASSWORD_CONFIRMATION')
              : null,
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
                    var res = await UserService().updatePassword(
                        userProvider.user.id, _oldPassword, _newPassword);
                    if (res.statusCode == 401) return sessionExpired(context);
                    if (res.statusCode == 200) {
                      Navigator.of(context).pop();
                      showSnackbar(context,
                          getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
                    } else if (res.statusCode == 400) {
                      _error = getTranslate(context, "INVALID_PASSWORD");
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    showSnackbar(
                        context, getTranslate(context, "ERROR_SERVER"));
                  }
                }
              });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, 'PASSWORD')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  getTranslate(context, "CHANGE_PASSWORD_NOTICE"),
                  style: TextStyle(color: GREY_LIGHt),
                ),
                SizedBox(height: 20.0),
                buildOldPasswordInput(),
                SizedBox(height: 20.0),
                buildNewPasswordInput(),
                SizedBox(height: 20.0),
                buildNewPasswordConfirmationInput(),
                SizedBox(height: 60.0),
                buildSaveBtn(userProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
