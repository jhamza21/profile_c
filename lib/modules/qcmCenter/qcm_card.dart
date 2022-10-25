import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/last_failed_qcm.dart';
import 'package:profilecenter/utils/helpers/last_success_qcm.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/qcm_level.dart';
import 'package:profilecenter/models/qcm_module.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/core/services/qcm_service.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_screen.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/qcm_level_item.dart';

class QcmCard extends StatefulWidget {
  final QcmModule qcmModule;
  final List<QcmCertification> qcmCertifs;
  final User candidat;
  final bool isCompanyRequest;
  QcmCard(
      this.qcmModule, this.qcmCertifs, this.isCompanyRequest, this.candidat);
  @override
  _QcmCardState createState() => _QcmCardState();
}

class _QcmCardState extends State<QcmCard> {
  bool _isLoading = false;

  void _showCandidatAlreadyInvitedDialog(
      String date, QcmModule qcmModule, QcmLevel qcmLevel) {
    showBottomModal(
        context,
        null,
        "${getTranslate(context, "QCM_INVIT_ALREADY_SENT_1")} $date. ${getTranslate(context, "QCM_INVIT_ALREADY_SENT_2")}",
        getTranslate(context, "YES"),
        () async {
          try {
            Navigator.of(context).pop();
            setState(() {
              _isLoading = true;
            });
            var res = await QcmService().sendQcmEvaluationRequest(
                widget.candidat.id, qcmModule.id, qcmLevel.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            showSnackbar(
                context, getTranslate(context, "QCM_REQUEST_SENT_SUCCESS"));
            Navigator.of(context).pop();
            setState(() {
              _isLoading = false;
            });
          } catch (e) {
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
            setState(() {
              _isLoading = false;
            });
          }
        },
        getTranslate(context, "NO"),
        () {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        });
  }

  void sendQcmRequest(QcmModule qcmModule, QcmLevel qcmLevel) async {
    try {
      setState(() {
        _isLoading = true;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      var res =
          await QcmService().getLatestQcmRequest(qcmModule.id, qcmLevel.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      var jsonData = json.decode(res.body);
      if (jsonData["data"] != null) {
        String date = jsonData["data"]["created_at"].substring(0, 10);
        _showCandidatAlreadyInvitedDialog(date, qcmModule, qcmLevel);
        return;
      }
      res = await QcmService().sendQcmEvaluationRequest(
          widget.candidat.id, qcmModule.id, qcmLevel.id);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      showSnackbar(context, getTranslate(context, "QCM_REQUEST_SENT_SUCCESS"));
      Navigator.of(context).pop();
    } catch (e) {
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(QcmModule qcmModule, QcmLevel qcmLevel) {
    showBottomModal(
        context,
        qcmModule.title + "(" + qcmLevel.title + ")",
        widget.isCompanyRequest
            ? "${getTranslate(context, "QCM_REQUEST_1")} ${widget.candidat.firstName} ${widget.candidat.lastName} ${getTranslate(context, "QCM_REQUEST_2")}"
            : getTranslate(context, "QCM_NOTICE_1") +
                qcmLevel.time +
                getTranslate(context, "QCM_NOTICE_2"),
        widget.isCompanyRequest
            ? getTranslate(context, "YES")
            : getTranslate(context, "START"),
        () {
          Navigator.of(context).pop();
          if (widget.isCompanyRequest)
            sendQcmRequest(qcmModule, qcmLevel);
          else
            Navigator.of(context).pushNamed(QcmScreen.routeName,
                arguments:
                    QcmScreenArguments(qcmModule, qcmLevel, false, null));
        },
        getTranslate(context, "CANCEL"),
        () {
          Navigator.of(context).pop();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: BLUE_LIGHT),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: 200.0,
              child: Text(
                "  " + widget.qcmModule.title,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          _isLoading ? circularProgress : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...widget.qcmModule.levels.map(
                (e) => GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            QcmCertification _qcmCertifSuccess = lastQcmSuccess(
                                widget.qcmCertifs,
                                widget.qcmModule.title,
                                e.title);
                            QcmCertification _qcmCertifFailed = lastQcmFailed(
                                widget.qcmCertifs,
                                widget.qcmModule.title,
                                e.title);
                            if (_qcmCertifSuccess != null) {
                              showSnackbar(
                                  context,
                                  widget.isCompanyRequest
                                      ? "${widget.candidat.firstName} ${widget.candidat.lastName} ${getTranslate(context, "QCM_RESPONSE_1")} ${_qcmCertifSuccess.mark.toInt()}% ${getTranslate(context, "FOR_QCM")} ${widget.qcmModule.title} (${e.title})"
                                      : "${getTranslate(context, "QCM_RESPONSE_2")} ${_qcmCertifSuccess.mark.toInt()}% ${getTranslate(context, "FOR_QCM")} ${widget.qcmModule.title} (${e.title})");
                            } else if (_qcmCertifFailed != null) {
                              int days = getDays(
                                  _qcmCertifFailed.createdAt,
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()));
                              showSnackbar(
                                  context,
                                  widget.isCompanyRequest
                                      ? "${widget.candidat.firstName} ${widget.candidat.lastName} ${getTranslate(context, "QCM_FAIL_1")} ${widget.qcmModule.title} (${e.title}). ${getTranslate(context, "QCM_FAIL_2")} ${30 - days} ${getTranslate(context, "QCM_FAIL_3")}"
                                      : "${getTranslate(context, "QCM_FAIL_C_1")} ${widget.qcmModule.title} (${e.title}). ${getTranslate(context, "QCM_FAIL_2")} ${30 - days} ${getTranslate(context, "QCM_FAIL_3")}");
                              if (days == 30) {
                                setState(() {
                                  _showDialog(widget.qcmModule, e);
                                });
                              }
                            } else {
                              _showDialog(widget.qcmModule, e);
                            }
                          },
                    child: QcmLevelItem(e.title)),
              )
            ],
          )
        ],
      ),
    );
  }
}
