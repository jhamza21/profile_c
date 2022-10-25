import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/payment.dart';
import 'package:profilecenter/utils/helpers/get_sender_name.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/invoiceInfo.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/core/services/pdf_service.dart';
import 'package:profilecenter/modules/chatCenter/invoice_details.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class PayResponse extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  PayResponse(this.message, this.userProvider);
  @override
  _PayResponseState createState() => _PayResponseState();
}

class _PayResponseState extends State<PayResponse> {
  bool _isAccepting = false;
  bool _isLoading = true;
  bool _isError = false;
  final _formKey = new GlobalKey<FormState>();
  GlobalKey<SfSignaturePadState> _signatureKey =
      new GlobalKey<SfSignaturePadState>();
  List<Payment> _oldPayments = [];
  int _totalDays = 0;
  int _payedDays = 0;
  bool _isSigned = false;
  bool _isSignatureError = false;
  int _nbDays;

  @override
  void initState() {
    super.initState();
    fetchPaiementsHistoric();
  }

  void fetchPaiementsHistoric() async {
    try {
      final res = await OfferService().getPayments(widget.message.devis.id);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _oldPayments = Payment.listFromJson(jsonData["data"]);
      _oldPayments.forEach((element) {
        _payedDays += element.nbDays;
      });
      _totalDays = widget.message.devis.projectPeriod *
          widget.message.devis.workDaysPerMonth;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;

    if (form.validate() && !_isSignatureError) {
      form.save();
      return true;
    }
    return false;
  }

  String getMessagetitle(bool isMe) {
    return "${getTranslate(context, "PAY_REQUEST_FOR_PROJECT")} : ${widget.message.offer.title}";
  }

  String getMessagetitle1(bool isMe) {
    return "${getTranslate(context, "INVOICE_NUMBER")} : ${widget.message.invoice.invoiceNumber}";
  }

  String getMessageSubtitle(bool isMe) {
    if (!isMe) {
      if (widget.message.response == true)
        return getTranslate(context, "PAY_REQUEST_ACCEPTED");
      else if (widget.message.response == false && widget.message.text != '')
        return getTranslate(context, "PAY_NEGOCIATION_RECEIVED");
      else if (widget.message.response == false)
        return getTranslate(context, "PAY_REQUEST_REFUSED");
      else
        return getTranslate(context, "NEW_PAY_REQUEST_SENT");
    } else {
      if (widget.message.response == true)
        return getTranslate(context, "PAY_REQUEST_ACCEPTED");
      else if (widget.message.response == false && widget.message.text != '')
        return getTranslate(context, "PAY_NEGOCIATION_SENT");
      else if (widget.message.response == false)
        return getTranslate(context, "PAY_REQUEST_REFUSED");
      else
        return getTranslate(context, "NEW_PAY_REQUEST_RECEIVED");
    }
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

  Widget _showPayRequestDialog(dialogContext, context) {
    _isSigned = false;
    _isSignatureError = false;
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 40.0,
                decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                child: Center(
                    child: Text(
                  getTranslate(context, "PAY_REQUEST"),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '- ${getTranslate(context, "TOTAL_PROJECT_DAYS")} :',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          Text('$_totalDays ${getTranslate(context, "DAYS")}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('- ${getTranslate(context, "DAYS_PAYED")} :',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          Text('$_payedDays ${getTranslate(context, "DAYS")}',
                              style: TextStyle(
                                  color: GREEN_LIGHT,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '- ${getTranslate(context, "DAYS_TO_BE_PAYED")} :',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          Text(
                              '${_totalDays - _payedDays} ${getTranslate(context, "DAYS")}',
                              style: TextStyle(
                                  color: RED_DARK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) => value.isEmpty ||
                                int.tryParse(value.trim()) == null
                            ? getTranslate(context, "FILL_IN_FIELD")
                            : int.parse(value.trim()) > _totalDays - _payedDays
                                ? "${getTranslate(context, "DAYS_TO_BE_PAYED")} : ${_totalDays - _payedDays} ${getTranslate(context, "DAYS")}"
                                : null,
                        onSaved: (value) => _nbDays = int.parse(value.trim()),
                        decoration: inputTextDecoration(
                            10.0,
                            null,
                            getTranslate(context, "ENTER_DAYS_NUMBER"),
                            null,
                            null),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "${getTranslate(context, "SIGNATURE")} :",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 10.0),
                      buildSignaturePad(set),
                    ],
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
                        onPressed: _isAccepting
                            ? null
                            : () async {
                                set(() {
                                  _isSignatureError =
                                      _isSigned == false ? true : false;
                                });
                                if (validateAndSave()) {
                                  Navigator.of(dialogContext).pop();
                                  //get signature
                                  final image = await _signatureKey.currentState
                                      ?.toImage();
                                  try {
                                    setState(() {
                                      _isAccepting = true;
                                    });
                                    //get devis info
                                    var res = await OfferService()
                                        .getInvoiceData(
                                            widget.message.devis.id);
                                    if (res.statusCode == 401)
                                      return sessionExpired(context);
                                    if (res.statusCode != 200)
                                      throw "ERROR_SERVER";
                                    var jsonData = json.decode(res.body);
                                    InvoiceInfo invoiceinfo =
                                        InvoiceInfo.fromJson(jsonData);
                                    final imageSignature =
                                        await image.toByteData(
                                            format: ui.ImageByteFormat.png);
                                    //genererate pdf
                                    String _today = DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now());
                                    final invoiceFileData =
                                        await PdfService.generateFacture(
                                      imageSignature,
                                      invoiceinfo,
                                      _nbDays,
                                      _today,
                                    );
                                    final acceptProposalRes =
                                        await OfferService().acceptPayProposal(
                                            widget.message.id,
                                            invoiceinfo.invoiceNumber,
                                            _today,
                                            _nbDays,
                                            invoiceFileData);
                                    if (acceptProposalRes.statusCode != 200)
                                      throw "ERROR_SERVER";
                                    if (res.statusCode == 401)
                                      return sessionExpired(context);
                                    showSnackbar(
                                        context,
                                        getTranslate(
                                            context, "PAY_REQUEST_SENT"));
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isAccepting = false;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _isAccepting = false;
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
        ),
      );
    });
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
                  _isLoading
                      ? circularProgress
                      : _isError
                          ? Text(getTranslate(context, "ERROR_OCCURED"))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  getMessagetitle1(isMe),
                                  style: TextStyle(
                                      color: BLUE_SKY,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  getMessagetitle(isMe),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0),
                                ),
                                SizedBox(height: 10.0),
                                widget.message.response == true
                                    ? SizedBox(
                                        height: 30,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                                InvoiceDetails.routeName,
                                                arguments:
                                                    InvoiceDetailsArguments(
                                                        null,
                                                        widget.message.invoice,
                                                        false,
                                                        false));
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    RED_DARK),
                                          ),
                                          child: Text(getTranslate(
                                              context, "CONSULT_INVOICE")),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(height: 10.0),
                                Text(
                                  getMessageSubtitle(isMe),
                                  style: TextStyle(
                                      color: GREY_LIGHt, fontSize: 12.0),
                                ),
                                SizedBox(height: 10.0),
                                widget.message.text != ''
                                    ? Text(
                                        widget.message.text,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0),
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(height: 10.0),
                                !isMe &&
                                        widget.message.response == false &&
                                        widget.message.text != ''
                                    ? SizedBox(
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          icon: _isAccepting
                                              ? circularProgress
                                              : SizedBox.shrink(),
                                          onPressed: _isAccepting
                                              ? null
                                              : () async {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return _showPayRequestDialog(
                                                            dialogContext,
                                                            context);
                                                      });
                                                },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    RED_DARK),
                                          ),
                                          label: Text(getTranslate(
                                              context, "REQUEST_AGAIN")),
                                        ),
                                      )
                                    : SizedBox.shrink()
                              ],
                            ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
