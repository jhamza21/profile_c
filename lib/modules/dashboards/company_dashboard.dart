import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/modules/settings/pack_changer_company.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/companyOffers/company_offers.dart';
import 'package:profilecenter/modules/settings/app_settings.dart';
import 'package:profilecenter/modules/disponibility/disponibility_company.dart';
import 'package:profilecenter/modules/documents/files_center_company.dart';
import 'package:profilecenter/modules/favoriteCandidat/favorite_candidat.dart';
import 'package:profilecenter/modules/financeCenter/finance_company.dart';
import 'package:profilecenter/modules/infoCompany/company_info.dart';
import 'package:profilecenter/modules/dashboards/list_candidat_suggestions.dart';
import 'package:profilecenter/widgets/profile_progress.dart';
import 'package:provider/provider.dart';

class CompanyDashboard extends StatefulWidget {
  @override
  _CompanyDashboardState createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
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
        getTranslate(context, "UPGRADE_PACKAGE_DISPONIBILITE_ACCESS_NOTICE"),
        getTranslate(context, "YES"),
        () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(PackChangerCompany.routeName);
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

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(getTranslate(context, "PROFILES")),
            ),
            SizedBox(height: 10.0),
            ListCandidatSuggestion(),
            SizedBox(height: 20.0),
            ProfileProgress(userProvider.profileProgress),
            SizedBox(height: 30.0),
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
                                  iconSize: 110.0,
                                  onPressed: () {
                                    //app settings
                                    Navigator.of(context)
                                        .pushNamed(AppSettings.routeName);
                                  },
                                  icon: Image.asset(SETTINGS_BUTTON)),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 110.0,
                                  onPressed: () {
                                    //diponibility
                                    if (userProvider.user.pack.notAllowed
                                        .contains(CALENDAR_PRIVILEGE))
                                      _showUpgradePackageDialog();
                                    else if (userProvider.profileProgress !=
                                        100)
                                      _showCompleteProfileDialog();
                                    else
                                      Navigator.of(context).pushNamed(
                                          DisponibilityCompany.routeName);
                                  },
                                  icon: Image.asset(DISPONIBILITY_BUTTON)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 108.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 110.0,
                                  onPressed: () {
                                    //files center
                                    Navigator.of(context).pushNamed(
                                        FilesCenterCompany.routeName);
                                  },
                                  icon: Image.asset(DOCS_BUTTON)),
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    iconSize: 110.0,
                                    onPressed: () {
                                      //statistics
                                      Navigator.of(context)
                                          .pushNamed(FinanceCompany.routeName);
                                    },
                                    icon: Image.asset(STATISTICS_BUTTON)),
                              ),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 110.0,
                                  onPressed: () async {
                                    //projects
                                    if (userProvider.profileProgress != 100)
                                      _showCompleteProfileDialog();
                                    else
                                      Navigator.of(context)
                                          .pushNamed(CompanyOffers.routeName);
                                  },
                                  icon: Image.asset(PROJECTS_BUTTON)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 210.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 110.0,
                                  onPressed: () => {
                                        //info perso
                                        Navigator.of(context)
                                            .pushNamed(CompanyInfo.routeName)
                                      },
                                  icon: Image.asset(QCM_BUTTON)),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: 110.0,
                                  onPressed: () => {
                                        //favorite candidat
                                        Navigator.of(context).pushNamed(
                                            FavoriteCandidat.routeName)
                                      },
                                  icon: Image.asset(FAVORITE_BUTTON)),
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
