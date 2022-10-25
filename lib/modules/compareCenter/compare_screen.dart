import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/convert_money.dart';
import 'package:profilecenter/utils/helpers/generate_user_qcm_certifications.dart';
import 'package:profilecenter/utils/helpers/get_experience_period.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/compare_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/compareCenter/candidat_header.dart';
import 'package:profilecenter/modules/compareCenter/compare_item.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:provider/provider.dart';

class CompareScreen extends StatefulWidget {
  static const routeName = '/compareScreen';

  final List<String> tags;
  CompareScreen(this.tags);
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  User _userA;
  User _userB;
  List<QcmCertification> _userAcertifs;
  List<QcmCertification> _userBcertifs;

  void fetchUsersToCompare(CompareProvider compareProvider) async {
    _userA = null;
    _userB = null;
    if (compareProvider.usersToCompare.length > 0) {
      _userA = compareProvider.usersToCompare[0];
      _userAcertifs = generateUserCertifications(_userA.qcmCertifications);
    }
    if (compareProvider.usersToCompare.length > 1) {
      _userB = compareProvider.usersToCompare[1];
      _userBcertifs = generateUserCertifications(_userB.qcmCertifications);
    }
    if (_userA == null && _userB == null) {
      Navigator.of(context).pop();
    }
  }

  String getQcmNote(List<QcmCertification> certifs, String module) {
    QcmCertification qcmCertification = certifs.firstWhere(
        (element) =>
            element.moduleName.trim().toUpperCase() ==
            module.trim().toUpperCase(),
        orElse: () => null);
    if (qcmCertification != null)
      return "${qcmCertification.mark.toInt()} %";
    else
      return getTranslate(context, "NO_QCM");
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    CompareProvider compareProvider =
        Provider.of<CompareProvider>(context, listen: true);
    fetchUsersToCompare(compareProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "COMPARE_CENTER")),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _userA != null ? CandidatHeader(_userA) : SizedBox.shrink(),
                  _userB != null ? CandidatHeader(_userB) : SizedBox.shrink(),
                ],
              ),
              SizedBox(height: 20.0),
              Divider(color: GREY_LIGHt),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          MdiIcons.hexagon,
                          color: BLUE_SKY,
                          size: 60,
                        ),
                        userProvider.user.pack.notAllowed
                                .contains(COMPARATOR_DATA_PRIVILEGE)
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                width: 30,
                                height: 20,
                              )
                            : Text(
                                "${_userA.note.toInt()}%",
                                style: TextStyle(color: Colors.white),
                              )
                      ],
                    ),
                  ),
                  Text(
                    getTranslate(context, "MATCH NOTE"),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: RED_DARK),
                  ),
                  Container(
                    width: 100,
                    child: _userB != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                MdiIcons.hexagon,
                                color: BLUE_SKY,
                                size: 60,
                              ),
                              userProvider.user.pack.notAllowed
                                      .contains(COMPARATOR_DATA_PRIVILEGE)
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: 30,
                                      height: 20,
                                    )
                                  : Text(
                                      "${_userB.note.toInt()}%",
                                      style: TextStyle(color: Colors.white),
                                    )
                            ],
                          )
                        : SizedBox.shrink(),
                  )
                ],
              ),
              Divider(color: GREY_LIGHt),
              SizedBox(height: 20.0),
              CompareItem(
                  "${_userA.experiences.length} ${getTranslate(context, "PROJECTS")}",
                  SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(PROJECTS_ICON)),
                  _userB != null
                      ? "${_userB.experiences.length} ${getTranslate(context, "PROJECTS")}"
                      : null),
              CompareItem(
                  "${getExperiencesPeriod(_userA.experiences)}",
                  SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(EXPERIENCE_ICON)),
                  _userB != null
                      ? "${getExperiencesPeriod(_userB.experiences)}"
                      : null),
              CompareItem(
                  _userA.stars == null ? "..." : "${_userA.stars}/5",
                  SizedBox(
                      width: 40.0, height: 40.0, child: Image.asset(NOTE_ICON)),
                  _userB == null
                      ? null
                      : _userB.stars == null
                          ? "..."
                          : "${_userB.stars}/5"),
              ...widget.tags.map((tag) => CompareItem(
                  getQcmNote(_userAcertifs, tag),
                  Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: YELLOW_DARK,
                          borderRadius: BorderRadius.circular(30)),
                      child: Container(
                        width: 50,
                        child: Center(
                          child: Text(
                            tag.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  _userB == null ? '' : getQcmNote(_userBcertifs, tag))),
              CompareItem(
                  _userA.distance != null
                      ? "${_userA.distance.toInt()} km"
                      : getTranslate(context, "NO_LOCATION"),
                  SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(LOCALISATION_ICON)),
                  _userB == null
                      ? ''
                      : _userB.distance != null
                          ? "${_userB.distance.toInt()} km"
                          : getTranslate(context, "NO_LOCATION")),
              CompareItem(
                  _userA.isDisponible
                      ? getTranslate(context, "DISPONIBLE")
                      : "${getTranslate(context, "NON_DISPONIBLE")}\n${getTranslate(context, "RETURN_DATE")} ${_userA.returnToJobDate == null ? '' : _userA.returnToJobDate}",
                  SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(CALENDAR_ICON)),
                  _userB == null
                      ? ''
                      : _userB.isDisponible
                          ? getTranslate(context, "DISPONIBLE")
                          : "${getTranslate(context, "NON_DISPONIBLE")}\n${getTranslate(context, "RETURN_DATE")} ${_userB.returnToJobDate == null ? '' : _userB.returnToJobDate}"),
              CompareItem(
                  "${_userA.disponibility} ${getTranslate(context, "DAY_PER_WEEK")}",
                  SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(CALENDAR_ICON)),
                  _userB != null
                      ? "${_userB.disponibility} ${getTranslate(context, "DAY_PER_WEEK")}"
                      : null),
              CompareItem(
                  _userA.salary == null
                      ? getTranslate(context, "NOT_MENTIONNED")
                      : "${convertMoney(_userA.devise, _userA.salary, userProvider.user.devise).toStringAsFixed(2)} ${userProvider.user.devise.name} ${_userA.role == 'freelance' ? '/jour' : '/mois'}",
                  SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(MONEY_ICON)),
                  _userB == null
                      ? ''
                      : _userB.salary == null
                          ? getTranslate(context, "NOT_MENTIONNED")
                          : "${convertMoney(_userB.devise, _userB.salary, userProvider.user.devise).toStringAsFixed(2)} ${userProvider.user.devise.name} ${_userB.role == 'freelance' ? '/jour' : '/mois'}"),
            ],
          ),
        ),
      ),
    );
  }
}
