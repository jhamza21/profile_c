import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_candidat_name.dart';
import 'package:profilecenter/utils/helpers/get_user_avatar.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/profile/candidat_profile.dart';
import 'package:provider/provider.dart';

class CandidatSuggestionCard extends StatefulWidget {
  final User candidat;
  CandidatSuggestionCard(this.candidat);
  @override
  _CandidatSuggestionCardState createState() => _CandidatSuggestionCardState();
}

class _CandidatSuggestionCardState extends State<CandidatSuggestionCard> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    Experience _lastExperience = widget.candidat.experiences.length != 0
        ? widget.candidat.experiences[widget.candidat.experiences.length - 1]
        : null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(CandidatProfile.routeName,
            arguments: widget.candidat.id),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 120,
            height: 20,
            child: _lastExperience != null
                ? Text(
                    _lastExperience.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: GREY_LIGHt,
                        fontSize: 12),
                  )
                : SizedBox(),
          ),
          getUserAvatar(widget.candidat, BLUE_LIGHT, 25),
          SizedBox(height: 10.0),
          Container(
            width: 110,
            child: Text(
              getCandidatName(
                  widget.candidat.firstName,
                  widget.candidat.lastName,
                  userProvider.user.pack.notAllowed
                      .contains(CANDIDAT_NAMES_PRIVILEGE)),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ]),
      ),
    );
  }
}
