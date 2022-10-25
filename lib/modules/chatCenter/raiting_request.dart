import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_time_from_message.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RaitingRequestCard extends StatefulWidget {
  final Message message;
  final UserProvider userProvider;
  RaitingRequestCard(this.message, this.userProvider);
  @override
  _RaitingRequestCardState createState() => _RaitingRequestCardState();
}

class _RaitingRequestCardState extends State<RaitingRequestCard> {
  bool _isAccepting = false;
  double _rating = 0;
  String _comment;
  bool _isRated = false;
  bool _isRatedError = false;
  final _formKey = new GlobalKey<FormState>();

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate() && !_isRatedError) {
      form.save();
      return true;
    }
    return false;
  }

  String getMessagetitle() {
    return widget.message.response == null
        ? "${getTranslate(context, "END_PROJECT_NOTICE")} ${widget.message.offer.title}?"
        : "${getTranslate(context, "PROJECT")} : ${widget.message.offer.title} ${getTranslate(context, "PROJECT_END")}";
  }

  String getMessageSubtitle() {
    return "${getTranslate(context, "NOTE")} : ${widget.message.text.substring(0, 1)}/5 \n${getTranslate(context, "REMARK")} : ${widget.message.text.substring(1)}";
  }

  Widget _showRaitingDialog(dialogContext, context) {
    _isRated = false;
    _rating = 0;
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                  child: Center(
                      child: Text(
                    getTranslate(context, "NOTE"),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
                SizedBox(height: 5.0),
                SmoothStarRating(
                  rating: _rating,
                  size: 35,
                  filledIconData: Icons.star,
                  halfFilledIconData: Icons.star_half,
                  defaultIconData: Icons.star_border,
                  starCount: 5,
                  allowHalfRating: false,
                  spacing: 2.0,
                  onRated: (value) {
                    setState(() {
                      _isRated = true;
                      _rating = value;
                    });
                  },
                ),
                if (_isRatedError)
                  Text(
                    getTranslate(context, "FILL_IN_FIELD"),
                    style:
                        TextStyle(color: Colors.deepOrange[200], fontSize: 12),
                  ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    maxLength: 100,
                    maxLines: 4,
                    validator: (value) => value.isEmpty
                        ? getTranslate(context, "FILL_IN_FIELD")
                        : null,
                    onSaved: (value) => _comment = value.trim(),
                    decoration: inputTextDecoration(10.0, null,
                        getTranslate(context, "REMARK"), null, null),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                          onPressed: _isAccepting
                              ? null
                              : () async {
                                  set(() {
                                    _isRatedError = _isRated ? false : true;
                                  });
                                  try {
                                    if (validateAndSave()) {
                                      Navigator.of(dialogContext).pop();
                                      setState(() {
                                        _isAccepting = true;
                                      });
                                      var res = await OfferService()
                                          .cloturerProject(widget.message.id,
                                              _rating.toInt(), _comment);
                                      if (res.statusCode == 401)
                                        return sessionExpired(context);
                                      if (res.statusCode != 200)
                                        throw "ERROR_SERVER";
                                      showSnackbar(
                                          context,
                                          getTranslate(
                                              context, "RATING_SUCCESS"));
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _isAccepting = false;
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _isAccepting = false;
                                    });
                                    showSnackbar(context,
                                        getTranslate(context, "ERROR_SERVER"));
                                  }
                                },
                          child: Text(getTranslate(context, "SEND")),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(getTranslate(context, "CANCEL"))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.response == null &&
            widget.userProvider.user.role != COMPANY_ROLE
        ? SizedBox.shrink()
        : Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                        color: BLUE_LIGHT,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Profile center",
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0),
                            ),
                            SizedBox(width: 10),
                            Text(
                              getMessageTime(widget.message, context),
                              style: TextStyle(
                                  color: GREY_LIGHt,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              getMessagetitle(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0),
                            ),
                            if (widget.message.response != null)
                              SizedBox(height: 10.0),
                            if (widget.message.response != null)
                              Text(
                                getMessageSubtitle(),
                                style: TextStyle(
                                    color: GREY_LIGHt, fontSize: 12.0),
                              ),
                            SizedBox(height: 10.0),
                            widget.message.response == null
                                ? SizedBox(
                                    height: 30,
                                    child: ElevatedButton.icon(
                                      onPressed: _isAccepting
                                          ? null
                                          : () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return _showRaitingDialog(
                                                        dialogContext, context);
                                                  });
                                            },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(RED_DARK),
                                      ),
                                      icon: _isAccepting
                                          ? circularProgress
                                          : SizedBox.shrink(),
                                      label: Text(getTranslate(
                                          context, "END_PROJECT_BTN")),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
