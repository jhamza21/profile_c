import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_skills_provider.dart';
import 'package:profilecenter/modules/skills/add_skill.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:profilecenter/modules/skills/skill_card.dart';
import 'package:provider/provider.dart';

class ListSkills extends StatefulWidget {
  @override
  _ListSkillsState createState() => _ListSkillsState();
}

class _ListSkillsState extends State<ListSkills> {
  @override
  Widget build(BuildContext context) {
    UserSkillsProvider userSkillsProvider =
        Provider.of<UserSkillsProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslate(context, "SKILLS"),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AddSkill();
                      });
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                )),
          ],
        ),
        userSkillsProvider.skills.length != 0
            ? Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  children: userSkillsProvider.skills
                      .map<Widget>((e) => SkillCard(e, userSkillsProvider))
                      .toList(),
                ),
              )
            : EmptyDataCard(getTranslate(context, "NO_DATA")),
      ],
    );
  }
}
