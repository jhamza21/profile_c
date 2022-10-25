import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/cover_letter_provider.dart';
import 'package:profilecenter/modules/documents/add_document.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/document_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class AddUpdateCoverLetterDoc extends StatefulWidget {
  static const routeName = '/addUpdateCoverLetterDoc';

  @override
  _AddUpdateCoverLetterDocState createState() =>
      _AddUpdateCoverLetterDocState();
}

class _AddUpdateCoverLetterDocState extends State<AddUpdateCoverLetterDoc> {
  static const MAX_DOCS = 2;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  void fetchDocuments() async {
    CoverLetterProvider coverLetterProvider =
        Provider.of<CoverLetterProvider>(context, listen: false);
    coverLetterProvider.fetchDocuments(context);
  }

  Widget buildDocumentsShow(CoverLetterProvider coverLetterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
            itemCount: coverLetterProvider.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return DocumentCard(coverLetterProvider.documents[index]);
            }),
        coverLetterProvider.documents.length < MAX_DOCS
            ? TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AddDocument.routeName,
                      arguments: AddDocumentArguments(
                          getTranslate(context, "COVER_LETTER"),
                          COVER_LETTER_DOC,
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
    CoverLetterProvider coverLetterProvider =
        Provider.of<CoverLetterProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "COVER_LETTER"),
        ),
      ),
      body: coverLetterProvider.isLoading
          ? Center(child: circularProgress)
          : coverLetterProvider.isError
              ? ErrorScreen()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.0,
                      ),
                      buildDocumentsShow(coverLetterProvider),
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
