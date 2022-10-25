import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/qcm_module.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/qcm_service.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_card.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';

class QcmCenter extends StatefulWidget {
  static const routeName = '/qcmCenter';
  final QcmCenterArguments qcmCenterArguments;
  QcmCenter(this.qcmCenterArguments);
  @override
  _QcmCenterState createState() => _QcmCenterState();
}

class _QcmCenterState extends State<QcmCenter> {
  List<QcmModule> _modules = [];
  bool _isLoading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _getModules();
  }

  Future<void> _getModules() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final res = await QcmService().getModules();
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _modules = QcmModule.listFromJson(jsonData["modules"]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Test Center",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(
              child: circularProgress,
            )
          : _error
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _modules.length == 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Center(
                                child: Text(
                                  getTranslate(context, "NO_DATA"),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _modules.length,
                              itemBuilder: (context, i) {
                                return _modules[i].levels.isNotEmpty
                                    ? QcmCard(
                                        _modules[i],
                                        widget.qcmCenterArguments.qcmCertifs,
                                        widget.qcmCenterArguments
                                            .isCompanyrequest,
                                        widget.qcmCenterArguments.candidat)
                                    : SizedBox.shrink();
                              })),
                ),
    );
  }
}

class QcmCenterArguments {
  final List<QcmCertification> qcmCertifs;
  bool isCompanyrequest;
  final User candidat;
  QcmCenterArguments(this.qcmCertifs, this.isCompanyrequest, this.candidat);
}
