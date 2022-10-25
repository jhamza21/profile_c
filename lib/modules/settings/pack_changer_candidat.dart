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

class PackChangerCandidat extends StatefulWidget {
  static const routeName = '/packChangerCandidat';

  @override
  _PackChangerCandidatState createState() => _PackChangerCandidatState();
}

class _PackChangerCandidatState extends State<PackChangerCandidat> {
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
      if (res.statusCode == 401) return sessionExpired(context);
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
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30.0),
                      Text(
                        getTranslate(context, "PACKS_NOTICE"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      ..._packs.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedpack = e;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: _selectedpack.id == e.id
                                ? RED_LIGHT
                                : BLUE_LIGHT,
                            trailing: Text(e.prix.toStringAsFixed(2) + "€",
                                style: TextStyle(
                                    color: _selectedpack.id == e.id
                                        ? Colors.grey[800]
                                        : Colors.white)),
                            title: Text(
                              getPackTitle(e, userProvider),
                              style: TextStyle(
                                  color: _selectedpack.id == e.id
                                      ? BLUE_SKY
                                      : Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.0),
                      TextButton(
                          onPressed: userProvider.user.pack.id ==
                                      _selectedpack.id ||
                                  userProvider.user.pack.prix >
                                      _selectedpack.prix
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                      context, PayPack.routeName,
                                      arguments: PayPackArguments(
                                          pack: _selectedpack,
                                          onCallback: () {
                                            userProvider.setPack(_selectedpack);
                                            Navigator.of(context).pop();
                                            showSnackbar(
                                                context,
                                                getTranslate(context,
                                                    "PROFILE_UPDATE_SUCCESS"));
                                          }));
                                },
                          child: Text(getTranslate(context, "VALIDATE"))),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
    );
  }
}
