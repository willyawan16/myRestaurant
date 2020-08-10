/// Dash pattern line chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

/// Example of a line chart rendered with dash patterns.
class MyChart extends StatefulWidget {
  List data;

  MyChart({Key key, this.data}) : super(key: key);
  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {

  List<charts.Series<Income, String>> _seriesLineData;

  _generateData() {
    var lineIncomeData = [
      new Income('4',widget.data[0], Colors.grey),
      new Income('3',widget.data[1], Colors.grey),
      new Income('2',widget.data[2], Colors.grey),
      new Income('1',widget.data[3], Colors.grey),
      new Income('Today',widget.data[4], Colors.green),
    ];
    
    _seriesLineData.add(
        charts.Series(
          data: lineIncomeData,
          domainFn: (Income income, _) => income.daysAgo,
          measureFn: (Income income, _) => income.incomeVal,
          colorFn: (Income income, _) => charts.ColorUtil.fromDartColor(income.incomeCol),
          id: 'Income',
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _seriesLineData = List<charts.Series<Income, String>>();
    _generateData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: charts.BarChart(
        _seriesLineData,
        animate: true,
        // defaultRenderer: new charts.LineRendererConfig(
        //   includeArea: true,
        //   stacked: true,
        //   includePoints: false,
        // ),
        animationDuration: Duration(milliseconds: 500),
        behaviors: [
          new charts.ChartTitle(
            'Hari lalu',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification: charts.OutsideJustification.middleDrawArea
          ),
          new charts.ChartTitle(
            'Pendapatan (Rp)',
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification: charts.OutsideJustification.middleDrawArea
          )
        ], 
      ),
    );
  }

}


class Income {
  String daysAgo;
  int incomeVal;
  Color incomeCol;

  Income(this.daysAgo, this.incomeVal, this.incomeCol);
}