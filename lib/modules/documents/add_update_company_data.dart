import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/companyData.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/providers/company_data_provider.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/document_card_form.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class AddUpdateCompanyData extends StatefulWidget {
  static const routeName = '/addUpdateCompanyData';

  @override
  _AddUpdateCompanyDataState createState() => _AddUpdateCompanyDataState();
}

class _AddUpdateCompanyDataState extends State<AddUpdateCompanyData> {
  final _formKey = new GlobalKey<FormState>();
  bool _isSaving = false;

  Document _kbisDocument;
  bool _kbisDocError = false;

  String _companyName,
      _address,
      _legalForm,
      _firstName,
      _lastName,
      _birthday,
      _region,
      _nationality;
  ProgressDialog pd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pd = ProgressDialog(context: context);
    fetchCompanyCoord();
    initializeData();
  }

  void fetchCompanyCoord() async {
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: false);
    companyDataProvider.fetchCompanyCoord(context);
  }

  void initializeData() {
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: false);
    CompanyData _companyData = companyDataProvider.companyData;
    if (_companyData != null) {
      _companyName = _companyData.companyName;
      _address = _companyData.address;
      _legalForm = _companyData.legalForm;
      _firstName = _companyData.firstName;
      _lastName = _companyData.lastName;
      _birthday = _companyData.birthday;
      _region = _companyData.region;
      _nationality = _companyData.nationality;
      _kbisDocument = _companyData.kbisDocument;
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    setState(() {
      _kbisDocError = _kbisDocument == null ? true : false;
    });
    if (form.validate() && !_kbisDocError) {
      form.save();
      return true;
    }
    return false;
  }

  void deleteDocument() {
    setState(() {
      _kbisDocument = null;
    });
  }

  void _getFileFromStorage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();
    var res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: DOCS_FILE_EXTENSION,
    );
    if (res != null) {
      PlatformFile file = res.files.first;
      if (file.size >= 5172864) {
        showSnackbar(context, getTranslate(context, "FILE_SIZE_TOO_BIG"));
      } else {
        DateTime now = DateTime.now();

        String date = DateFormat('yyyy-MM-dd kk:mm').format(now);
        setState(() {
          _kbisDocument =
              Document(null, file.name, File(file.path), date, false, null);
          _kbisDocError = false;
          extractKbisData(File(file.path));
        });
      }
    }
  }

  void extractKbisData(File kbisDoc) async {
    try {
      setState(() {
        _isLoading = true;
      });
      pd.show(max: 100, msg: getTranslate(context, "EXTRACT_DATA"));
      final res = await DocumentService().extractDataFromKbis(kbisDoc);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(await res.stream.bytesToString());
      setState(() {
        _companyName = jsonData["name_company"];
        _address = jsonData["adress"];
        _legalForm = jsonData["sas"];
        _firstName = jsonData["prenom_representant"];
        _lastName = jsonData["nom_representant"];
        _birthday = jsonData["date_naissance"];
        _region = jsonData["ville"];
        _nationality = jsonData["nationalité"];
        _isLoading = false;
      });
      pd.close();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      pd.close();
      showSnackbar(context, getTranslate(context, "EXTRACT_DATA_ERROR"));
    }
  }

  Widget buildDocumentsShow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "KBIS"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        _kbisDocument != null
            ? DocumentCardForm(_kbisDocument, deleteDocument)
            : TextButton.icon(
                onPressed: () {
                  _getFileFromStorage();
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                ),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent)),
                label: Text(
                  getTranslate(context, "ADD_DOC"),
                )),
        _kbisDocError
            ? Text(
                getTranslate(context, "FILL_IN_FIELD"),
                style: TextStyle(color: RED_DARK),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget buildCompanyNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "COMPANY_NAME"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _companyName,
          decoration: inputTextDecoration(
              10,
              Icon(_companyName != null ? Icons.check : Icons.close,
                  size: 18,
                  color: _companyName != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "COMPANY_NAME"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _companyName = value.trim(),
        ),
      ],
    );
  }

  Widget buildAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Addresse de l'entreprise", style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _address,
          decoration: inputTextDecoration(
              10,
              Icon(_address != null ? Icons.check : Icons.close,
                  size: 18, color: _address != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "COMPANY_ADDRESS"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _address = value.trim(),
        ),
      ],
    );
  }

  Widget buildLegalFormInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "LEGAL_FORM"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _legalForm,
          decoration: inputTextDecoration(
              10,
              Icon(_legalForm != null ? Icons.check : Icons.close,
                  size: 18, color: _legalForm != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "LEGAL_FORM"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _legalForm = value.trim(),
        ),
      ],
    );
  }

  Widget buildFirstNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "FIRST_NAME_REPRESENTATNT"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _firstName,
          decoration: inputTextDecoration(
              10,
              Icon(_firstName != null ? Icons.check : Icons.close,
                  size: 18, color: _firstName != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "FIRST_NAME_REPRESENTATNT"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _firstName = value.trim(),
        ),
      ],
    );
  }

  Widget buildLastNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "NAME_REPRESENTATNT"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _lastName,
          decoration: inputTextDecoration(
              10,
              Icon(_lastName != null ? Icons.check : Icons.close,
                  size: 18, color: _lastName != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "NAME_REPRESENTATNT"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _lastName = value.trim(),
        ),
      ],
    );
  }

  Widget buildBirthdayInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "BIRTHDAY"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _birthday,
          decoration: inputTextDecoration(
              10,
              Icon(_birthday != null ? Icons.check : Icons.close,
                  size: 18, color: _birthday != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "BIRTHDAY"),
              null,
              null),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _birthday = value.trim(),
        ),
      ],
    );
  }

  Widget buildRegionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "BIRTH_CITY"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _region,
          decoration: inputTextDecoration(
              10,
              Icon(_region != null ? Icons.check : Icons.close,
                  size: 18, color: _region != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "BIRTH_CITY"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _region = value.trim(),
        ),
      ],
    );
  }

  Widget buildNationalityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "NATIONALITY"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _nationality,
          decoration: inputTextDecoration(
              10,
              Icon(_nationality != null ? Icons.check : Icons.close,
                  size: 18,
                  color: _nationality != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "NATIONALITY"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _nationality = value.trim(),
        ),
      ],
    );
  }

  Widget buildSaveBtn(CompanyDataProvider companyDataProvider) {
    return TextButton.icon(
      icon: _isSaving ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SAVE'),
      ),
      onPressed: _isSaving
          ? null
          : () async {
              if (validateAndSave()) {
                setState(() {
                  _isSaving = true;
                });
                StreamedResponse res;
                if (companyDataProvider.companyData != null)
                  res = await DocumentService().updateCompanyData(
                      _kbisDocument.id == null ? _kbisDocument : null,
                      _companyName,
                      _address,
                      _legalForm,
                      _firstName,
                      _lastName,
                      _birthday,
                      _region,
                      _nationality);
                else
                  res = await DocumentService().sendCompanyData(
                      _kbisDocument,
                      _companyName,
                      _address,
                      _legalForm,
                      _firstName,
                      _lastName,
                      _birthday,
                      _region,
                      _nationality);

                if (res.statusCode != 200) {
                  setState(() {
                    _isSaving = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                } else {
                  var jsonData = json.decode(await res.stream.bytesToString());
                  companyDataProvider
                      .set(CompanyData.fromJson(jsonData["data"]));
                  Navigator.of(context).pop();
                  showSnackbar(
                      context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
                }
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    CompanyDataProvider companyDataProvider =
        Provider.of<CompanyDataProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          getTranslate(context, "COMPANY_DATA"),
        ),
      ),
      body: companyDataProvider.isLoading || _isLoading
          ? Center(child: circularProgress)
          : companyDataProvider.isError
              ? ErrorScreen()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 20.0),
                          Text(getTranslate(context, "PERSONAL_INFOS_NOTICE"),
                              style: TextStyle(color: GREY_LIGHt)),
                          SizedBox(height: 20.0),
                          buildDocumentsShow(),
                          SizedBox(height: 20.0),
                          buildCompanyNameInput(),
                          SizedBox(height: 20.0),
                          buildAddressInput(),
                          SizedBox(height: 20.0),
                          buildLegalFormInput(),
                          SizedBox(height: 20.0),
                          buildFirstNameInput(),
                          SizedBox(height: 20.0),
                          buildLastNameInput(),
                          SizedBox(height: 20.0),
                          buildBirthdayInput(),
                          SizedBox(height: 20.0),
                          buildRegionInput(),
                          SizedBox(height: 20.0),
                          buildNationalityInput(),
                          SizedBox(height: 20.0),
                          SizedBox(height: 20.0),
                          buildSaveBtn(companyDataProvider),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
