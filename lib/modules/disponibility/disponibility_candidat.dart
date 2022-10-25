import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/modules/infoCandidate/candidate_info.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/meeting.dart';
import 'package:profilecenter/providers/meeting_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/modules/disponibility/add_update_meeting.dart';
import 'package:profilecenter/modules/disponibility/meeting_card.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class DisponibilityCandidat extends StatefulWidget {
  static const routeName = '/disponibilityCandidat';

  @override
  _DisponibilityCandidatState createState() => _DisponibilityCandidatState();
}

class _DisponibilityCandidatState extends State<DisponibilityCandidat> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, List<Meeting>> _selectedMeetings = {};
  bool _isLoadingDispoDays = false;
  bool _isLoadingIsDispo = false;
  bool _isLoadingReturnDate = false;
  bool _isLoadingMobility = false;
  TextEditingController dateCtl = TextEditingController();
  bool _isDiponible = true;
  String _disponibleDay;

  List<Meeting> _getMeetingsForDay(DateTime day) {
    return _selectedMeetings[DateFormat('yyyy-MM-dd').format(day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    initializeUserDisponibility();
    fetchMeetings();
  }

  void initializeUserDisponibility() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _isDiponible = userProvider.user.isDisponible;
    _disponibleDay = userProvider.user.returnToJobDate;

/*     dateCtl.text =
      DateFormat('dd-MM-yyyy').format(DateTime.parse(_disponibleDay)); */
  }

  void fetchMeetings() async {
    MeetingProvider meetingProvider =
        Provider.of<MeetingProvider>(context, listen: false);
    meetingProvider.fetchMeetings(context);
  }

  void initializeCalendar(MeetingProvider meetingProvider) {
    _selectedMeetings = {};
    meetingProvider.meetings.forEach((meeting) {
      for (int i = 0;
          i <=
              // DateTime.parse(meeting.endtDate)
              DateTime.parse(meeting.startDate)
                  .difference(DateTime.parse(meeting.startDate))
                  .inDays;
          i++) {
        DateTime _day =
            DateTime.parse(meeting.startDate).add(Duration(days: i));
        String _dayName = DateFormat('EEEE').format(_day);
        if (_dayName == 'Saturday' || _dayName == 'Sunday') continue;
        if (meeting.reccurentDay != '' && _dayName != meeting.reccurentDay)
          continue;
        String _formattedDay = DateFormat('yyyy-MM-dd').format(_day);
        if (_selectedMeetings[_formattedDay] == null)
          _selectedMeetings[_formattedDay] = [];
        _selectedMeetings[_formattedDay].add(meeting);
      }
    });
  }

  Widget buildCalendar() {
    return Container(
      decoration: BoxDecoration(
          color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
      child: TableCalendar(
        locale: Localizations.localeOf(context).toString(),
        startingDayOfWeek: StartingDayOfWeek.monday,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2050, 3, 14),
        focusedDay: _focusedDay,
        onDaySelected: (DateTime selectDay, DateTime focusDay) {
          setState(() {
            _selectedDay = selectDay;
            _focusedDay = focusDay;
          });
        },
        selectedDayPredicate: (DateTime date) {
          return isSameDay(_selectedDay, date);
        },
        calendarStyle: CalendarStyle(
          isTodayHighlighted: true,
          selectedDecoration:
              BoxDecoration(color: RED_DARK, shape: BoxShape.circle),
          todayDecoration:
              BoxDecoration(color: RED_BURGUNDY, shape: BoxShape.circle),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Icons.arrow_back_ios,
            color: RED_DARK,
          ),
          rightChevronIcon: Icon(
            Icons.arrow_forward_ios,
            color: RED_DARK,
          ),
        ),
        eventLoader: _getMeetingsForDay,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, meetings) {
            List<Widget> _widgets = [];
            meetings.forEach((meet) {
              _widgets.add(
                Icon(
                  Icons.circle,
                  size: 10,
                  color: Color(int.parse(meet.color)),
                ),
              );
            });
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _widgets);
          },
        ),
      ),
    );
  }

  void updateReturnToJobDate(String date) async {
    try {
      setState(() {
        _isLoadingReturnDate = true;
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
        _isLoadingReturnDate = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReturnDate = false;
        _disponibleDay = null;
        dateCtl.text = '';
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void updateUserIsDisponible(bool value) async {
    try {
      setState(() {
        _isLoadingIsDispo = true;
      });
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      var res = await UserService()
          .updateUserIsDisponible(userProvider.user.id, value);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      userProvider.setUserIsDiponible(value);
      showSnackbar(context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
      setState(() {
        _isDiponible = value;
        _isLoadingIsDispo = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingIsDispo = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      updateReturnToJobDate(DateFormat("yyyy-MM-dd").format(d));
    }
  }

  Widget _showDatePicker() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(fontSize: 12),
          hintText: getTranslate(context, "RETURN_DATE")),
      controller: dateCtl,
      onTap: () {
        if (!_isLoadingIsDispo && !_isLoadingReturnDate) {
          FocusScope.of(context).requestFocus(new FocusNode());
          _selectDate(context);
        }
      },
    );
  }

  Widget buildDisponibilityDateInput(UserProvider userProvider) {
    return Row(
      children: [
        Text("${getTranslate(context, "NON_DISPONIBLE")} :"),
        SizedBox(width: 10),
        _isLoadingIsDispo
            ? circularProgress
            : SizedBox(
                height: 25,
                child: Switch(
                  value: !_isDiponible,
                  onChanged: (value) {
                    updateUserIsDisponible(!value);
                  },
                ),
              ),
        Spacer(),
        !_isDiponible
            ? Container(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getTranslate(context, "RETURN_DATE"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5.0),
                        _isLoadingReturnDate
                            ? circularProgress
                            : SizedBox.shrink()
                      ],
                    ),
                    _showDatePicker(),
                  ],
                ))
            : SizedBox.shrink()
      ],
    );
  }

  void updateUserDisponibilityDays(
      int newValue, UserProvider userProvider) async {
    try {
      setState(() {
        _isLoadingDispoDays = true;
      });
      var res = await UserService()
          .updateDisponibility(userProvider.user.id, newValue);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      userProvider.setDisponibility(newValue);
      setState(() {
        _isLoadingDispoDays = false;
      });
      showSnackbar(context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
    } catch (e) {
      setState(() {
        _isLoadingDispoDays = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  Widget buildDaysDisponibilityInput(UserProvider userProvider) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "${getTranslate(context, "DISPONIBILITY")} :",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 10),
              _isLoadingDispoDays ? circularProgress : SizedBox.shrink(),
            ],
          ),
          FormField<String>(builder: (FormFieldState<String> state) {
            return DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: userProvider.user.disponibility,
                dropdownColor: BLUE_LIGHT,
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: _isLoadingDispoDays
                    ? null
                    : (int newValue) async {
                        updateUserDisponibilityDays(newValue, userProvider);
                      },
                items: [1, 2, 3, 4, 5].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      "$value ${getTranslate(context, "DAY_PER_WEEK")}",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    ]);
  }

  void updateUserMobility(String newValue, UserProvider userProvider) async {
    try {
      setState(() {
        _isLoadingMobility = true;
      });
      var res =
          await UserService().updateMobility(userProvider.user.id, newValue);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      userProvider.setMobility(newValue);
      setState(() {
        _isLoadingMobility = false;
      });
      showSnackbar(context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
    } catch (e) {
      setState(() {
        _isLoadingMobility = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  Widget buildMobilityInput(UserProvider userProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(getTranslate(context, "MOBILITY")),
            SizedBox(width: 10),
            _isLoadingMobility ? circularProgress : SizedBox.shrink(),
          ],
        ),
        Container(
          width: 100,
          child: FormField<String>(builder: (FormFieldState<String> state) {
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: userProvider.user.mobility,
                dropdownColor: BLUE_LIGHT,
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: _isLoadingMobility
                    ? null
                    : (String newValue) async {
                        updateUserMobility(newValue, userProvider);
                      },
                items:
                    ["remote", "presentiel", "indifferent"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      getTranslate(context, value),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showNoRhNameNoticeDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "COMPLETE_PROFILE_RESTRICTION"),
        getTranslate(context, "YES"),
        () async {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(CandidateInfo.routeName);
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  Widget buildAddMeetingBtn(UserProvider userProvider) {
    return TextButton.icon(
        onPressed: () {
          if (userProvider.user.firstName == '')
            _showNoRhNameNoticeDialog();
          else
            Navigator.pushNamed(context, AddUpdateMeeting.routeName,
                arguments: AddUpdateMeetingArguments(
                    null, DateFormat("yyyy-MM-dd").format(_selectedDay)));
        },
        icon: Icon(
          Icons.add_circle_rounded,
          color: RED_DARK,
          size: 20,
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        label: Text(
          getTranslate(context, "PLAN_MEETING"),
          style: TextStyle(color: GREY_LIGHt),
        ));
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    MeetingProvider meetingProvider =
        Provider.of<MeetingProvider>(context, listen: true);
    initializeCalendar(meetingProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "DISPONIBILITY")),
      ),
      body: meetingProvider.isLoading
          ? Center(child: circularProgress)
          : meetingProvider.isError
              ? ErrorScreen()
              // : userProvider.user.pack.notAllowed.contains(CALENDAR_PRIVILEGE)
              //       || meetingProvider.meetings.length == 0
              //     ? Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Container(
              //               child: Image.asset(
              //             "assets/images/stop.png",
              //             height: 100,
              //           )),
              //           SizedBox(
              //             height: 20,
              //           ),
              //           Center(
              //             child: Text(getTranslate(context, "NO-CALENDAR")),
              //           ),
              //         ],
              //       )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCalendar(),
                        SizedBox(height: 10),
                        Divider(color: GREY_LIGHt),
                        buildDisponibilityDateInput(userProvider),
                        Divider(color: GREY_LIGHt),
                        buildDaysDisponibilityInput(userProvider),
                        Divider(color: GREY_LIGHt),
                        buildMobilityInput(userProvider),
                        Divider(color: GREY_LIGHt),
                        SizedBox(height: 10),
                        ..._getMeetingsForDay(_selectedDay)
                            .map((Meeting meeting) => MeetingCard(meeting)),
                        SizedBox(height: 10),
                        buildAddMeetingBtn(userProvider),
                      ],
                    ),
                  ),
                ),
    );
  }
}
