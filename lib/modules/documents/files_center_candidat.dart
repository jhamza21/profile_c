import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
//import 'package:profilecenter/modules/chatCenter/supply_screen.dart';
//import 'package:profilecenter/modules/infoCandidate/add_update_birthday.dart';
import 'package:profilecenter/modules/documents/add_update_kbis.dart';
import 'package:profilecenter/providers/cover_letter_provider.dart';
import 'package:profilecenter/providers/cv_provider.dart';
import 'package:profilecenter/providers/diplomas_provider.dart';
import 'package:profilecenter/providers/identity_doc_provider.dart';
import 'package:profilecenter/providers/kbis_provider.dart';
import 'package:profilecenter/providers/portfolio_provider.dart';
import 'package:profilecenter/modules/documents/add_update_cover_letter_doc.dart';
import 'package:profilecenter/modules/documents/add_update_cv_doc.dart';
import 'package:profilecenter/modules/documents/add_update_diplomas_doc.dart';
import 'package:profilecenter/modules/documents/add_update_identity_doc.dart';
import 'package:profilecenter/modules/documents/add_update_portfolio_doc.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/file_center_item.dart';
import 'package:provider/provider.dart';

class FilesCenterCandidat extends StatefulWidget {
  static const routeName = '/filesCenterCandidat';

  @override
  _FilesCenterCandidatState createState() => _FilesCenterCandidatState();
}

class _FilesCenterCandidatState extends State<FilesCenterCandidat> {
  @override
  void initState() {
    super.initState();
    CoverLetterProvider coverLetterProvider =
        Provider.of<CoverLetterProvider>(context, listen: false);
    coverLetterProvider.fetchDocuments(context);
    CvProvider cvProvider = Provider.of<CvProvider>(context, listen: false);
    cvProvider.fetchDocuments(context);
    DiplomasProvider diplomasProvider =
        Provider.of<DiplomasProvider>(context, listen: false);
    diplomasProvider.fetchDocuments(context);
    IdentityDocProvider identityDocProvider =
        Provider.of<IdentityDocProvider>(context, listen: false);
    identityDocProvider.fetchDocuments(context);
    PortfolioProvider portfolioProvider =
        Provider.of<PortfolioProvider>(context, listen: false);
    portfolioProvider.fetchDocuments(context);
    KbisProvider kbisProvider =
        Provider.of<KbisProvider>(context, listen: false);
    kbisProvider.fetchDocuments(context);

    // InfoBankProvider infoBankProvider =
    //     Provider.of<InfoBankProvider>(context, listen: false);
    // infoBankProvider.fetchInfoBank();
  }

  @override
  Widget build(BuildContext context) {
    CoverLetterProvider coverLetterProvider =
        Provider.of<CoverLetterProvider>(context, listen: true);
    CvProvider cvProvider = Provider.of<CvProvider>(context, listen: true);
    DiplomasProvider diplomasProvider =
        Provider.of<DiplomasProvider>(context, listen: true);
    IdentityDocProvider identityDocProvider =
        Provider.of<IdentityDocProvider>(context, listen: true);
    PortfolioProvider portfolioProvider =
        Provider.of<PortfolioProvider>(context, listen: true);
    KbisProvider kbisProvider =
        Provider.of<KbisProvider>(context, listen: true);

    // InfoBankProvider infoBankProvider =
    //     Provider.of<InfoBankProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "FILE_CENTER"),
        ),
      ),
      body: coverLetterProvider.isLoading ||
              cvProvider.isLoading ||
              diplomasProvider.isLoading ||
              identityDocProvider.isLoading ||
              portfolioProvider.isLoading
          //|| infoBankProvider.isLoading
          ? Center(child: circularProgress)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Personnel",
                      style: TextStyle(color: GREY_LIGHt),
                    ),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        IDENTITY_DOC_ICON,
                        getTranslate(context, "IDENTITY_DOCUMENT"),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateIdentityDoc.routeName),
                        identityDocProvider.documents.length != 0),
                    SizedBox(height: 30.0),
                    Text(
                      "Professionnel",
                      style: TextStyle(color: GREY_LIGHt),
                    ),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        CV_ICON,
                        "CV",
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateCvDoc.routeName),
                        cvProvider.documents.length != 0),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        COVER_LETTER_ICON,
                        getTranslate(context, "COVER_LETTER"),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateCoverLetterDoc.routeName),
                        coverLetterProvider.documents.length != 0),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        DIPLOMA_ICON,
                        getTranslate(context, "DIPLOMAS"),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateDiplomasDoc.routeName),
                        diplomasProvider.documents.length != 0),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        PORTFOLIO_ICON,
                        "Portfolio",
                        () => Navigator.of(context)
                            .pushNamed(AddUpdatePortfolioDoc.routeName),
                        portfolioProvider.documents.length != 0),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        PORTFOLIO_ICON,
                        getTranslate(context, "KBIS_OPTIONAL"),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateKbisDoc.routeName),
                        kbisProvider.documents.length != 0),
                  ],
                ),
              ),
            ),
    );
  }
}
