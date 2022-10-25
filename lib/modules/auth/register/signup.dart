import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/auth/register/terme_condition.dart';
import 'package:profilecenter/core/services/auth_service.dart';
import 'package:profilecenter/modules/auth/login/login.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class SignUp extends StatefulWidget {
  static const routeName = '/signup';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int _currentIndex = 0;
  String _role, _gender;
  final _formKey = new GlobalKey<FormState>();
  String _email, _password, _error;
  bool _isLoading = false, _showPassword = false, _conditionsAccept = false;

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      if (!_conditionsAccept) {
        showSnackbar(context, getTranslate(context, "CONDITIONS_NOT_ACCEPTED"));
        return false;
      }
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

  Widget buildSwitchFormBtn() {
    return Center(
      child: GestureDetector(
        onTap: () => {Navigator.of(context).popAndPushNamed(Login.routeName)},
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: getTranslate(context, "HAVE_ACCOUNT"),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: getTranslate(context, "SIGN_IN"),
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
      keyboardType: TextInputType.emailAddress,
      decoration: inputTextDecoration(
          30.0,
          Icon(
            Icons.email,
            color: RED_LIGHT,
          ),
          getTranslate(context, 'EMAIL'),
          null,
          null),
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
        Icon(
          Icons.lock_outline,
          color: RED_LIGHT,
        ),
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

  Widget buildPasswordConfirmationInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: !_showPassword,
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
          : value != _password
              ? getTranslate(context, 'INVALID_PASSWORD_CONFIRMATION')
              : null,
    );
  }

  Widget buildTextBtnTerme() {
    return Center(
      child: GestureDetector(
        onTap: () =>
            {Navigator.of(context).pushNamed(TermeCondition.routeName)},
        child: RichText(
          text: TextSpan(
            text: getTranslate(context, "TERME_CONDITION"),
            style: TextStyle(
              letterSpacing: 0.5,
              fontSize: 10.0,
              color: RED_LIGHT,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: RED_LIGHT,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SIGN_UP'),
      ),
      onPressed: _isLoading
          ? null
          : () {
              if (validateAndSave()) signUp();
            },
    );
  }

  void signUp() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      var res = await AuthService().signUp(_email, _password, _role, _gender);
      if (res.statusCode == 201) {
        showSnackbar(context, getTranslate(context, "SIGN_UP_SUCCESS"));
        Navigator.of(context).popAndPushNamed(Login.routeName);
      } else if (res.statusCode == 400) {
        _error = getTranslate(context, "EMAIL_ALREADY_IN_USE");
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

  Widget buildConditionServiceNotice() {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      onTap: () {
        setState(() {
          _conditionsAccept = !_conditionsAccept;
        });
      },
      leading: Checkbox(
          activeColor: Colors.white,
          checkColor: Colors.black,
          value: _conditionsAccept,
          onChanged: (val) {
            setState(() {
              _conditionsAccept = val;
            });
          }),
      title: Text(
        getTranslate(context, "CONDITIONS_SERVICE_NOTICE"),
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget chooseUserType() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          getTranslate(context, "IAM"),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          getTranslate(context, "GENDER_NOTICE"),
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //men
            InkWell(
              onTap: () {
                setState(() {
                  _gender = "men";
                });
              },
              child: Container(
                height: 120,
                width: 115,
                decoration: BoxDecoration(
                  color: _gender == "men" ? RED_LIGHT : BLUE_LIGHT,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: Image.asset(MEN_ICON)),
                    SizedBox(height: 10.0),
                    Text(getTranslate(context, "MEN"),
                        style: TextStyle(
                            color:
                                _gender == "men" ? Colors.black : Colors.white))
                  ],
                ),
              ),
            ),
            //women
            InkWell(
              onTap: () {
                setState(() {
                  _gender = "women";
                });
              },
              child: Container(
                height: 120,
                width: 115,
                decoration: BoxDecoration(
                  color: _gender == "women" ? RED_LIGHT : BLUE_LIGHT,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: Image.asset(WOMAN_ICON)),
                    SizedBox(height: 10.0),
                    Text(getTranslate(context, "WOMAN"),
                        style: TextStyle(
                            color: _gender == "women"
                                ? Colors.black
                                : Colors.white))
                  ],
                ),
              ),
            ),
            //company
            InkWell(
              onTap: () {
                setState(() {
                  _gender = "entreprise";
                });
              },
              child: Container(
                height: 120,
                width: 115,
                decoration: BoxDecoration(
                  color: _gender == "entreprise" ? RED_LIGHT : BLUE_LIGHT,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: Image.asset(COMPANY_LOGO)),
                    SizedBox(height: 10.0),
                    Text(getTranslate(context, "COMPANY"),
                        style: TextStyle(
                            color: _gender == "entreprise"
                                ? Colors.black
                                : Colors.white))
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 150.0),
        Container(
          width: MediaQuery.of(context).size.width,
          child: TextButton(
              onPressed: _gender == null
                  ? null
                  : () {
                      setState(() {
                        if (_gender == "entreprise") {
                          _role = null;
                          _currentIndex = 2;
                        } else
                          _currentIndex = 1;
                      });
                    },
              child: Text(getTranslate(context, "VALIDATE"))),
        )
      ]),
    );
  }

  Widget chooseJob() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              getTranslate(context, "WHAT_IS_YOUR_JOB"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              getTranslate(context, "GENDER_NOTICE"),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 50),
            //freelance
            ListTile(
              onTap: () {
                setState(() {
                  _role = "freelance";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _role == "freelance" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                getTranslate(context, "FREELANCE"),
                style: TextStyle(
                    color:
                        _role == "freelance" ? Colors.grey[800] : Colors.white),
              ),
              trailing: Radio(
                value: "freelance",
                groupValue: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            //salariee
            ListTile(
              onTap: () {
                setState(() {
                  _role = "salarie";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _role == "salarie" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                getTranslate(context, "EMPLOYEE"),
                style: TextStyle(
                    color:
                        _role == "salarie" ? Colors.grey[800] : Colors.white),
              ),
              trailing: Radio(
                value: "salarie",
                groupValue: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            //apprenti
            ListTile(
              onTap: () {
                setState(() {
                  _role = "apprenti";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _role == "apprenti" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                getTranslate(context, "STUDENT"),
                style: TextStyle(
                    color:
                        _role == "apprenti" ? Colors.grey[800] : Colors.white),
              ),
              trailing: Radio(
                value: "apprenti",
                groupValue: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            //stagiare
            ListTile(
              onTap: () {
                setState(() {
                  _role = "stagiaire";
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _role == "stagiaire" ? RED_LIGHT : BLUE_LIGHT,
              title: Text(
                getTranslate(context, "TRAINEE"),
                style: TextStyle(
                    color:
                        _role == "stagiaire" ? Colors.grey[800] : Colors.white),
              ),
              trailing: Radio(
                value: "stagiaire",
                groupValue: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
            ),
            SizedBox(height: 120.0),
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextButton(
                  onPressed: _role == null
                      ? null
                      : () {
                          setState(() {
                            _currentIndex = 2;
                          });
                        },
                  child: Text(getTranslate(context, "VALIDATE"))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30.0),
              buildLogo(),
              SizedBox(height: 40.0),
              buildEmailInput(),
              SizedBox(height: 20.0),
              buildPasswordInput(),
              SizedBox(height: 20.0),
              buildPasswordConfirmationInput(),
              SizedBox(height: 30.0),
              buildTextBtnTerme(),
              SizedBox(height: 5.0),
              buildConditionServiceNotice(),
              buildErrorMessage(),
              SizedBox(height: 40.0),
              buildSignUpBtn(),
              SizedBox(height: 20.0),
              buildSwitchFormBtn(),
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentIndex != 0)
                setState(() {
                  _currentIndex = 0;
                });
              else
                Navigator.pop(context);
            },
          ),
        ),
        body: _currentIndex == 0
            ? chooseUserType()
            : _currentIndex == 1
                ? chooseJob()
                : _buildSignupForm());
  }
}
