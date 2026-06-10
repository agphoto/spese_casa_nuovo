import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:spese_casa_nuovo/utils/format.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

class StatisticsComponent extends StatefulWidget {
  const StatisticsComponent({super.key}) ;

  @override
  State<StatisticsComponent> createState() => _StatisticsComponentState();
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

  /// Aggrega gli eventi per giorno sommando gli importi, ordinati per data.
  /// Rende le due linee (entrate/uscite) un trend leggibile invece di un punto
  /// per ogni singola transazione.
  List<TimeSeriesSales> _dailySeries(List<Event> events) {
    final Map<DateTime, double> byDay = {};
    for (final e in events) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      byDay[day] = (byDay[day] ?? 0) + e.amount;
    }
    final entries = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => TimeSeriesSales(e.key, e.value)).toList();
  }

  /// Costruisce un grafico lineare indipendente per una singola serie,
  /// con asse e scala propri: così entrate e uscite restano separate e non
  /// condividono la stessa scala verticale.
  Widget _lineChart(String title, List<TimeSeriesSales> data,
      charts.Color color, Color totalColor) {
    final axisCurrency = NumberFormat.decimalPattern('it_IT');
    // Totale della serie, calcolato in modo sicuro anche con lista vuota.
    final double total = data.fold<double>(0.0, (s, e) => s + e.sales);
    final series = charts.Series<TimeSeriesSales, DateTime>(
      id: title,
      colorFn: (_, __) => color,
      domainFn: (TimeSeriesSales s, _) => s.time,
      measureFn: (TimeSeriesSales s, _) => s.sales,
      displayName: title,
      data: data,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.0)),
              Text(
                formatCurrency(total),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: totalColor),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: data.isEmpty
              ? const Center(child: Text('Nessun dato'))
              : charts.TimeSeriesChart(
                  [series],
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                        (value) => value == null
                            ? ''
                            : '€ ${axisCurrency.format(value)}'),
                    renderSpec: const charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                          fontSize: 12, color: charts.MaterialPalette.white),
                      lineStyle: charts.LineStyleSpec(
                          color: charts.Color(r: 90, g: 90, b: 90)),
                    ),
                  ),
                  selectionModels: [
                    charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                      changedListener: _onSelectionChanged,
                    )
                  ],
                  defaultRenderer: charts.LineRendererConfig(
                    includeArea: true,
                    areaOpacity: 0.12,
                    includePoints: true,
                    includeLine: true,
                    radiusPx: 5.0,
                    strokeWidthPx: 2.5,
                  ),
                  // Margine sul dominio così i punti agli estremi (es. con sole
                  // due date) non finiscono incollati ai bordi e restano ben
                  // visibili.
                  domainAxis: charts.DateTimeAxisSpec(
                    viewport: data.length < 2
                        ? null
                        : charts.DateTimeExtents(
                            start: data.first.time
                                .subtract(const Duration(hours: 12)),
                            end: data.last.time.add(const Duration(hours: 12)),
                          ),
                    renderSpec: const charts.SmallTickRendererSpec(
                      axisLineStyle: charts.LineStyleSpec(
                        color: charts.Color(r: 255, g: 255, b: 255),
                      ),
                      labelStyle: charts.TextStyleSpec(
                        color: charts.Color(r: 255, g: 255, b: 255),
                      ),
                    ),
                  ),
                  animate: true,
                ),
        ),
      ],
    );
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

  List<Widget> getSelectedDatum(charts.SelectionModel model) {
    if (!model.hasDatumSelection) {
      return [const Text('Nessun dato.')];
    }

    final List<Widget> rows = [];
    for (final element in model.selectedDatum) {
      final TimeSeriesSales datum = element.datum;
      // La serie selezionata ('IN'/'OUT') dice dove cercare i movimenti.
      final List<Event> source = element.series.id == 'IN' ? eIn : eOut;
      final day = DateTime(datum.time.year, datum.time.month, datum.time.day);
      final dayEvents = source
          .where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day)
          .toList();

      // Intestazione: data e totale del giorno.
      rows.add(Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
        child: Text(
          '${DateFormat('dd/MM/yyyy').format(day)} — ${formatCurrency(datum.sales)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ));

      // Dettaglio dei singoli movimenti: testo, categoria e importo.
      for (final e in dayEvents) {
        final categoryLabel = c
            .firstWhere((x) => x.id == e.idCategory,
                orElse: () => Category(idNature: e.idNature, label: '—'))
            .label;
        rows.add(Text('• ${e.text}  [$categoryLabel] : ${formatCurrency(e.amount)}'));
      }
    }
    return rows;
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

    // Grafici lineari indipendenti: totali giornalieri di entrate e uscite,
    // ciascuno con il proprio asse e la propria scala.
    final List<TimeSeriesSales> outDaily = _dailySeries(eOut);
    final List<TimeSeriesSales> inDaily = _dailySeries(eIn);

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
                    centerText: "IN: ${formatCurrency(inTotal)}",
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
                    centerText: "OUT: ${formatCurrency(outTotal)}",
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
            _lineChart(
              'Entrate',
              inDaily,
              charts.MaterialPalette.green.shadeDefault,
              Colors.green,
            ),
            const SizedBox(height: 30),
            _lineChart(
              'Uscite',
              outDaily,
              charts.MaterialPalette.red.shadeDefault,
              Colors.red,
            ),
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
