import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/modules/mission/mission_card.dart';
import 'package:profilecenter/providers/mission_provider.dart';
import 'package:profilecenter/modules/mission/add_update_old_mission.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:profilecenter/modules/mission/old_mission_card.dart';
import 'package:provider/provider.dart';

class ListMissions extends StatefulWidget {
  @override
  _ListMissionsState createState() => _ListMissionsState();
}

class _ListMissionsState extends State<ListMissions> {
  @override
  Widget build(BuildContext context) {
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10.0),
        Text(
          getTranslate(context, "MISSIONS_IN_PROGRESS"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        missionProvider.missionsInProgress.length != 0
            ? ListView.builder(
                itemCount: missionProvider.missionsInProgress.length,
                reverse: true,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return MissionCard(missionProvider.missionsInProgress[index]);
                })
            : EmptyDataCard(getTranslate(context, "NO_DATA")),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslate(context, "MISSIONS_DONE"),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AddUpdateOldMission.routeName, arguments: null),
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                )),
          ],
        ),
        missionProvider.missionsCompleted.length == 0 &&
                missionProvider.oldMissions.length == 0
            ? EmptyDataCard(getTranslate(context, "NO_DATA"))
            : ListView.builder(
                itemCount: missionProvider.missionsCompleted.length,
                reverse: true,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return MissionCard(missionProvider.missionsCompleted[index]);
                }),
        ListView.builder(
            itemCount: missionProvider.oldMissions.length,
            reverse: true,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return OldMissionCard(missionProvider.oldMissions[index]);
            })
      ],
    );
  }
}
