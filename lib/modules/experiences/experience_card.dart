import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/experience_provider.dart';
import 'package:profilecenter/core/services/experience_service.dart';
import 'package:profilecenter/modules/experiences/add_update_experience.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class ExperienceCard extends StatefulWidget {
  final Experience experience;
  final bool readOnly;
  ExperienceCard({this.experience, this.readOnly});

  @override
  _ExperienceCardState createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isDeleting = false;

  void _showDeleteDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "DELETE_EXPERIENCE_ALERT"),
      getTranslate(context, "DELETE"),
      () async {
        try {
          Navigator.of(context).pop();
          setState(() {
            _isDeleting = true;
          });
          final res =
              await ExperienceService().deleteExperience(widget.experience.id);
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          setState(() {
            _isDeleting = false;
          });
          ExperienceProvider experienceProvider =
              Provider.of<ExperienceProvider>(context, listen: false);
          experienceProvider.remove(widget.experience);
          showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
        } catch (e) {
          setState(() {
            _isDeleting = false;
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

  String getExperiencePeriod(String startDate, String endDate) {
    String res = startDate;
    res += "\n";
    if (endDate == null)
      res += getTranslate(context, "TODAY");
    else
      res += endDate;
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ListTile(
          contentPadding:
              EdgeInsets.fromLTRB(8, 0, !widget.readOnly ? 0 : 8, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          tileColor: BLUE_LIGHT,
          leading: getCompanyAvatar(widget.experience.companyName,
              widget.experience.company, BLUE_LIGHT, 22),
          title: Text(
            widget.experience.title,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Text(
            widget.experience.company != null
                ? widget.experience.company.name
                : widget.experience.companyName,
            style: TextStyle(color: GREY_LIGHt, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isDeleting
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: circularProgress,
                    )
                  : Text(
                      getExperiencePeriod(
                        widget.experience.startDate,
                        widget.experience.endDate,
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
              if (!widget.readOnly && !_isDeleting)
                Icon(
                  Icons.arrow_left,
                  color: RED_LIGHT,
                )
            ],
          ),
        ),
        secondaryActions: widget.readOnly || _isDeleting
            ? null
            : <Widget>[
                IconSlideAction(
                  caption: getTranslate(context, "UPDATE"),
                  color: BLUE_SKY,
                  icon: Icons.edit,
                  onTap: () => Navigator.of(context).pushNamed(
                      AddUpdateExperience.routeName,
                      arguments: widget.experience),
                ),
                IconSlideAction(
                  caption: getTranslate(context, "DELETE"),
                  color: RED_LIGHT,
                  icon: Icons.delete,
                  onTap: () => _showDeleteDialog(),
                ),
              ],
      ),
    );
  }
}
