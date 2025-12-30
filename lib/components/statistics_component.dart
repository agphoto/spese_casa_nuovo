import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

class StatisticsComponent extends StatefulWidget {
  const StatisticsComponent({super.key}) ;

  @override
  _StatisticsComponentState createState() => _StatisticsComponentState();
}

class _StatisticsComponentState extends State<StatisticsComponent> {
  List<Category> c = [];
  List<Event> eIn = [];
  List<Event> eOut = [];

  Future<List<Category>> getCategoryList() =>
      CategoryDao().all(CategoryFilter(filterBoth: true));

  Future<List<Event>> getInEvents() =>
      EventDao().allByHome(0, EventFilter(filterIn: true, filterOut: false));

  Future<List<Event>> getOutEvents() =>
      EventDao().allByHome(0, EventFilter(filterIn: false, filterOut: true));

  void getAll() async {
    c = await getCategoryList();
    eIn = await getInEvents();
    eOut = await getOutEvents();

    setState(() {});
  }

  Map<String, double> buildOutDataMap() {
    Map<String, double> dataMap = {};
    for (var item in eOut) {
      // int cat = item.idCategory;
      String label =
          c.firstWhere((element) => element.id == item.idCategory).label;
      dataMap[label] = (dataMap[label] ?? 0) + item.amount;
    }
    return dataMap;
  }

  Map<String, double> buildInDataMap() {
    Map<String, double> dataMap = {};
    for (var item in eIn) {
      //int cat = item.idCategory;
      String label =
          c.firstWhere((element) => element.id == item.idCategory).label;
      dataMap[label] = (dataMap[label] ?? 0) + item.amount;
    }
    return dataMap;
  }

  double get outTotal {
    double val =
        eOut.map((e) => e.amount).reduce((value, element) => value + element);

    return double.parse(val.toStringAsFixed(2));
  }

  double get inTotal {
    double val =
        eIn.map((e) => e.amount).reduce((value, element) => value + element);
    return double.parse(val.toStringAsFixed(2));
  }

  @override
  void initState() {
    // TODO: implement initState
    getAll();
    super.initState();
  }

  List<Text> getSelectedDatum(charts.SelectionModel model) {
    if (model.hasDatumSelection) {
      return model.selectedDatum
          .map((element) =>
              "${DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                  .format(element.datum.time)} : ${element.datum.sales}€")
          .toList()
          .map((e) => Text(e.toString()))
          .toList();
    } else {
      return [const Text('Nessun dato.')];
    }
  }

  Future<void> _onSelectionChanged(charts.SelectionModel model) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dettaglio'),
          content: SingleChildScrollView(
            child: ListBody(
              children: getSelectedDatum(model),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (eIn.isEmpty && eOut.isEmpty) return const Text('No data!');

    // Pie charts
    Map<String, double> inDataMap = buildInDataMap();
    Map<String, double> outDataMap = buildOutDataMap();

    // Linear charts

    List<TimeSeriesSales> linearValues =
        eOut.map((e) => TimeSeriesSales(e.date, e.amount)).toList();
    charts.Series<TimeSeriesSales, DateTime> linearPoints =
        charts.Series<TimeSeriesSales, DateTime>(
      id: 'OUT',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      displayName: "OUT",
      data: linearValues,
    );

    List<TimeSeriesSales> linearValuesIn =
        eIn.map((e) => TimeSeriesSales(e.date, e.amount)).toList();
    charts.Series<TimeSeriesSales, DateTime> linearPointsIn =
        charts.Series<TimeSeriesSales, DateTime>(
      id: 'IN',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: linearValuesIn,
      displayName: "IN",
    );

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            inDataMap.isNotEmpty
                ? PieChart(
                    dataMap: inDataMap,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 22,
                    chartRadius: MediaQuery.of(context).size.width / 2.5,
                    // colorList: colorList,
                    // gradientList: gradientList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 22,
                    centerText: "IN: $inTotal €",
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10.0),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: true,
                      decimalPlaces: 1,
                    ),
                    // gradientList: ---To add gradient colors---
                    // emptyColorGradient: ---Empty Color gradient---
                  )
                : const Text('No data'),
            const SizedBox(
              height: 30.0,
            ),
            outDataMap.isNotEmpty
                ? PieChart(
                    dataMap: outDataMap,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 22,
                    chartRadius: MediaQuery.of(context).size.width / 2.5,
                    // colorList: colorList,
                    // gradientList: gradientList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 22,
                    centerText: "OUT: $outTotal €",
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10.0),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: true,
                      decimalPlaces: 1,
                    ),
                    // gradientList: ---To add gradient colors---
                    // emptyColorGradient: ---Empty Color gradient---
                  )
                : const Text('No data'),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 400,
              child: charts.TimeSeriesChart([linearPoints, linearPointsIn],
                      domainAxis: const charts.DateTimeAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                          axisLineStyle: charts.LineStyleSpec(
                            color: charts.Color(b: 255, g: 255, r: 255),
                          ),
                          labelStyle: charts.TextStyleSpec(
                            color: charts.Color(b: 255, g: 255, r: 255),
                          ),
                        ),
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                          tickFormatterSpec:
                              charts.BasicNumericTickFormatterSpec(
                                  (value) => '$value€'),
                          renderSpec: const charts.GridlineRendererSpec(

                              // Tick and Label styling here.
                              labelStyle: charts.TextStyleSpec(
                                  fontSize: 12, // size in Pts.
                                  color: charts.MaterialPalette.white),

                              // Change the line colors to match text color.
                              lineStyle: charts.LineStyleSpec(
                                  color: charts.MaterialPalette.white))),
                      selectionModels: [
                        charts.SelectionModelConfig(
                          type: charts.SelectionModelType.info,
                          changedListener: _onSelectionChanged,
                        )
                      ],
                      defaultRenderer: charts.LineRendererConfig(
                        includeArea: false,
                        stacked: false,
                        includePoints: true,
                        includeLine: true,
                      ),
                      animate: true),
            )
          ],
        ),
      ),
    );
  }
}

//  -----------------------
//  Sample linear data type.
//  -----------------------
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
