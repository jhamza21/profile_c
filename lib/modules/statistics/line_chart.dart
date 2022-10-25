import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:profilecenter/models/activity.dart';

class LineChart extends StatefulWidget {
  final String profileViewsLabel;
  final List<Activity> profileViews;
  final String profileAppearanceLabel;
  final List<Activity> profileAppearance;

  LineChart(this.profileViewsLabel, this.profileViews,
      this.profileAppearanceLabel, this.profileAppearance);
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<charts.Series<ChartData, DateTime>> _seriesData = [];

  @override
  void initState() {
    super.initState();

    List<ChartData> dataProfileAppearance = [];
    List<ChartData> dataProfileViews = [];
    int _nbAppearance = 0;
    int _nbViews = 0;
    widget.profileViews.forEach((e) {
      _nbViews++;
      dataProfileViews.add(ChartData(DateTime.parse(e.date), _nbViews));
    });
    widget.profileAppearance.forEach((e) {
      _nbAppearance++;
      dataProfileAppearance
          .add(ChartData(DateTime.parse(e.date), _nbAppearance));
    });

    _seriesData.add(
      charts.Series(
        domainFn: (ChartData data, _) => data.date,
        measureFn: (ChartData data, _) => data.value,
        // labelAccessorFn: (ChartData data, _) =>
        //     '${data.value} ${widget.chart.unity}',
        id: widget.profileAppearanceLabel,
        colorFn: (ChartData data, _) => charts.Color.fromHex(code: "#FFFF00"),
        data: dataProfileAppearance,
      ),
    );
    _seriesData.add(
      charts.Series(
        domainFn: (ChartData data, _) => data.date,
        measureFn: (ChartData data, _) => data.value,
        // labelAccessorFn: (ChartData data, _) =>
        //     '${data.value} ${widget.chart.unity}',
        id: widget.profileViewsLabel,
        colorFn: (ChartData data, _) => charts.Color.fromHex(code: "#00ff00"),
        data: dataProfileViews,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: MediaQuery.of(context).size.width,
      child: new charts.TimeSeriesChart(
        _seriesData,
        animate: true,
        // Configure the default renderer as a line renderer. This will be used
        // for any series that does not define a rendererIdKey.
        //
        // This is the default configuration, but is shown here for  illustration.
        defaultRenderer: new charts.LineRendererConfig(),
        // Custom renderer configuration for the point series.
        customSeriesRenderers: [
          new charts.PointRendererConfig(
              // ID used to link series to this renderer.
              customRendererId: 'customPoint')
        ],
        // Optionally pass in a [DateTimeFactory] used by the chart. The factory
        // should create the same type of [DateTime] as the data provided. If none
        // specified, the default creates local date time.
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        behaviors: [
          new charts.SeriesLegend(
            position: charts.BehaviorPosition.top,
            cellPadding: EdgeInsets.only(top: 8, right: 1, left: 0),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final int value;

  ChartData(this.date, this.value);
}
