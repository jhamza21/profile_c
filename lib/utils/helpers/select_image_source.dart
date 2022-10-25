import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

void showSelectImageSource(context, Function() storageFn, Function() cameraFn) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
            child: Container(
          child: new Wrap(
            children: [
              new ListTile(
                  leading: new Icon(Icons.photo_library),
                  title: new Text(getTranslate(context, "FROM_GALLERY")),
                  onTap: storageFn),
              new ListTile(
                leading: new Icon(Icons.photo_camera),
                title: new Text(getTranslate(context, "FROM_CAMERA")),
                onTap: cameraFn,
              ),
            ],
          ),
        ));
      });
}
