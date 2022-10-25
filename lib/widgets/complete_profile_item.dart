import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class CompleteProfileItem extends StatelessWidget {
  final bool isChecked;
  final String title;
  final String text;
  final void Function() onClick;
  final bool isDocument;
  
  CompleteProfileItem(
      this.isDocument, this.isChecked, this.title, this.text, this.onClick);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(color: GREY_LIGHt),
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                isChecked
                    ? Icon(
                        Icons.check,
                        color: GREEN_LIGHT,
                        size: 18,
                      )
                    : !isChecked && !isDocument
                        ? Icon(
                            Icons.close,
                            color: RED_DARK,
                            size: 18,
                          )
                        : SizedBox.shrink(),
                SizedBox(
                  width: isChecked ? 10.0 : 0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: isChecked
                      ? Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                        )
                      : isDocument
                          ? GestureDetector(
                              onTap: onClick,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: RED_DARK,
                                    size: 16,
                                  ),
                                  SizedBox(width: 10),
                                  Text(getTranslate(context, "ADD_DOC"))
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                ),
              ],
            ),
            isChecked || !isDocument
                ? GestureDetector(
                    onTap: onClick,
                    child: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: Image.asset(EDIT_ICON)))
                : SizedBox.shrink()
          ],
        ),
        Divider(
          color: GREY_LIGHt,
          thickness: 0.2,
        ),
        SizedBox(
          height: 15.0,
        )
      ],
    );
  }
}
