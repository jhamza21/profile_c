import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/kbis_provider.dart';
import 'package:profilecenter/providers/video_presentation_provider.dart';
import 'package:profilecenter/utils/helpers/format_bytes.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/providers/cover_letter_provider.dart';
import 'package:profilecenter/providers/cv_provider.dart';
import 'package:profilecenter/providers/diplomas_provider.dart';
import 'package:profilecenter/providers/identity_doc_provider.dart';
import 'package:profilecenter/providers/portfolio_provider.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/select_image_source.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddDocument extends StatefulWidget {
  static const routeName = '/addDocument';

  final AddDocumentArguments addDocumentArguments;
  AddDocument(this.addDocumentArguments);

  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  Document _selectedDoc;
  bool _isSaving = false;
  String _newDocName;
  final _formKey = new GlobalKey<FormState>();

  Future getImageFromCamera() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();
    var img = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 50);
    if (img != null) {
      if (File(img.path).lengthSync() >= 5172864) {
        showSnackbar(context, getTranslate(context, "FILE_SIZE_TOO_BIG"));
        return;
      } else {
        DateTime now = DateTime.now();
        String date = DateFormat('yyyy-MM-dd kk:mm').format(now);
        setState(() {
          _selectedDoc = Document(
              null,
              path.basename(img.path),
              File(img.path),
              date,
              widget.addDocumentArguments.primary,
              widget.addDocumentArguments.type);
        });
      }
    }
  }

  void _getFileFromStorage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();
    var res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.addDocumentArguments.allowedExtensions);
    if (res != null) {
      PlatformFile file = res.files.first;
      int _maxSize = widget.addDocumentArguments.type == VIDEO_PRESENTATION
          ? 10345728
          : 5172864;
      if (file.size >= _maxSize) {
        showSnackbar(
            context,
            getTranslate(
                context,
                widget.addDocumentArguments.type == VIDEO_PRESENTATION
                    ? "VIDEO_SIZE_TOO_BIG"
                    : "FILE_SIZE_TOO_BIG"));
      } else {
        DateTime now = DateTime.now();

        String date = DateFormat('yyyy-MM-dd kk:mm').format(now);
        setState(() {
          _selectedDoc = Document(
              null,
              file.name,
              File(file.path),
              date,
              widget.addDocumentArguments.primary,
              widget.addDocumentArguments.type);
        });
      }
    }
  }

  Future _selectImageSource(context) async {
    if (widget.addDocumentArguments.type == VIDEO_PRESENTATION) {
      _getFileFromStorage();
      return;
    }
    showSelectImageSource(context, () {
      _getFileFromStorage();
      Navigator.of(context).pop();
    }, () {
      getImageFromCamera();
      Navigator.of(context).pop();
    });
  }

  renameDocumentDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: BLUE_LIGHT,
            contentPadding: EdgeInsets.zero,
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                    child: Center(
                        child: Text(
                      "Renommer document",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.text,
                      decoration: inputTextDecoration(10.0, null,
                          getTranslate(context, "DOCUMENT_TITLE"), null, null),
                      validator: (value) => value.isEmpty
                          ? getTranslate(context, "FILL_IN_FIELD")
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _newDocName = value.trim();
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      BLUE_DARK_LIGHT)),
                              onPressed: () {
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  String dir =
                                      path.dirname(_selectedDoc.file.path);
                                  String extension =
                                      path.extension(_selectedDoc.file.path);
                                  String newPath =
                                      path.join(dir, _newDocName + extension);
                                  _selectedDoc.title = _newDocName + extension;
                                  setState(() {
                                    _selectedDoc.file =
                                        _selectedDoc.file.renameSync(newPath);
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(getTranslate(context, "VALIDATE"))),
                        ),
                        Expanded(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      BLUE_DARK_LIGHT)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(getTranslate(context, "CANCEL"))),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget buildSaveBtn() {
    return TextButton.icon(
      icon: _isSaving ? circularProgress : SizedBox(),
      label: Text(getTranslate(context, 'SAVE')),
      onPressed: _isSaving || _selectedDoc == null
          ? null
          : () async {
              setState(() {
                _isSaving = true;
              });
              var res = await DocumentService().addDocument(
                  _selectedDoc.file,
                  widget.addDocumentArguments.type,
                  widget.addDocumentArguments.primary);
              if (res.statusCode != 200) {
                setState(() {
                  _isSaving = false;
                });
                showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
              } else {
                var jsonData = json.decode(await res.stream.bytesToString());
                _selectedDoc.id = jsonData["document"]["id"];
                if (_selectedDoc.type == COVER_LETTER_DOC) {
                  CoverLetterProvider coverLetterProvider =
                      Provider.of<CoverLetterProvider>(context, listen: false);
                  coverLetterProvider.addDocument(_selectedDoc);
                } else if (_selectedDoc.type == CV_DOC) {
                  CvProvider cvProvider =
                      Provider.of<CvProvider>(context, listen: false);
                  cvProvider.addDocument(_selectedDoc);
                } else if (_selectedDoc.type == DIPLOMAS_DOC) {
                  DiplomasProvider diplomasProvider =
                      Provider.of<DiplomasProvider>(context, listen: false);
                  diplomasProvider.addDocument(_selectedDoc);
                } else if (_selectedDoc.type == IDENTITY_DOC) {
                  IdentityDocProvider identityDocProvider =
                      Provider.of<IdentityDocProvider>(context, listen: false);
                  identityDocProvider.addDocument(_selectedDoc);
                } else if (_selectedDoc.type == PORTFOLIO_DOC) {
                  PortfolioProvider portfolioProvider =
                      Provider.of<PortfolioProvider>(context, listen: false);
                  portfolioProvider.addDocument(_selectedDoc);
                } else if (_selectedDoc.type == KBIS_DOC) {
                  KbisProvider kbisProvider =
                      Provider.of<KbisProvider>(context, listen: false);
                  kbisProvider.addDocument(_selectedDoc);
                } else if (_selectedDoc.type == VIDEO_PRESENTATION) {
                  VideoPresentationProvider videoPresentationProvider =
                      Provider.of<VideoPresentationProvider>(context,
                          listen: false);
                  videoPresentationProvider.setVideo(_selectedDoc);
                }
                showSnackbar(context, getTranslate(context, "SUCCESS_DOC_ADD"));
                Navigator.of(context).pop();
              }
            },
    );
  }

  Widget buildDocumentInput() {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
          color: BLUE_LIGHT, borderRadius: BorderRadius.circular(30.0)),
      child: GestureDetector(
        onTap: () {
          _selectImageSource(context);
        },
        child: _selectedDoc == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 50,
                    color: GREY_LIGHt,
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTranslate(context, "ADD_DOC"),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: GREY_LIGHt),
                      ),
                    ],
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedDoc.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          "${getTranslate(context, "SIZE")} : " +
                              formatBytes(_selectedDoc.file.lengthSync(), 2),
                          style: TextStyle(color: GREY_LIGHt),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        renameDocumentDialog();
                      },
                      icon: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                      )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDoc = null;
                        });
                      },
                      icon: Image.asset(TRASH_ICON,
                          height: 22, width: 22, color: RED_DARK)),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.addDocumentArguments.title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildDocumentInput(),
              SizedBox(height: 60.0),
              buildSaveBtn(),
            ]),
      ),
    );
  }
}

class AddDocumentArguments {
  final String title;
  final String type;
  final bool primary;
  final List<String> allowedExtensions;
  AddDocumentArguments(
    this.title,
    this.type,
    this.primary,
    this.allowedExtensions,
  );
}
