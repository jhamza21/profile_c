import 'package:flutter/material.dart';

void showSnackbar(context, String txt) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
}
