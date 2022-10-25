import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/kbis_provider.dart';
import 'package:profilecenter/providers/portfolio_provider.dart';
import 'package:profilecenter/modules/documents/add_document.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/document_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class AddUpdateKbisDoc extends StatefulWidget {
  static const routeName = '/addUpdateKbisDoc';

  @override
  _AddUpdateKbisDocState createState() => _AddUpdateKbisDocState();
}

class _AddUpdateKbisDocState extends State<AddUpdateKbisDoc> {
  static const MAX_DOCS = 1;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  void fetchDocuments() async {
    PortfolioProvider portfolioProvider =
        Provider.of<PortfolioProvider>(context, listen: false);
    portfolioProvider.fetchDocuments(context);
  }

  Widget buildDocumentsShow(KbisProvider kbisProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
            itemCount: kbisProvider.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return DocumentCard(kbisProvider.documents[index]);
            }),
        kbisProvider.documents.length < MAX_DOCS
            ? TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AddDocument.routeName,
                      arguments: AddDocumentArguments(
                          "KBIS", KBIS_DOC, false, DOCS_FILE_EXTENSION));
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent)),
                label: Text(
                  getTranslate(context, "ADD_DOC"),
                ))
            : SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    KbisProvider kbisProvider =
        Provider.of<KbisProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "KBIS",
        ),
        elevation: 0,
      ),
      body: kbisProvider.isLoading
          ? Center(child: circularProgress)
          : kbisProvider.isError
              ? ErrorScreen()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.0,
                      ),
                      buildDocumentsShow(kbisProvider),
                      Spacer(),
                      Divider(
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslate(context, "ALLOWED_DOCS") +
                                MAX_DOCS.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(getTranslate(context, "ALLOWED_DOCS_SIZE") + "5",
                              style: TextStyle(color: Colors.white))
                        ],
                      )
                    ],
                  ),
                ),
    );
  }
}
