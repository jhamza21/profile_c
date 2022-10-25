import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/models/mentionLegalData.dart';
import 'package:profilecenter/providers/mention_legal_data_provider.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/document_card_form.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class AddUpdateLegalMention extends StatefulWidget {
  static const routeName = '/addUpdateLegalMention';

  @override
  _AddUpdateLegalMentionState createState() => _AddUpdateLegalMentionState();
}

class _AddUpdateLegalMentionState extends State<AddUpdateLegalMention> {
  final _formKey = new GlobalKey<FormState>();
  Document _kbisDocument;
  Document _statusDocument;
  bool _kbisDocError = false;
  bool _isSaving = false;
  String _capital, _siret, _rcs, _naf, _tva, _facture, _taxe;
  ProgressDialog pd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pd = ProgressDialog(context: context);
    fetchLegalMention();
    initializeData();
  }

  void fetchLegalMention() async {
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: false);
    mentionLegalDataProvider.fetchLegalMention(context);
  }

  void initializeData() {
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: false);
    MentionLegalData _mentionLegalData =
        mentionLegalDataProvider.mentionLegalData;
    if (_mentionLegalData != null) {
      _capital = _mentionLegalData.capital;
      _siret = _mentionLegalData.siret;
      _rcs = _mentionLegalData.rcs;
      _naf = _mentionLegalData.naf;
      _tva = _mentionLegalData.tva;
      _facture = _mentionLegalData.facture;
      _taxe = _mentionLegalData.taxe;
      _kbisDocument = _mentionLegalData.kbisDocument;
      _statusDocument = _mentionLegalData.statusDocument;
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

  void deleteKbisDocument() {
    setState(() {
      _kbisDocument = null;
    });
  }

  void deleteStatusDocument() {
    setState(() {
      _statusDocument = null;
    });
  }

  void _getFileFromStorage(bool isKbis) async {
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
          if (isKbis) {
            _kbisDocument =
                Document(null, file.name, File(file.path), date, false, null);
            _kbisDocError = false;
            extractKbisData(File(file.path));
          } else {
            _statusDocument =
                Document(null, file.name, File(file.path), date, false, null);
          }
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
        _isLoading = true;
        _capital = jsonData["capital"].toString();
        _siret = jsonData["siret"];
        _rcs = jsonData["rcs"];
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
        SizedBox(height: 10),
        _kbisDocument != null
            ? DocumentCardForm(_kbisDocument, deleteKbisDocument)
            : TextButton.icon(
                onPressed: () {
                  _getFileFromStorage(true);
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
        SizedBox(height: 10),
        Text(getTranslate(context, "STATUS"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10),
        _statusDocument != null
            ? DocumentCardForm(_statusDocument, deleteStatusDocument)
            : TextButton.icon(
                onPressed: () {
                  _getFileFromStorage(false);
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
      ],
    );
  }

  Widget buildCapitalInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "SOCIAL_CAPITAL"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _capital,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_capital != null ? Icons.check : Icons.close,
                  size: 18, color: _capital != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "SOCIAL_CAPITAL"),
              null,
              Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text("€"))),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _capital = value.trim(),
        ),
      ],
    );
  }

  Widget buildSiretInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "SIRET"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _siret,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_siret != null ? Icons.check : Icons.close,
                  size: 18, color: _siret != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "SIRET"),
              null,
              null),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _siret = value.trim(),
        ),
      ],
    );
  }

  Widget buildRcsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "RCS_OF"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _rcs,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_rcs != null ? Icons.check : Icons.close,
                  size: 18, color: _rcs != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "RCS_OF"),
              null,
              null),
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _rcs = value.trim(),
        ),
      ],
    );
  }

  Widget buildNafInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "NAF"), style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _naf,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_naf != null ? Icons.check : Icons.close,
                  size: 18, color: _naf != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "NAF"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _naf = value.trim(),
        ),
      ],
    );
  }

  Widget buildTvaInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "TVA_NUMBER"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _tva,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_tva != null ? Icons.check : Icons.close,
                  size: 18, color: _tva != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "TVA_NUMBER"),
              null,
              null),
          keyboardType: TextInputType.text,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          onSaved: (value) => _tva = value.trim(),
        ),
      ],
    );
  }

  Widget buildFactureInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "INVOICE_PAYED_IN"),
            style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _facture,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_facture != null ? Icons.check : Icons.close,
                  size: 18, color: _facture != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "INVOICE_PAYED_IN"),
              null,
              Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(getTranslate(context, "DAYS")))),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value.isEmpty || int.tryParse(value.trim()) == null
                  ? getTranslate(context, "FILL_IN_FIELD")
                  : null,
          onSaved: (value) => _facture = value.trim(),
        ),
      ],
    );
  }

  Widget buildTaxeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTranslate(context, "TVA"), style: TextStyle(color: GREY_LIGHt)),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _taxe,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10,
              Icon(_taxe != null ? Icons.check : Icons.close,
                  size: 18, color: _taxe != null ? GREEN_LIGHT : RED_DARK),
              getTranslate(context, "TVA"),
              null,
              Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text("%"))),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value.isEmpty || double.tryParse(value.trim()) == null
                  ? getTranslate(context, "FILL_IN_FIELD")
                  : null,
          onSaved: (value) => _taxe = value.trim(),
        ),
      ],
    );
  }

  Widget buildSaveBtn(MentionLegalDataProvider mentionLegalDataProvider) {
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
                if (mentionLegalDataProvider.mentionLegalData != null)
                  res = await DocumentService().updateLegalMention(
                      _kbisDocument.id == null ? _kbisDocument : null,
                      _statusDocument == null || _statusDocument.id == null
                          ? _statusDocument
                          : null,
                      mentionLegalDataProvider
                                  .mentionLegalData.statusDocument !=
                              null &&
                          _statusDocument == null,
                      _capital,
                      _siret,
                      _rcs,
                      _naf,
                      _tva,
                      _facture,
                      _taxe);
                else
                  res = await DocumentService().sendLegalMention(
                      _kbisDocument,
                      _statusDocument,
                      _capital,
                      _siret,
                      _rcs,
                      _naf,
                      _tva,
                      _facture,
                      _taxe);

                if (res.statusCode != 200) {
                  setState(() {
                    _isSaving = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                } else {
                  var jsonData = json.decode(await res.stream.bytesToString());
                  mentionLegalDataProvider
                      .set(MentionLegalData.fromJson(jsonData["data"]));
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
    MentionLegalDataProvider mentionLegalDataProvider =
        Provider.of<MentionLegalDataProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          getTranslate(context, "LEGAL_MENTION"),
        ),
      ),
      body: mentionLegalDataProvider.isLoading || _isLoading
          ? Center(child: circularProgress)
          : mentionLegalDataProvider.isError
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
                          buildCapitalInput(),
                          SizedBox(height: 20.0),
                          buildSiretInput(),
                          SizedBox(height: 20.0),
                          buildRcsInput(),
                          SizedBox(height: 20.0),
                          buildNafInput(),
                          SizedBox(height: 20.0),
                          buildTvaInput(),
                          SizedBox(height: 20.0),
                          buildFactureInput(),
                          SizedBox(height: 20.0),
                          buildTaxeInput(),
                          SizedBox(height: 20.0),
                          buildSaveBtn(mentionLegalDataProvider),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
