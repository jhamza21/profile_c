import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/modules/documents/add_update_company_data.dart';
import 'package:profilecenter/modules/documents/add_update_legal_mention.dart';
import 'package:profilecenter/providers/company_data_provider.dart';
import 'package:profilecenter/providers/mention_legal_data_provider.dart';
import 'package:profilecenter/providers/project_offers_provider.dart';
import 'package:profilecenter/modules/companyOffers/add_update_offer.dart';
import 'package:profilecenter/modules/companyOffers/offer_card.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class ProjectOffer extends StatefulWidget {
  @override
  _ProjectOfferState createState() => _ProjectOfferState();
}

class _ProjectOfferState extends State<ProjectOffer> {
  @override
  void initState() {
    super.initState();
    fetchProjectOffers();
    fetchMentionLegalData();
    fetchCompanyData();
  }

  void fetchProjectOffers() async {
    ProjectOffersProvider projectOffersProvider =
        Provider.of<ProjectOffersProvider>(context, listen: false);
    projectOffersProvider.fetchProjectOffers(context);
  }

  fetchMentionLegalData() {
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: false);
    mentionLegalDataProvider.fetchLegalMention(context);
  }

  fetchCompanyData() {
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: false);
    companyDataProvider.fetchCompanyCoord(context);
  }

  void _showCompleteProfileDialog(String msg, Function redirection) {
    showBottomModal(context, null, msg, getTranslate(context, "YES"),
        redirection, getTranslate(context, "NO"), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    ProjectOffersProvider projectOffersProvider =
        Provider.of<ProjectOffersProvider>(context, listen: true);
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: true);
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: true);
    return projectOffersProvider.isLoading ||
            mentionLegalDataProvider.isLoading ||
            companyDataProvider.isLoading
        ? Center(child: circularProgress)
        : projectOffersProvider.isError ||
                mentionLegalDataProvider.isError ||
                companyDataProvider.isError
            ? ErrorScreen()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      ...projectOffersProvider.projectOffers
                          .map((e) => OfferCard(e, PROJECT_OFFER))
                          .toList(),
                      TextButton.icon(
                          onPressed: () {
                            if (companyDataProvider.companyData == null)
                              _showCompleteProfileDialog(
                                  getTranslate(
                                      context, "COMPLETE_PROFILE_RESTRICTION"),
                                  () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed(AddUpdateCompanyData.routeName);
                              });
                            else if (mentionLegalDataProvider
                                    .mentionLegalData ==
                                null)
                              _showCompleteProfileDialog(
                                  getTranslate(context,
                                      "COMPLETE_MENTION_LEGAL_RESTRICTION"),
                                  () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed(AddUpdateLegalMention.routeName);
                              });
                            else
                              Navigator.of(context).pushNamed(
                                  AddUpdateOffer.routeName,
                                  arguments: AddUpdateOfferArguments(
                                      null, PROJECT_OFFER));
                          },
                          icon: Icon(
                            Icons.add_circle_rounded,
                            color: RED_DARK,
                            size: 20,
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          label: Text(
                            getTranslate(context, "ADD_OFFER"),
                          )),
                    ],
                  ),
                ),
              );
  }
}
