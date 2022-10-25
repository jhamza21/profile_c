import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/last_failed_qcm.dart';
import 'package:profilecenter/utils/helpers/last_success_qcm.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/qcm_level.dart';
import 'package:profilecenter/models/qcm_module.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/qcm_service.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_screen.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class QcmRequestCard extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  QcmRequestCard(this.message, this.userProvider);
  @override
  _QcmRequestCardState createState() => _QcmRequestCardState();
}

class _QcmRequestCardState extends State<QcmRequestCard> {
  bool _isAccepting = false;
  bool _isRefusing = false;

  void _showRefuseQcmRequestDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "REFUSE_QCM_ALERT"),
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
            final res = await QcmService()
                .refuseQcmEvaluationRequest(widget.message.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
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

  void _getQcmTime(QcmModule qcmModule, QcmLevel qcmLevel) async {
    try {
      setState(() {
        _isAccepting = true;
      });
      var res = await QcmService().getQcmTime(qcmModule.id, qcmLevel.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      var jsonData = json.decode(res.body);
      String qcmTime = jsonData["time"];
      setState(() {
        _isAccepting = false;
      });
      _showDialog(qcmModule, qcmLevel, qcmTime);
    } catch (e) {
      setState(() {
        _isAccepting = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void _showDialog(QcmModule qcmModule, QcmLevel qcmLevel, String qcmTime) {
    showBottomModal(
        context,
        qcmModule.title + "(" + qcmLevel.title + ")",
        getTranslate(context, "QCM_NOTICE_1") +
            qcmTime +
            getTranslate(context, "QCM_NOTICE_2"),
        getTranslate(context, "CANCEL"),
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "START"),
        () {
          qcmLevel.time = qcmTime;
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(QcmScreen.routeName,
              arguments: QcmScreenArguments(
                  qcmModule, qcmLevel, true, widget.message.id));
        });
  }

  void _handleAcceptQcmTest(List<QcmCertification> _qcmCertifs,
      QcmModule qcmModule, QcmLevel qcmLevel) {
    QcmCertification _qcmCertifSuccess =
        lastQcmSuccess(_qcmCertifs, qcmModule.title, qcmLevel.title);
    QcmCertification _qcmCertifFailed =
        lastQcmFailed(_qcmCertifs, qcmModule.title, qcmLevel.title);
    if (_qcmCertifSuccess != null) {
      showBottomModal(
          context,
          "${getTranslate(context, "QCM_ALREADY_PASSED_1")} ${_qcmCertifSuccess.mark}",
          getTranslate(context, "QCM_ALREADY_PASSED_2"),
          getTranslate(context, "YES"), () async {
        try {
          Navigator.of(context).pop();
          setState(() {
            _isAccepting = true;
          });
          final res = await QcmService().acceptQcmEvaluationRequest(
              widget.message.id, _qcmCertifSuccess.mark.toInt());
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          setState(() {
            _isAccepting = false;
          });
        } catch (e) {
          setState(() {
            _isAccepting = false;
          });
          showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
        }
      }, getTranslate(context, "NO"), () => Navigator.of(context).pop());
    } else if (_qcmCertifFailed != null)
      showBottomModal(
          context,
          "${getTranslate(context, "QCM_FAILED_1")} ${qcmModule.title} (${qcmLevel.title}). ${getTranslate(context, "QCM_ALREADY_PASSED_1")} ${_qcmCertifFailed.mark.toInt()}%.",
          getTranslate(context, "QCM_ALREADY_PASSED_2"),
          getTranslate(context, "YES"), () async {
        try {
          Navigator.of(context).pop();
          setState(() {
            _isAccepting = true;
          });
          final res = await QcmService().acceptQcmEvaluationRequest(
              widget.message.id, _qcmCertifFailed.mark.toInt());
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          setState(() {
            _isAccepting = false;
          });
        } catch (e) {
          setState(() {
            _isAccepting = false;
          });
          showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
        }
      }, getTranslate(context, "NO"), () => Navigator.of(context).pop());
    else
      _getQcmTime(qcmModule, qcmLevel);
  }

  String getMessagetitle(bool isMe) {
    return "${getTranslate(context, "EVALUATION_IN")} ${widget.message.qcmModule.title} (${widget.message.qcmLevel.title})";
  }

  String getMessageSubtitle(bool isMe) {
    if (isMe) {
      if (widget.message.response == null)
        return getTranslate(context, "QCM_NOT_PASSED_YET");
      else if (widget.message.response == false)
        return getTranslate(context, "CANDIDAT_REFUSE_QCM");
      else
        return getTranslate(context, "CANDIDAT_ACCEPT_QCM");
    } else {
      if (widget.message.response == null)
        return getTranslate(context, "PASS_EXAM_QUICK");
      else if (widget.message.response == false)
        return getTranslate(context, "CANDIDAT_REFUSE_QCM");
      else
        return getTranslate(context, "CANDIDAT_ACCEPT_QCM");
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
                                    onPressed: () {
                                      _handleAcceptQcmTest(
                                          widget.userProvider.user
                                              .qcmCertifications,
                                          widget.message.qcmModule,
                                          widget.message.qcmLevel);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(RED_DARK),
                                    ),
                                    icon: _isAccepting
                                        ? circularProgress
                                        : SizedBox.shrink(),
                                    label: Text(getTranslate(context, "PASS")),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showRefuseQcmRequestDialog();
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
                          : SizedBox.shrink()
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
