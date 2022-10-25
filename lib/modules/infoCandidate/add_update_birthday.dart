import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateBirthday extends StatefulWidget {
  static const routeName = '/addUpdateBirthday';

  @override
  _AddUpdateBirthdayState createState() => _AddUpdateBirthdayState();
}

class _AddUpdateBirthdayState extends State<AddUpdateBirthday> {
  final _formKey = new GlobalKey<FormState>();
  String _birthday;
  bool _isLoading = false;

  Widget _showDatePicker(String previousBirthday) {
    return DatePickerWidget(
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      initialDate: previousBirthday != ''
          ? DateTime.parse(previousBirthday)
          : DateTime(1991, 10, 12),
      dateFormat: "dd-MM-yyyy",
      locale: DatePicker.localeFromString('en'),
      onChange: (DateTime newDate, _) {
        setState(() {
          _birthday = newDate.toString();
        });
      },
      pickerTheme: DateTimePickerTheme(
        backgroundColor: BLUE_LIGHT,
        itemTextStyle: TextStyle(color: Colors.white),
        dividerColor: RED_LIGHT,
      ),
    );
  }

  Widget buildSaveBtn(UserProvider userProvider) {
    return TextButton.icon(
        icon: _isLoading ? circularProgress : SizedBox(),
        label: Text(
          getTranslate(context, 'SAVE'),
        ),
        onPressed: _isLoading || _birthday == null
            ? null
            : () async {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var res = await UserService()
                      .updateBirthday(userProvider.user.id, _birthday);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  userProvider.setBirthday(_birthday);
                  Navigator.of(context).pop();
                  showSnackbar(
                      context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                }
              });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "BIRTHDAY"),
        ),
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
                getTranslate(context, "BIRTHDAY_NOTICE"),
                style: TextStyle(color: GREY_LIGHt),
              ),
              SizedBox(height: 20.0),
              _showDatePicker(userProvider.user.birthday),
              SizedBox(height: 60.0),
              buildSaveBtn(userProvider),
            ],
          ),
        ),
      ),
    );
  }
}
