import 'package:flutter/material.dart';
import 'package:profilecenter/modules/companyOffers/intership_offer.dart';
import 'package:profilecenter/modules/companyOffers/job_offer.dart';
import 'package:profilecenter/modules/companyOffers/project_offer.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class CompanyOffers extends StatefulWidget {
  static const routeName = '/companyOffers';

  @override
  _CompanyOffersState createState() => _CompanyOffersState();
}

class _CompanyOffersState extends State<CompanyOffers> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(getTranslate(context, "MY_OFFERS")),
          bottom: TabBar(
            tabs: [
              Tab(text: getTranslate(context, "JOB")),
              Tab(text: getTranslate(context, "PROJECTS")),
              Tab(text: getTranslate(context, "INTERSHIPS")),
            ],
          ),
        ),
        body: TabBarView(
          children: [JobOffer(), ProjectOffer(), IntershipOffer()],
        ),
      ),
    );
  }
}
