import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/mission_provider.dart';
import 'package:profilecenter/core/services/mission_service.dart';
import 'package:profilecenter/modules/mission/add_update_old_mission.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class OldMissionCard extends StatefulWidget {
  final Experience mission;
  OldMissionCard(this.mission);

  @override
  _OldMissionCardState createState() => _OldMissionCardState();
}

class _OldMissionCardState extends State<OldMissionCard> {
  bool _isDeleting = false;

  void _showDeleteDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "DELETE_MISSION_ALERT"),
      getTranslate(context, "DELETE"),
      () async {
        try {
          Navigator.of(context).pop();
          setState(() {
            _isDeleting = true;
          });
          final res = await MissionService().deleteMission(widget.mission.id);
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          setState(() {
            _isDeleting = false;
          });
          MissionProvider missionProvider =
              Provider.of<MissionProvider>(context, listen: false);
          missionProvider.remove(widget.mission);
          setState(() {
            _isDeleting = false;
          });
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

  String getMissionPeriod(String startDate, String endDate) {
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
          contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          tileColor: BLUE_LIGHT,
          leading: getCompanyAvatar(widget.mission.companyName,
              widget.mission.company, BLUE_LIGHT, 22),
          title: Text(
            widget.mission.title,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Text(
            widget.mission.company != null
                ? widget.mission.company.name
                : widget.mission.companyName,
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
                      getMissionPeriod(
                        widget.mission.startDate,
                        widget.mission.endDate,
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
              if (!_isDeleting)
                Icon(
                  Icons.arrow_left,
                  color: RED_LIGHT,
                )
            ],
          ),
        ),
        secondaryActions: _isDeleting
            ? null
            : <Widget>[
                IconSlideAction(
                  caption: getTranslate(context, "UPDATE"),
                  color: BLUE_SKY,
                  icon: Icons.edit,
                  onTap: () => Navigator.of(context).pushNamed(
                      AddUpdateOldMission.routeName,
                      arguments: widget.mission),
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
