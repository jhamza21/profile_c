import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/intership_offers_provider.dart';
import 'package:profilecenter/modules/companyOffers/add_update_offer.dart';
import 'package:profilecenter/modules/companyOffers/offer_card.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class IntershipOffer extends StatefulWidget {
  @override
  _IntershipOfferState createState() => _IntershipOfferState();
}

class _IntershipOfferState extends State<IntershipOffer> {
  @override
  void initState() {
    super.initState();
    fetchIntershipOffers();
  }

  void fetchIntershipOffers() async {
    IntershipOffersProvider intershipOffersProvider =
        Provider.of<IntershipOffersProvider>(context, listen: false);
    intershipOffersProvider.fetchIntershipOffers(context);
  }

  @override
  Widget build(BuildContext context) {
    IntershipOffersProvider intershipOffersProvider =
        Provider.of<IntershipOffersProvider>(context, listen: true);
    return intershipOffersProvider.isLoading
        ? Center(child: circularProgress)
        : intershipOffersProvider.isError
            ? ErrorScreen()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      ...intershipOffersProvider.intershipOffers
                          .map((e) => OfferCard(e, INTERSHIP_OFFER))
                          .toList(),
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                AddUpdateOffer.routeName,
                                arguments: AddUpdateOfferArguments(
                                    null, INTERSHIP_OFFER));
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
