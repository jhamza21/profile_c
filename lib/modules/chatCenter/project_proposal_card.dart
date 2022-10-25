import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class ProjectProposalCard extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  ProjectProposalCard(this.message, this.userProvider);
  @override
  _ProjectProposalCardState createState() => _ProjectProposalCardState();
}

class _ProjectProposalCardState extends State<ProjectProposalCard> {
  bool _isAccepting = false;
  bool _isRefusing = false;

  void _showRefuseProposalDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "REFUSE_PROPOSITION_SERVICE_ALERT"),
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "YES"),
        () async {
          try {
            Navigator.of(context).pop();
            setState(() {
              _isRefusing = true;
            });
            final res =
                await OfferService().refuseProjectProposal(widget.message.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            showSnackbar(context, getTranslate(context, "REFUSE_SUCCESS"));
            setState(() {
              _isRefusing = false;
            });
          } catch (e) {
            setState(() {
              _isRefusing = false;
            });
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        });
  }

  void _showAcceptingProposalDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "ACCEPT_PROPOSITION_SERVICE_ALERT"),
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "YES"),
        () async {
          try {
            Navigator.of(context).pop();
            setState(() {
              _isAccepting = true;
            });
            final res =
                await OfferService().acceptProjectProposal(widget.message.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            showSnackbar(context, getTranslate(context, "ACCEPT_SUCCESS"));
            setState(() {
              _isAccepting = false;
            });
          } catch (e) {
            setState(() {
              _isAccepting = false;
            });
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        });
  }

  String getMessagetitle(bool isMe) {
    return "${getTranslate(context, "PROPOSITION_SERVICE")} ${widget.message.offer.title}";
  }

  String getMessageSubtitle(bool isMe) {
    if (isMe) {
      if (widget.message.response == null)
        return getTranslate(context, "PROPOSITION_NOT_YET_ANSWERED");
      else if (widget.message.response == false)
        return getTranslate(context, "PROPOSITION_REFUSED");
      else
        return getTranslate(context, "PROPOSITION_ACCEPTED");
    } else {
      if (widget.message.response == null)
        return getTranslate(context, "PROPOSITION_RECEIVED");
      else if (widget.message.response == false)
        return getTranslate(context, "PROPOSITION_REFUSED");
      else
        return getTranslate(context, "PROPOSITION_ACCEPTED");
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
                      !isMe && widget.message.response == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton.icon(
                                    onPressed: _isAccepting
                                        ? null
                                        : () {
                                            _showAcceptingProposalDialog();
                                          },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(RED_DARK),
                                    ),
                                    icon: _isAccepting
                                        ? circularProgress
                                        : SizedBox.shrink(),
                                    label:
                                        Text(getTranslate(context, "ACCEPT")),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton.icon(
                                    onPressed: _isRefusing
                                        ? null
                                        : () {
                                            _showRefuseProposalDialog();
                                          },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(RED_DARK),
                                    ),
                                    icon: _isRefusing
                                        ? circularProgress
                                        : SizedBox.shrink(),
                                    label:
                                        Text(getTranslate(context, "REFUSE")),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
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
