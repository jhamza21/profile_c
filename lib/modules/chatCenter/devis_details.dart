import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/core/services/pdf_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class DevisDetails extends StatefulWidget {
  static const routeName = '/devisDetails';

  final DevisDetailsArguments arguments;
  DevisDetails(this.arguments);

  @override
  _DevisDetailsState createState() => _DevisDetailsState();
}

class _DevisDetailsState extends State<DevisDetails> {
  final _formKey = new GlobalKey<FormState>();
  String _token;
  bool _isLoading = true;
  bool _isAccepting = false;
  bool _isRefusing = false;
  bool _isNegociate = false;
  String _msgNegociation;
  GlobalKey<SfSignaturePadState> _signatureKey =
      new GlobalKey<SfSignaturePadState>();
  bool _isSigned = false;
  bool _isSignatureError = false;

  bool validateAndSave() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    iniializeToken();
  }

  void iniializeToken() async {
    String token = await SecureStorageService.readToken();
    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  void _showRefuseProposalDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "REFUSE_DEVIS_ALERT"),
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "YES"),
        () async {
          try {
            Navigator.of(context).pop();
            setState(() {
              _isRefusing = true;
            });
            final res = await OfferService()
                .refuseDevis(widget.arguments.devisRequestId);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            showSnackbar(context, getTranslate(context, "REFUSE_SUCCESS"));
            Navigator.of(context).pop();
            setState(() {
              _isRefusing = false;
            });
          } catch (e) {
            setState(() {
              _isRefusing = false;
            });
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        });
  }

  Widget _showNegociateDialog(dialogContext, context) {
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Center(
                  child: Text(
                getTranslate(context, "NEGOCIATION"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  maxLength: 100,
                  initialValue: _msgNegociation,
                  validator: (value) => value.isEmpty
                      ? getTranslate(context, "FILL_IN_FIELD")
                      : null,
                  keyboardType: TextInputType.text,
                  onSaved: (value) => _msgNegociation = value.trim(),
                  maxLines: 4,
                  decoration: inputTextDecoration(10.0, null,
                      getTranslate(context, "ENTER_MSG"), null, null),
                ),
              ),
            ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                      onPressed: _isNegociate
                          ? null
                          : () async {
                              if (validateAndSave()) {
                                Navigator.of(dialogContext).pop();
                                try {
                                  setState(() {
                                    _isNegociate = true;
                                  });
                                  final res = await OfferService()
                                      .negociateDevis(
                                          widget.arguments.devisRequestId,
                                          _msgNegociation);
                                  if (res.statusCode == 401)
                                    return sessionExpired(context);
                                  if (res.statusCode != 200)
                                    throw "ERROR_SERVER";
                                  showSnackbar(
                                      context,
                                      getTranslate(
                                          context, "NEGOCIATION_SENT"));
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _isNegociate = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _isNegociate = false;
                                  });
                                  showSnackbar(context,
                                      getTranslate(context, "ERROR_SERVER"));
                                }
                              }
                            },
                      child: Text(
                        getTranslate(context, "SEND"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(getTranslate(context, "CANCEL"))),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  bool _handleOnDrawStart() {
    _isSigned = true;
    return false;
  }

  Widget buildSignaturePad(set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _isSignatureError ? Colors.red : BLUE_LIGHT,
                      width: 1.5)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SfSignaturePad(
                  key: _signatureKey,
                  backgroundColor: Colors.white,
                  strokeColor: Colors.black,
                  onDrawStart: _handleOnDrawStart,
                ),
              ),
            ),
            Positioned(
                right: 5,
                top: 5,
                child: IconButton(
                  onPressed: () {
                    _signatureKey = new GlobalKey<SfSignaturePadState>();
                    set(() {
                      _isSigned = false;
                    });
                  },
                  icon: Icon(Icons.cancel),
                  color: GREY_LIGHt,
                )),
          ],
        ),
        _isSignatureError
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 10),
                child: Text(
                  getTranslate(context, "FILL_IN_FIELD"),
                  style: TextStyle(color: Colors.deepOrange[200], fontSize: 12),
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget _showCompanyInputSignatureDialog(dialogContext, context) {
    _isSigned = false;
    _isSignatureError = false;
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Center(
                  child: Text(
                getTranslate(context, "SIGNATURE"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildSignaturePad(set),
            ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                      onPressed: _isAccepting
                          ? null
                          : () async {
                              set(() {
                                _isSignatureError =
                                    _isSigned == false ? true : false;
                              });
                              if (!_isSignatureError) {
                                Navigator.of(dialogContext).pop();
                                try {
                                  setState(() {
                                    _isAccepting = true;
                                  });
                                  final image = await _signatureKey.currentState
                                      ?.toImage();
                                  final imageSignature = await image.toByteData(
                                      format: ui.ImageByteFormat.png);
                                  var res = await DocumentService()
                                      .downloadDocument(
                                          widget.arguments.devis.devisDocId);
                                  if (res.statusCode != 200)
                                    throw "ERROR_SERVER";
                                  final devisFileSignedData =
                                      await PdfService.addCompanySignature(
                                          res.bodyBytes, imageSignature);
                                  var res2 = await OfferService().acceptDevis(
                                      widget.arguments.devis,
                                      widget.arguments.devisRequestId,
                                      devisFileSignedData);
                                  if (res2.statusCode != 200)
                                    throw "ERROR_SERVER";
                                  showSnackbar(context,
                                      getTranslate(context, "DEVIS_ACCEPTED"));
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _isAccepting = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _isAccepting = false;
                                    _isSigned = false;
                                  });
                                  showSnackbar(context,
                                      getTranslate(context, "ERROR_SERVER"));
                                }
                              }
                            },
                      child: Text(
                        getTranslate(context, "SEND"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(getTranslate(context, "CANCEL"))),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void downloadDoc(int docId) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) await Permission.storage.request();
      //  String path = await ExtStorage.getExternalStoragePublicDirectory(
      //      ExtStorage.DIRECTORY_DOWNLOADS);
      Directory directory = await getApplicationDocumentsDirectory();
      await FlutterDownloader.enqueue(
        url: URL_BACKEND + "api/document/decryptFile?file_id=$docId",
        headers: {
          "Authorization": "Bearer $_token",
        },
        savedDir: directory.path,
        // savedDir: path,
        fileName: "Devis-${widget.arguments.devis.devisNumber}.pdf",
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
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "DEVIS_DETAILS")),
        actions: [
          IconButton(
              onPressed: () {
                downloadDoc(widget.arguments.devis.devisDocId);
              },
              icon: Icon(Icons.file_download))
        ],
      ),
      body: _isLoading
          ? Center(child: circularProgress)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: widget.arguments.isCompany &&
                                !widget.arguments.isAccepted
                            ? MediaQuery.of(context).size.height - 210
                            : MediaQuery.of(context).size.height - 110,
                        child: SfPdfViewer.network(
                          URL_BACKEND +
                              "api/document/decryptFile?file_id=${widget.arguments.devis.devisDocId}",
                          headers: {
                            "Authorization": "Bearer $_token",
                          },
                        )),
                    widget.arguments.isCompany && !widget.arguments.isAccepted
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                              right: 12.0,
                              top: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 35,
                                  child: ElevatedButton.icon(
                                    onPressed: _isAccepting
                                        ? null
                                        : () async {
                                            await showDialog(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return _showCompanyInputSignatureDialog(
                                                      dialogContext, context);
                                                });
                                          },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(RED_DARK),
                                    ),
                                    icon: _isAccepting
                                        ? circularProgress
                                        : SizedBox.shrink(),
                                    label:
                                        Text(getTranslate(context, "ACCEPT")),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 35,
                                        child: ElevatedButton.icon(
                                          onPressed: _isNegociate
                                              ? null
                                              : () async {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return _showNegociateDialog(
                                                            dialogContext,
                                                            context);
                                                      });
                                                },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    RED_DARK),
                                          ),
                                          icon: _isNegociate
                                              ? circularProgress
                                              : SizedBox.shrink(),
                                          label: Text(getTranslate(
                                              context, "NEGOCIATE_BTN")),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    Expanded(
                                      child: SizedBox(
                                        height: 35,
                                        child: ElevatedButton.icon(
                                          onPressed: _isRefusing
                                              ? null
                                              : () =>
                                                  _showRefuseProposalDialog(),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    RED_DARK),
                                          ),
                                          icon: _isRefusing
                                              ? circularProgress
                                              : SizedBox.shrink(),
                                          label: Text(
                                              getTranslate(context, "REFUSE")),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
    );
  }
}

class DevisDetailsArguments {
  final int devisRequestId;
  final Devis devis;
  final bool isCompany;
  final bool isAccepted;
  DevisDetailsArguments(
      this.devisRequestId, this.devis, this.isCompany, this.isAccepted);
}
