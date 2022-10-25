import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/mission.dart';
import 'package:profilecenter/modules/chatCenter/devis_details.dart';
import 'package:profilecenter/providers/mission_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:provider/provider.dart';

class MissionDetails extends StatefulWidget {
  static const routeName = '/missiondetails';
  final Mission mission;
  MissionDetails(this.mission);

  @override
  _MissionDetailsState createState() => _MissionDetailsState();
}

class _MissionDetailsState extends State<MissionDetails> {
  double prixMission;
  double prixTva;
  double prixCommisionPc;

  @override
  void initState() {
    super.initState();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    prixMission = widget.mission.devis.workDaysPerMonth *
        widget.mission.devis.projectPeriod *
        widget.mission.devis.tjm *
        userProvider.user.devise.rapport;
    prixTva = (prixMission / 100) *
        widget.mission.devis.tva *
        userProvider.user.devise.rapport;
    prixCommisionPc = (prixMission / 100) *
        widget.mission.devis.commisionPc *
        userProvider.user.devise.rapport;
  }

  @override
  Widget build(BuildContext context) {
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: true);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: Text(getTranslate(context, "MISSION_DETAILS")),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mission.offer.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                    color:
                        widget.mission.inProgress ? RED_BURGUNDY : GREEN_LIGHT,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.mission.inProgress
                        ? getTranslate(context, "MISSION_IN_PROGRESS")
                        : getTranslate(context, "MISSION_DONE"),
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                    color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: getCompanyAvatar(widget.mission.company.name,
                          widget.mission.company, BLUE_DARK_LIGHT, 22),
                      title: Text(
                        widget.mission.offer.title,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        widget.mission.company.name,
                        style: TextStyle(color: GREY_LIGHt),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 70.0),
                        Container(
                          height: 23.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: YELLOW_DARK),
                          child: Center(
                              child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                    child: Icon(
                                  Icons.star,
                                  color: YELLOW_LIGHT,
                                  size: 16,
                                )),
                                TextSpan(
                                    text: ' ' +
                                        '${missionProvider.averageStarts(widget.mission.company.id)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: YELLOW_LIGHT)),
                              ],
                            ),
                          )),
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          "${missionProvider.missionsCompleted.length} ${getTranslate(context, "MISSIONS")}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0)
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                    color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslate(context, "END_MISSION_NOTICE"),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        getTranslate(context, "NOTE"),
                        style: TextStyle(color: GREY_LIGHt, fontSize: 15),
                      ),
                      SizedBox(height: 5.0),
                      widget.mission.note == null
                          ? Text(getTranslate(context, "NOTE_NOT_YET"))
                          : Container(
                              height: 20.0,
                              child: ListView.builder(
                                  itemCount: widget.mission.note,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Icon(
                                      Icons.star,
                                      color: YELLOW_LIGHT,
                                      size: 20,
                                    );
                                  }),
                            ),
                      SizedBox(height: 10.0),
                      Text(
                        getTranslate(context, "REMARK"),
                        style: TextStyle(color: GREY_LIGHt, fontSize: 15),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: BLUE_DARK_LIGHT,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Text(widget.mission.comment == null
                                  ? getTranslate(context, "REMARK_NOT_YET")
                                  : widget.mission.comment)
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                    color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslate(context, "DEVIS_SUMMARY"),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslate(context, "TOTAL_HT"),
                            style: TextStyle(color: GREY_LIGHt, fontSize: 15),
                          ),
                          Text(
                            "$prixMission ${userProvider.user.devise.symbol}",
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslate(context, "TOTAL_TTC"),
                            style: TextStyle(color: GREY_LIGHt, fontSize: 15),
                          ),
                          Text(
                            "${prixMission + prixTva} ${userProvider.user.devise.symbol}",
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslate(context, "PC_COMMISSION"),
                            style: TextStyle(color: GREY_LIGHt, fontSize: 15),
                          ),
                          Text(
                            "$prixCommisionPc ${userProvider.user.devise.symbol}",
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: BLUE_DARK_LIGHT,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(getTranslate(context, "YOU_RECEIVE")),
                              Text(
                                  "$prixMission ${userProvider.user.devise.symbol}")
                            ],
                          )),
                      SizedBox(height: 15.0),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                            DevisDetails.routeName,
                            arguments: DevisDetailsArguments(
                                widget.mission.devis.devisDocId,
                                widget.mission.devis,
                                false,
                                true)),
                        child: Center(
                          child: Text(
                            getTranslate(context, "SEE_DEVIS_DETAILS"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: BLUE_SKY),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
