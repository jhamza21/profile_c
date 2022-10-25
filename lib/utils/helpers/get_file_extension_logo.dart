import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';

Image getLogo(String title) {
  if (title.contains(".pdf"))
    return Image.asset(PDF_ICON);
  else if (title.contains(".jpg") || title.contains(".jpeg"))
    return Image.asset(JPG_ICON);
  else if (title.contains(".png"))
    return Image.asset(PNG_ICON);
  else if (title.contains(".doc") || title.contains(".docx"))
    return Image.asset(WORD_ICON);
  else if (title.contains(".xls") || title.contains(".xlsx"))
    return Image.asset(XLS_ICON);
  else
    return Image.asset(UNKNOWN_EXTENSION_ICON);
}
