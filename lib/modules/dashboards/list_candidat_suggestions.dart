import 'dart:async';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/candidat_suggestions_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/candidat_suggestion_card.dart';
import 'package:provider/provider.dart';

class ListCandidatSuggestion extends StatefulWidget {
  @override
  _ListCandidatSuggestionState createState() => _ListCandidatSuggestionState();
}

class _ListCandidatSuggestionState extends State<ListCandidatSuggestion> {
  final scrollDirection = Axis.horizontal;
  int _currentPage = 1;
  bool end = false;
  Timer _timer;
  PageController _pageController =
      PageController(initialPage: 1, viewportFraction: 0.4);

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
    CandidatSuggestionsProvider candidatSuggestionsProvider =
        Provider.of<CandidatSuggestionsProvider>(context, listen: false);
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < candidatSuggestionsProvider.suggestions.length) {
        // _currentPage++;
        end = true;
      } else {
        // _currentPage = 1;
        end = false;
      }

      if (end == false) {
        _currentPage = 1;
      } else {
        _currentPage++;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void fetchSuggestions() async {
    CandidatSuggestionsProvider candidatSuggestionsProvider =
        Provider.of<CandidatSuggestionsProvider>(context, listen: false);
    candidatSuggestionsProvider.fetchSuggestions(context);
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    CandidatSuggestionsProvider candidatSuggestionsProvider =
        Provider.of<CandidatSuggestionsProvider>(context, listen: true);
    return Container(
      height: 130,
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), color: BLUE_DARK_LIGHT),
      child: candidatSuggestionsProvider.isLoading
          ? Center(child: Text(getTranslate(context, "WAIT_PLEASE")))
          : candidatSuggestionsProvider.suggestions.length == 0
              ? Center(child: Text(getTranslate(context, "NO_DATA")))
              : Row(
                  children: [
                    Icon(Icons.keyboard_arrow_left, color: GREY_LIGHt),
                    Expanded(
                      child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: scrollDirection,
                          itemCount:
                              candidatSuggestionsProvider.suggestions.length,
                          itemBuilder: (context, index) {
                            return CandidatSuggestionCard(
                                candidatSuggestionsProvider.suggestions[index]);
                          }),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: GREY_LIGHt),
                  ],
                ),
    );
  }
}
