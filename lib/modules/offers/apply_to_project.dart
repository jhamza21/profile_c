import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/devise.dart';
import 'package:profilecenter/models/invoiceInfo.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/core/services/pdf_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ApplyToProject extends StatefulWidget {
  static const routeName = '/applyToProject';
  final ApplyToProjectArguments arguments;
  ApplyToProject(this.arguments);
  @override
  _ApplyToProjectState createState() => _ApplyToProjectState();
}

class _ApplyToProjectState extends State<ApplyToProject> {
  final _formKey = new GlobalKey<FormState>();
  GlobalKey<SfSignaturePadState> _signatureKey =
      new GlobalKey<SfSignaturePadState>();
  bool _isSigned = false;
  bool _isSignatureError = false;

  bool _isLoading = false;
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController endDateCtl = TextEditingController();
  String _startDate, _endDate, _description;
  double _tjm;
  int _nbDailyMeetingsPerWeek, _teleworkDays, _workDaysPerMonth, _projectPeriod;
  bool _forfaitType;
  bool _isForfaitTypeError = false;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    Devis _devis = widget.arguments.devis;
    if (_devis != null) {
      _description = _devis.description;
      _startDate = _devis.startDate;
      startDateCtl.text = _startDate;
      _endDate = _devis.endDate;
      endDateCtl.text = _endDate;
      _tjm = _devis.tjm;
      _projectPeriod = _devis.projectPeriod;
      _nbDailyMeetingsPerWeek = _devis.meetingDays;
      _teleworkDays = _devis.teleworkDays;
      _workDaysPerMonth = _devis.workDaysPerMonth;
      _forfaitType = _devis.forfaitType;
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    setState(() {
      _isSignatureError = _isSigned == false ? true : false;
      _isForfaitTypeError = _forfaitType == null ? true : false;
    });
    if (form.validate() && !_isForfaitTypeError && !_isSignatureError) {
      form.save();
      return true;
    }
    return false;
  }

