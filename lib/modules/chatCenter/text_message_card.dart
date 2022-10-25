import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

Widget textMessageCard(
    Message message, UserProvider userProvider, BuildContext context) {
  bool isMe = message.sender.id == userProvider.user.id ? true : false;
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
                      getSenderName(message.sender),
                      style: TextStyle(
                          color: GREY_LIGHt,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0),
                    ),
                    SizedBox(width: 10),
                    Text(
                      getMessageTime(message, context),
                      style: TextStyle(
                          color: GREY_LIGHt,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  message.text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0),
                ),
                if (message.isSending || message.isError)
                  SizedBox(height: 10.0),
                if (message.isSending || message.isError)
                  Text(
                    message.isSending
                        ? getTranslate(context, "SEND_IN_PROGRESS")
                        : message.isError
                            ? getTranslate(context, "SEND_ERROR")
                            : "",
                    style: TextStyle(
                        color: message.isError ? RED_DARK : GREY_LIGHt,
                        fontSize: 10.0),
                  ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
