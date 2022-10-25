import 'package:flutter/material.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class SalaryChanger extends StatefulWidget {
  static const routeName = '/salaryChanger';

  @override
  _SalaryChangerState createState() => _SalaryChangerState();
}

class _SalaryChangerState extends State<SalaryChanger> {
  final _formKey = new GlobalKey<FormState>();
  double _salary;
  bool _isLoading = false;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildSalryInput(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        initialValue: userProvider.user.salary == null
            ? null
            : userProvider.user.salary.toString(),
        keyboardType: TextInputType.number,
        decoration: inputTextDecoration(
            30.0,
            null,
            userProvider.user.role == "freelance"
                ? "${getTranslate(context, "INPUT_TJM")}"
                : "${getTranslate(context, "INPUT_SALARY")}",
            null,
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Text(userProvider.user.devise.name),
            )),
        validator: (value) =>
            value.isEmpty || double.tryParse(value.trim()) == null
                ? getTranslate(context, "FILL_IN_FIELD")
                : double.tryParse(value) > 9999 || double.tryParse(value) < 1
                    ? getTranslate(context, "TJM_INVALID")
                    : null,
        onSaved: (value) => _salary = double.parse(value.trim()),
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
                  var res = await UserService()
                      .updateSalary(userProvider.user.id, _salary);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  userProvider.setSalary(_salary);
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
        title: Text(userProvider.user.role == "freelance"
            ? getTranslate(context, "TJM")
            : getTranslate(context, "MONTHLY_SALARY")),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20.0,
              ),
              Text(
                userProvider.user.role == "freelance"
                    ? getTranslate(context, "TJM_NOTICE")
                    : getTranslate(context, "SALARY_NOTICE"),
                style: TextStyle(color: GREY_LIGHt),
              ),
              SizedBox(height: 20.0),
              buildSalryInput(userProvider),
              SizedBox(height: 60.0),
              buildSaveBtn(userProvider),
            ],
          ),
        ),
      ),
    );
  }
}
