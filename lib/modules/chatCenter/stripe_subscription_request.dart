import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/supported_countries_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/stripe_service.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeSubscriptionRequest extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  StripeSubscriptionRequest(this.message, this.userProvider);
  @override
  _StripeSubscriptionRequestState createState() =>
      _StripeSubscriptionRequestState();
}

class _StripeSubscriptionRequestState extends State<StripeSubscriptionRequest> {
  String _stripeId;
  bool _isAccountVerified = false;
  bool _isLoading = true;
  bool _isGeneratingLink = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    checkStripeAccount();
  }

  void checkStripeAccount() async {
    try {
      SupportedCountriesProvider supportedCountriesProvider =
          Provider.of<SupportedCountriesProvider>(context, listen: false);
      supportedCountriesProvider.fetchCountries(context);
      _stripeId = widget.userProvider.user.stripeId;
      if (_stripeId != null) {
        var res = await StripeServices.getAccount(_stripeId);
        var jsonData = json.decode(res.body);
        if (jsonData["capabilities"]["transfers"] == "active")
          _isAccountVerified = true;
      }
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

  String getMessagetitle() {
    if (_isError) return getTranslate(context, "STRIPE_INIT_ERROR");
    if (_stripeId == null)
      return getTranslate(context, "INVIT_SUBSCRIBE_STRIPE");
    else if (!_isAccountVerified)
      return getTranslate(context, "VERIFY_STRIPE_ACCOUNT");
    else
      return getTranslate(context, "SUBSCRIPTION_SUCCESS");
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
                      if (!_isAccountVerified)
                        Icon(
                          MdiIcons.alert,
                          color: YELLOW_LIGHT,
                          size: 20,
                        ),
                      if (_isAccountVerified)
                        Icon(
                          MdiIcons.accountCheck,
                          color: GREEN_LIGHT,
                          size: 20,
                        ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  _isLoading
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: circularProgress,
                        ))
                      : _isError
                          ? Text(
                              getMessagetitle(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  getMessagetitle(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0),
                                ),
                                SizedBox(height: 10.0),
                                if (!_isAccountVerified)
                                  SizedBox(
                                    height: 30,
                                    child: ElevatedButton.icon(
                                      icon: _isGeneratingLink
                                          ? circularProgress
                                          : SizedBox.shrink(),
                                      onPressed: _isGeneratingLink
                                          ? null
                                          : () async {
                                              try {
                                                setState(() {
                                                  _isGeneratingLink = true;
                                                });
                                                //user don't yet have an account
                                                if (_stripeId == null) {
                                                  SupportedCountriesProvider
                                                      supportedCountriesProvider =
                                                      Provider.of<
                                                              SupportedCountriesProvider>(
                                                          context,
                                                          listen: false);
                                                  String countyCode =
                                                      supportedCountriesProvider
                                                          .getCountryCode(widget
                                                              .userProvider
                                                              .user
                                                              .address
                                                              .country);
                                                  var accountRes =
                                                      await StripeServices
                                                          .createStripeAccount(
                                                              countyCode);
                                                  if (accountRes.statusCode !=
                                                      200) throw "ERROR_SERVER";
                                                  var accountResData = json
                                                      .decode(accountRes.body);
                                                  _stripeId =
                                                      accountResData["id"];
                                                  var saveAccountRes =
                                                      await UserService()
                                                          .setUserStripeId(
                                                    widget.userProvider.user.id,
                                                    _stripeId,
                                                  );
                                                  widget.userProvider
                                                      .setStripeId(_stripeId);
                                                  if (saveAccountRes
                                                          .statusCode !=
                                                      200) throw "ERROR_SERVER";
                                                }
                                                var linkRes =
                                                    await StripeServices
                                                        .getAccountLink(
                                                            _stripeId);
                                                if (linkRes.statusCode != 200)
                                                  throw "ERROR_SERVER";
                                                var linkresData =
                                                    json.decode(linkRes.body);
                                                if (await canLaunchUrl(
                                                    linkresData["url"])) {
                                                  Navigator.of(context).pop();
                                                  await launchUrl(
                                                      linkresData["url"]);
                                                } else
                                                  throw 'Could not launch URL';

                                                setState(() {
                                                  _isGeneratingLink = false;
                                                });
                                              } catch (e) {
                                                setState(() {
                                                  _isGeneratingLink = false;
                                                });
                                                showSnackbar(
                                                    context,
                                                    getTranslate(context,
                                                        "ERROR_SERVER"));
                                              }
                                            },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(RED_DARK),
                                      ),
                                      label: Text(_stripeId == null
                                          ? getTranslate(
                                              context, "SUBSCRIPE_STRIPE_BTN")
                                          : getTranslate(
                                              context, "VERFIY_STRIPE_BTN")),
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