  Widget _showTitle(text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 10),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildDescriptionInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      initialValue: _description,
      maxLength: 100,
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      keyboardType: TextInputType.text,
      onSaved: (value) => _description = value.trim(),
      maxLines: 4,
      decoration: inputTextDecoration(10.0, null,
          getTranslate(context, "YOUR_JOB_DESCRIPTION"), null, null),
    );
  }

  Widget buildSalryInput(previousSalary, Devise devise) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      initialValue: _tjm != null
          ? _tjm.toString()
          : previousSalary == 0
              ? null
              : previousSalary.toString(),
      keyboardType: TextInputType.number,
      decoration: inputTextDecoration(
          10.0,
          null,
          getTranslate(context, "TJM"),
          null,
          Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 7),
              child: Text("${devise.name}/${getTranslate(context, "DAY")}  "))),
      validator: (value) =>
          value.isEmpty || double.tryParse(value.trim()) == null
              ? getTranslate(context, "FILL_IN_FIELD")
              : null,
      onSaved: (value) => _tjm = double.parse(value.trim()),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: RED_DARK,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: RED_DARK)
                .copyWith(secondary: RED_DARK),
          ),
          child: child,
        );
      },
    );
    if (d != null) {
      _startDate = new DateFormat("yyyy-MM-dd").format(d);
      startDateCtl.text = _startDate;
      if (_projectPeriod != null) {
        _endDate = new DateFormat("yyyy-MM-dd")
            .format(d.add(Duration(days: _projectPeriod * 31)));
        endDateCtl.text = _endDate;
      }
    }
  }

  Widget _showStartDatePicker() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0,
          null,
          getTranslate(context, "MISSION_START_DATE"),
          null,
          Icon(Icons.calendar_today, color: Colors.white)),
      controller: startDateCtl,
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context);
      },
    );
  }

  Widget _showEndDatePicker() {
    return TextFormField(
      readOnly: true,
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0, null, getTranslate(context, "MISSION_END_DATE"), null, null),
      controller: endDateCtl,
    );
  }

  Widget buildProjectperiodInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0,
          null,
          getTranslate(context, "PROJECT_PERIOD"),
          null,
          Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Text(
                  _forfaitType == true ? '' : getTranslate(context, "MONTH")))),
      initialValue: _projectPeriod != null ? "$_projectPeriod" : null,
      keyboardType: TextInputType.number,
      validator: (value) => value.isEmpty || int.tryParse(value.trim()) == null
          ? getTranslate(context, "FILL_IN_FIELD")
          : null,
      onChanged: (value) {
        if (value.isEmpty) {
          _projectPeriod = null;
          _endDate = null;
          endDateCtl.text = '';
        } else {
          _projectPeriod = int.parse(value);
          if (_startDate != null) {
            _endDate = new DateFormat("yyyy-MM-dd").format(
                DateTime.parse(_startDate)
                    .add(Duration(days: _projectPeriod * 31)));
            endDateCtl.text = _endDate;
          }
        }
      },
    );
  }

  Widget buildWorkDaysPerMonthInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0,
          null,
          getTranslate(context, "WORK_DAYS_PER_MONTH"),
          null,
          Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Text(getTranslate(context, "DAY_PER_MONTH")))),
      initialValue: _workDaysPerMonth != null ? "$_workDaysPerMonth" : null,
      keyboardType: TextInputType.number,
      validator: (value) => value.isEmpty || int.tryParse(value.trim()) == null
          ? getTranslate(context, "FILL_IN_FIELD")
          : int.parse(value) > 31 || int.parse(value) < 1
              ? getTranslate(context, "DAYS_PER_MONTH_NOTICE")
              : null,
      onSaved: (value) => _workDaysPerMonth = int.parse(value),
    );
  }

  Widget buildTeleWorkInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0, null, getTranslate(context, "TELEWORK_DAYS"), null, null),
      initialValue: _teleworkDays != null ? "$_teleworkDays" : null,
      keyboardType: TextInputType.number,
      validator: (value) => value.isEmpty || int.tryParse(value.trim()) == null
          ? getTranslate(context, "FILL_IN_FIELD")
          : int.parse(value) > 5 || int.parse(value) < 0
              ? getTranslate(context, "DAYS_PER_WEEK_NOTICE")
              : null,
      onSaved: (value) => _teleworkDays = int.parse(value),
    );
  }

  Widget buildDailyMeetingInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0,
          null,
          getTranslate(context, "MEETING_PER_WEEK"),
          null,
          Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Text(getTranslate(context, "TIMES_PER_WEEK")))),
      initialValue:
          _nbDailyMeetingsPerWeek != null ? "$_nbDailyMeetingsPerWeek" : null,
      keyboardType: TextInputType.number,
      validator: (value) => value.isEmpty || int.tryParse(value.trim()) == null
          ? getTranslate(context, "FILL_IN_FIELD")
          : int.parse(value) > 5 || int.parse(value) < 0
              ? getTranslate(context, "DAYS_PER_WEEK_NOTICE")
              : null,
      onSaved: (value) => _nbDailyMeetingsPerWeek = int.parse(value),
    );
  }

  Widget buildForfaitTypeInput() {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: inputTextDecoration(
            10.0,
            null,
            null,
            _isForfaitTypeError ? getTranslate(context, "FILL_IN_FIELD") : null,
            null),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<bool>(
            hint: Text(getTranslate(context, "MISSION_FORFAIT")),
            dropdownColor: BLUE_LIGHT,
            icon: Icon(
              Icons.arrow_drop_down_sharp,
              color: Colors.white,
            ),
            isDense: true,
            value: _forfaitType,
            onChanged: (bool value) async {
              setState(() {
                _forfaitType = value;
              });
              if (_forfaitType == true) {
                _forfaitType = value;
                _projectPeriod = 1;
              } else {
                _forfaitType = value;
              }
            },
            items: [true, false].map((bool value) {
              return DropdownMenuItem<bool>(
                value: value,
                child: Text(
                  value
                      ? getTranslate(context, "YES") +
                          " ( < 1  " +
                          getTranslate(context, "MOIS")
                      : getTranslate(context, "NO"),
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  bool _handleOnDrawStart() {
    _isSigned = true;
    return false;
  }

  Widget buildSignaturePad() {
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
                    setState(() {
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

  Widget buildApplyBtn(UserProvider userProvider) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, "SEND"),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  //get devis info
                  var res = await OfferService()
                      .getDevisData(widget.arguments.offer.id);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  var jsonData = json.decode(res.body);
                  InvoiceInfo invoiceinfo = InvoiceInfo.fromJson(jsonData);
                  //get signature
                  final image = await _signatureKey.currentState?.toImage();
                  final imageSignature =
                      await image.toByteData(format: ui.ImageByteFormat.png);
                  //genererate pdf
                  String _today =
                      DateFormat('yyyy/MM/dd').format(DateTime.now());
                  final devisFileData = await PdfService.generateDevis(
                      imageSignature,
                      invoiceinfo,
                      _today,
                      _description,
                      _tjm * userProvider.user.devise.rapport,
                      _projectPeriod,
                      _workDaysPerMonth,
                      _nbDailyMeetingsPerWeek,
                      _teleworkDays,
                      _startDate);
                  var res2 = await OfferService().sendDevis(
                      invoiceinfo.invoiceNumber,
                      devisFileData,
                      widget.arguments.offer.id,
                      invoiceinfo.tva,
                      _description,
                      _today,
                      _startDate,
                      _endDate,
                      _tjm * userProvider.user.devise.rapport,
                      invoiceinfo.commissionPc,
                      _projectPeriod,
                      _nbDailyMeetingsPerWeek,
                      _teleworkDays,
                      _workDaysPerMonth,
                      _forfaitType,
                      widget.arguments.propositionMsgId);
                  if (res2.statusCode != 200) throw "ERROR_SERVER";
                  Navigator.of(context).pop();
                  showSnackbar(context, getTranslate(context, "DEVIS_SENT"));
                  widget.arguments.onCallback();
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                }
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "DEVIS_PROPOSITION")),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "YOUR_JOB_DESCRIPTION")),
                buildDescriptionInput(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "TJM")),
                buildSalryInput(
                    userProvider.user.salary, userProvider.user.devise),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "MISSION_FORFAIT")),
                buildForfaitTypeInput(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "MISSION_START_DATE")),
                _showStartDatePicker(),
                SizedBox(height: 20.0),
                _forfaitType == true
                    ? SizedBox.shrink()
                    : _showTitle(getTranslate(context, "PROJECT_PERIOD")),

                _forfaitType == true
                    ? SizedBox.shrink()
                    : buildProjectperiodInput(),

                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "MISSION_END_DATE")),
                _showEndDatePicker(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "WORK_DAYS_PER_MONTH")),
                buildWorkDaysPerMonthInput(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "TELEWORK_DAYS")),
                buildTeleWorkInput(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "MEETING_PER_WEEK")),
                buildDailyMeetingInput(),
                // SizedBox(height: 20.0),
                // _showTitle(getTranslate(context, "MISSION_FORFAIT")),
                // buildForfaitTypeInput(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "SIGNATURE")),
                buildSignaturePad(),
                SizedBox(height: 20.0),
                buildApplyBtn(userProvider)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApplyToProjectArguments {
  final Offer offer;
  final int propositionMsgId;
  final Devis devis;
  final Function() onCallback;

  ApplyToProjectArguments(
      this.offer, this.propositionMsgId, this.devis, this.onCallback);
}
