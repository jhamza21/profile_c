import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/auth_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class ForgotPassword extends StatefulWidget {
  static const routeName = '/forgotPassword';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = new GlobalKey<FormState>();
  final _emailTextFieldController = TextEditingController();
  bool _isLoading = false;
  String _email;

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildEmailInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _emailTextFieldController,
      keyboardType: TextInputType.emailAddress,
      decoration: inputTextDecoration(
          30.0,
          Icon(Icons.email, color: RED_LIGHT),
          getTranslate(context, 'EMAIL'),
          null,
          _emailTextFieldController.text != ''
              ? GestureDetector(
                  child: Icon(Icons.cancel, color: RED_LIGHT),
                  onTap: () {
                    setState(() {
                      _email = null;
                    });
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).unfocus();
                      _emailTextFieldController.clear();
                    });
                  },
                )
              : null),
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
    );
  }

  Widget buildSendBtn() {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(getTranslate(context, 'SEND')),
      onPressed: _isLoading
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var res = await AuthService().forgotPassword(_email);
                  setState(() {
                    _isLoading = false;
                  });
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  Navigator.of(context).pop();
                  showSnackbar(context,
                      getTranslate(context, "RESET_PASSWORD_LINK_SENT"));
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 100.0,
              ),
              Text(
                getTranslate(context, "FORGOT_PASSWORD"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                getTranslate(context, "FORGOT_PASSWORD_NOTICE"),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 50),
              buildEmailInput(),
              SizedBox(height: 50),
              buildSendBtn(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: _buildForm());
  }
}
