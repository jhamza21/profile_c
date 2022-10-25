import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/get_candidat_name.dart';
import 'package:profilecenter/utils/helpers/get_experience_period.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/get_user_avatar.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/compare_provider.dart';
import 'package:profilecenter/providers/favorite_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/message_service.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/modules/chatCenter/chat_screen.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_center.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/descr_card.dart';
import 'package:provider/provider.dart';

class CandidatHeader extends StatefulWidget {
  final User user;
  CandidatHeader(this.user);
  @override
  _CandidatHeaderState createState() => _CandidatHeaderState();
}

class _CandidatHeaderState extends State<CandidatHeader> {
  bool _isToggleFavorite = false;
  bool _isSearchingChatRoom = false;

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

  @override
  Widget build(BuildContext context) {
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: true);
    CompareProvider compareProvider =
        Provider.of<CompareProvider>(context, listen: true);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0), color: BLUE_DARK_LIGHT),
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                compareProvider.remove(widget.user);
              },
              icon: Icon(
                Icons.remove_circle,
                color: RED_LIGHT,
              )),
          getUserAvatar(widget.user, BLUE_LIGHT, 35),
          SizedBox(height: 12.0),
          Text(
              getCandidatName(
                  widget.user.firstName,
                  widget.user.lastName,
                  userProvider.user.pack.notAllowed
                      .contains(CANDIDAT_NAMES_PRIVILEGE)),
              style: TextStyle(color: Colors.white)),
          SizedBox(height: 10),
          widget.user.experiences.length != 0
              ? Container(
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  child: Text(
                      widget
                              .user
                              .experiences[widget.user.experiences.length - 1]
                              .title +
                          " • " +
                          getExperiencePeriod(widget.user
                              .experiences[widget.user.experiences.length - 1]),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: GREY_LIGHt, fontSize: 12)),
                )
              : SizedBox.shrink(),
          SizedBox(height: 10),
          DescrCard(null, getTranslate(context, widget.user.role.toUpperCase()),
              BLUE_LIGHT),
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
                      width: 42.0,
                      height: 42.0,
                      child: _isToggleFavorite
                          ? circularProgress
                          : favoriteProvider.contains(widget.user)
                              ? Image.asset(
                                  HEART_ICON,
                                  color: RED_DARK,
                                )
                              : Image.asset(
                                  HEART_ICON,
                                  color: GREY_LIGHt,
                                ))),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(QcmCenter.routeName,
                        arguments: QcmCenterArguments(
                            widget.user.qcmCertifications, true, widget.user));
                  },
                  icon: SizedBox(
                      width: 20.0, height: 20.0, child: Image.asset(QCM_ICON))),
              IconButton(
                  onPressed: () {
                    searchChatRoom(widget.user);
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
    );
  }
}
