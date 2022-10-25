import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/auth_service.dart';
import 'package:profilecenter/modules/auth/forgot_password/forgot_password.dart';
import 'package:profilecenter/modules/auth/register/signup.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = new GlobalKey<FormState>();
  String _email, _password, _error;
  bool _isLoading = false;
  bool _showPassword = false;

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildLogo() {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset(APP_LOGO),
    );
  }

  Widget buildSignUpBtn() {
    return Center(
      child: GestureDetector(
        onTap: () => {Navigator.of(context).pushNamed(SignUp.routeName)},
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: getTranslate(context, "DONT_HAVE_ACCOUNT"),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: getTranslate(context, "SIGN_UP"),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      initialValue: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: inputTextDecoration(30.0, Icon(Icons.email, color: RED_LIGHT),
          getTranslate(context, 'EMAIL'), null, null),
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : !EmailValidator.validate(value)
              ? getTranslate(context, 'INVALID_EMAIL')
              : null,
      onSaved: (value) => _email = value.trim(),
    );
  }

  Widget buildErrorMessage() {
    if (_error != null)
      return Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Text(
          _error,
          style: TextStyle(
              fontSize: 15.0,
              color: Colors.deepOrange[200],
              fontWeight: FontWeight.bold),
        ),
      );
    else
      return SizedBox.shrink();
  }

  Widget buildPasswordInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: !_showPassword,
      decoration: inputTextDecoration(
        30.0,
        Icon(Icons.lock_outline, color: RED_LIGHT),
        getTranslate(context, 'PASSWORD'),
        null,
        GestureDetector(
            child: Icon(
              !_showPassword ? Icons.visibility_off : Icons.visibility,
              color: RED_LIGHT,
            ),
            onTap: () {
              setState(() {
                _showPassword = !_showPassword;
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
      onChanged: (value) => _password = value.trim(),
    );
  }

  Widget buildForgotPassword() {
    return Align(
        alignment: Alignment.topLeft,
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            onPressed: () {
              Navigator.of(context).pushNamed(ForgotPassword.routeName);
            },
            child: Text(
              getTranslate(context, "FORGOT_PASSWORD"),
              style: TextStyle(color: Colors.white),
            )));
  }

  Widget buildSignInBtn() {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'CONNECTION'),
      ),
      onPressed: _isLoading
          ? null
          : () {
              if (validateAndSave()) signIn();
            },
    );
  }

  void _showVerifyAccount() {
    showBottomModal(
        context,
        getTranslate(context, "ACCOUNT_VERIFICATION"),
        getTranslate(context, "VERIFY_YOUR_ACCOUNT"),
        "OK",
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "RESEND_LINK"),
        () async {
          try {
            var res = await AuthService().resendLink(_email);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            Navigator.of(context).pop();
            showSnackbar(
                context, getTranslate(context, "VERIFICATION_EMAIL_SENT"));
          } catch (e) {
            Navigator.of(context).pop();
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        });
  }

  void signIn() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      var res = await AuthService().signIn(_email, _password);
      final jsonData = json.decode(res.body);
      if (res.statusCode == 200) {
        UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);
        SecureStorageService.saveToken(jsonData["token"]);
        userProvider.setUser(User.fromJson(jsonData["authUser"]));
        userProvider.setIsLoggedIn(true);
        userProvider.checkFirebaseToken();
        Navigator.of(context).pop();
      } else if (res.statusCode == 400) {
        if (jsonData["error"] == "account_not_verified") {
          _showVerifyAccount();
        } else {
          _error = getTranslate(context, jsonData["error"]);
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _error = getTranslate(context, "ERROR_SERVER");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 40),
              buildLogo(),
              SizedBox(height: 40),
              buildEmailInput(),
              SizedBox(height: 20),
              buildPasswordInput(),
              buildForgotPassword(),
              buildErrorMessage(),
              SizedBox(height: 60),
              buildSignInBtn(),
              SizedBox(height: 20.0),
              buildSignUpBtn(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: _buildForm());
  }
}
