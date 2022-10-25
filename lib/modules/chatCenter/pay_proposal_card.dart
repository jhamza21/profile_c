import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/models/payment.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/stripe_service.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/invoiceInfo.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/core/services/pdf_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class PayProposalCard extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  PayProposalCard(this.message, this.userProvider);
  @override
  _PayProposalCardState createState() => _PayProposalCardState();
}

class _PayProposalCardState extends State<PayProposalCard> {
  bool _isLoading = true;
  bool _isError = false;
  bool _isAccepting = false;
  bool _isRefusing = false;
  int _nbDays;
  final _formKey = new GlobalKey<FormState>();
  GlobalKey<SfSignaturePadState> _signatureKey =
      new GlobalKey<SfSignaturePadState>();
  bool _isSigned = false;
  bool _isSignatureError = false;
  String _stripeId;
  bool _isVerified = false;
  List<Payment> _oldPayments = [];
  int _totalDays = 0;
  int _payedDays = 0;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    try {
      _stripeId = widget.userProvider.user.stripeId;
      if (_stripeId != null) {
        var res = await StripeServices.getAccount(_stripeId);
        var jsonData = json.decode(res.body);
        if (jsonData["capabilities"]["transfers"] == "active")
          _isVerified = true;
      }

      final res = await OfferService().getPayments(widget.message.devis.id);
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

  void _showRefuseProposalDialog() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "REFUSE_PAY_PROPOSAL_ALERT"),
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
            final res =
                await OfferService().refusePayProposal(widget.message.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            showSnackbar(context, getTranslate(context, "REFUSE_SUCCESS"));
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
                                    if (res.statusCode == 401)
                                      return sessionExpired(context);
                                    if (acceptProposalRes.statusCode != 200)
                                      throw "ERROR_SERVER";
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

  String getMessagetitle() {
    return "${getTranslate(context, "WANT_TO_SEND_PAY_FOR_PROJECT")} ${widget.message.offer.title}?";
  }

  String getMessageSubtitle() {
    if (widget.message.response == null)
      return "";
    else if (widget.message.response == false)
      return getTranslate(context, "PAT_PROPOSAL_REFUSED");
    else
      return getTranslate(context, "PAY_PROPOSAL_ACCEPTED");
  }

  void _showStripeAccountNotFound(bool haveAccount) {
    showBottomModal(
        context,
        null,
        haveAccount
            ? getTranslate(context, "VERIFY_STRIPE_ACCOUNT")
            : getTranslate(context, "INVIT_SUBSCRIBE_STRIPE"),
        getTranslate(context, "CLOSE"), () {
      Navigator.of(context).pop();
    }, null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                  color: BLUE_LIGHT,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Profile center",
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
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: circularProgress,
                        )
                      : _isError
                          ? Text(getTranslate(context, "ERROR_OCCURED"))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getMessagetitle(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0),
                                ),
                                Text(
                                  getMessageSubtitle(),
                                  style: TextStyle(
                                      color: GREY_LIGHt, fontSize: 12.0),
                                ),
                                widget.message.response == null
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            child: ElevatedButton.icon(
                                              onPressed: _isAccepting
                                                  ? null
                                                  : () async {
                                                      if (!_isVerified)
                                                        _showStripeAccountNotFound(
                                                            _stripeId != null);
                                                      else
                                                        await showDialog(
                                                            context: context,
                                                            builder:
                                                                (dialogContext) {
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
                                              icon: _isAccepting
                                                  ? circularProgress
                                                  : SizedBox.shrink(),
                                              label: Text(
                                                  getTranslate(context, "YES")),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: ElevatedButton.icon(
                                              onPressed: _isRefusing
                                                  ? null
                                                  : () {
                                                      _showRefuseProposalDialog();
                                                    },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        RED_DARK),
                                              ),
                                              icon: _isRefusing
                                                  ? circularProgress
                                                  : SizedBox.shrink(),
                                              label: Text(
                                                  getTranslate(context, "NO")),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
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
