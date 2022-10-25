import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/support/help_screen.dart';
import 'package:profilecenter/providers/qcm_certificat_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/settings/app_settings.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/disponibility/disponibility_candidat.dart';
import 'package:profilecenter/modules/documents/files_center_candidat.dart';
import 'package:profilecenter/modules/infoCandidate/candidate_info.dart';
import 'package:profilecenter/modules/financeCenter/finance_candidat.dart';
import 'package:profilecenter/modules/dashboards/list_qcm_certification.dart';
import 'package:profilecenter/modules/profile/profile_pro.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_center.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/candidat_header.dart';
import 'package:profilecenter/widgets/profile_progress.dart';
import 'package:provider/provider.dart';

class CandidatDashboard extends StatefulWidget {
  @override
  _CandidatDashboardState createState() => _CandidatDashboardState();
}

class _CandidatDashboardState extends State<CandidatDashboard> {
  void _showCompleteProfileDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "COMPLETE_PROFILE_RESTRICTION"),
        getTranslate(context, "YES"),
        () {
          Navigator.of(context).pop();

          Navigator.of(context).pushNamed(CandidateInfo.routeName);
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
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
        });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    QcmCertificationProvider qcmCertificationProvider =
        Provider.of<QcmCertificationProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(HelpScreen.routeName);
              },
              icon: Image.asset(APP_ASSISTANCE_ICON))
        ],
        //backgroundColor: BLUE_DARK,
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CandidatHeader(userProvider.user),
            SizedBox(height: 1.0),
            ProfileProgress(userProvider.profileProgress),
            SizedBox(height: 10.0),
            ListQcmCertification(userProvider),
            SizedBox(height: 15.0),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    height: 320,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Positioned(
                          top: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () {
                                    //diponibility
                                    if (userProvider.user.pack.notAllowed
                                        .contains(CALENDAR_PRIVILEGE))
                                      _showUpgradePackageDialog(getTranslate(
                                          context,
                                          "UPGRADE_PACKAGE_DISPONIBILITE_ACCESS_NOTICE"));
                                    else if (userProvider.profileProgress !=
                                        100)
                                      _showCompleteProfileDialog();
                                    else
                                      Navigator.of(context).pushNamed(
                                          DisponibilityCandidat.routeName);
                                  },
                                  icon: Image.asset(DISPONIBILITY_BUTTON)),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () {
                                    //app settings
                                    Navigator.of(context)
                                        .pushNamed(AppSettings.routeName);
                                  },
                                  icon: Image.asset(SETTINGS_BUTTON)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 100.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () {
                                    //files center
                                    Navigator.of(context).pushNamed(
                                        FilesCenterCandidat.routeName);
                                  },
                                  icon: Image.asset(DOCS_BUTTON)),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () {
                                    //finance button
                                    Navigator.of(context)
                                        .pushNamed(FinanceCandidat.routeName);
                                  },
                                  icon: Image.asset(FINANCE_BUTTON)),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () {
                                    //tests center
                                    if (userProvider.user.pack.notAllowed
                                        .contains(QCM_PRIVILEGE))
                                      _showUpgradePackageDialog(getTranslate(
                                          context,
                                          "UPGRADE_PACKAGE_QCM_ACCESS_NOTICE"));
                                    else if (qcmCertificationProvider.isLoading)
                                      showSnackbar(context,
                                          getTranslate(context, "WAIT_PLEASE"));
                                    else if (qcmCertificationProvider.isError)
                                      showSnackbar(
                                          context,
                                          getTranslate(
                                              context, "ERROR_SERVER"));
                                    else
                                      Navigator.of(context).pushNamed(
                                          QcmCenter.routeName,
                                          arguments: QcmCenterArguments(
                                              qcmCertificationProvider
                                                  .certifications,
                                              false,
                                              null));
                                  },
                                  icon: Image.asset(QCM_BUTTON)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 195.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () {
                                    //profile pro
                                    Navigator.of(context)
                                        .pushNamed(ProfilePro.routeName);
                                  },
                                  icon: Image.asset(PROFILE_BUTTON)),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 105.0,
                                  onPressed: () => {
                                        //info perso
                                        Navigator.of(context)
                                            .pushNamed(CandidateInfo.routeName)
                                      },
                                  icon: Image.asset(PERSONAL_INFO_BUTTON)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
