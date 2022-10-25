import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/modules/home/home_root.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splashScreen';
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 6000,
      pageTransitionType: PageTransitionType.fade,
      nextScreen: HomeRoot(),
      backgroundColor: BLUE_DARK,
      splashIconSize: MediaQuery.of(context).size.height,
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 180,
                width: 180,
                child: Image.asset("assets/images/logo.png")),
            SizedBox(height: 30),
            Text(
              "Profile Center",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )
          ],
        ),
      ),
    );
  }
}
