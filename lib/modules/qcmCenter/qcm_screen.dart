import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:profilecenter/providers/qcm_certificat_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/qcm_level.dart';
import 'package:profilecenter/models/qcm_module.dart';
import 'package:profilecenter/models/qcm_question.dart';
import 'package:profilecenter/core/services/qcm_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class QcmScreen extends StatefulWidget {
  static const routeName = '/qcmScreen';

  final QcmScreenArguments qcmScreenArguments;
  QcmScreen(this.qcmScreenArguments);
  @override
  _QcmScreenState createState() => _QcmScreenState();
}

class _QcmScreenState extends State<QcmScreen> {
  List<QcmQuestion> _questions = [];
  Timer _timer;
  int _qcmTime = 0;
  bool _isTestFinished = false;
  bool _isLoading = false;
  bool _isTestFail = false;
  bool _isTestSuccess = false;
  bool _error = false;
  QcmCertification _qcmCertificationRes;

  @override
  void initState() {
    super.initState();
    _getQuestions();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  Future<void> _getQuestions() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final res = await QcmService().getQuestion(
          widget.qcmScreenArguments.qcmModule.id,
          widget.qcmScreenArguments.qcmLevel.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _questions = QcmQuestion.listFromJson(jsonData["questions"]);
      _qcmTime = getSeconds(widget.qcmScreenArguments.qcmLevel.time);
      startTimer();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _isLoading = false;
      });
    }
  }

  void _showConfirmationDialog() {
    int notAnswered = 0;
    _questions.forEach((element) {
      if (element.responseId == null) notAnswered++;
    });
    showBottomModal(
        context,
        notAnswered != 0
            ? "$notAnswered ${getTranslate(context, "QUESTIONS_WITH_NO_ANSWERS")}"
            : null,
        getTranslate(context, "VALIDATE_QCM"),
        getTranslate(context, "YES"),
        () {
          Navigator.pop(context);
          validateQcm();
        },
        getTranslate(context, "NO"),
        () {
          Navigator.pop(context);
        });
  }

  Future<bool> _showLeavingDialog() {
    return showBottomModal(
      context,
      null,
      getTranslate(context, "LEAVE_QCM_WARNING"),
      getTranslate(context, "YES"),
      () {
        Navigator.pop(context, false);
        validateQcm();
      },
      getTranslate(context, "NO"),
      () {
        Navigator.pop(context, false);
      },
    );
  }

  void validateQcm() async {
    try {
      stopTimer();
      setState(() {
        _isLoading = true;
        _isTestFinished = true;
      });
      final res = await QcmService().sendResponses(
          widget.qcmScreenArguments.qcmModule.id,
          widget.qcmScreenArguments.qcmLevel.id,
          _questions);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _qcmCertificationRes = QcmCertification.fromJson(jsonData["data"]);
      await QcmService().acceptQcmEvaluationRequest(
          widget.qcmScreenArguments.messageId,
          _qcmCertificationRes.mark.toInt());
      if (_qcmCertificationRes.status == "failed") {
        //test fail
        _isTestFail = true;
      } else {
        //test succes
        QcmCertificationProvider qcmCertificationProvider =
            Provider.of<QcmCertificationProvider>(context, listen: false);
        qcmCertificationProvider.add(_qcmCertificationRes);
        _isTestSuccess = true;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _isLoading = false;
      });
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_qcmTime == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _qcmTime--;
          });
        }
      },
    );
  }

  void stopTimer() {
    if (_timer != null) _timer.cancel();
  }

  String formatTime(int time) {
    int minutes = (time / 60).truncate();
    int seconds = time - (minutes * 60);
    String min = minutes < 10 ? "0" + minutes.toString() : minutes.toString();
    String sec = seconds < 10 ? "0" + seconds.toString() : seconds.toString();
    return min + ":" + sec;
  }

  int getSeconds(String _time) {
    List<String> data = _time.split(":");
    int _minutes = int.parse(data[0]);
    int _seconds = int.parse(data[1]);
    return _minutes * 60 + _seconds;
  }

  Widget questionCard(QcmQuestion question) {
    int index = _questions.indexOf(question);
    return IntrinsicHeight(
      child: Row(
        children: [
          Text(
            "Q" + (index + 1).toString(),
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          VerticalDivider(
            thickness: 2,
            width: 30,
            color: Colors.white,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[350],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Html(data: question.title),
                ),
              ),
              ...question.suggestions
                  .map((e) => suggestionCard(e, index))
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget suggestionCard(Suggestion s, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Radio(
              value: s.id,
              groupValue: _questions[index].responseId,
              onChanged: (val) {
                setState(() {
                  _questions[index].responseId = val;
                });
              }),
          Container(
            width: MediaQuery.of(context).size.width * .60,
            child: Text(
              s.title,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget qcmSuccess() {
    return Center(
      child: Container(
        height: 320,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: BLUE_LIGHT),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: GREEN_LIGHT, size: 40.0),
            SizedBox(height: 10),
            Text(
              "${getTranslate(context, "EVALUATION_IN")} " +
                  widget.qcmScreenArguments.qcmModule.title +
                  " (" +
                  widget.qcmScreenArguments.qcmLevel.title +
                  ")",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "${getTranslate(context, "QCM_SUCCESS_1")} ${_qcmCertificationRes.mark.toInt()}%. ${getTranslate(context, "QCM_SUCCESS_2")} ${_qcmCertificationRes.seuil.toInt()}%.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Text(
              getTranslate(context, "QCM_SUCCESS_3"),
              textAlign: TextAlign.center,
              style: TextStyle(color: GREY_LIGHt),
            ),
            SizedBox(height: 10.0),
            widget.qcmScreenArguments.isRequestFromCompany
                ? Text(
                    getTranslate(context, "QCM_SUCCESS_4"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GREY_LIGHt),
                  )
                : SizedBox.shrink(),
            SizedBox(height: 20.0),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(getTranslate(context, "CLOSE")))
          ],
        ),
      ),
    );
  }

  Widget qcmFail() {
    return Center(
      child: Container(
        height: 290,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: BLUE_LIGHT),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sms_failed_outlined, color: GREY_DARK, size: 40.0),
            SizedBox(height: 10),
            Text(
              "${getTranslate(context, "EVALUATION_IN")} " +
                  widget.qcmScreenArguments.qcmModule.title +
                  " (" +
                  widget.qcmScreenArguments.qcmLevel.title +
                  ")",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              getTranslate(context, "QCM_FAIL_C"),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            SizedBox(height: 10.0),
            Text(
              "${getTranslate(context, "QCM_FAIL_M_2")} ${_qcmCertificationRes.mark.toInt()}%. ${getTranslate(context, "QCM_FAIL_M_3")} ${_qcmCertificationRes.seuil.toInt()}%.",
              textAlign: TextAlign.center,
              style: TextStyle(color: GREY_LIGHt),
            ),
            SizedBox(height: 10.0),
            widget.qcmScreenArguments.isRequestFromCompany
                ? Text(
                    getTranslate(context, "QCM_SUCCESS_4"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GREY_LIGHt),
                  )
                : SizedBox.shrink(),
            SizedBox(height: 20.0),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(getTranslate(context, "CLOSE")))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          _isTestFinished ? true : await _showLeavingDialog(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.qcmScreenArguments.qcmModule.title +
              " (" +
              widget.qcmScreenArguments.qcmLevel.title +
              ")"),
          actions: [
            Center(
              child: _qcmTime == 0
                  ? SizedBox.shrink()
                  : Text(
                      formatTime(_qcmTime) + "    ",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: circularProgress,
              )
            : _error
                ? ErrorScreen()
                : _isTestFail
                    ? qcmFail()
                    : _isTestSuccess
                        ? qcmSuccess()
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Divider(color: GREY_LIGHt),
                                  ..._questions
                                      .map((e) => Column(
                                            children: [
                                              questionCard(e),
                                              Divider(color: GREY_LIGHt)
                                            ],
                                          ))
                                      .toList(),
                                  SizedBox(height: 20.0),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            _showConfirmationDialog();
                                          },
                                    child: Text(
                                        getTranslate(context, "SHOW_RESULT")),
                                  ),
                                ],
                              ),
                            ),
                          ),
      ),
    );
  }
}

class QcmScreenArguments {
  final QcmModule qcmModule;
  final QcmLevel qcmLevel;
  final bool isRequestFromCompany;
  final int messageId;
  QcmScreenArguments(
      this.qcmModule, this.qcmLevel, this.isRequestFromCompany, this.messageId);
}
