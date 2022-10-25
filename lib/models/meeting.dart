import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/models/user.dart';

class Meeting {
  int id;
  String projectName;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String reccurentDay;
  int ownerId;
  List<User> invited;
  String color;
  ChatRoom chatRoom;

  Meeting(this.projectName, this.startDate, this.endDate, this.startTime,
      this.endTime, this.reccurentDay, this.invited, this.color);

  Meeting.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        ownerId = json['user_id'],
        projectName = json['project_name'],
        startDate = json['meeting_start_date'],
       // endDate = json['meeting_end_date'],
        startTime = json['meeting_start_time'],
        endTime = json['meeting_end_time'],
        reccurentDay = json['meeting_day'] ?? '',
        invited = User.listFromJson(json['users']),
        chatRoom = ChatRoom.fromJson(json['chatroom']),
        color = json['color'];
  static List<Meeting> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Meeting.fromJson(value)).toList();
  }

  static const List<String> meetingDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
}
