import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_candidat_name.dart';
import 'package:profilecenter/utils/helpers/get_user_avatar.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/favorite_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/modules/profile/candidat_profile.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class FavoriteCandidatCard extends StatefulWidget {
  final User favoriteCandidat;

  FavoriteCandidatCard(this.favoriteCandidat);
  @override
  _FavoriteCandidatCardState createState() => _FavoriteCandidatCardState();
}

class _FavoriteCandidatCardState extends State<FavoriteCandidatCard> {
  bool _isLoading = false;

  _showPopupDeleteConfirmation(int userId) {
    showBottomModal(
        context,
        null,
        getTranslate(context, "REMOVE_FAVORIS"),
        getTranslate(context, "YES"),
        () async {
          Navigator.of(context).pop();
          removeFromFavorite(userId);
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  void removeFromFavorite(int userId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final res = await UserService().addDeleteCandidatToFavorite(userId);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      FavoriteProvider favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);
      favoriteProvider.remove(widget.favoriteCandidat);
      showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(CandidatProfile.routeName,
          arguments: widget.favoriteCandidat.id),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: BLUE_LIGHT,
            leading: getUserAvatar(widget.favoriteCandidat, BLUE_DARK, 25),
            trailing: IconButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _showPopupDeleteConfirmation(
                            widget.favoriteCandidat.id);
                      },
                icon: _isLoading
                    ? circularProgress
                    : Image.asset(
                        TRASH_ICON,
                        color: RED_DARK,
                        height: 20,
                        width: 20,
                      )),
            title: Text(
                getCandidatName(
                    widget.favoriteCandidat.firstName,
                    widget.favoriteCandidat.lastName,
                    userProvider.user.pack.notAllowed
                        .contains(CANDIDAT_NAMES_PRIVILEGE)),
                style: TextStyle(color: Colors.white)),
            subtitle: Text(
              widget.favoriteCandidat.email,
              style: TextStyle(color: GREY_LIGHt),
            )),
      ),
    );
  }
}
