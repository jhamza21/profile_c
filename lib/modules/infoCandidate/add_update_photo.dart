import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/select_image_source.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class AddUpdatePhoto extends StatefulWidget {
  static const routeName = '/addUpdatePhoto';

  @override
  _AddUpdatePhotoState createState() => _AddUpdatePhotoState();
}

class _AddUpdatePhotoState extends State<AddUpdatePhoto> {
  final _formKey = new GlobalKey<FormState>();
  File _selectedImage;
  bool _isLoading = false;

  Future getImageFromCamera(bool fromCamera) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();
    var img = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front);
    if (img != null) {
      if (File(img.path).lengthSync() >= 5242880) {
        showSnackbar(context, getTranslate(context, "FILE_SIZE_TOO_BIG"));
        return;
      } else {
        _selectedImage = File(img.path);
        String dir = path.dirname(_selectedImage.path);
        String extension = path.extension(_selectedImage.path);
        String newPath = path.join(dir, extension);
        setState(() {
          _selectedImage = _selectedImage.renameSync(newPath);
        });
      }
    }
  }

  Future _selectImageSource(context) async {
    showSelectImageSource(context, () {
      getImageFromCamera(false);
      Navigator.of(context).pop();
    }, () {
      getImageFromCamera(true);
      Navigator.of(context).pop();
    });
  }

  Widget buildImageInput() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return _selectedImage != null || userProvider.user.image != ''
        ? Column(
            children: [
              SizedBox(
                height: 140.0,
                width: 140.0,
                child: CircleAvatar(
                  backgroundImage: _selectedImage != null
                      ? new FileImage(_selectedImage)
                      : NetworkImage(URL_BACKEND + userProvider.user.image),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent)),
                      onPressed: () => _selectImageSource(context),
                      icon: SizedBox(
                          height: 30.0,
                          width: 30.0,
                          child: Image.asset(
                            UPLOAD_PHOTO_ICON,
                            color: Colors.white,
                          )),
                      label: Text(getTranslate(context, "CHANGE"),
                          style: TextStyle(color: Colors.white)))
                ],
              )
            ],
          )
        : Container(
            height: 200.0,
            decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(30.0)),
            child: GestureDetector(
              onTap: () {
                _selectImageSource(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 70.0,
                      width: 70.0,
                      child: Image.asset(UPLOAD_PHOTO_ICON)),
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTranslate(context, "ADD_IMAGE"),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }

  Widget buildSaveBtn() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SAVE'),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              var res = await UserService()
                  .updatePhoto(userProvider.user.id, _selectedImage);
              if (res.statusCode != 200) {
                setState(() {
                  _isLoading = false;
                });
                showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
              } else {
                var jsonData = json.decode(await res.stream.bytesToString());
                userProvider.setPhoto(jsonData["data"]["pro_picture"]);
                Navigator.of(context).pop();
                showSnackbar(
                    context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "PROFESSIONAL_PHOTO")),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20.0,
              ),
              Text(
                getTranslate(context, "PROFESSIONAL_PHOTO_NOTICE"),
                style: TextStyle(color: GREY_LIGHt),
              ),
              SizedBox(height: 40.0),
              buildImageInput(),
              SizedBox(height: 60.0),
              buildSaveBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
