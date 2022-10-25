import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/models/payment.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/invoice.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/core/services/pdf_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class InvoiceDetails extends StatefulWidget {
  static const routeName = '/invoiceDetails';

  final InvoiceDetailsArguments arguments;
  InvoiceDetails(this.arguments);

  @override
  _InvoiceDetailsState createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
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

  List<Payment> _oldPayments = [];

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
    fetchPaiementsHistoric();
  }

  void iniializeToken() async {
    _token = await SecureStorageService.readToken();
  }

  void fetchPaiementsHistoric() async {
    try {
      final res =
          await OfferService().getPayments(widget.arguments.invoice.devisId);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _oldPayments = Payment.listFromJson(jsonData["data"]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRefuseProposalDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "REFUSE_PAY_REQUEST_ALERT"),
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
                .refusePayRequest(widget.arguments.payRequestId);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            showSnackbar(context, getTranslate(context, "REFUSE_SUCCESS"));
            Navigator.of(context).pop();
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
        contentPadding: EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      .negociatePayRequest(
                                          widget.arguments.payRequestId,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      .downloadDocument(widget
                                          .arguments.invoice.invoiceDocId);
                                  if (res.statusCode == 401)
                                    return sessionExpired(context);
                                  if (res.statusCode != 200)
                                    throw "ERROR_SERVER";
                                  final invoiceFileSignedData =
                                      await PdfService.addCompanySignature(
                                          res.bodyBytes, imageSignature);
                                  var res2 = await OfferService()
                                      .acceptPayRequest(
                                          widget.arguments.invoice,
                                          widget.arguments.payRequestId,
                                          invoiceFileSignedData);
                                  if (res.statusCode == 401)
                                    return sessionExpired(context);
                                  if (res2.statusCode != 200)
                                    throw "ERROR_SERVER";
                                  final jsonData = json.decode(
                                      await res2.stream.bytesToString());
                                  if (jsonData["message"] == "success") {
                                    showSnackbar(
                                        context,
                                        getTranslate(
                                            context, "PAY_REQUEST_ACCEPTED"));
                                    Navigator.of(context).pop();
                                  } else
                                    showSnackbar(context, jsonData["message"]);

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
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40.0,
                        decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getTranslate(context, "SEND"),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
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
      // String path = await ExtStorage.getExternalStoragePublicDirectory(
      //     ExtStorage.DIRECTORY_DOWNLOADS);
      Directory directory = await getApplicationDocumentsDirectory();
      await FlutterDownloader.enqueue(
        url: URL_BACKEND + "api/document/decryptFile?file_id=$docId",
        headers: {
          "Authorization": "Bearer $_token",
        },
        savedDir: directory.path,
        // savedDir: path,
        fileName: "Devis-${widget.arguments.invoice.invoiceNumber}.pdf",
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
        title: Text(getTranslate(context, "INVOICE_DETAILS")),
        actions: [
          IconButton(
              onPressed: () {
                downloadDoc(widget.arguments.invoice.invoiceDocId);
              },
              icon: Icon(Icons.file_download))
        ],
      ),
      body: _isLoading
          ? Center(
              child: circularProgress,
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      getTranslate(context, "HISTORIC"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    if (_oldPayments.length == 0)
                      Text(getTranslate(context, "NO_DATA")),
                    ..._oldPayments.map((e) => Row(
                          children: [
                            Text("${e.date} à ${e.time} : "),
                            SizedBox(width: 5.0),
                            Text(
                              "${e.amount}€",
                              style: TextStyle(
                                  color: GREEN_LIGHT,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                    SizedBox(height: 20.0),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: widget.arguments.isCompany &&
                                !widget.arguments.isAccepted
                            ? MediaQuery.of(context).size.height - 210
                            : MediaQuery.of(context).size.height - 110,
                        child: SfPdfViewer.network(
                          URL_BACKEND +
                              "api/document/decryptFile?file_id=${widget.arguments.invoice.invoiceDocId}",
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
                                        Text(getTranslate(context, "PAY_BTN")),
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

class InvoiceDetailsArguments {
  final int payRequestId;
  final Invoice invoice;
  final bool isCompany;
  final bool isAccepted;
  InvoiceDetailsArguments(
      this.payRequestId, this.invoice, this.isCompany, this.isAccepted);
}
