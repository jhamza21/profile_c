import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/modules/settings/pay_pack/pay_pack.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/pack.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/pack_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class PackChangerCompany extends StatefulWidget {
  static const routeName = '/packChangerCompany';

  @override
  _PackChangerCompanyState createState() => _PackChangerCompanyState();
}

class _PackChangerCompanyState extends State<PackChangerCompany> {
  List<Pack> _packs = [];
  Pack _selectedpack;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _getPacks();
    _initializeData();
  }

  void _getPacks() async {
    try {
      final res = await PackService().getPacks();
      if (res.statusCode == 401 || res.statusCode == 403)
        return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _packs = Pack.listFromJson(jsonData["data"]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void _initializeData() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _selectedpack = userProvider.user.pack;
  }

  Widget buildUpdatePackBtn(UserProvider userProvider, Pack pack) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
          onPressed: userProvider.user.pack.id == pack.id ||
                  userProvider.user.pack.prix > pack.prix
              ? null
              : () {
                  Navigator.pushNamed(context, PayPack.routeName,
                      arguments: PayPackArguments(
                          pack: _selectedpack,
                          onCallback: () {
                            userProvider.setPack(_selectedpack);
                            Navigator.of(context).pop();
                            showSnackbar(
                                context,
                                getTranslate(
                                    context, "PROFILE_UPDATE_SUCCESS"));
                          }));
                },
          icon: Icon(Icons.arrow_forward_rounded, size: 30)),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String getPackTitle(Pack pack, UserProvider userProvider) {
    String res = pack.name;
    if (pack.id == 1) {
      DateTime validity =
          DateTime.parse(userProvider.user.createdAt.substring(0, 10))
              .add(Duration(days: 730));
      res += " (${DateFormat('yyyy-MM-dd').format(validity)})";
    }
    return res;
  }

  Widget checkIcon() => Padding(
        padding: EdgeInsets.only(bottom: 12, top: 6),
        child: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      );

  Widget cancelIcon() => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 6),
        child: Icon(
          Icons.cancel,
          color: Colors.red,
        ),
      );

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: Text(getTranslate(context, "PACKS")),
        ),
        body: _isLoading
            ? Center(child: circularProgress)
            : _isError
                ? ErrorScreen()
                : SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 120.0, top: 20),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 70,
                                    width: 70,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 70,
                                    width: 70,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 70,
                                    width: 70,
                                  ),
                                ]),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 110.0, right: 2.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(height: 40.0),
                                  ..._packs.map(
                                    (e) => Expanded(
                                      flex: 2,
                                      child: ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 0, right: 0),
                                        onTap: () {
                                          setState(() {
                                            _selectedpack = e;
                                          });
                                        },
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedpack = e;
                                                    });
                                                  },
                                                  child: Text(
                                                    getPackTitle(
                                                            e, userProvider)
                                                        .split("-")
                                                        .last,
                                                    style: TextStyle(
                                                        color: _selectedpack
                                                                    .id ==
                                                                e.id
                                                            ? /* RED_LIGHT  */ BLUE_SKY
                                                            : Colors.white70,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.1),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder(
                                  verticalInside:
                                      BorderSide(color: Colors.transparent),
                                  horizontalInside:
                                      BorderSide(color: Colors.transparent)),
                              columnWidths: {
                                0: FractionColumnWidth(.3),
                                1: FractionColumnWidth(.2),
                                2: FractionColumnWidth(.3),
                                3: FractionColumnWidth(.2)
                              },
                              children: [
                                TableRow(children: [
                                  Text(
                                    'Moteur de recherche',
                                    textAlign: TextAlign.center,
                                  ),
                                  checkIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Filtres',
                                    textAlign: TextAlign.center,
                                  ),
                                  checkIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Map',
                                    textAlign: TextAlign.center,
                                  ),
                                  checkIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Distance',
                                    textAlign: TextAlign.center,
                                  ),
                                  checkIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Chat',
                                    textAlign: TextAlign.center,
                                  ),
                                  cancelIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Devis',
                                    textAlign: TextAlign.center,
                                  ),
                                  cancelIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Tests',
                                    textAlign: TextAlign.center,
                                  ),
                                  cancelIcon(),
                                  checkIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Comparaison profils',
                                    textAlign: TextAlign.center,
                                  ),
                                  cancelIcon(),
                                  cancelIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Agenda',
                                    textAlign: TextAlign.center,
                                  ),
                                  cancelIcon(),
                                  cancelIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  Text(
                                    'Fichiers',
                                    textAlign: TextAlign.center,
                                  ),
                                  cancelIcon(),
                                  cancelIcon(),
                                  checkIcon(),
                                ]),
                                TableRow(children: [
                                  SizedBox(),
                                  SizedBox(),
                                  SizedBox(),
                                  SizedBox()
                                ])
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 122.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: _packs
                                    .map((e) =>
                                        buildUpdatePackBtn(userProvider, e))
                                    .toList()),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 72.0, right: 26),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(height: 30.0),
                                  ..._packs.map(
                                    (e) => Container(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                          e.prix.toStringAsFixed(0) + "€",
                                          style: TextStyle(
                                              color: _selectedpack.id == e.id
                                                  ? BLUE_SKY
                                                  : Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8)),
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ));
  }
}
