import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/identity_doc_provider.dart';
import 'package:profilecenter/modules/documents/add_document.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/document_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class AddUpdateIdentityDoc extends StatefulWidget {
  static const routeName = '/addUpdateIdentityDoc';

  @override
  _AddUpdateIdentityDocState createState() => _AddUpdateIdentityDocState();
}

class _AddUpdateIdentityDocState extends State<AddUpdateIdentityDoc> {
  static const MAX_DOCS = 1;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  void fetchDocuments() async {
    IdentityDocProvider identityDocProvider =
        Provider.of<IdentityDocProvider>(context, listen: false);
    identityDocProvider.fetchDocuments(context);
  }

  Widget buildDocumentsShow(IdentityDocProvider identityDocProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
            itemCount: identityDocProvider.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return DocumentCard(identityDocProvider.documents[index]);
            }),
        identityDocProvider.documents.length < MAX_DOCS
            ? TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AddDocument.routeName,
                      arguments: AddDocumentArguments(
                          getTranslate(context, "IDENTITY_DOCUMENT"),
                          IDENTITY_DOC,
                          false,
                          DOCS_FILE_EXTENSION));
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
    IdentityDocProvider identityDocProvider =
        Provider.of<IdentityDocProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "IDENTITY_DOCUMENT"),
        ),
      ),
      body: identityDocProvider.isLoading
          ? Center(child: circularProgress)
          : identityDocProvider.isError
              ? ErrorScreen()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.0,
                      ),
                      buildDocumentsShow(identityDocProvider),
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
