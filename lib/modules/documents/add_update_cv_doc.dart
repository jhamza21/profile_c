import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/providers/cv_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/modules/documents/add_document.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/document_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class AddUpdateCvDoc extends StatefulWidget {
  static const routeName = '/addUpdateCvDoc';

  @override
  _AddUpdateCvDocState createState() => _AddUpdateCvDocState();
}

class _AddUpdateCvDocState extends State<AddUpdateCvDoc> {
  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  void fetchDocuments() async {
    CvProvider cvProvider = Provider.of<CvProvider>(context, listen: false);
    cvProvider.fetchDocuments(context);
  }

  Widget buildPrimaryCvCard(CvProvider cvProvider) {
    Document primaryCv = cvProvider.getPrimary();
    return primaryCv == null
        ? TextButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AddDocument.routeName,
                  arguments: AddDocumentArguments(
                      getTranslate(context, "CV_PRINCIPAL"),
                      CV_DOC,
                      true,
                      DOCS_FILE_EXTENSION));
            },
            icon: Icon(
              Icons.add_circle_rounded,
              color: RED_DARK,
              size: 20,
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            label: Text(
              getTranslate(context, "ADD_DOC"),
              style: TextStyle(color: GREY_LIGHt),
            ))
        : DocumentCard(primaryCv);
  }

  Widget buildSecondaryCvCard(CvProvider cvProvider) {
    Document secondaryCv = cvProvider.getSecondary();
    return secondaryCv == null
        ? TextButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AddDocument.routeName,
                  arguments: AddDocumentArguments(
                      getTranslate(context, "CV_SECONDARY"),
                      CV_DOC,
                      false,
                      DOCS_FILE_EXTENSION));
            },
            icon: Icon(
              Icons.add_circle_rounded,
              color: RED_DARK,
              size: 20,
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            label: Text(
              getTranslate(context, "ADD_DOC"),
              style: TextStyle(color: GREY_LIGHt),
            ))
        : DocumentCard(secondaryCv);
  }

  @override
  Widget build(BuildContext context) {
    CvProvider cvProvider = Provider.of<CvProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "CV"),
        ),
      ),
      body: cvProvider.isLoading
          ? Center(child: circularProgress)
          : cvProvider.isError
              ? ErrorScreen()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60.0),
                      Text(
                        getTranslate(context, "CV_PRINCIPAL"),
                        style: TextStyle(
                            color: GREY_LIGHt, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.0),
                      buildPrimaryCvCard(cvProvider),
                      SizedBox(height: 80.0),
                      Text(
                        getTranslate(context, "CV_SECONDARY"),
                        style: TextStyle(
                            color: GREY_LIGHt, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.0),
                      buildSecondaryCvCard(cvProvider),
                      Spacer(),
                      Divider(
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslate(context, "ALLOWED_DOCS") + "2",
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
