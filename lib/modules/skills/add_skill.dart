import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/providers/platform_skills_provider.dart';
import 'package:profilecenter/providers/user_skills_provider.dart';
import 'package:profilecenter/core/services/skill_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddSkill extends StatefulWidget {
  @override
  _AddSkillState createState() => _AddSkillState();
}

class _AddSkillState extends State<AddSkill> {
  String _skillName;
  bool _isLoading = false;
  final _textFieldController = TextEditingController();
  List<String> _filtredAvailableSkillsInPlatform = [];

  @override
  void initState() {
    super.initState();
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: false);
    platformSkillsProvider.fetchSkills(context);
  }

  void addSkill(
      UserSkillsProvider userSkillsProvider, BuildContext context, set) async {
    try {
      set(() {
        _isLoading = true;
      });
      final res = await SkillService().createSkill(_skillName);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      userSkillsProvider.addSkill(Skill.fromJson(jsonData["skills"]));
      showSnackbar(context, getTranslate(context, "ADD_SUCCESS"));
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      set(() {
        _isLoading = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void filterAvailableSkillsInPlatform(
      set, String text, PlatformSkillsProvider platformSkillsProvider) {
    set(() {
      _skillName = text;
      _filtredAvailableSkillsInPlatform = [];
      if (text == '' || text == null) {
        _filtredAvailableSkillsInPlatform = platformSkillsProvider.subSkills;
        return;
      }
      platformSkillsProvider.subSkills.forEach((skill) {
        if (skill.toLowerCase().contains(text.toLowerCase()))
          _filtredAvailableSkillsInPlatform.add(skill);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    UserSkillsProvider userSkillsProvider =
        Provider.of<UserSkillsProvider>(context, listen: true);
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: true);
    _filtredAvailableSkillsInPlatform = platformSkillsProvider.subSkills;
    return StatefulBuilder(builder: (context, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: BLUE_DARK_LIGHT,
              height: 30.0,
              child: Center(
                  child: Text(
                getTranslate(context, "ADD_SKILL"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _textFieldController,
                    style: TextStyle(color: Colors.white),
                    decoration: inputTextDecoration(10.0, null,
                        getTranslate(context, "SEARCH_HERE"), null, null),
                    onChanged: (value) => filterAvailableSkillsInPlatform(
                        set, value, platformSkillsProvider),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 260,
                    width: 300,
                    child: platformSkillsProvider.isLoading
                        ? Center(child: circularProgress)
                        : Scrollbar(
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: [
                                ..._filtredAvailableSkillsInPlatform.map(
                                  (skill) => InkWell(
                                    onTap: () {
                                      if (!userSkillsProvider.contains(skill)) {
                                        set(() {
                                          _skillName = skill;
                                          _textFieldController.text = skill;
                                        });
                                        filterAvailableSkillsInPlatform(
                                            set, skill, platformSkillsProvider);
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            color: userSkillsProvider
                                                    .contains(skill)
                                                ? RED_LIGHT
                                                : BLUE_DARK_LIGHT),
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          skill,
                                          style: TextStyle(
                                              color: userSkillsProvider
                                                      .contains(skill)
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: _isLoading ||
                                _skillName == null ||
                                _skillName == '' ||
                                userSkillsProvider.contains(_skillName)
                            ? null
                            : () {
                                addSkill(userSkillsProvider, context, set);
                              },
                        icon: _isLoading ? circularProgress : SizedBox.shrink(),
                        label: Text(
                          getTranslate(context, "ADD"),
                        )),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        getTranslate(context, "CLOSE"),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
