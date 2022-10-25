import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class MeetingService {
//get meetings
  Future<http.Response> getMeetings() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/meeting";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

//add meeting
  Future<http.Response> addMeeting(
      String projectName,
      String startDate,
      // String endDate,
      String day,
      String startTime,
      String endTime,
      String color,
      List<User> invitedUsers) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/meeting/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "project_name": projectName,
          "meeting_start_date": startDate,
          // "meeting_end_date": endDate,
          "meeting_day": day,
          "meeting_start_time": startTime,
          "meeting_end_time": endTime,
          "meeting_color": color,
          "user_id": invitedUsers.map((e) => e.id).toList()
        }));
  }

  //update meeting
  Future<http.Response> updateMeeting(
      int id,
      String projectName,
      String startDate,
      // String endDate,
      String day,
      String startTime,
      String endTime,
      String color,
      List<User> invitedUsers) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/meeting/edit/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "project_name": projectName,
          "meeting_start_date": startDate,
          // "meeting_end_date": endDate,
          "meeting_day": day,
          "meeting_start_time": startTime,
          "meeting_end_time": endTime,
          "meeting_color": color,
          "user_id": invitedUsers.map((e) => e.id).toList()
        }));
  }

//delete meeting
  Future<http.Response> deleteMeeting(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/meeting/delete/$id";
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}
