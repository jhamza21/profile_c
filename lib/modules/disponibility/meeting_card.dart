import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/chatCenter/chat_screen.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/meeting.dart';
import 'package:profilecenter/providers/meeting_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/meeting_service.dart';
import 'package:profilecenter/modules/disponibility/add_update_meeting.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class MeetingCard extends StatefulWidget {
  final Meeting meeting;
  MeetingCard(this.meeting);
  @override
  _MeetingCardState createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  bool _isDeleting = false;

  void _showDeleteDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "DELETE_MEETING_ALERT"),
        getTranslate(context, "YES"),
        () async {
          try {
            Navigator.of(context).pop();
            setState(() {
              _isDeleting = true;
            });
            final res = await MeetingService().deleteMeeting(widget.meeting.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            MeetingProvider meetingProvider =
                Provider.of<MeetingProvider>(context, listen: false);
            meetingProvider.remove(widget.meeting);
            showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
          } catch (e) {
            setState(() {
              _isDeleting = false;
            });
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Icon(
            Icons.circle,
            size: 15,
            color: Color(int.parse(widget.meeting.color)),
          ),
        ),
        tileColor: BLUE_LIGHT,
        title: Text(
          widget.meeting.projectName,
          style: TextStyle(color: Colors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userProvider.user.id == widget.meeting.ownerId)
              IconButton(
                  onPressed: _isDeleting
                      ? null
                      : () => Navigator.pushNamed(
                          context, AddUpdateMeeting.routeName,
                          arguments:
                              AddUpdateMeetingArguments(widget.meeting, null)),
                  icon: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                  )),
            if (userProvider.user.id == widget.meeting.ownerId)
              IconButton(
                  onPressed: () {
                    _showDeleteDialog();
                  },
                  icon: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: _isDeleting
                        ? circularProgress
                        : Image.asset(TRASH_ICON, color: GREY_LIGHt),
                  )),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ChatScreen.routeName,
                      arguments: widget.meeting.chatRoom);
                },
                icon: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: Image.asset(CHAT_ICON, color: GREY_LIGHt))),
          ],
        ),
      ),
    );
  }
}
