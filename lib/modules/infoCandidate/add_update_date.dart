import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateDate extends StatefulWidget {
  static const routeName = '/addUpdateDate';
  @override
  State<AddUpdateDate> createState() => _AddUpdateDateState();
}

class _AddUpdateDateState extends State<AddUpdateDate> {
  bool _isLoading = false;
  TextEditingController dateCtl = TextEditingController();
  String _disponibleDay;
  DateTime d;

  void updateReturnToJobDate(String date) async {
    try {
      setState(() {
        _isLoading = true;
        _disponibleDay = date;
        dateCtl.text =
            DateFormat('dd-MM-yyyy').format(DateTime.parse(_disponibleDay));
      });
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      var res =
          await UserService().updateReturntoJobDate(userProvider.user.id, date);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      userProvider.setReturnToJobDate(date);
      showSnackbar(context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _disponibleDay = null;
        dateCtl.text = '';
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  Widget _showDatePicker(String d) {
    return DatePickerWidget(
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      initialDate: DateTime.now(),
      dateFormat: "yyyy-MM-dd",
      locale: DatePicker.localeFromString('en'),
      onChange: (DateTime newDate, _) {
        setState(() {
          d = newDate.toString();
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
        onPressed: () {
          if (d != null) {
            updateReturnToJobDate(DateFormat("yyyy-MM-dd").format(d));
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
          getTranslate(context, "SEND"),
        ),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
