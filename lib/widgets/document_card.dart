import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/providers/cover_letter_provider.dart';
import 'package:profilecenter/providers/cv_provider.dart';
import 'package:profilecenter/providers/diplomas_provider.dart';
import 'package:profilecenter/providers/identity_doc_provider.dart';
import 'package:profilecenter/providers/kbis_provider.dart';
import 'package:profilecenter/providers/portfolio_provider.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_file_extension_logo.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class DocumentCard extends StatefulWidget {
  final Document document;

  DocumentCard(this.document);
  @override
  _DocumentCardState createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _isDeleting = false;
  bool _isSwitching = false;

  void downloadDoc(Document doc) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) await Permission.storage.request();
      String token = await SecureStorageService.readToken();
      Directory directory = await getApplicationDocumentsDirectory();
      await FlutterDownloader.enqueue(
        url: URL_BACKEND + "document/decryptFile?file_id=" + doc.id.toString(),
        headers: {
          "Authorization": "Bearer $token",
        },
        savedDir: directory.path,
        //savedDir: path,
        fileName: doc.title,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
    } catch (e) {
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void _switchDocuments() async {
    try {
      setState(() {
        _isSwitching = true;
      });
      var res = await DocumentService().switchDocument();
      if (res.statusCode != 200) throw "ERROR_SERVER";
      CvProvider cvProvider = Provider.of<CvProvider>(context, listen: false);
      cvProvider.switchCvs();
      setState(() {
        _isSwitching = false;
      });
    } catch (e) {
      setState(() {
        _isSwitching = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void _showDeleteDialog(Document doc) {
    showBottomModal(
        context,
        null,
        getTranslate(context, "DELETE_DOC_NOTICE"),
        getTranslate(context, "YES"),
        () async {
          Navigator.of(context).pop();

          try {
            setState(() {
              _isDeleting = true;
            });
            var res = await DocumentService().deleteDocument(doc.id);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            if (doc.type == COVER_LETTER_DOC) {
              CoverLetterProvider coverLetterProvider =
                  Provider.of<CoverLetterProvider>(context, listen: false);
              coverLetterProvider.remove(doc);
            } else if (doc.type == CV_DOC) {
              CvProvider cvProvider =
                  Provider.of<CvProvider>(context, listen: false);
              cvProvider.remove(doc);
            } else if (doc.type == DIPLOMAS_DOC) {
              DiplomasProvider dimplomasProvider =
                  Provider.of<DiplomasProvider>(context, listen: false);
              dimplomasProvider.remove(doc);
            } else if (doc.type == IDENTITY_DOC) {
              IdentityDocProvider identityDocProvider =
                  Provider.of<IdentityDocProvider>(context, listen: false);
              identityDocProvider.remove(doc);
            } else if (doc.type == PORTFOLIO_DOC) {
              PortfolioProvider portfolioProvider =
                  Provider.of<PortfolioProvider>(context, listen: false);
              portfolioProvider.remove(doc);
            } else if (doc.type == KBIS_DOC) {
              KbisProvider kbisProvider =
                  Provider.of<KbisProvider>(context, listen: false);
              kbisProvider.remove(doc);
            }
            setState(() {
              _isDeleting = false;
            });
            showSnackbar(context, getTranslate(context, "SUCCESS_DOC_DELETE"));
          } catch (e) {
            setState(() {
              _isDeleting = false;
            });
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: BLUE_LIGHT, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 30.0,
                  child: getLogo(widget.document.title),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 175,
                      child: Text(
                        widget.document.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      getTranslate(context, "DOC_DATE") +
                          widget.document.date
                              .substring(0, 16)
                              .replaceAll("T", " "),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.document.type == CV_DOC
                    ? IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: _isSwitching
                            ? null
                            : () {
                                _switchDocuments();
                              },
                        icon: _isSwitching
                            ? circularProgress
                            : Icon(
                                widget.document.isPrimary
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: GREY_LIGHt,
                              ))
                    : SizedBox.shrink(),
                IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      downloadDoc(widget.document);
                    },
                    icon: Icon(
                      Icons.download_rounded,
                      color: GREY_LIGHt,
                    )),
                IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: _isDeleting
                        ? null
                        : () {
                            _showDeleteDialog(widget.document);
                          },
                    icon: _isDeleting
                        ? circularProgress
                        : Image.asset(
                            TRASH_ICON,
                            height: 22,
                            width: 20,
                            color: RED_DARK,
                          ))
              ],
            ),
          ],
        ));
  }
}
