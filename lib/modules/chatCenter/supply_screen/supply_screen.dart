import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/modules/chatCenter/supply_screen/pay_supply/pay_supply.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/models/payment.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/modules/chatCenter/devis_details.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';

class SupplyScreen extends StatefulWidget {
  static const routeName = '/supplyScreen';
  final SupplyScreenArguments arguments;
  SupplyScreen(this.arguments);

  @override
  _SupplyScreenState createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  final _formKey = new GlobalKey<FormState>();
  var amountController = TextEditingController();
  List<Payment> _oldSupplies = [];
  double _amount;
  double _suppliedAmount = 0;
  bool _error = false;
  bool _isLoading = false;
  double prixTotal;

  @override
  void initState() {
    super.initState();
    fetchOldSupplies();
    double prixMission = widget.arguments.devis.workDaysPerMonth *
        widget.arguments.devis.projectPeriod *
        widget.arguments.devis.tjm;
    double prixTva = (prixMission / 100) * widget.arguments.devis.tva;
    double prixCommisionPc =
        (prixMission / 100) * widget.arguments.devis.commisionPc;
    prixTotal = prixMission + prixCommisionPc + prixTva;
  }

  void fetchOldSupplies() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final res = await OfferService().getSupplies(widget.arguments.devis.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _oldSupplies = Payment.listFromJson(jsonData["data"]);
      _oldSupplies.forEach((element) {
        _suppliedAmount += element.amount;
      });
      amountController.text = "${prixTotal - _suppliedAmount}";
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

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildSupplyAmountInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: inputTextDecoration(
            30.0,
            null,
            getTranslate(context, "SUPPLY_SUM"),
            null,
            Container(
                padding: EdgeInsets.symmetric(vertical: 15), child: Text("€"))),
        validator: (value) => value.isEmpty ||
                double.tryParse(value.trim()) == null
            ? getTranslate(context, "FILL_IN_FIELD")
            : double.parse(value.trim()) > prixTotal - _suppliedAmount
                ? "${getTranslate(context, "SUPPLY_MAX")} : ${prixTotal - _suppliedAmount}€"
                : null,
        onSaved: (value) => _amount = double.parse(value.trim()),
      ),
    );
  }

  Widget buildSaveBtn() {
    return TextButton(
      child: Text(
        getTranslate(context, "SUPLY_BTN"),
      ),
      onPressed: () async {
        if (validateAndSave()) {
          Navigator.pushNamed(context, PaySupply.routeName,
              arguments: PaySupplyArguments(
                  amount: _amount,
                  onCallback: () {
                    fetchOldSupplies();
                    amountController.clear();
                    if (widget.arguments.devis.tjm *
                                widget.arguments.devis.workDaysPerMonth -
                            _suppliedAmount ==
                        0) Navigator.of(context).pop();
                  }));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "SUPLY")),
      ),
      body: _isLoading
          ? Center(child: circularProgress)
          : _error
              ? ErrorScreen()
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20.0),
                        Center(
                          child: Text(
                            widget.arguments.project.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${getTranslate(context, "DEVIS_NUMBER")} : ${widget.arguments.devis.devisNumber}",
                              style: TextStyle(color: GREY_LIGHt),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      DevisDetails.routeName,
                                      arguments: DevisDetailsArguments(
                                          null,
                                          widget.arguments.devis,
                                          false,
                                          false));
                                },
                                child: Icon(
                                  Icons.visibility_outlined,
                                  color: GREY_LIGHt,
                                ))
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslate(context, "SUM_OLD_SUPPLIES")),
                            SizedBox(width: 5.0),
                            Text(
                              "$_suppliedAmount€",
                              style: TextStyle(
                                  color: GREEN_LIGHT,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslate(context, "AMOUNT_TO_SUPPLY")),
                            SizedBox(width: 5.0),
                            Text(
                              "${prixTotal - _suppliedAmount}€",
                              style: TextStyle(
                                  color: RED_DARK, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslate(context, "TOTAL_SUPPLIES")),
                            SizedBox(width: 5.0),
                            Text(
                              "$prixTotal€",
                              style: TextStyle(
                                  color: GREEN_LIGHT,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          getTranslate(context, "HISTORIC"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5.0),
                        if (_oldSupplies.length == 0)
                          Text(getTranslate(context, "NO_DATA")),
                        ..._oldSupplies.map((e) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${e.date} à ${e.time} :"),
                                Text(
                                  "${e.amount}€",
                                  style: TextStyle(
                                      color: GREEN_LIGHT,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                        SizedBox(height: 20.0),
                        buildSupplyAmountInput(),
                        SizedBox(height: 60.0),
                        buildSaveBtn(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class SupplyScreenArguments {
  final User user;
  final Devis devis;
  final Offer project;
  final void Function(Payment) callback;
  SupplyScreenArguments(this.user, this.devis, this.project, this.callback);
}
