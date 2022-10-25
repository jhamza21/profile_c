import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/chatCenter/invoice_details.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class PayRequest extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  PayRequest(this.message, this.userProvider);
  @override
  _PayRequestState createState() => _PayRequestState();
}

class _PayRequestState extends State<PayRequest> {
  String getMessagetitle(bool isMe) {
    return "${getTranslate(context, "PAY_REQUEST_FOR_PROJECT")} : ${widget.message.offer.title}";
  }
    String getMessagetitle1(bool isMe) { 
    return  "${getTranslate(context, "INVOICE_NUMBER")} : ${widget.message.invoice.invoiceNumber}"  ;
  }

  String getMessageSubtitle(bool isMe) {
    if (isMe) {
      if (widget.message.response == null)
        return getTranslate(context, "PAY_REQUEST_NOT_ANSWERED");
      else if (widget.message.response == true)
        return getTranslate(context, "PAY_REQUEST_ACCEPTED");
      else if (widget.message.response == false && widget.message.text != '')
        return getTranslate(context, "PAY_NEGOCIATION_RECEIVED");
      else
        return getTranslate(context, "PAY_REQUEST_REFUSED");
    } else {
      if (widget.message.response == null)
        return getTranslate(context, "REPLY_ASAP");
      else if (widget.message.response == true)
        return getTranslate(context, "PAY_REQUEST_ACCEPTED");
      else if (widget.message.response == false && widget.message.text != '')
        return getTranslate(context, "PAY_NEGOCIATION_SENT");
      else
        return getTranslate(context, "PAY_REQUEST_REFUSED");
    }
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                         Text(
                        getMessagetitle1(isMe),
                        style: TextStyle(
                            color: BLUE_SKY,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                        SizedBox(height: 5.0),
                      Text(
                        getMessagetitle(isMe),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                      SizedBox(height: 10.0),
                      if (widget.message.response != true)
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  InvoiceDetails.routeName,
                                  arguments: InvoiceDetailsArguments(
                                      widget.message.id,
                                      widget.message.invoice,
                                      !isMe,
                                      widget.message.response == true ||
                                          widget.message.text != ''));
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(RED_DARK),
                            ),
                            child:
                                Text(getTranslate(context, "CONSULT_INVOICE")),
                          ),
                        ),
                      SizedBox(height: 10.0),
                      Text(
                        getMessageSubtitle(isMe),
                        style: TextStyle(color: GREY_LIGHt, fontSize: 12.0),
                      ),
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
