import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/utils/helpers/compare_dates.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/providers/mission_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/company_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/core/services/mission_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateOldMission extends StatefulWidget {
  static const routeName = '/addUpdateOldMission';

  final Experience mission;
  AddUpdateOldMission(this.mission);

  @override
  _AddUpdateOldMissionState createState() => _AddUpdateOldMissionState();
}

class _AddUpdateOldMissionState extends State<AddUpdateOldMission> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = false;
  String _title, _startDate, _endDate;
  bool _isCurrentlyJob = false;
  Company _selectedCompany;
  bool _isCompanyError = false;
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController endDateCtl = TextEditingController();
  TextEditingController _typeAheadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mission != null) {
      _title = widget.mission.title;
      _startDate = widget.mission.startDate;
      startDateCtl.text = _startDate;
      _endDate = widget.mission.endDate;
      _isCurrentlyJob = _endDate == null;
      endDateCtl.text = _endDate;
      _selectedCompany = widget.mission.company;
      _typeAheadController.text = widget.mission.company != null
          ? widget.mission.company.name
          : widget.mission.companyName;
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate() && !_isCompanyError) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
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
      if (isStart) {
        _startDate = new DateFormat("yyyy-MM-dd").format(d);
        startDateCtl.text = _startDate;
      } else {
        _endDate = new DateFormat("yyyy-MM-dd").format(d);
        endDateCtl.text = _endDate;
      }
    }
  }

  Widget _showDatePicker(bool isStart) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : !isStart && _startDate != null && !isDateBigger(_startDate, value)
              ? getTranslate(context, "INVALID_DATE")
              : null,
      decoration: inputTextDecoration(
          10.0,
          null,
          isStart
              ? getTranslate(context, "START_DATE")
              : getTranslate(context, "END_DATE"),
          null,
          null),
      controller: isStart ? startDateCtl : endDateCtl,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context, isStart);
      },
    );
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

  Widget _showTitleInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      maxLength: 30,
      initialValue: _title,
      keyboardType: TextInputType.text,
      decoration: inputTextDecoration(
          10.0, null, "Ex : Senior QA Test Lead", null, null),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onChanged: (value) => _title = value.trim(),
    );
  }

  Widget showCompanyInput() {
    return new TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10.0,
              null,
              getTranslate(context, "COMPANY_NAME"),
              _isCompanyError ? getTranslate(context, "FILL_IN_FIELD") : null,
              null),
        ),
        suggestionsCallback: CompanyService().getSuggetions,
        hideSuggestionsOnKeyboardHide: true,
        debounceDuration: Duration(milliseconds: 500),
        noItemsFoundBuilder: (value) {
          return Container(
            height: 50,
            child: Center(
              child: Text(
                getTranslate(context, "NO_DATA"),
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        },
        itemBuilder: (context, Company company) {
          return ListTile(
            leading: getCompanyAvatar(null, company, BLUE_LIGHT, 15),
            title: Text(company.name),
          );
        },
        validator: (value) {
          setState(() {
            if (value.isEmpty || value == null)
              _isCompanyError = true;
            else
              _isCompanyError = false;
          });
          return null;
        },
        onSuggestionSelected: (Company company) {
          _typeAheadController.text = company.name;
          _selectedCompany = company;
        });
  }

  Widget _showIscurrentlyJob() {
    return Row(
      children: [
        Checkbox(
            value: _isCurrentlyJob,
            onChanged: (value) {
              setState(() {
                _isCurrentlyJob = !_isCurrentlyJob;
              });
              _endDate = null;
              endDateCtl.text = '';
            }),
        GestureDetector(
            onTap: () {
              setState(() {
                _isCurrentlyJob = !_isCurrentlyJob;
              });
              _endDate = null;
              endDateCtl.text = '';
            },
            child: Text(getTranslate(context, "CURRENTLY_HOLD_JOB")))
      ],
    );
  }

  Widget _showSaveFormBtn(MissionProvider missionProvider) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox.shrink(),
      label: Text(
        getTranslate(context, "SAVE"),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final res = widget.mission == null
                      ? await MissionService().createMission(_title, _startDate,
                          _endDate, _selectedCompany, _typeAheadController.text)
                      : await MissionService().updateMission(
                          widget.mission.id,
                          _title,
                          _startDate,
                          _endDate,
                          _selectedCompany,
                          _typeAheadController.text);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  final jsonData = json.decode(res.body);
                  missionProvider
                      .addMission(Experience.fromJson(jsonData["data"]));
                  showSnackbar(
                      context,
                      widget.mission == null
                          ? getTranslate(context, "ADD_SUCCESS")
                          : getTranslate(context, "MODIFY_SUCCESS"));
                  Navigator.of(context).pop();
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
    MissionProvider missionProvider =
        Provider.of<MissionProvider>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslate(context, "MISSION"),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 30.0),
                  _showTitle(getTranslate(context, "MISSION_TITLE")),
                  _showTitleInput(),
                  _showTitle(getTranslate(context, "COMPANY_NAME")),
                  showCompanyInput(),
                  SizedBox(height: 20.0),
                  _showTitle(getTranslate(context, "START_DATE")),
                  _showDatePicker(true),
                  if (!_isCurrentlyJob) SizedBox(height: 20.0),
                  if (!_isCurrentlyJob)
                    _showTitle(getTranslate(context, "END_DATE")),
                  if (!_isCurrentlyJob) _showDatePicker(false),
                  SizedBox(height: 20.0),
                  _showIscurrentlyJob(),
                  SizedBox(height: 60.0),
                  _showSaveFormBtn(missionProvider)
                ],
              ),
            ),
          ),
        ));
  }
}
