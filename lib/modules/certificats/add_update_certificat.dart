import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/models/certificat.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/providers/certificat_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/certificat_service.dart';
import 'package:profilecenter/core/services/company_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateCertificat extends StatefulWidget {
  static const routeName = '/addUpdateCertificat';
  final Certificat certificat;
  AddUpdateCertificat(this.certificat);
  @override
  _AddUpdateCertificatState createState() => _AddUpdateCertificatState();
}

class _AddUpdateCertificatState extends State<AddUpdateCertificat> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = false;
  String _title, _delivered, _validity;
  bool _isValidForever = false;
  Company _selectedCompany;
  bool _isCompanyError = false;
  TextEditingController _deliveredDateCtl = TextEditingController();
  TextEditingController _typeAheadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.certificat != null) {
      _title = widget.certificat.title;
      _delivered = widget.certificat.delivered;
      _deliveredDateCtl.text = _delivered;
      _validity = widget.certificat.validity;
      _selectedCompany = widget.certificat.company;
      _isValidForever = widget.certificat.validity == null;
      _typeAheadController.text = widget.certificat.company != null
          ? widget.certificat.company.name
          : widget.certificat.companyName;
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
      _delivered = new DateFormat("yyyy-MM-dd").format(d);
      _deliveredDateCtl.text = _delivered;
    }
  }

  Widget _showDatePicker() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: inputTextDecoration(
          10.0, null, getTranslate(context, "DELIVRANCE_DATE"), null, null),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      controller: _deliveredDateCtl,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context);
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
      decoration:
          inputTextDecoration(10.0, null, "Ex : Certificat MP2L", null, null),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onChanged: (value) => _title = value.trim(),
    );
  }

  Widget __showValidityInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      initialValue: _validity,
      keyboardType: TextInputType.number,
      decoration: inputTextDecoration(
          10.0, null, getTranslate(context, "VALIDITY"), null, null),
      validator: (value) => value.isEmpty || int.tryParse(value.trim()) == null
          ? getTranslate(context, "FILL_IN_FIELD")
          : null,
      onChanged: (value) => _validity = value.trim(),
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
        debounceDuration: Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: true,
        noItemsFoundBuilder: (value) {
          return Container(
            height: 50,
            color: BLUE_DARK_LIGHT,
            child: Center(
              child: Text(
                getTranslate(context, "NO_DATA"),
                style: TextStyle(color: Colors.grey),
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

  Widget _showIsValifForever() {
    return Row(
      children: [
        Checkbox(
            value: _isValidForever,
            onChanged: (value) {
              setState(() {
                _isValidForever = !_isValidForever;
              });
              _validity = null;
            }),
        GestureDetector(
            onTap: () {
              setState(() {
                _isValidForever = !_isValidForever;
              });
              _validity = null;
            },
            child: Text(getTranslate(context, "VALID_FOREVER")))
      ],
    );
  }

  Widget _showSaveFormBtn(CertificatProvider certificatProvider) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox.shrink(),
      label: Text(getTranslate(context, "SAVE")),
      onPressed: _isLoading
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final res = widget.certificat == null
                      ? await CertificatService().createCertificat(
                          _title,
                          _delivered,
                          _validity,
                          _selectedCompany,
                          _typeAheadController.text)
                      : await CertificatService().updateCertificat(
                          widget.certificat.id,
                          _title,
                          _delivered,
                          _validity,
                          _selectedCompany,
                          _typeAheadController.text);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  final jsonData = json.decode(res.body);
                  certificatProvider
                      .addCertificat(Certificat.fromJson(jsonData["data"]));
                  showSnackbar(
                      context,
                      widget.certificat == null
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
    var certificatProvider =
        Provider.of<CertificatProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "CERTIFICATS")),
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
                _showTitle(getTranslate(context, "CERTIFICAT_TITLE")),
                _showTitleInput(),
                _showTitle(getTranslate(context, "COMPANY_NAME")),
                showCompanyInput(),
                SizedBox(height: 20.0),
                _showTitle(getTranslate(context, "DELIVRANCE_DATE")),
                _showDatePicker(),
                if (!_isValidForever) SizedBox(height: 20.0),
                if (!_isValidForever)
                  _showTitle(getTranslate(context, "VALIDITY")),
                if (!_isValidForever) __showValidityInput(),
                SizedBox(height: 20.0),
                _showIsValifForever(),
                SizedBox(height: 60.0),
                _showSaveFormBtn(certificatProvider)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
