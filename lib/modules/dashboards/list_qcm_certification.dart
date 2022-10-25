import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_center.dart';
import 'package:profilecenter/providers/qcm_certificat_provider.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/generate_user_qcm_certifications.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/widgets/qcm_circular_progress.dart';
import 'package:provider/provider.dart';

class ListQcmCertification extends StatefulWidget {
  final UserProvider userProvider;
  ListQcmCertification(this.userProvider);
  @override
  _ListQcmCertificationState createState() => _ListQcmCertificationState();
}

class _ListQcmCertificationState extends State<ListQcmCertification> {
  @override
  void initState() {
    super.initState();
    fetchCertificats();
  }

  void fetchCertificats() async {
    QcmCertificationProvider qcmCertificationProvider =
        Provider.of<QcmCertificationProvider>(context, listen: false);
    qcmCertificationProvider.fetchCertificats(context);
  }

  void _showUpgradePackageDialog(String msg) {
    showBottomModal(
      context,
      null,
      msg,
      getTranslate(context, "YES"),
      () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(PackChangerCandidat.routeName);
      },
      getTranslate(context, "NO"),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    QcmCertificationProvider qcmCertificationProvider =
        Provider.of<QcmCertificationProvider>(context, listen: true);
    final successCertificates =
        generateUserCertifications(qcmCertificationProvider.certifications);
    return qcmCertificationProvider.isError
        ? SizedBox.shrink()
        : Container(
            height: 108,
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: BLUE_DARK_LIGHT),
            child: qcmCertificationProvider.isLoading
                ? Center(child: Text(getTranslate(context, "WAIT_PLEASE")))
                : qcmCertificationProvider.certifications.length == 0 ||
                        successCertificates.length == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                              child: Text(
                            getTranslate(
                                context, "PASS_QCM_TO_BOOST_VISIBILITY"),
                            style: TextStyle(color: GREY_LIGHt),
                          )),
                          SizedBox(height: 10.0),
                          GestureDetector(
                              onTap: () {
                                UserProvider userProvider =
                                    Provider.of<UserProvider>(context,
                                        listen: false);
                                //tests center
                                if (userProvider.user.pack.notAllowed
                                    .contains(QCM_PRIVILEGE))
                                  _showUpgradePackageDialog(getTranslate(
                                      context,
                                      "UPGRADE_PACKAGE_QCM_ACCESS_NOTICE"));
                                else
                                  Navigator.of(context).pushNamed(
                                      QcmCenter.routeName,
                                      arguments: QcmCenterArguments(
                                          qcmCertificationProvider
                                              .certifications,
                                          false,
                                          null));
                              },
                              child: Text(getTranslate(context, "START")))
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Scrollbar(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    successCertificates.last.levelName.length,
                                itemBuilder: (context, index) {
                                  QcmCertification qcmCertification =
                                      successCertificates[index];
                                  return QcmCircularProgress(
                                      qcmCertification.mark,
                                      qcmCertification.moduleName);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
          );
  }
}
