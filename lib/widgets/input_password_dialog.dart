import 'package:flutter/material.dart';
import 'package:profilecenter/core/services/auth_service.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class InputPasswordDialog extends StatefulWidget {
  @override
  _InputPasswordDialogState createState() => _InputPasswordDialogState();
}

class _InputPasswordDialogState extends State<InputPasswordDialog> {
  final _formKey = new GlobalKey<FormState>();
  bool _showPassword = false;
  String _password;
  bool _error = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (dialogContext, setState) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: BLUE_LIGHT,
          contentPadding: EdgeInsets.all(0),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                  child: Center(
                      child: Text(
                    getTranslate(context, "PASSWORD"),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10.0),
                      Text(
                        getTranslate(context, "CONFIRM_IDENTITY"),
                        style: TextStyle(color: GREY_LIGHt, fontSize: 13.0),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        obscureText: !_showPassword,
                        decoration: inputTextDecoration(
                          10.0,
                          Icon(Icons.lock_outline, color: Colors.grey[500]),
                          getTranslate(context, 'PASSWORD'),
                          _error
                              ? getTranslate(context, "INVALID_PASSWORD")
                              : null,
                          GestureDetector(
                              child: Icon(
                                  !_showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[500]),
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
                                    !value.contains(
                                        new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))
                                ? getTranslate(
                                    context, 'INVALID_PASSWORD_LENGTH')
                                : null,
                        onChanged: (value) => _password = value.trim(),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon:
                              _isLoading ? circularProgress : SizedBox.shrink(),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(0)),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                      _error = false;
                                    });
                                    var res = await AuthService()
                                        .checkPassword(_password);
                                    if (res.statusCode == 200)
                                      Navigator.of(dialogContext).pop();
                                    else
                                      setState(() {
                                        _isLoading = false;
                                        _error = true;
                                      });
                                  }
                                },
                          label: Text(getTranslate(context, "VALIDATE")),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text(getTranslate(context, "CANCEL"))),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
