import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/modules/infoCompany/company_info.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/models/meeting.dart';
import 'package:profilecenter/providers/meeting_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/disponibility/add_update_meeting.dart';
import 'package:profilecenter/modules/disponibility/meeting_card.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class DisponibilityCompany extends StatefulWidget {
  static const routeName = '/disponibilityCompany';

  @override
  _DisponibilityCompanyState createState() => _DisponibilityCompanyState();
}

class _DisponibilityCompanyState extends State<DisponibilityCompany> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, List<Meeting>> _selectedMeetings = {};

  List<Meeting> _getMeetingsForDay(DateTime day) {
    return _selectedMeetings[DateFormat('yyyy-MM-dd').format(day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    fetchMeetings();
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

  void _showNoRhNameNoticeDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "COMPLETE_PROFILE_RESTRICTION"),
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "YES"),
        () async {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(CompanyInfo.routeName);
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
