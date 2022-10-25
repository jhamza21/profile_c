import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/models/certificat.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/modules/certificats/certification_card.dart';
import 'package:profilecenter/modules/experiences/experience_card.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/utils/helpers/calculate_age.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/convert_money.dart';
import 'package:profilecenter/utils/helpers/generate_user_qcm_certifications.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/favorite_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/message_service.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/modules/chatCenter/chat_screen.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_center.dart';
import 'package:profilecenter/modules/profile/portfolio.dart';
import 'package:profilecenter/modules/talents/video_presentation.dart';
import 'package:profilecenter/widgets/candidat_header.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/descr_card.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:profilecenter/widgets/qcm_circular_progress.dart';
import 'package:provider/provider.dart';

class CandidatProfile extends StatefulWidget {
  static const routeName = '/candidatProfile';
  final int userId;
  CandidatProfile(this.userId);

  @override
  _CandidatProfileState createState() => _CandidatProfileState();
}

class _CandidatProfileState extends State<CandidatProfile> {
  bool _isToggleFavorite = false;
  bool _isLoading = true;
  bool _error = false;
  User _user;
  List<QcmCertification> _qcmCertifications = [];
  List<Certificat> _certificats = [];
  List<Experience> _experiences = [];

  bool _isSearchingChatRoom = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    try {
      final res = await UserService().getCandidatProfile(widget.userId);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _user = User.fromJson(jsonData["user"]);
      _qcmCertifications = generateUserCertifications(_user.qcmCertifications);
      _certificats = _user.certificats;
      _certificats.sort((a, b) => getDays(b.delivered, a.delivered));
      _experiences = _user.experiences
          .where((element) => element.type == EXPERIENCE_TYPE)
          .toList();
      _experiences.sort((a, b) => getDays(b.startDate, a.startDate));
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

  void _showUpgradePackageDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "UPGRADE_PACKAGE_NOTICE"),
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "YES"),
        () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(PackChangerCandidat.routeName);
        });
  }

  void searchChatRoom(User user) async {
    try {
      setState(() {
        _isSearchingChatRoom = true;
      });
      final res = await MessageService().getChatRoom(user.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      var jsonData = json.decode(res.body);
      ChatRoom _chatRoom = ChatRoom.fromJson(jsonData["data"]);
      Navigator.of(context)
          .pushNamed(ChatScreen.routeName, arguments: _chatRoom);
      setState(() {
        _isSearchingChatRoom = false;
      });
    } catch (e) {
      setState(() {
        _isSearchingChatRoom = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void toggleFavorite(
      int userId, bool isSelected, FavoriteProvider favoriteProvider) async {
    try {
      setState(() {
        _isToggleFavorite = true;
      });
      final res = await UserService().addDeleteCandidatToFavorite(userId);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      if (isSelected)
        favoriteProvider.remove(_user);
      else
        favoriteProvider.add(_user);
      setState(() {
        _isToggleFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isToggleFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "CANDIDATE")),
      ),
      body: _error
          ? ErrorScreen()
          : _isLoading
              ? Center(child: circularProgress)
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CandidatHeader(_user),
                        SizedBox(height: 15.0),
                        Wrap(
                          children: [
                            DescrCard(
                                null,
                                getTranslate(context, _user.role.toUpperCase()),
                                BLUE_LIGHT),
                            _user.birthday != ''
                                ? DescrCard(
                                    null,
                                    "${calculateAge(DateTime.parse(_user.birthday))} ${getTranslate(context, "YEAR")}",
                                    BLUE_LIGHT)
                                : SizedBox.shrink(),
                            DescrCard(
                                _user.civility == "men"
                                    ? Icon(MdiIcons.genderMale,
                                        size: 20, color: Colors.white)
                                    : Icon(MdiIcons.genderFemale,
                                        size: 20, color: Colors.white),
                                null,
                                BLUE_LIGHT),
                            _user.address != null
                                ? DescrCard(
                                    null, _user.address.region, BLUE_LIGHT)
                                : SizedBox.shrink(),
                            _user.distance != null
                                ? DescrCard(
                                    null,
                                    "${_user.distance.toInt()}" + " km",
                                    BLUE_LIGHT)
                                : SizedBox.shrink(),
                            DescrCard(
                                null,
                                "${_user.disponibility} ${getTranslate(context, "DAY_PER_WEEK")}",
                                BLUE_LIGHT),
                            DescrCard(
                                null,
                                getTranslate(context, _user.mobility),
                                BLUE_LIGHT),
                            _user.salary != null && _user.salary != 0.0
                                ? DescrCard(
                                    null,
                                    "${convertMoney(_user.devise, _user.salary, userProvider.user.devise).toStringAsFixed(2)}"
                                    " ${userProvider.user.devise.name}",
                                    BLUE_LIGHT)
                                : SizedBox.shrink(),
                          ],
                        ),
                        Divider(color: GREY_LIGHt),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () {
                                  toggleFavorite(
                                      _user.id,
                                      favoriteProvider.contains(_user),
                                      favoriteProvider);
                                },
                                icon: SizedBox(
                                    width: 70.0,
                                    height: 70.0,
                                    child: _isToggleFavorite
                                        ? circularProgress
                                        : Image.asset(
                                            HEART_ICON,
                                            color:
                                                favoriteProvider.contains(_user)
                                                    ? RED_DARK
                                                    : GREY_LIGHt,
                                          ))),
                            IconButton(
                                onPressed: () {
                                  if (userProvider.user.pack.notAllowed
                                      .contains(CHAT_PRIVILEGE))
                                    _showUpgradePackageDialog();
                                  else
                                    Navigator.of(context).pushNamed(
                                        QcmCenter.routeName,
                                        arguments: QcmCenterArguments(
                                            _user.qcmCertifications,
                                            true,
                                            _user));
                                },
                                icon: SizedBox(
                                    width: 18.0,
                                    height: 20.0,
                                    child: Image.asset(QCM_ICON))),
                            IconButton(
                                onPressed: () {
                                  if (userProvider.user.pack.notAllowed
                                      .contains(CHAT_PRIVILEGE))
                                    _showUpgradePackageDialog();
                                  else
                                    searchChatRoom(_user);
                                },
                                icon: SizedBox(
                                    width: 18.0,
                                    height: 20.0,
                                    child: _isSearchingChatRoom
                                        ? circularProgress
                                        : Image.asset(CHAT_ICON))),
                          ],
                        ),
                        Divider(color: GREY_LIGHt),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              getTranslate(context, "EXPERIENCES"),
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        _experiences.length != 0
                            ? ListView.builder(
                                itemCount: _experiences.length,
                                reverse: true,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ExperienceCard(
                                    experience: _experiences[index],
                                    readOnly: true,
                                  );
                                })
                            : EmptyDataCard(getTranslate(context, "NO_DATA")),
                        SizedBox(height: 10.0),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              getTranslate(context, "CERTIFICATS"),
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        _certificats.length != 0
                            ? ListView.builder(
                                itemCount: _certificats.length,
                                reverse: true,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return CertificationCard(
                                    certificat: _certificats[index],
                                    readOnly: true,
                                  );
                                })
                            : EmptyDataCard(getTranslate(context, "NO_DATA")),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              getTranslate(context, "USED_LANGUAGES"),
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        _qcmCertifications.length == 0
                            ? EmptyDataCard(getTranslate(context, "NO_DATA"))
                            : Container(
                                height: 110,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: BLUE_LIGHT),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.keyboard_arrow_left,
                                        color: GREY_LIGHt),
                                    Expanded(
                                      child: Scrollbar(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _qcmCertifications
                                              .last.levelName.length,
                                          itemBuilder: (context, index) {
                                            return QcmCircularProgress(
                                                _qcmCertifications[index].mark,
                                                _qcmCertifications[index]
                                                    .moduleName);
                                          },
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_right,
                                        color: GREY_LIGHt),
                                  ],
                                ),
                              ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              getTranslate(context, "PORTFOLIO"),
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Portfolio(widget.userId),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              getTranslate(context, "PRESENTATION_VIDEO"),
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        VideoPresentation(widget.userId)
                      ],
                    ),
                  ),
                ),
    );
  }
}
