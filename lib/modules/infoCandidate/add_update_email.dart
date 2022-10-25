import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/input_password_dialog.dart';
import 'package:provider/provider.dart';

class AddUpdateEmail extends StatefulWidget {
  static const routeName = '/addUpdateEmail';

  @override
  _AddUpdateEmailState createState() => _AddUpdateEmailState();
}

class _AddUpdateEmailState extends State<AddUpdateEmail> {
  final _formKey = new GlobalKey<FormState>();
  String _email;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showPasswordInput();
    });
  }

  void _showPasswordInput() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return InputPasswordDialog();
        });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildEmailInput(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 25.0, 12.0, 0.0),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
        initialValue: userProvider.user.email,
        decoration: inputTextDecoration(
            30.0,
            Icon(
              Icons.email,
              color: Colors.white,
            ),
            getTranslate(context, 'EMAIL'),
            null,
            null),
        validator: (value) => value.isEmpty
            ? getTranslate(context, "FILL_IN_FIELD")
            : !EmailValidator.validate(value)
                ? getTranslate(context, 'INVALID_EMAIL')
                : null,
        onChanged: (value) {
          setState(() {
            _email = value.trim();
          });
        },
      ),
    );
  }

  Widget buildSaveBtn(UserProvider userProvider) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SAVE'),
      ),
      onPressed: _isLoading ||
              _email == null ||
              _email == userProvider.user.email
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var res = await UserService()
                      .updateEmail(userProvider.user.id, _email);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  userProvider.setEmail(_email);
                  Navigator.of(context).pop();
                  showSnackbar(
                      context, getTranslate(context, "EMAIL_CHANGE_SUCCESS"));
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
        title: Text(getTranslate(context, 'EMAIL')),
      ),
      body: Padding(
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
                getTranslate(context, "EMAIL_NOTICE"),
                style: TextStyle(color: GREY_LIGHt),
              ),
              SizedBox(height: 20.0),
              buildEmailInput(userProvider),
              SizedBox(height: 60.0),
              buildSaveBtn(userProvider),
            ],
          ),
        ),
      ),
    );
  }
}
