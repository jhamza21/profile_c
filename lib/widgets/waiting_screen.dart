import 'package:flutter/material.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class WaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: circularProgress,
      ),
    );
  }
}
