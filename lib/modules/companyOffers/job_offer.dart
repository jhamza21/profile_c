import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/job_offers_provider.dart';
import 'package:profilecenter/modules/companyOffers/add_update_offer.dart';
import 'package:profilecenter/modules/companyOffers/offer_card.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class JobOffer extends StatefulWidget {
  @override
  _JobOfferState createState() => _JobOfferState();
}

class _JobOfferState extends State<JobOffer> {
  @override
  void initState() {
    super.initState();
    fetchJobOffers();
  }

  void fetchJobOffers() async {
    JobOffersProvider jobOffersProvider =
        Provider.of<JobOffersProvider>(context, listen: false);
    jobOffersProvider.fetchJobOffers(context);
  }

  @override
  Widget build(BuildContext context) {
    JobOffersProvider jobOffersProvider =
        Provider.of<JobOffersProvider>(context, listen: true);
    return jobOffersProvider.isLoading
        ? Center(child: circularProgress)
        : jobOffersProvider.isError
            ? ErrorScreen()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...jobOffersProvider.jobOffers
                          .map((e) => OfferCard(e, JOB_OFFER)),                  
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                AddUpdateOffer.routeName,
                                arguments:
                                    AddUpdateOfferArguments(null, JOB_OFFER));
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
