import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_24.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/setting_button.dart';

class List23 extends StatefulWidget {
  const List23({super.key});
  @override
  State<List23> createState() => _List23State();
}

class _List23State extends State<List23> {
  DateTime? filterDateTime;
  String titleMenu = "";

  bool _showWidgetB = false;
  Alert? alert;
  final Logger logger = Logger();
  final DataHelper dataHelper = DataHelper();
  final Map<int, BillRecord> billRecords = {};

  void getBillRecords() async {
    var tmpBillRecords = await dataHelper.billRecords();
    setState(() {
      billRecords.clear();
      billRecords.addAll(tmpBillRecords);
      logger.d("${billRecords.entries.first.value.dateTime}");
    });
    logger.d("billRecords is Empty = ${billRecords.isEmpty}");
  }

  @override
  void initState() {
    alert = Alert(context: context);
    getBillRecords();
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Map<int, BillRecord> filteredBillRecords = Map.from(billRecords)
      ..removeWhere((k, v) {
        final date = DateTime.fromMillisecondsSinceEpoch(v.dateTime);
        if (filterDateTime != null) {
          final isEqual = date.day == (filterDateTime?.day) &&
              date.month == (filterDateTime?.month) &&
              date.year == (filterDateTime?.year);
          return !isEqual;
        }
        return false;
      });
    List<Widget> itemBuilderMenu = [];
    logger.d("filterDateTime is Null = ${filterDateTime == null}");
    logger.d("billRecords is Empty = ${billRecords.isEmpty}");

    for (var e in filteredBillRecords.entries) {
      itemBuilderMenu.add(Center(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: SettingButton(
                colorScheme: colorScheme,
                callbackRebuild: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => List24(billRecord: e.value)));
                },
                callbackDelete: () {
                  alert!.showAlert(
                      "Delete Bill", "Are You Sure?", true, () async {});
                },
                content: e.value.dateTime.toString(),
              ))));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: SafeArea(child: ListView(children: itemBuilderMenu))),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: DateTimeField(
                    value: filterDateTime,
                    decoration: const InputDecoration(
                      labelText: 'Enter Date',
                      helperText: 'DD/MM/YYYY',
                    ),
                    dateFormat: DateFormat('dd/MM/yyyy'),
                    initialPickerDateTime: DateTime.now(),
                    mode: DateTimeFieldPickerMode.date,
                    onChanged: (DateTime? value) {
                      if (value != null) {
                        setState(() {
                          filterDateTime = value;
                        });
                      }
                    })),
            crossFadeState: _showWidgetB
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            false,
            true
          ], listCallback: [
            () {
              Navigator.pop(context);
            },
            () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () {
              setState(() {
                _showWidgetB = !_showWidgetB;
                filterDateTime = null;
              });
            },
          ], icons: [
            Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.home,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.search,
              color: colorScheme.primary,
            )
          ]),
        ],
      ),
    );
  }
}
