import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/activity_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/complete_profile_notice_company.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:profilecenter/widgets/finance_item.dart';
import 'package:provider/provider.dart';

class FinanceCompany extends StatefulWidget {
  static const routeName = '/financeCompany';

  @override
  _FinanceCompanyState createState() => _FinanceCompanyState();
}

class _FinanceCompanyState extends State<FinanceCompany> {
  bool _isLoading = true;
  bool _error = false;

  int _nbOffers,
      _nbCandidatures,
      _missionInProgress,
      _missionDone,
      _nbProfileViews;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  void fetchActivities() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      final res = await ActivityService()
          .getCompanyStatistic(userProvider.user.company.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _nbOffers = jsonData["nbre_offre"];
      _nbCandidatures = jsonData["nbre_condidature"];
      _missionDone = jsonData["nbre_projet_realise"];
      _missionInProgress = jsonData["nbre_projet_en_cours"];
      _nbProfileViews = jsonData["nbre_profile_views"];
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
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: Text(getTranslate(context, "STATISTICS"))),
      body: _isLoading
          ? Center(
              child: circularProgress,
            )
          : _error
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CompleteProfileNoticeCompany(),
                        SizedBox(height: 20.0),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: BLUE_LIGHT,
                          title: Text(
                            getTranslate(context, "MY_ATTRACTIVITY"),
                            style: TextStyle(color: GREY_LIGHt),
                          ),
                          trailing: Text(
                            userProvider.profileProgress.toString() + "%",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: GREEN_LIGHT),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: BLUE_LIGHT,
                          title: Text(
                            getTranslate(context, "MISSION_IN_PROGRESS"),
                            style: TextStyle(color: GREY_LIGHt),
                          ),
                          trailing: Text(
                            "$_missionInProgress",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: GREEN_LIGHT),
                          ),
                        ),
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
                              text: getTranslate(context, "APPLIES"),
                              value: "$_nbCandidatures",
                            ),
                            SizedBox(width: 10.0),
                            FinanceItem(
                              text: getTranslate(context, "OFFERS_NUMBERS"),
                              value: "$_nbOffers",
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
                              text: getTranslate(context, "PROFILE_VIEWS"),
                              value: "$_nbProfileViews " +
                                  getTranslate(context, "FOIS"),
                            ),
                            SizedBox(width: 10.0),
                            FinanceItem(
                              text: getTranslate(context, "MISSIONS_DONE"),
                              value: "$_missionDone",
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
