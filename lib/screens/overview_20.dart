import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';

class Overview20 extends StatefulWidget {
  const Overview20({super.key});

  @override
  State<Overview20> createState() => _Overview20State();
}

class _Overview20State extends State<Overview20> {
  var maxBillMoney = 0.0;
  final dataHelper = DataHelper();
  final Map<int, BillRecord> billRecords = {};
  final List<FlSpot> spotsBillRecord = [];

  final logger = Logger();

  List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Color(0xFF2196F3),
  ];
  bool isInited = false;

  var amountBill = "";
  var revenue = 0.0;
  var agvPerBill = "";
  var investment = "";
  var profit = "";

  String formatDate(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String formatNumber(double numberDouble) {
    final number = numberDouble.toInt();
    if (number < 1000) {
      return number.toString();
    }

    if (number < 1000000) {
      double thousands = number / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k'; // Sử dụng toStringAsFixed để xử lý số thập phân
    }

    if (number < 1000000000) {
      double millions = number / 1000000;
      return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M'; // Sử dụng toStringAsFixed để xử lý số thập phân
    }

    if (number < 1000000000000) {
      double billions = number / 1000000000;
      return '${billions.toStringAsFixed(billions.truncateToDouble() == billions ? 0 : 1)}B'; // Sử dụng toStringAsFixed để xử lý số thập phân
    }

    if (number < 1000000000000000) {
      double trillions = number / 1000000000000;
      return '${trillions.toStringAsFixed(trillions.truncateToDouble() == trillions ? 0 : 1)}T'; // Sử dụng toStringAsFixed để xử lý số thập phân
    }

    return number.toString(); // Trả về số gốc nếu quá lớn
  }

  void getBillRecords() async {
    final now = DateTime(2025, 1, 8);
    final tmpBillRecords = await dataHelper.billRecords(
        where: ("datetime >= ? AND datetime < ? "
            "ORDER BY datetime"),
        whereArgs: [
          now.millisecondsSinceEpoch,
          now.add(const Duration(days: 1)).millisecondsSinceEpoch
        ]);
    final List<List<double>> tmpSpots = [];
    final List<FlSpot> tmptSpotsBillRecord = [];

    for (var e in tmpBillRecords.entries) {
      logger.d("billRecord ${e.value.id}");
      final date = DateTime.fromMillisecondsSinceEpoch(e.value.dateTime);
      final billMoney = await dataHelper.revenueBillRecord(e.value.id ?? 0);
      if (billMoney > maxBillMoney) {
        maxBillMoney = billMoney;
      }
      tmpSpots.add([date.hour.toDouble(), billMoney]);
    }
    logger.d("maxBillMoney: $maxBillMoney");
    for (var i = 0; i < tmpSpots.length; i++) {
      final y = tmpSpots.elementAtOrNull(i)?[1] ?? 0.0;
      final x = tmpSpots.elementAtOrNull(i)?[0] ?? 0.0;
      final newY = (y / maxBillMoney) * 6;
      logger.d("x: $x, y: $newY");
      tmptSpotsBillRecord.add(FlSpot(x, newY));
    }
    setState(() {
      billRecords.clear();
      spotsBillRecord.clear();
      billRecords.addAll(tmpBillRecords);
      spotsBillRecord.addAll(tmptSpotsBillRecord);
      isInited = true;
    });
  }

  @override
  void initState() {
    getBillRecords();
    super.initState();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 6:
        text = const Text('6', style: style);
        break;
      case 12:
        text = const Text('12', style: style);
        break;
      case 18:
        text = const Text('18', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = formatNumber(maxBillMoney / 6);
        break;
      case 3:
        text = formatNumber((maxBillMoney / 6) * 3);
        break;
      case 5:
        text = formatNumber((maxBillMoney / 6) * 5);
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          // spots: spotsBillRecord,
          spots: spotsBillRecord,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget newChart() {
    return (isInited)
        ? Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.70,
                child: LineChart(avgData()),
              ),
              SizedBox(
                width: 60,
                height: 34,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'avg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> itemBuilder = [];

    itemBuilder.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Amount Bill: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: amountBill,
                  style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Revenue: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: revenue.toString(),
                  style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'AGV Per Bill: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: agvPerBill,
                  style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Investment: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: investment,
                  style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Profit: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: profit,
                  style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
      ],
    ));

    itemBuilder.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () {}, child: Text('Bill List')),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
          child: ElevatedButton(
              onPressed: () {}, child: Text('Investment Import')),
        ),
      ],
    ));

    itemBuilder.add(Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(onPressed: () {}, child: Text('Choose Date')),
    )));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: ListView(
            children: itemBuilder,
          )),
          Expanded(child: newChart()),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            false,
            false
          ], listCallback: [
            () {
              Navigator.pop(context);
            },
            () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          ], icons: [
            Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.home,
              color: colorScheme.primary,
            )
          ])
        ],
      ),
    );
  }
}
