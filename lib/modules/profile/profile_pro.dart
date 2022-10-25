import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/certificat_provider.dart';
import 'package:profilecenter/providers/experience_provider.dart';
import 'package:profilecenter/providers/mission_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/providers/user_skills_provider.dart';
import 'package:profilecenter/providers/video_presentation_provider.dart';
import 'package:profilecenter/modules/certificats/list_certificats.dart';
import 'package:profilecenter/modules/experiences/list_experiences.dart';
import 'package:profilecenter/modules/mission/list_mission.dart';
import 'package:profilecenter/modules/profile/videoPresentation.dart';
import 'package:profilecenter/modules/skills/list_skills.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/candidat_header.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class ProfilePro extends StatefulWidget {
  static const routeName = '/profilePro';

  @override
  _ProfileProState createState() => _ProfileProState();
}

class _ProfileProState extends State<ProfilePro> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    UserSkillsProvider userSkillsProvider =
        Provider.of<UserSkillsProvider>(context, listen: false);
    CertificatProvider certificatProvider =
        Provider.of<CertificatProvider>(context, listen: false);
    ExperienceProvider experienceProvider =
        Provider.of<ExperienceProvider>(context, listen: false);
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: false);
    VideoPresentationProvider videoPresentationProvider =
        Provider.of<VideoPresentationProvider>(context, listen: false);
    userSkillsProvider.fetchSkills(context);
    certificatProvider.fetchCertificats(context);
    experienceProvider.fetchExperiences(context);
    missionProvider.fetchMissions(context);
    videoPresentationProvider.fetchVideoPresentation(context);
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    UserSkillsProvider userSkillsProvider =
        Provider.of<UserSkillsProvider>(context, listen: true);
    CertificatProvider certificatProvider =
        Provider.of<CertificatProvider>(context, listen: true);
    ExperienceProvider experienceProvider =
        Provider.of<ExperienceProvider>(context, listen: true);
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: true);
    VideoPresentationProvider videoPresentationProvider =
        Provider.of<VideoPresentationProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "PROFILE_PRO")),
        leading: SizedBox.shrink(),
        backgroundColor: BLUE_DARK,
        ),
      body: userSkillsProvider.isLoading ||
              experienceProvider.isLoading ||
              certificatProvider.isLoading ||
              missionProvider.isLoading ||
              videoPresentationProvider.isLoading
          ? Center(child: circularProgress)
          : userSkillsProvider.isError ||
                  experienceProvider.isError ||
                  certificatProvider.isError ||
                  missionProvider.isError ||
                  videoPresentationProvider.isError
              ? ErrorScreen()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CandidatHeader(userProvider.user),
                            SizedBox(height: 10.0),
                            Divider(),
                            ListExperiences(),
                            ListSkills(),
                            ListCertificats(),
                            if (userProvider.user.role == "freelance")
                              ListMissions(),
                            VideoPresentation()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}
