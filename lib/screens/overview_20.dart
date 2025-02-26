import 'dart:math';

import 'package:date_field/date_field.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/screens/list_23.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Overview20 extends StatefulWidget {
  const Overview20({super.key});

  @override
  State<Overview20> createState() => _Overview20State();
}

class _Overview20State extends State<Overview20> {
  var maxBillMoney = 0.0;
  final dataHelper = DataHelper();

  final List<FlSpot> spotsHourBill = [];
  final List<FlSpot> spotsMinuteBill = [];

  bool isInited = false;
  DateTime? date;

  var amountBill = 0;
  var revenue = 0.0;
  var agvPerBill = 0.0;

  String formatDate(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String formatNumber(double number) {
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

  void getBillRecords(DateTime now1) async {
    final now = DateTime(now1.year, now1.month, now1.day);
    final tomorrow = now.add(const Duration(days: 1));

    final tmpBillRecords = await dataHelper.billRecords(
      where:
          "STRFTIME('%Y-%m-%d %H:%M:%f', datetime) >= ? AND STRFTIME('%Y-%m-%d %H:%M:%f', datetime) < ?",
      whereArgs: [
        DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').format(now), // Format now
        DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS')
            .format(tomorrow), // Format tomorrow
      ],
    );
    final Map<int, double> tmpSpotsHour = {};
    final Map<int, double> tmpSpotsMinute = {};
    final List<FlSpot> tmptSpotsHourBill = [];
    final List<FlSpot> tmpSpotsMinuteBill = [];

    var tmpAmountBill = 0;
    var sumOfbillNumber = 0.0;
    for (var e in tmpBillRecords) {
      final date = e.dateTime;
      final billMoney =
          (await dataHelper.revenueBillRecord(e.id ?? 0)) - e.discount;
      final hour = date.hour + (date.minute / 60).ceil();
      final minute = date.hour * 60 + date.minute;
      tmpAmountBill += 1;
      sumOfbillNumber += billMoney;
      // logger.d("hour $hour => $billMoney");
      tmpSpotsHour[hour] = (tmpSpotsHour[hour] ?? 0) + billMoney;
      // the max tmpSpotsMinute element number is 1439 = 60*24 - 1
      tmpSpotsMinute[minute] = (tmpSpotsMinute[minute] ?? 0) + billMoney;
      if (maxBillMoney < tmpSpotsHour[hour]!) {
        maxBillMoney = tmpSpotsHour[hour]!;
      }
    }

    // logger.d("maxBillMoney: $maxBillMoney");
    for (var e in tmpSpotsHour.entries) {
      final y = e.value;
      final x = e.key.toDouble();
      final newY = (y / maxBillMoney) * 6;
      // logger.d("x: $x, y: $newY");
      tmptSpotsHourBill.add(FlSpot(x, newY));
    }
    for (var e in tmpSpotsMinute.entries) {
      final y = e.value;
      final x = e.key.toDouble();
      final newX = (x / 1439) * 24;
      final newY = (y / maxBillMoney) * 6;
      // logger.d("xM: $newX, yM: $newY");
      tmpSpotsMinuteBill.add(FlSpot(newX, newY));
    }
    setState(() {
      spotsHourBill.clear();
      spotsMinuteBill.clear();
      spotsHourBill.addAll(tmptSpotsHourBill);
      spotsMinuteBill.addAll(tmpSpotsMinuteBill);
      revenue = sumOfbillNumber;
      agvPerBill = (tmpAmountBill != 0) ? sumOfbillNumber / tmpAmountBill : 0;
      amountBill = tmpAmountBill;
      date = now;
      isInited = true;
    });
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
      fontSize: 12,
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

  LineChartData chartData() {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColorsByHour = [
      colorScheme.primaryContainer,
      colorScheme.primary
    ];
    final gradientColorsByMinute = [
      colorScheme.secondaryContainer,
      colorScheme.secondary
    ];
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
      maxX: 24,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          // spots: spotsBillRecord,
          spots: spotsHourBill,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColorsByHour,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColorsByHour
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          // spots: spotsBillRecord,
          spots: spotsMinuteBill,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColorsByMinute,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColorsByMinute
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
                child: LineChart(chartData()),
              ),
            ],
          )
        : SizedBox();
  }

  @override
  void initState() {
    getBillRecords(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> itemBuilder = [];
    final appLocalizations = AppLocalizations.of(context)!;

    itemBuilder.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: '${appLocalizations.numberOfBill}: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: formatNumber(amountBill.toDouble()),
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
                  text: '${appLocalizations.revenue}: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: formatNumber(revenue),
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
                  text: '${appLocalizations.avgPerBill}: ',
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: formatNumber(agvPerBill),
                  style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
      ],
    ));

    itemBuilder.add(Center(
      child: ElevatedButton(
          onPressed: () {
            navigateWithFade(context, List23());
          },
          child: Text(appLocalizations.billList)),
    ));

    itemBuilder.add(Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          width: 160,
          child: DateTimeField(
            value: date,
            decoration: const InputDecoration(
              helperText: 'DD/MM/YYYY',
            ),
            dateFormat: DateFormat('dd/MM/yyyy'),
            initialPickerDateTime: DateTime.now(),
            mode: DateTimeFieldPickerMode.date,
            onChanged: (DateTime? value) {
              if (value != null) getBillRecords(value);
            },
          )),
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
