import 'package:flutter/material.dart';

class QcmCircularProgress extends StatelessWidget {
  final double value;
  final String text;
  QcmCircularProgress(this.value, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  backgroundColor: Color(0xff1b2840),
                  value: value / 100,
                  strokeWidth: 4.0,
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Color(value <= 50
                          ? 0xffffd7d3
                          : value <= 75
                              ? 0xfff79f95
                              : value < 100
                                  ? 0xfff28071
                                  : 0xfff0604d)),
                ),
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Color(0xff1b2840),
                ),
                child: Center(
                  child: Text(
                    value.toInt().toString() + "%",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            width: 50,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
