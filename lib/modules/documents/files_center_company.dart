import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/company_data_provider.dart';
import 'package:profilecenter/providers/identity_doc_provider.dart';
import 'package:profilecenter/providers/mention_legal_data_provider.dart';
import 'package:profilecenter/modules/documents/add_update_company_data.dart';
import 'package:profilecenter/modules/documents/add_update_identity_doc.dart';
import 'package:profilecenter/modules/documents/add_update_legal_mention.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/file_center_item.dart';
import 'package:provider/provider.dart';

class FilesCenterCompany extends StatefulWidget {
  static const routeName = '/filesCenterCompany';

  @override
  _FilesCenterCompanyState createState() => _FilesCenterCompanyState();
}

class _FilesCenterCompanyState extends State<FilesCenterCompany> {
  @override
  void initState() {
    super.initState();
    IdentityDocProvider identityDocProvider =
        Provider.of<IdentityDocProvider>(context, listen: false);
    identityDocProvider.fetchDocuments(context);
    // InfoBankProvider infoBankProvider =
    //     Provider.of<InfoBankProvider>(context, listen: false);
    // infoBankProvider.fetchInfoBank(context);
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: false);
    mentionLegalDataProvider.fetchLegalMention(context);
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: false);
    companyDataProvider.fetchCompanyCoord(context);
  }

  @override
  Widget build(BuildContext context) {
    IdentityDocProvider identityDocProvider =
        Provider.of<IdentityDocProvider>(context, listen: true);
    // InfoBankProvider infoBankProvider =
    //     Provider.of<InfoBankProvider>(context, listen: true);
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: true);
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        getTranslate(context, "FILE_CENTER"),
      )),
      body: identityDocProvider.isLoading ||
              //  infoBankProvider.isLoading ||
              mentionLegalDataProvider.isLoading ||
              companyDataProvider.isLoading
          ? Center(child: circularProgress)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        IDENTITY_DOC_ICON,
                        getTranslate(context, "IDENTITY_DOCUMENT"),
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateIdentityDoc.routeName),
                        identityDocProvider.documents.length != 0),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        LEGAL_MENTION_ICON,
                        "Mentions légales",
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateLegalMention.routeName),
                        mentionLegalDataProvider.mentionLegalData != null),
                    SizedBox(height: 10.0),
                    FileCenterItem(
                        COMPANY_DATA_ICON,
                        "Données de l'entreprise",
                        () => Navigator.of(context)
                            .pushNamed(AddUpdateCompanyData.routeName),
                        companyDataProvider.companyData != null),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
    );
  }
}
