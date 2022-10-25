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
import 'package:profilecenter/modules/profile/company_profile.dart';
import 'package:profilecenter/modules/offers/postulate_to_job_intership_offer.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferDetails extends StatefulWidget {
  static const routeName = '/offerDetails';

  final OfferDetailsArguments arguments;
  OfferDetails(this.arguments);

  @override
  _OfferDetailsState createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails> {
  bool _isLoading = false;

  Widget _showTitle(text) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  String get url => "${widget.arguments.offer.link}";

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
        });
  }

  void sendProjectProposal() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final res = await OfferService().sendProjectProposal(
          widget.arguments.offer.id, widget.arguments.offer.companyRh.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      showSnackbar(context, getTranslate(context, "SERVICES_PROPOSITION_SENT"));
      widget.arguments.offer.isAvailable = false;
      widget.arguments.onCallback();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
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

  Widget _showPostulateBtn() {
    SupportedCountriesProvider supportedCountriesProvider =
        Provider.of<SupportedCountriesProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ElevatedButton.icon(
        icon: _isLoading
            ? circularProgress
            : Icon(
                Icons.post_add,
              ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              !widget.arguments.offer.isAvailable ||
                      widget.arguments.offer.isPropositionSent
                  ? GREY_LIGHt
                  : RED_DARK),
          padding: MaterialStateProperty.all(EdgeInsets.all(8.0)),
        ),
        label: Text(
          widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == false ||
                  widget.arguments.offer.offerType == INTERSHIP_OFFER
              ? getTranslate(context, "APPLY")
              : widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? "Redirect"
                  : getTranslate(context, "SERVICES_PROPOSITION_BTN"),
        ),
        onPressed: !widget.arguments.offer.isAvailable ||
                widget.arguments.offer.isPropositionSent
            ? null
            : () {
                if (userProvider.user.pack.notAllowed
                    .contains(POSTULATE_PRIVILEGE))
                  _showUpgradePackageDialog();
                else if (widget.arguments.offer.offerType == JOB_OFFER &&
                        widget.arguments.offer.typeOffre == false ||
                    widget.arguments.offer.offerType == INTERSHIP_OFFER)
                  Navigator.of(context).pushNamed(
                      PostulateToJobIntershipOffer.routeName,
                      arguments: PostulateToJobIntershipOfferArguments(
                          widget.arguments.offer, () {
                        widget.arguments.offer.isAvailable = false;
                        widget.arguments.onCallback();
                        setState(() {});
                      }));
                else if (widget.arguments.offer.offerType == JOB_OFFER &&
                    widget.arguments.offer.typeOffre == true)
                  launchUrl(Uri.parse(url));
                else if (![FREELANCE_ROLE, SALARIEE_ROLE]
                    .contains(userProvider.user.role))
                  _showEventDisallowedDialog(userProvider.user.role);
                else if (!supportedCountriesProvider
                    .isSupported(userProvider.user.address.country))
                  _showUnsupportedCountryDialog();
                else
                  _showSendProjectProposalDialog();
              });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "OFFER_DETAILS")),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: widget.arguments.offer.offerType == JOB_OFFER &&
                          widget.arguments.offer.typeOffre == true
                      ? CircleAvatar(
                          backgroundColor: RED_LIGHT,
                          child: Text(
                            widget.arguments.offer.title[0].toUpperCase(),
                            style: TextStyle(fontSize: 20),
                          ),
                          minRadius: 20,
                          maxRadius: 25,
                        )
                      : getCompanyAvatar(
                          null, widget.arguments.offer.company, BLUE_DARK, 25),
                  title: Text(widget.arguments.offer.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle: widget.arguments.offer.offerType == JOB_OFFER &&
                          widget.arguments.offer.typeOffre == true
                      ? null
                      : Row(
                          children: [
                            Text(
                              getTranslate(context, "OFFER_SUITS_YOU"),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "${widget.arguments.offer.note.toInt()}" + " %",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 10),
              widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(getTranslate(context, "OFFER_TYPE")),
                          SizedBox(height: 5),
                          Text(
                            getTranslate(
                                context, widget.arguments.offer.offerType),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )),
              SizedBox(height: 10),
              widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(getTranslate(context, "PUBLISHED_BY")),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.arguments.offer.company.name),
                              SizedBox(width: 10),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        CompanyeProfile.routeName,
                                        arguments:
                                            widget.arguments.offer.company.id);
                                  },
                                  child: Icon(
                                    Icons.redo_outlined,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ],
                      )),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _showTitle(getTranslate(context, "PUBLISHED_AT")),
                    SizedBox(height: 5),
                    Text(widget.arguments.offer.createdAt.substring(0, 10)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _showTitle(
                        "${getTranslate(context, "OFFER_DESCRIPTION")} :"),
                    SizedBox(height: 5),
                    Text(widget.arguments.offer.description),
                  ],
                ),
              ),
              SizedBox(height: 10),
              widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(getTranslate(context, "JOB_TIME_TYPE")),
                          SizedBox(height: 5),
                          Text(getTranslate(
                              context, widget.arguments.offer.mobility)),
                        ],
                      ),
                    ),
              SizedBox(height: 10),
              widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "REQUIRED_SKILLS")} :"),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                ...widget.arguments.offer.skills
                                    .map((e) => Text(e.title + ", "))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: 10),
              widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "REQUIRED_TOOLS")} :"),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                ...widget.arguments.offer.tools
                                    .map((e) => Text(e.title + ", "))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: 10),
              widget.arguments.offer.offerType == JOB_OFFER &&
                      widget.arguments.offer.typeOffre == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "REQUIRED_LANGUAGES")} :"),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                ...widget.arguments.offer.languages.map((e) =>
                                    Text(e.title + "(${e.selectedLevel}), "))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: 20),
              _showPostulateBtn()
            ],
          ),
        ),
      ),
    );
  }
}

class OfferDetailsArguments {
  final Offer offer;
  final Function() onCallback;

  OfferDetailsArguments(this.offer, this.onCallback);
}
