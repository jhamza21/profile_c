import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/compare_dates.dart';
import 'package:profilecenter/utils/helpers/compare_times.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/get_user_avatar.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/meeting.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/meeting_provider.dart';
import 'package:profilecenter/core/services/meeting_service.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateMeeting extends StatefulWidget {
  static const routeName = '/addUpdateMeeting';
  final AddUpdateMeetingArguments arguments;
  AddUpdateMeeting(this.arguments);
  @override
  _AddUpdateMeetingState createState() => _AddUpdateMeetingState();
}

class _AddUpdateMeetingState extends State<AddUpdateMeeting> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = false, _isRecurrent = false;
  String _projectName,
      _startDate,
      // _endDate,
      _startTime,
      _endTime,
      _recurrentDay,
      _color;
  List<User> _invited = [];
  bool _isInvitedError = false;
  bool _isColorError = false;
  bool _isRecurrentDayError = false;
  //bool _isEndTimeError = false;
  TextEditingController startDateCtl = TextEditingController();
  //TextEditingController endDateCtl = TextEditingController();
  TextEditingController startTimeCtl = TextEditingController();
  TextEditingController endTimeCtl = TextEditingController();
  TextEditingController _typeAheadController = TextEditingController();
  User _selectedUser;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    if (widget.arguments.meeting != null) {
      Meeting _meeting = widget.arguments.meeting;
      _projectName = _meeting.projectName;
      _startDate = _meeting.startDate;
      startDateCtl.text = _startDate;
      // _endDate = _meeting.endDate;
      //  endDateCtl.text = _endDate;
      _startTime = _meeting.startTime;
      startTimeCtl.text = _startTime;
      if (_meeting.endTime != '') {
        _endTime = _meeting.endTime;
        _isRecurrent = true;
      }
      // _endTime = _meeting.endTime;
      // endTimeCtl.text = _endTime;
      if (_meeting.reccurentDay != '') {
        _recurrentDay = _meeting.reccurentDay;
        _isRecurrent = true;
      }
      _invited = _meeting.invited;
      _color = _meeting.color;
    } else {
      _startDate = widget.arguments.startDate;
      startDateCtl.text = _startDate;
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    setState(() {
      _isRecurrentDayError =
          _isRecurrent && _recurrentDay == null ? true : false;
      // _isRecurrent && _endTime == null ? false : true;
      _isInvitedError = _invited.length != 0 ? false : true;
      _isColorError = _color != null ? false : true;
    });
    if (form.validate() && !_isInvitedError && !_isColorError) {
      form.save();
      return true;
    }
    return false;
  }

  Widget _showTitle(text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 10),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildProjectameInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      initialValue: _projectName,
      keyboardType: TextInputType.text,
      decoration: inputTextDecoration(
          10.0, null, getTranslate(context, "PROJECT_NAME"), null, null),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onSaved: (value) => _projectName = value.trim(),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: RED_DARK,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: RED_DARK)
                .copyWith(secondary: RED_DARK),
          ),
          child: child,
        );
      },
    );
    if (d != null) {
      if (isStart) {
        _startDate = new DateFormat("yyyy-MM-dd").format(d);
        startDateCtl.text = _startDate;
      }
      /*  else {
        _endDate = new DateFormat("yyyy-MM-dd").format(d);
        endDateCtl.text = _endDate;
      } */
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay d = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: RED_DARK,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: RED_DARK)
                .copyWith(secondary: RED_DARK),
          ),
          child: child,
        );
      },
    );
    if (d != null) {
      if (isStart) {
        _startTime = d.format(context);
        startTimeCtl.text = _startTime;
      } else {
        _endTime = d.format(context);
        endTimeCtl.text = _endTime;
      }
    }
  }

  Widget _showDatePicker(bool isStart) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0,
          null,
          // isStart ?
          getTranslate(context, "START_DATE"),
          // : getTranslate(context, "END_DATE"),
          null,
          null),
      controller: startDateCtl,
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : !isStart && _startDate != null && !isDateBigger(_startDate, value)
              ? getTranslate(context, "INVALID_DATE")
              : null,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context, isStart);
      },
    );
  }

  Widget _showTimePicker(bool isStart) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0,
          null,
          isStart
              ? getTranslate(context, "START_TIME")
              : getTranslate(context, "END_TIME"),
          null,
          null),
      controller: isStart ? startTimeCtl : endTimeCtl,
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : !isStart /* && _endTime != null  */ &&
                  !isTimeBigger(_startTime, value)
              ? getTranslate(context, "INVALID_TIME")
              : null,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectTime(context, isStart);
      },
    );
  }

  Widget _showDayInput() {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: inputTextDecoration(
              10.0,
              null,
              getTranslate(context, "SELECT_RECURRENT_DAY"),
              _isRecurrentDayError
                  ? getTranslate(context, "FILL_IN_FIELD")
                  : null,
              null),
          isEmpty: _recurrentDay == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _recurrentDay,
              dropdownColor: BLUE_LIGHT,
              icon: Icon(
                Icons.arrow_drop_down_sharp,
                color: Colors.white,
              ),
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  _recurrentDay = newValue;
                  state.didChange(newValue);
                });
              },
              items: Meeting.meetingDays.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    getTranslate(context, value.toUpperCase()),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _showColorSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _color = RED;
            });
          },
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: _color == RED ? Colors.white : Colors.transparent),
                color: Color(int.parse(RED)),
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _color = BLUE;
            });
          },
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: _color == BLUE ? Colors.white : Colors.transparent),
                color: Color(int.parse(BLUE)),
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _color = GREEN;
            });
          },
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: _color == GREEN ? Colors.white : Colors.transparent),
                color: Color(int.parse(GREEN)),
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _color = YELLOW;
            });
          },
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color:
                        _color == YELLOW ? Colors.white : Colors.transparent),
                color: Color(int.parse(YELLOW)),
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _color = BROWN;
            });
          },
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: _color == BROWN ? Colors.white : Colors.transparent),
                color: Color(int.parse(BROWN)),
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _color = PURPLE;
            });
          },
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color:
                        _color == PURPLE ? Colors.white : Colors.transparent),
                color: Color(int.parse(PURPLE)),
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    );
  }

  Widget _showUserSuggestions() {
    return StatefulBuilder(builder: (context, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: BLUE_DARK_LIGHT,
              height: 40.0,
              child: Center(
                  child: Text(
                getTranslate(context, "INVITED_PEOPLE"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  Text(
                    getTranslate(context, "SEARCH_USER_NOTICE"),
                    style: TextStyle(color: GREY_LIGHt, fontSize: 13),
                  ),
                  SizedBox(height: 10),
                  TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _typeAheadController,
                        style: TextStyle(color: Colors.white),
                        decoration: inputTextDecoration(10.0, null,
                            getTranslate(context, "SEARCH_HERE"), null, null),
                      ),
                      suggestionsCallback: UserService().getSuggetions,
                      debounceDuration: Duration(milliseconds: 500),
                      hideSuggestionsOnKeyboardHide: true,
                      noItemsFoundBuilder: (value) {
                        return Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              getTranslate(context, "NO_DATA"),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                      itemBuilder: (context, User user) {
                        return ListTile(
                          title: user.company != null
                              ? Text("${user.company.name}")
                              : Text("${user.firstName} ${user.lastName}"),
                          //subtitle: Text(user.email),
                          leading: user.company != null
                              ? getCompanyAvatar(
                                  null, user.company, BLUE_LIGHT, 15)
                              : getUserAvatar(user, BLUE_LIGHT, 15),
                        );
                      },
                      onSuggestionSelected: (User user) {
                        _typeAheadController.text =
                            "${user.firstName} ${user.lastName}";
                        set(() {
                          _selectedUser = user;
                        });
                      }),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: _selectedUser == null
                            ? null
                            : () {
                                if (_invited.indexWhere((element) =>
                                        element.id == _selectedUser.id) ==
                                    -1) {
                                  setState(() {
                                    _invited.add(_selectedUser);
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                        child: Text(getTranslate(context, "ADD"))),
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(getTranslate(context, "CANCEL"))),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _showSaveFormBtn() {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox.shrink(),
      label: Text(
        getTranslate(context, "SAVE"),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final res = widget.arguments.meeting == null
                      ? await MeetingService().addMeeting(
                          _projectName,
                          _startDate,
                          // _endDate,
                          _recurrentDay,
                          _startTime,
                          _endTime,
                          _color,
                          _invited)
                      : await MeetingService().updateMeeting(
                          widget.arguments.meeting.id,
                          _projectName,
                          _startDate,
                          //_endDate,
                          _recurrentDay,
                          _startTime,
                          _endTime,
                          _color,
                          _invited);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  final jsonData = json.decode(res.body);
                  MeetingProvider meetingProvider =
                      Provider.of<MeetingProvider>(context, listen: false);
                  meetingProvider
                      .addMeeting(Meeting.fromJson(jsonData["data"]));
                  showSnackbar(
                      context,
                      widget.arguments.meeting == null
                          ? getTranslate(context, "ADD_SUCCESS")
                          : getTranslate(context, "MODIFY_SUCCESS"));
                  Navigator.of(context).pop();
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

  // ignore: non_constant_identifier_names
  Widget FormBuild() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _showTitle(getTranslate(context, "PROJECT_NAME")),
              buildProjectameInput(),
              SizedBox(height: 10),
              _showTitle(getTranslate(context, "START_DATE")),
              _showDatePicker(true),
              /*   SizedBox(height: 10),
                _showTitle(getTranslate(context, "END_DATE")),
                _showDatePicker(false), */
              SizedBox(height: 10.0),
              _showTitle(getTranslate(context, "START_TIME")),
              _showTimePicker(true),
              SizedBox(height: 10.0),
              _showTitle(getTranslate(context, "END_TIME")),
              _showTimePicker(false),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslate(context, "RECURRENT_MEETING"),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _isRecurrent,
                    onChanged: (value) {
                      setState(() {
                        _isRecurrent = value;
                      });
                    },
                  ),
                ],
              ),
              _isRecurrent ? SizedBox(height: 10.0) : SizedBox.shrink(),
              _isRecurrent ? _showDayInput() : SizedBox.shrink(),
              SizedBox(height: 20.0),
              _showColorSelect(),
              _isColorError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                      child: Text(
                        getTranslate(context, "FILL_IN_FIELD"),
                        style: TextStyle(
                            color: Colors.deepOrange[200], fontSize: 12),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 20.0),
              Text(
                getTranslate(context, "INVITED_PEOPLE"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              TextButton.icon(
                  onPressed: _isLoading
                      ? () => null
                      : () async {
                          _typeAheadController.clear();
                          _selectedUser = null;
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return _showUserSuggestions();
                              });
                        },
                  icon: Icon(
                    Icons.add_circle_rounded,
                    color: RED_DARK,
                    size: 20,
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent)),
                  label: Text(
                    getTranslate(context, "INVITE_PEOPOLE"),
                    style: TextStyle(color: GREY_LIGHt),
                  )),
              SizedBox(height: 10),
              ..._invited.map((User user) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _invited.removeWhere(
                                (element) => element.id == user.id);
                          });
                        },
                        icon: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: Image.asset(TRASH_ICON, color: GREY_LIGHt),
                        ),
                      ),
                      tileColor: BLUE_LIGHT,
                      leading: user.company != null
                          ? getCompanyAvatar(null, user.company, BLUE_LIGHT, 20)
                          : getUserAvatar(user, BLUE_LIGHT, 20),
                      // subtitle: Text(
                      //   user.email,
                      //   style: TextStyle(color: GREY_LIGHt),
                      // ),
                      title: Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              _isInvitedError
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        getTranslate(context, "INVITED_TO_MEET_EMPTY"),
                        style: TextStyle(
                            color: Colors.deepOrange[200], fontSize: 12),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 50.0),
              _showSaveFormBtn()
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget FormBuild2() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _showTitle(getTranslate(context, "PROJECT_NAME")),
              buildProjectameInput(),
              SizedBox(height: 10),
              _showTitle(getTranslate(context, "START_DATE")),
              _showDatePicker(true),
              SizedBox(height: 10),
              _showTitle(getTranslate(context, "START_TIME")),
              _showTimePicker(true),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslate(context, "RECURRENT_MEETING"),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _isRecurrent,
                    onChanged: (value) {
                      setState(() {
                        _isRecurrent = value;
                      });
                    },
                  ),
                ],
              ),
              _isRecurrent ? SizedBox(height: 10.0) : SizedBox.shrink(),
              _isRecurrent ? _showDayInput() : SizedBox.shrink(),
              SizedBox(height: 20.0),
              _showColorSelect(),
              _isColorError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                      child: Text(
                        getTranslate(context, "FILL_IN_FIELD"),
                        style: TextStyle(
                            color: Colors.deepOrange[200], fontSize: 12),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 20.0),
              Text(
                getTranslate(context, "INVITED_PEOPLE"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              TextButton.icon(
                  onPressed: _isLoading
                      ? () => null
                      : () async {
                          _typeAheadController.clear();
                          _selectedUser = null;
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return _showUserSuggestions();
                              });
                        },
                  icon: Icon(
                    Icons.add_circle_rounded,
                    color: RED_DARK,
                    size: 20,
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent)),
                  label: Text(
                    getTranslate(context, "INVITE_PEOPOLE"),
                    style: TextStyle(color: GREY_LIGHt),
                  )),
              SizedBox(height: 10),
              ..._invited.map((User user) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _invited.removeWhere(
                                (element) => element.id == user.id);
                          });
                        },
                        icon: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: Image.asset(TRASH_ICON, color: GREY_LIGHt),
                        ),
                      ),
                      tileColor: BLUE_LIGHT,
                      leading: user.company != null
                          ? getCompanyAvatar(null, user.company, BLUE_LIGHT, 30)
                          : getUserAvatar(user, BLUE_LIGHT, 30),
                      // subtitle: Text(
                      //   user.email,
                      //   style: TextStyle(color: GREY_LIGHt),
                      // ),
                      title: Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              _isInvitedError
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        getTranslate(context, "INVITED_TO_MEET_EMPTY"),
                        style: TextStyle(
                            color: Colors.deepOrange[200], fontSize: 12),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 50.0),
              _showSaveFormBtn()
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
        title: Text(getTranslate(context, "PLAN_MEETING")),
      ),
      body: _isRecurrent ? FormBuild2() : FormBuild(),
    );
  }
}

class AddUpdateMeetingArguments {
  final Meeting meeting;
  final String startDate;
  AddUpdateMeetingArguments(this.meeting, this.startDate);
}
