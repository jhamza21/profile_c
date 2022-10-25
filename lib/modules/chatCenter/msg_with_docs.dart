import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_file_extension_logo.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class MsgWithDocs extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  final List<Document> docs;
  MsgWithDocs(this.docs, this.message, this.userProvider);

  @override
  _MsgWithDocsState createState() => _MsgWithDocsState();
}

class _MsgWithDocsState extends State<MsgWithDocs> {
  bool _isLoading = true;
  bool _error = false;
  Document _cvDoc;
  Document _coverLetterDoc;

  @override
  void initState() {
    super.initState();
    fetchDocument();
  }

  void fetchDocument() async {
    try {
      final res = await DocumentService().getDocumentById(widget.docs[0].id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _cvDoc = Document.fromJson(jsonData["data"]);
      if (widget.docs.length > 1) {
        final res = await DocumentService().getDocumentById(widget.docs[1].id);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _coverLetterDoc = Document.fromJson(jsonData["data"]);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _isLoading = false;
      });
    }
  }

  void downloadDoc(Document doc) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) await Permission.storage.request();
      String token = await SecureStorageService.readToken();
      // String path = await ExtStorage.getExternalStoragePublicDirectory(
      //     ExtStorage.DIRECTORY_DOWNLOADS);
      Directory directory = await getApplicationDocumentsDirectory();
      await FlutterDownloader.enqueue(
        url: URL_BACKEND +
            "api/document/decryptFile?file_id=" +
            doc.id.toString(),
        headers: {
          "Authorization": "Bearer $token",
        },
        // savedDir: path,
        savedDir: directory.path,
        fileName: doc.title,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
    } catch (e) {
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  String getMessageTitle(bool isMe, Message message) {
    return "${getTranslate(context, "APPLY_FOR")} ${getTranslate(context, message.offer.offerType)} : ${message.offer.title}";
  }

  @override
  Widget build(BuildContext context) {
    bool isMe =
        widget.message.sender.id == widget.userProvider.user.id ? true : false;
    return Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                  color: isMe ? Colors.transparent : BLUE_LIGHT,
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          bottomLeft: Radius.circular(15.0))
                      : BorderRadius.only(
                          topRight: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0))),
              child: Column(
                crossAxisAlignment:
                    !isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        getSenderName(widget.message.sender),
                        style: TextStyle(
                            color: GREY_LIGHt,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                      SizedBox(width: 10),
                      Text(
                        getMessageTime(widget.message, context),
                        style: TextStyle(
                            color: GREY_LIGHt,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    getMessageTitle(isMe, widget.message),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  SizedBox(height: 8.0),
                  _isLoading
                      ? circularProgress
                      : _error
                          ? Text(getTranslate(context, "ERROR_OCCURED"))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(getTranslate(context, "CV_DOC") + " :"),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 30.0,
                                          child: getLogo(_cvDoc.title),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          width: 150,
                                          child: Text(
                                            _cvDoc.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          downloadDoc(_cvDoc);
                                        },
                                        icon: Icon(
                                          Icons.download_rounded,
                                          color: GREY_LIGHt,
                                        )),
                                  ],
                                ),
                                if (_coverLetterDoc != null)
                                  Text(getTranslate(
                                          context, "COVER_LETTER_DOC") +
                                      " :"),
                                if (_coverLetterDoc != null)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 30.0,
                                            child:
                                                getLogo(_coverLetterDoc.title),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            width: 150,
                                            child: Text(
                                              _coverLetterDoc.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {
                                            downloadDoc(_coverLetterDoc);
                                          },
                                          icon: Icon(
                                            Icons.download_rounded,
                                            color: GREY_LIGHt,
                                          )),
                                    ],
                                  ),
                              ],
                            )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
