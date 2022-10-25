import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/core/services/help_service.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:path/path.dart';

class HelpScreen extends StatefulWidget {
  static String routeName = "/helpScreen";

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  File file;
  bool _isLoading = false;
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  Future imagePicker() async {
    final myfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 150,
      imageQuality: 90,
    );
    if (myfile == null) return;

    setState(() {
      file = File(myfile.path);
    });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget emailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      style: TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        fillColor: BLUE_DARK_LIGHT,
        filled: true,
        border: OutlineInputBorder(),
        hintText: 'Email',
        labelText: 'Email *',
      ),
      validator: (value) => value.isEmpty
          ? getTranslate(context, "FILL_IN_FIELD")
          : !EmailValidator.validate(value)
              ? getTranslate(context, 'INVALID_EMAIL')
              : null,
      onSaved: (value) => emailController.text = value.trim(),
    );
  }

  Widget objectField(BuildContext context) {
    return TextFormField(
      controller: subjectController,
      style: TextStyle(color: Colors.white),
      maxLength: 50,
      decoration: const InputDecoration(
        fillColor: BLUE_DARK_LIGHT,
        filled: true,
        border: OutlineInputBorder(),
        hintText: 'Objet',
        labelText: 'Objet *',
      ),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onSaved: (value) => subjectController.text = value.trim(),
    );
  }

  Widget nameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      autofocus: true,
      style: TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        fillColor: BLUE_DARK_LIGHT,
        filled: true,
        border: OutlineInputBorder(),
        hintText: 'Nom',
        labelText: 'Nom *',
      ),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onSaved: (value) => nameController.text = value.trim(),
    );
  }

  Widget messageField(BuildContext context) {
    return TextFormField(
      controller: messageController,
      style: TextStyle(color: Colors.white),
      maxLength: 250,
      maxLines: 6,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        fillColor: BLUE_DARK_LIGHT,
        filled: true,
        border: OutlineInputBorder(),
        hintText: 'Message',
        labelText: 'Message *',
      ),
      validator: (value) =>
          value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
      onSaved: (value) => messageController.text = value.trim(),
    );
  }

  Widget getimage(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: imagePicker,
            child: Text(
              file != null
                  ? basename(file.path)
                  : getTranslate(context, "SELECT_IMAGE"),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
          ),
        ),
        IconButton(
            onPressed: () {
              setState(() {
                file = null;
              });
            },
            icon: Icon(
              Icons.delete,
              color: Colors.white,
              size: 18,
            )),
      ],
    );
  }

  Widget btnButtonSend(BuildContext context) {
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SEND'),
        style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 0.5),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              if (validateAndSave()) {
                setState(() {
                  _isLoading = true;
                });

                final res = await CallApi().sendReclam(
                    contactSubject: subjectController.text,
                    contactName: nameController.text,
                    contactEmail: emailController.text,
                    contactMessage: messageController.text,
                    file: file);

                if (res.statusCode == 200) {
                  showSnackbar(context,
                      getTranslate(context, "SUCCESS_SEND_RECLAMATION"));
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                }
              }
            },
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 10.0),
            nameField(context),
            SizedBox(height: 25.0),
            emailField(context),
            SizedBox(height: 25.0),
            objectField(context),
            SizedBox(height: 20.0),
            messageField(context),
            getimage(context),
            SizedBox(height: 30),
            btnButtonSend(context),
            SizedBox(height: 30),
            Text(
              getTranslate(context, 'CHAMPS_OBLIGATOIRES'),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.grey),
            ),
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
          getTranslate(context, 'HELP_FORM'),
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildForm(context),
        ),
      ),
    );
  }
}
