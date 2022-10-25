import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class FileCenterItem extends StatefulWidget {
  final void Function() onClickRedirection;
  final String title;
  final String icon;
  final bool isComplete;

  FileCenterItem(
    this.icon,
    this.title,
    this.onClickRedirection,
    this.isComplete,
  );
  @override
  _FileCenterItemState createState() => _FileCenterItemState();
}

class _FileCenterItemState extends State<FileCenterItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: widget.onClickRedirection,
      tileColor: BLUE_LIGHT,
      leading: SizedBox(
        height: 35.0,
        width: 35.0,
        child: Image.asset(
          widget.icon,
          fit: BoxFit.fill,
          color: widget.isComplete ? GREEN_LIGHT : RED_DARK,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          !widget.isComplete
              ? Text(
                  getTranslate(context, "INCOMPLETE") + "  ",
                  style: TextStyle(color: RED_DARK),
                )
              : SizedBox.shrink(),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
