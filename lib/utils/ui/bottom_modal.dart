import 'package:flutter/material.dart';

Future<bool> showBottomModal(
  context,
  String title,
  String subtitle,
  String btnA,
  Function() btnAF,
  String btnB,
  Function() btnBF,
) {
  return showModalBottomSheet(
      context: context,
      builder: (dialogContext) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (btnA != null)
                      new TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          onPressed: btnAF,
                          child: Text(
                            btnA,
                            style: TextStyle(color: Colors.black),
                          )),
                    if (btnB != null)
                      new TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          onPressed: btnBF,
                          child: Text(
                            btnB,
                            style: TextStyle(color: Colors.black),
                          ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}
