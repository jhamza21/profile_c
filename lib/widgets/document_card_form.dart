import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_file_extension_logo.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class DocumentCardForm extends StatefulWidget {
  final Document document;
  final void Function() delete;

  DocumentCardForm(this.document, this.delete);
  @override
  _DocumentCardFormState createState() => _DocumentCardFormState();
}

class _DocumentCardFormState extends State<DocumentCardForm> {
  bool _isDeleting = false;

  void downloadDoc(Document doc) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) await Permission.storage.request();
      String token = await SecureStorageService.readToken();
      // String path = await ExtStorage.getExternalStoragePublicDirectory(
      //     ExtStorage.DIRECTORY_DOWNLOADS);
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
                widget.document.id != null
                    ? IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          downloadDoc(widget.document);
                        },
                        icon: Icon(
                          Icons.download_rounded,
                          color: GREY_LIGHt,
                        ))
                    : SizedBox.shrink(),
                IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: _isDeleting
                        ? null
                        : () {
                            widget.delete();
                          },
                    icon: _isDeleting
                        ? circularProgress
                        : Image.asset(
                            TRASH_ICON,
                            width: 20,
                            color: RED_DARK,
                          ))
              ],
            ),
          ],
        ));
  }
}
