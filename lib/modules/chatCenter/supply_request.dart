import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/models/payment.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/modules/chatCenter/supply_screen/supply_screen.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class SupplyRequest extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  SupplyRequest(this.message, this.userProvider);
  @override
  _SupplyRequestState createState() => _SupplyRequestState();
}

class _SupplyRequestState extends State<SupplyRequest> {
  bool _isLoading = true;
  bool _error = false;
  double _suppliedAmount = 0;
  double prixMission;
  double prixTva;
  double prixCommisionPc;
  double prixTotal;

  @override
  void initState() {
    super.initState();
    fetchSuppliesHistoric();
  }

  void fetchSuppliesHistoric() async {
    try {
      final res = await OfferService().getSupplies(widget.message.devis.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      Payment.listFromJson(jsonData["data"]).forEach((element) {
        _suppliedAmount += element.amount;
      });
      double prixMission = widget.message.devis.workDaysPerMonth *
          widget.message.devis.projectPeriod *
          widget.message.devis.tjm;
      double prixTva = (prixMission / 100) * widget.message.devis.tva;
      double prixCommisionPc =
          (prixMission / 100) * widget.message.devis.commisionPc;
      prixTotal = prixMission + prixCommisionPc + prixTva;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _isLoading = false;
      });
    }
  }

  void addSupply(Payment payment) {
    setState(() {
      _suppliedAmount += payment.amount;
    });
  }

  String getMessagetitle() {
    if (_error) return getTranslate(context, "ERROR_OCCURED");
    if (prixTotal == _suppliedAmount)
      return getTranslate(context, "SUPPLY_END");
    return "${getTranslate(context, "AMOUNT_TO_SUPPLY")} ${prixTotal - _suppliedAmount}€ ${getTranslate(context, "FOR_PROJECT")} ${widget.message.offer.title}.";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                  color: BLUE_LIGHT,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Center",
                        style: TextStyle(
                            color: GREY_LIGHt,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        MdiIcons.informationOutline,
                        color: YELLOW_LIGHT,
                        size: 15,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _isLoading
                          ? Center(
                              child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: circularProgress,
                            ))
                          : Text(
                              getMessagetitle(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0),
                            ),
                      SizedBox(height: 10.0),
                      _isLoading || prixTotal == _suppliedAmount
                          ? SizedBox.shrink()
                          : SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      SupplyScreen.routeName,
                                      arguments: SupplyScreenArguments(
                                          widget.userProvider.user,
                                          widget.message.devis,
                                          widget.message.offer,
                                          addSupply));
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(RED_DARK),
                                ),
                                child: Text(getTranslate(context, "SUPLY_BTN")),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
