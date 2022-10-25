import 'dart:async';

import 'package:flutter/material.dart';
import 'package:profilecenter/modules/auth/register/signup.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/language_switch.dart';

import '../../widgets/slide_item.dart';
import '../../models/slide.dart';
import '../../widgets/slide_dots.dart';
import '../auth/login/login.dart';

class GettingStarted extends StatefulWidget {
  static const routeName = '/gettingStarted';
  @override
  _GettingStartedState createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 6), (Timer timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    if (_pageController.hasClients) _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            Row(
              children: [
                LanguageSwitch(),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: slideList.length,
                    itemBuilder: (ctx, i) => SlideItem(i),
                  ),
                  Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 35),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (int i = 0; i < slideList.length; i++)
                              if (i == _currentPage)
                                SlideDots(true)
                              else
                                SlideDots(false)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  child: Text(
                    getTranslate(context, "CREATE_ACCOUNT"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(SignUp.routeName);
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextButton(
                  child: Text(
                    getTranslate(context, "CONNECTION"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Login.routeName);
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
