import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/statistic_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/modules/statistics/line_chart.dart';
import 'package:profilecenter/modules/statistics/statistic_item.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class StatisticsCompany extends StatefulWidget {
  static const routeName = '/statisticsCompany';

  @override
  _StatisticsCompanyState createState() => _StatisticsCompanyState();
}

class _StatisticsCompanyState extends State<StatisticsCompany> {
  bool _isWeek = true;

  @override
  void initState() {
    super.initState();
    fetchCompanyStatistics();
  }

  void fetchCompanyStatistics() {
    StatisticProvider statisticProvider =
        Provider.of<StatisticProvider>(context, listen: false);
    if ((statisticProvider.isError || !statisticProvider.isFetched) &&
        !statisticProvider.isLoading)
      statisticProvider.fetchStatistics(context);
  }

  @override
  Widget build(BuildContext context) {
    StatisticProvider statisticProvider =
        Provider.of<StatisticProvider>(context, listen: true);
    int _nbViewsProfile = _isWeek
        ? statisticProvider.nbProfileViewsW
        : statisticProvider.nbProfileViewsM;
    int _nbApparition = _isWeek
        ? statisticProvider.nbApparitionW
        : statisticProvider.nbApparitionM;
    int _nbFavorite =
        _isWeek ? statisticProvider.nbFavoriteW : statisticProvider.nbFavoriteM;
    int _nbDiscussion = _isWeek
        ? statisticProvider.nbDiscussionW
        : statisticProvider.nbDiscussionM;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "ACIVITIES")),
        leading: SizedBox.shrink(),
        actions: [
          IconButton(
              onPressed: () {
                statisticProvider.setIsLoading(true);
                statisticProvider.fetchStatistics(context);
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: statisticProvider.isLoading
          ? Center(child: circularProgress)
          : statisticProvider.isError
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!_isWeek) {
                                  setState(() {
                                    _isWeek = true;
                                  });
                                }
                              },
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: _isWeek ? RED_LIGHT : BLUE_LIGHT),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      getTranslate(context, "WEEK"),
                                      style: TextStyle(
                                          color: _isWeek
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_isWeek) {
                                  setState(() {
                                    _isWeek = false;
                                  });
                                }
                              },
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: !_isWeek ? RED_LIGHT : BLUE_LIGHT),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      getTranslate(context, "MONTH"),
                                      style: TextStyle(
                                          color: !_isWeek
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(getTranslate(context, "STATISTICS"),
                            style: TextStyle(color: GREY_LIGHt)),
                        SizedBox(height: 10.0),
                        StatisticItem(
                            Image.asset(APPARITION_ICON),
                            "$_nbViewsProfile  ${getTranslate(context, "VIEWS")}",
                            getTranslate(context, "YOUR_PROFILE")),
                        SizedBox(height: 10.0),
                        StatisticItem(
                            Image.asset(APPARITION_ICON),
                            "$_nbApparition ${getTranslate(context, "APPARITIONS")}",
                            getTranslate(context, "IN_SEARCH_RESULT")),
                        SizedBox(height: 10),
                        StatisticItem(
                            Image.asset(HEART_ICON),
                            "$_nbFavorite ${getTranslate(context, "CANDIDATES")} ",
                            getTranslate(context, "ADDED_TO_FAVORITE")),
                        SizedBox(height: 10),
                        StatisticItem(
                            Image.asset(DISCUSSION_ICON),
                            "$_nbDiscussion discussions",
                            getTranslate(context, "IN_CHAT_CENTER")),
                        SizedBox(height: 10.0),
                        Text(getTranslate(context, "VISIBILITY_TWO_MONTHS"),
                            style: TextStyle(color: GREY_LIGHt)),
                        LineChart(
                            getTranslate(context, "PROFILE_VIEWS"),
                            statisticProvider.profileViews,
                            getTranslate(context, "APPERANCE_IN_SEARCH"),
                            statisticProvider.profileAppearance),
                      ],
                    ),
                  ),
                ),
    );
  }
}
