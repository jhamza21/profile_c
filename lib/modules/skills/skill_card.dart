import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/providers/user_skills_provider.dart';
import 'package:profilecenter/core/services/skill_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class SkillCard extends StatefulWidget {
  final Skill skill;
  final UserSkillsProvider userSkillsProvider;
  SkillCard(this.skill, this.userSkillsProvider);
  @override
  _SkillCardState createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> {
  bool _isLoading = false;

  void _showDeleteSkillDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "DELETE_SKILL_ALERT"),
      getTranslate(context, "DELETE"),
      () async {
        try {
          Navigator.of(context).pop();
          setState(() {
            _isLoading = true;
          });
          final res = await SkillService().deleteSkill(widget.skill.id);
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          widget.userSkillsProvider.remove(widget.skill);
          showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
        }
      },
      getTranslate(context, "CANCEL"),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: BLUE_LIGHT),
        padding:
            EdgeInsets.only(top: 8.0, bottom: 8.0, left: 12.0, right: 12.0),
        child: Wrap(
          children: [
            Text(
              widget.skill.title,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 15.0,
            ),
            InkWell(
              onTap: () => _isLoading ? null : _showDeleteSkillDialog(),
              child: _isLoading
                  ? circularProgress
                  : Icon(
                      Icons.remove_circle,
                      color: GREY_DARK,
                      size: 18.0,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
