import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/mission.dart';
import 'package:profilecenter/modules/mission/mission_details.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class MissionCard extends StatefulWidget {
  final Mission mission;
  MissionCard(this.mission);
  @override
  _MissionCardState createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
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
      child: ListTile(
        onTap: () => Navigator.of(context)
            .pushNamed(MissionDetails.routeName, arguments: widget.mission),
        contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        tileColor: BLUE_LIGHT,
        leading: getCompanyAvatar(widget.mission.company.name,
            widget.mission.company, BLUE_LIGHT, 22),
        title: Text(
          widget.mission.offer.title,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          widget.mission.company.name,
          style: TextStyle(color: GREY_LIGHt, fontSize: 12),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            getExperiencePeriod(
              widget.mission.devis.startDate,
              widget.mission.devis.endDate,
            ),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
