import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/providers/mission_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/disponibility/disponibility_candidat.dart';
import 'package:profilecenter/modules/financeCenter/residency_permi_changer.dart';
import 'package:profilecenter/modules/financeCenter/salary_changer.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/complete_profile_notice_candidat.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:profilecenter/widgets/finance_item.dart';
import 'package:provider/provider.dart';

class FinanceCandidat extends StatefulWidget {
  static const routeName = '/financeCandidat';

  @override
  _FinanceCandidatState createState() => _FinanceCandidatState();
}

class _FinanceCandidatState extends State<FinanceCandidat> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: false);
    missionProvider.fetchMissions(context);
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
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: true);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: Text(getTranslate(context, "STATISTICS"))),
      body: _isLoading || missionProvider.isLoading
          ? Center(child: circularProgress)
          : missionProvider.isError
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CompleteProfileNoticeCandidat(),
                        SizedBox(height: 20.0),
                        ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: BLUE_LIGHT,
                            title: Row(
                              children: [
                                Text(
                                  userProvider.user.role == "freelance"
                                      ? "${getTranslate(context, "TJM")} : "
                                      : "${getTranslate(context, "MONTHLY_SALARY")} : ",
                                  style: TextStyle(
                                      color: GREY_LIGHt, fontSize: 14),
                                ),
                                Text(
                                  userProvider.user.salary != null
                                      ? "${userProvider.user.salary} ${userProvider.user.devise.symbol}"
                                      : '',
                                  style: TextStyle(
                                      color: GREEN_LIGHT,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () async {
                                Navigator.of(context)
                                    .pushNamed(SalaryChanger.routeName);
                              },
                              child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child:
                                    Image.asset(EDIT_ICON, color: Colors.white),
                              ),
                            )),
                        SizedBox(height: 10.0),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: BLUE_LIGHT,
                          title: Row(
                            children: [
                              Text(
                                getTranslate(context, "DISPONIBILITY") + " : ",
                                style:
                                    TextStyle(color: GREY_LIGHt, fontSize: 14),
                              ),
                              Text(
                                userProvider.user.isDisponible
                                    ? getTranslate(context, "DISPONIBLE")
                                    : getTranslate(context, "NON_DISPONIBLE"),
                                style: TextStyle(
                                    color: userProvider.user.isDisponible
                                        ? GREEN_LIGHT
                                        : RED_DARK,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: GestureDetector(
                            onTap: () async {
                              if (userProvider.user.pack.notAllowed
                                  .contains(CALENDAR_PRIVILEGE))
                                _showUpgradePackageDialog(getTranslate(context,
                                    "UPGRADE_PACKAGE_DISPONIBILITE_ACCESS_NOTICE"));
                              else
                                Navigator.of(context)
                                    .pushNamed(DisponibilityCandidat.routeName);
                            },
                            child: SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child:
                                  Image.asset(EDIT_ICON, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: BLUE_LIGHT,
                            title: Row(
                              children: [
                                Text(
                                  getTranslate(context, "RESIDENCE_PERMIS") +
                                      " : ",
                                  style: TextStyle(
                                      color: GREY_LIGHt, fontSize: 14),
                                ),
                                Text(
                                  userProvider.user.residencyPermit != null
                                      ? userProvider.user.residencyPermit
                                          .toUpperCase()
                                      : '',
                                  style: TextStyle(
                                      color: GREEN_LIGHT,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pushNamed(
                                    ResidencyPermitChanger.routeName);
                              },
                              child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child:
                                    Image.asset(EDIT_ICON, color: Colors.white),
                              ),
                            )),
                        SizedBox(height: 40.0),
                        Text(
                          getTranslate(context, "STATISTICS"),
                          style: TextStyle(
                              color: GREY_LIGHt, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FinanceItem(
                                text: getTranslate(context, "TURNOVER"),
                                value:
                                    "${missionProvider.turnover * userProvider.user.devise.rapport} ${userProvider.user.devise.symbol}"),
                            SizedBox(width: 10.0),
                            FinanceItem(
                              text: getTranslate(context, "MISSIONS_DONE"),
                              value:
                                  "${missionProvider.missionsCompleted.length}",
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FinanceItem(
                              text:
                                  getTranslate(context, "MISSION_IN_PROGRESS"),
                              value:
                                  "${missionProvider.missionsInProgress.length}",
                            ),
                            SizedBox(width: 10.0),
                            FinanceItem(
                              text: getTranslate(context, "GLOBAL_MARK"),
                              value: "${missionProvider.globalAverageStarts}/5",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
