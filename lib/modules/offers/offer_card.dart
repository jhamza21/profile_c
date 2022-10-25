import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/providers/supported_countries_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/offers/offer_details.dart';
import 'package:profilecenter/modules/offers/postulate_to_job_intership_offer.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/descr_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferCard extends StatefulWidget {
  final Offer offer;
  final Function() onCallback;
  OfferCard(this.offer, this.onCallback);
  @override
  _OfferCardState createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool _isSendingProjecProposal = false;

  String get url => "${widget.offer.link}";
  // static const url = "https://www.google.com";

  void _showEventDisallowedDialog(String role) {
    showBottomModal(
        context,
        null,
        "${getTranslate(context, "POSTULATE_ROLE_RESTRICTION_1")} $role. ${getTranslate(context, "POSTULATE_ROLE_RESTRICTION_2")}",
        getTranslate(context, "CLOSE"), () {
      Navigator.of(context).pop();
    }, null, null);
  }

  void _showSendProjectProposalDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "SERVICES_PROPOSITION"),
      getTranslate(context, "YES"),
      () async {
        Navigator.of(context).pop();
        sendProjectProposal();
      },
      getTranslate(context, "NO"),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  void _showUpgradePackageDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "POSTULATE_PACK_RESTRICTION"),
        getTranslate(context, "YES"),
        () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(PackChangerCandidat.routeName);
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  void _showUnsupportedCountryDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "POSTULATE_COUNTRY_RESTRICTION"),
        getTranslate(context, "CLOSE"), () {
      Navigator.of(context).pop();
    }, null, null);
  }

  void sendProjectProposal() async {
    try {
      setState(() {
        _isSendingProjecProposal = true;
      });
      final res = await OfferService()
          .sendProjectProposal(widget.offer.id, widget.offer.companyRh.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      showSnackbar(context, getTranslate(context, "SERVICES_PROPOSITION_SENT"));
      widget.offer.isPropositionSent = true;
      widget.onCallback();
      setState(() {
        widget.offer.isAvailable = false;
        _isSendingProjecProposal = false;
      });
    } catch (e) {
      setState(() {
        _isSendingProjecProposal = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  @override
  Widget build(BuildContext context) {
    SupportedCountriesProvider supportedCountriesProvider =
        Provider.of<SupportedCountriesProvider>(context, listen: false);
    return GestureDetector(
      onTap: () =>
          widget.offer.offerType == JOB_OFFER && widget.offer.typeOffre == true
              ? Navigator.pushNamed(context, OfferDetails.routeName,
                  arguments: OfferDetailsArguments(widget.offer, () {
                    widget.onCallback();
                    widget.offer.isAvailable = false;
                  }))
              : widget.offer.offerType == JOB_OFFER &&
                      widget.offer.typeOffre == false
                  ? Navigator.pushNamed(context, OfferDetails.routeName,
                      arguments: OfferDetailsArguments(widget.offer, () {
                        widget.onCallback();
                        widget.offer.isAvailable = false;
                      }))
                  : Navigator.pushNamed(context, OfferDetails.routeName,
                      arguments: OfferDetailsArguments(widget.offer, () {
                        widget.onCallback();
                        widget.offer.isAvailable = false;
                      })),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.0, left: 5.0, right: 5.0),
            decoration: BoxDecoration(
              color: BLUE_DARK_LIGHT,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: widget.offer.offerType == JOB_OFFER &&
                            widget.offer.typeOffre == true
                        ? CircleAvatar(
                            backgroundColor: RED_LIGHT,
                            child: Text(
                              widget.offer.title[0].toUpperCase(),
                              style: TextStyle(fontSize: 20),
                            ),
                            minRadius: 20,
                            maxRadius: 22,
                          )
                        : widget.offer.offerType == JOB_OFFER &&
                                    widget.offer.typeOffre == false ||
                                widget.offer.offerType == INTERSHIP_OFFER ||
                                widget.offer.offerType == PROJECT_OFFER
                            ? getCompanyAvatar(
                                null, widget.offer.company, BLUE_LIGHT, 22)
                            : widget.offer.offerType == INTERSHIP_OFFER ||
                                    widget.offer.offerType == PROJECT_OFFER
                                ? getCompanyAvatar(
                                    null, widget.offer.company, BLUE_LIGHT, 22)
                                : '',
                    title: Text(widget.offer.title,
                        style: TextStyle(color: Colors.white)),
                    subtitle: widget.offer.company != null &&
                            widget.offer.company.name != '' &&
                            widget.offer.offerType == JOB_OFFER &&
                            widget.offer.typeOffre == false
                        ? Text(widget.offer.company.name,
                            style: TextStyle(color: GREY_LIGHt))
                        : widget.offer.offerType == JOB_OFFER &&
                                widget.offer.typeOffre == true
                            ? Text(
                                "offre Externe",
                                style: TextStyle(color: GREY_LIGHt),
                              )
                            : Text(widget.offer.company.name,
                                style: TextStyle(color: GREY_LIGHt)),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: [
                        DescrCard(
                            null,
                            getTranslate(context, widget.offer.offerType),
                            widget.offer.offerType == PROJECT_OFFER
                                ? RED_BURGUNDY
                                : widget.offer.offerType == JOB_OFFER &&
                                        widget.offer.typeOffre == false
                                    ? BLUE_LIGHT1
                                    : widget.offer.offerType == INTERSHIP_OFFER
                                        ? YELLOW_DARK
                                        : GREEN_DARK),
                        widget.offer.createdAt != null
                            ? DescrCard(
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                "${widget.offer.createdAt.substring(0, 10)}",
                                BLUE_LIGHT)
                            : SizedBox.shrink(),
                        widget.offer.offerType == JOB_OFFER &&
                                widget.offer.typeOffre == true &&
                                widget.offer.distance != null
                            ? SizedBox.shrink()
                            : DescrCard(
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                "${widget.offer.distance.toInt()}" + " km",
                                BLUE_LIGHT),
                        widget.offer.duration != null
                            ? DescrCard(
                                null,
                                widget.offer.duration
                                    .replaceFirst(
                                        "hours", getTranslate(context, "HOURS"))
                                    .replaceFirst(
                                        "hour", getTranslate(context, "HOUR"))
                                    .replaceFirst(
                                        "days", getTranslate(context, "DAYS"))
                                    .replaceFirst(
                                        "day", getTranslate(context, "DAY")),
                                BLUE_LIGHT)
                            : SizedBox.shrink(),
                        DescrCard(
                            Icon(
                              Icons.badge,
                              size: 15,
                              color: Colors.grey,
                            ),
                            "${getTranslate(context, "MOBILITY")} " +
                                getTranslate(
                                    context,
                                    widget.offer.mobility != ''
                                        ? widget.offer.mobility
                                        : 'indifferent'),
                            BLUE_LIGHT),
                        widget.offer.offerType == JOB_OFFER &&
                                widget.offer.typeOffre == true &&
                                widget.offer.note != null
                            ? SizedBox.shrink()
                            : DescrCard(
                                null,
                                "${getTranslate(context, "SUITS_YOU")} ${widget.offer.note.toInt()} %",
                                BLUE_LIGHT)
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: !widget.offer.isAvailable ||
                    widget.offer.isPropositionSent ||
                    _isSendingProjecProposal
                ? null
                : () {
                    UserProvider userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    if (userProvider.user.pack.notAllowed
                        .contains(POSTULATE_PRIVILEGE))
                      _showUpgradePackageDialog();
                    else if (widget.offer.offerType == JOB_OFFER &&
                            widget.offer.typeOffre == false ||
                        widget.offer.offerType == INTERSHIP_OFFER)
                      Navigator.of(context).pushNamed(
                          PostulateToJobIntershipOffer.routeName,
                          arguments: PostulateToJobIntershipOfferArguments(
                              widget.offer, () {
                            widget.offer.isAvailable = false;
                            setState(() {});
                          }));
                    else if (widget.offer.offerType == JOB_OFFER &&
                        widget.offer.typeOffre == true)
                      launchUrl(Uri.parse(url));
                    else if (![FREELANCE_ROLE, SALARIEE_ROLE]
                        .contains(userProvider.user.role))
                      _showEventDisallowedDialog(userProvider.user.role);
                    else if (!supportedCountriesProvider
                        .isSupported(userProvider.user.address.country))
                      _showUnsupportedCountryDialog();
                    else
                      _showSendProjectProposalDialog();
                  },
            child: Container(
                margin: EdgeInsets.only(left: 5.0, right: 5.0),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                    color: !widget.offer.isAvailable ||
                            widget.offer.isPropositionSent
                        ? GREY_LIGHt
                        : widget.offer.offerType == PROJECT_OFFER
                            ? RED_BURGUNDY
                            : widget.offer.offerType == JOB_OFFER &&
                                    widget.offer.typeOffre == false
                                ? BLUE_LIGHT1
                                : widget.offer.offerType == INTERSHIP_OFFER
                                    ? YELLOW_DARK
                                    : GREEN_DARK),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isSendingProjecProposal
                        ? circularProgress
                        : Icon(
                            Icons.post_add,
                            color: Colors.white,
                          ),
                    SizedBox(width: 10.0),
                    Text(
                      widget.offer.offerType == JOB_OFFER &&
                                  widget.offer.typeOffre == false ||
                              widget.offer.offerType == INTERSHIP_OFFER
                          ? getTranslate(context, "APPLY")
                          : widget.offer.offerType == JOB_OFFER &&
                                  widget.offer.typeOffre == true
                              ? "Redirect"
                              : getTranslate(
                                  context, "SERVICES_PROPOSITION_BTN"),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
