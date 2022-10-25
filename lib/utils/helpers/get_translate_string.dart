import 'package:flutter/material.dart';
import 'package:profilecenter/core/appLocalizations.dart';

String getTranslate(BuildContext context, String key) {
  return AppLocalizations.of(context).getTranslatedValue(key);
}
