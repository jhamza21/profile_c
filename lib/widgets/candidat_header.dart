import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_candidat_name.dart';
import 'package:profilecenter/utils/helpers/get_experience_period.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/get_user_avatar.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/experience_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/widgets/candidat_stars.dart';
import 'package:provider/provider.dart';

class CandidatHeader extends StatefulWidget {
  final User user;
  CandidatHeader(this.user);
  @override
  _CandidatHeaderState createState() => _CandidatHeaderState();
}

class _CandidatHeaderState extends State<CandidatHeader> {
  @override
  void initState() {
    super.initState();
    fetchUserExperiences();
    //fetchUser();

  }

  void fetchUserExperiences() async {
    ExperienceProvider experienceProvider =
        Provider.of<ExperienceProvider>(context, listen: false);
    experienceProvider.fetchExperiences(context);
  }

  void fetchUser() async {
    UserProvider userProvider =
    
        Provider.of<UserProvider>(context, listen: false);
    userProvider.checkLoggedInUser();
    // userProvider.logoutUser();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    ExperienceProvider experienceProvider =
        Provider.of<ExperienceProvider>(context, listen: true);
    return Column(
      children: [
        getUserAvatar(widget.user, BLUE_LIGHT, 40),
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                getCandidatName(
                    widget.user.firstName,
                    widget.user.lastName,
                    userProvider.user.pack.notAllowed
                        .contains(CANDIDAT_NAMES_PRIVILEGE)),
                style: TextStyle(color: Colors.white)),
            SizedBox(width: 10.0),
            CandidatStars(widget.user.id)
          ],
        ),
        SizedBox(height: 8),
        Text(getTranslate(context, widget.user.role.toUpperCase()),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(width: 10.0),
        SizedBox(height: 8),
        if (experienceProvider.isLoading)
          Text("...", style: TextStyle(color: GREY_LIGHt))
        else if (experienceProvider.lastExperience == null)
          SizedBox.shrink()
        else
          Text(
              experienceProvider.lastExperience.title +
                  " • " +
                  getExperiencePeriod(experienceProvider.lastExperience),
              style: TextStyle(color: GREY_LIGHt)),
      ],
    );
  }
}
