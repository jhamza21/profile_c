import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/calculate_age.dart';
import 'package:profilecenter/utils/helpers/get_experience_period.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/convert_money.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/compare_provider.dart';
import 'package:profilecenter/providers/favorite_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/message_service.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/modules/chatCenter/chat_screen.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/profile/candidat_profile.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_center.dart';
import 'package:profilecenter/widgets/candidat_header.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/descr_card.dart';
import 'package:provider/provider.dart';

class CandidatCard extends StatefulWidget {
  final User user;
  CandidatCard(this.user);
  @override
  _CandidatCardState createState() => _CandidatCardState();
}

class _CandidatCardState extends State<CandidatCard> {
  bool _isToggleFavorite = false;
  bool _isSearchingChatRoom = false;

  void _showUpgradePackageDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "UPGRADE_PACKAGE_NOTICE"),
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

  void searchChatRoom() async {
    try {
      setState(() {
        _isSearchingChatRoom = true;
      });

      final res = await MessageService().getChatRoom(widget.user.id);
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
        favoriteProvider.remove(widget.user);
      else
        favoriteProvider.add(widget.user);
      setState(() {
        _isToggleFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isToggleFavorite = false;
      });
    }
  }

  void toggleUserToCompare(
      bool isSelected, CompareProvider compareProvider) async {
    if (isSelected)
      compareProvider.remove(widget.user);
    else {
      bool isAdded = compareProvider.add(widget.user);
      if (!isAdded)
        showSnackbar(context, getTranslate(context, "COMPARATOR_MAX"));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: true);
    CompareProvider compareProvider =
        Provider.of<CompareProvider>(context, listen: true);
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(CandidatProfile.routeName, arguments: widget.user.id),
      child: Container(
        margin: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 5.0),
        decoration: BoxDecoration(
          color: BLUE_DARK_LIGHT,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CandidatHeader(widget.user),
              SizedBox(height: 10),
              Wrap(
                children: [
                  DescrCard(null, "${widget.user.note.toInt()} %" + " matching",
                      BLUE_SKY),
                  DescrCard(
                      null,
                      getTranslate(context, widget.user.role.toUpperCase()),
                      BLUE_LIGHT),
                  widget.user.experiences.length != 0
                      ? DescrCard(
                          null,
                          getExperiencePeriod(widget.user
                              .experiences[widget.user.experiences.length - 1]),
                          BLUE_LIGHT)
                      : SizedBox.shrink(),
                  widget.user.birthday != ''
                      ? DescrCard(
                          null,
                          "${calculateAge(DateTime.parse(widget.user.birthday))} ${getTranslate(context, "YEAR")}",
                          BLUE_LIGHT)
                      : SizedBox.shrink(),
                  DescrCard(
                      widget.user.civility == "men"
                          ? Icon(MdiIcons.genderMale,
                              size: 20, color: Colors.white)
                          : Icon(MdiIcons.genderFemale,
                              size: 20, color: Colors.white),
                      null,
                      BLUE_LIGHT),
                  widget.user.address != null
                      ? DescrCard(
                          Icon(Icons.location_on,
                              color: Colors.white, size: 15),
                          widget.user.address.region,
                          BLUE_LIGHT)
                      : SizedBox.shrink(),
                  widget.user.distance != null
                      ? DescrCard(null,
                          "${widget.user.distance.toInt()}" + " km", BLUE_LIGHT)
                      : SizedBox.shrink(),
                  DescrCard(
                      null,
                      "${widget.user.disponibility} ${getTranslate(context, "DAY_PER_WEEK")}",
                      BLUE_LIGHT),
                  DescrCard(
                      Icon(
                        Icons.badge,
                        size: 15,
                        color: Colors.grey,
                      ),
                      "${getTranslate(context, "MOBILITY")} " +
                          getTranslate(context, widget.user.mobility),
                      BLUE_LIGHT),
                  widget.user.salary != null && widget.user.salary != 0.0
                      ? DescrCard(
                          null,
                          "${convertMoney(widget.user.devise, widget.user.salary, userProvider.user.devise).toStringAsFixed(2)}"
                          " ${userProvider.user.devise.name}",
                          BLUE_LIGHT)
                      : SizedBox.shrink(),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        toggleFavorite(
                            widget.user.id,
                            favoriteProvider.contains(widget.user),
                            favoriteProvider);
                      },
                      icon: SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: _isToggleFavorite
                              ? circularProgress
                              : favoriteProvider.contains(widget.user)
                                  ? Image.asset(
                                      HEART_ICON,
                                      color: RED_DARK,
                                    )
                                  : Image.asset(HEART_ICON,
                                      color: GREY_LIGHt))),
                  IconButton(
                      onPressed: () {
                        toggleUserToCompare(
                            compareProvider.contains(widget.user),
                            compareProvider);
                      },
                      icon: SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: compareProvider.contains(widget.user)
                              ? Image.asset(
                                  COMPARE_ICON,
                                  color: RED_DARK,
                                )
                              : Image.asset(COMPARE_ICON))),
                  IconButton(
                      onPressed: () {
                        if (userProvider.user.pack.notAllowed
                            .contains(CHAT_PRIVILEGE))
                          _showUpgradePackageDialog();
                        Navigator.of(context).pushNamed(QcmCenter.routeName,
                            arguments: QcmCenterArguments(
                                widget.user.qcmCertifications,
                                true,
                                widget.user));
                      },
                      icon: SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: Image.asset(QCM_ICON))),
                  IconButton(
                      onPressed: () {
                        if (userProvider.user.pack.notAllowed
                            .contains(CHAT_PRIVILEGE))
                          _showUpgradePackageDialog();
                        else
                          searchChatRoom();
                      },
                      icon: SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: _isSearchingChatRoom
                              ? circularProgress
                              : Image.asset(CHAT_ICON))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
