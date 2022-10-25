import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class QcmResponseCard extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  QcmResponseCard(this.message, this.userProvider);
  @override
  _QcmResponseCardState createState() => _QcmResponseCardState();
}

class _QcmResponseCardState extends State<QcmResponseCard> {
  String getMessagetitle(bool isMe) {
    return "${getTranslate(context, "EVALUATION_IN")} ${widget.message.qcmModule.title} (${widget.message.qcmLevel.title})";
  }

  String getMessageSubtitle(bool isMe) {
    if (widget.message.response == false)
      return getTranslate(context, "CANDIDAT_REFUSE_QCM");
    else
      return "${getTranslate(context, "NOTE")} : ${widget.message.text}%";
  }

  @override
  Widget build(BuildContext context) {
    bool isMe =
        widget.message.sender.id == widget.userProvider.user.id ? true : false;

    return Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                  color: isMe ? Colors.transparent : BLUE_LIGHT,
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          bottomLeft: Radius.circular(15.0))
                      : BorderRadius.only(
                          topRight: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0))),
              child: Column(
                crossAxisAlignment:
                    !isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        getSenderName(widget.message.sender),
                        style: TextStyle(
                            color: GREY_LIGHt,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                      SizedBox(width: 10),
                      Text(
                        getMessageTime(widget.message, context),
                        style: TextStyle(
                            color: GREY_LIGHt,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getMessagetitle(isMe),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        getMessageSubtitle(isMe),
                        style: TextStyle(color: GREY_LIGHt, fontSize: 12.0),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
