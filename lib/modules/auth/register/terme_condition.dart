import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:profilecenter/providers/description_provider.dart';

import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TermeCondition extends StatefulWidget {
  static String routeName = "/terme";

  @override
  State<TermeCondition> createState() => _TermeConditionState();
}

class _TermeConditionState extends State<TermeCondition> {
  @override
  void initState() {
    super.initState();
    _getPlatformDescription();
  }

  void _getPlatformDescription() async {
    DescriptionProvider descriptionProvider =
        Provider.of<DescriptionProvider>(context, listen: false);
    descriptionProvider.fetchDescription(context);
  }

  @override
  Widget build(BuildContext context) {
    DescriptionProvider descriptionProvider =
        Provider.of<DescriptionProvider>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: Text('Terme & Condition'),
        ),
        body: descriptionProvider.isLoading
            ? Center(child: circularProgress)
            : descriptionProvider.isError
                ? ErrorScreen()
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 30.0),
                          // Text(
                          //   'Description',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(color: Colors.grey),
                          // ),
                          // SizedBox(height: 30.0),
                          Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Html(
                                data: descriptionProvider.description,
                                defaultTextStyle:
                                    TextStyle(color: Colors.white),
                              )),
                        ])));
  }
}
