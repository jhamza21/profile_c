import 'dart:io';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/settings/pack_changer_company.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/chatCenter/recent_chats.dart';
import 'package:profilecenter/modules/statistics/statistics_company.dart';
import 'package:profilecenter/modules/dashboards/company_dashboard.dart';
import 'package:profilecenter/modules/infoCompany/company_info.dart';
import 'package:profilecenter/modules/talents/search_talents.dart';
import 'package:profilecenter/widgets/waiting_screen.dart';
import 'package:provider/provider.dart';

class CompanyHome extends StatefulWidget {
  static const routeName = '/companyhome';
  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  int _currentIndex = 3;
  bool _isLoading = false;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showCompleteProfileDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "COMPLETE_PROFILE_RESTRICTION"),
        getTranslate(context, "YES"),
        () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(CompanyInfo.routeName);
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  void _showUpgradePackageDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "PACKACGE_ACCESS_CHAT_RESTRICTION"),
      getTranslate(context, "YES"),
      () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(PackChangerCompany.routeName);
      },
      getTranslate(context, "NO"),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  Future<bool> _showLeaveApplicationDialog() async {
    await showBottomModal(
        context,
        null,
        getTranslate(context, "LEAVE_APP"),
        getTranslate(context, "YES"),
        () {
          exit(0);
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    final List<Widget> _children = [
      StatisticsCompany(),
      SearchTalents(),
      RecentChats(),
      CompanyDashboard()
    ];
    return WillPopScope(
      onWillPop: () => _showLeaveApplicationDialog(),
      child: _isLoading
          ? WaitingScreen()
          : Scaffold(
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: BLUE_DARK_LIGHT,
                  boxShadow: [
                    BoxShadow(
                      color: RED_LIGHT,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 2.0,
                    ),
                  ],
                ),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () => onTabTapped(0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 25.0,
                            width: 25.0,
                            child: Image.asset(
                              CHART_ICON,
                              color: _currentIndex == 0
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          ),
                          Text(
                            getTranslate(context, "ACTIVITY"),
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentIndex == 0
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (userProvider.profileProgress != 100)
                          _showCompleteProfileDialog();
                        else
                          onTabTapped(1);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 25.0,
                            width: 25.0,
                            child: Image.asset(
                              TALENTS_ICON,
                              color: _currentIndex == 1
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          ),
                          Text(
                            getTranslate(context, "TALENTS"),
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentIndex == 1
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (userProvider.user.pack.notAllowed
                            .contains(CHAT_PRIVILEGE))
                          _showUpgradePackageDialog();
                        else if (userProvider.profileProgress != 100)
                          _showCompleteProfileDialog();
                        else
                          onTabTapped(2);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 25.0,
                            width: 25.0,
                            child: Image.asset(
                              CHAT_ICON_BOTTOM,
                              color: _currentIndex == 2
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          ),
                          Text(
                            getTranslate(context, "MESSAGES"),
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentIndex == 2
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => onTabTapped(3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 25.0,
                            width: 25.0,
                            child: Image.asset(
                              PROFILE_ICON,
                              color: _currentIndex == 3
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          ),
                          Text(
                            getTranslate(context, "PROFILE"),
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentIndex == 3
                                  ? Color(0xfff38071)
                                  : Color(0xff999fa7),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              body: _children[_currentIndex]),
    );
  }
}
