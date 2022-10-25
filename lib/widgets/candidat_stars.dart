import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:provider/provider.dart';

class CandidatStars extends StatefulWidget {
  final int userId;
  CandidatStars(this.userId);
  @override
  _CandidatStarsState createState() => _CandidatStarsState();
}

class _CandidatStarsState extends State<CandidatStars> {
  bool _isLoading = false;
  int _note = 0;

  @override
  void initState() {
    super.initState();
    fetchNote();
  }

  void fetchNote() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user.id == widget.userId &&
          userProvider.user.stars != null)
        _note = userProvider.user.stars;
      else {
        setState(() {
          _isLoading = true;
        });
        final res = await UserService().getUserNote(widget.userId);
        if (res.statusCode != 200) throw "ERROR_SERVER";
        final jsonData = json.decode(res.body);
        _note = jsonData["data"];
        if (userProvider.user.id == widget.userId) userProvider.setStars(_note);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23.0,
      width: 60.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), color: YELLOW_DARK),
      child: Center(
          child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
                child: Icon(
              Icons.star,
              color: YELLOW_LIGHT,
              size: 16,
            )),
            TextSpan(
                text: _isLoading ? "..." : ' $_note',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: YELLOW_LIGHT)),
          ],
        ),
      )),
    );
  }
}
