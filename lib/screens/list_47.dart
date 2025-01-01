import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/bill_record_helper.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/widgets/order_setting_button.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ListScreen47 extends StatefulWidget {
  const ListScreen47({super.key});

  @override
  State<ListScreen47> createState() => _ListScreen47State();
}

class _ListScreen47State extends State<ListScreen47> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final BillRecordHelper billRecordHelper = BillRecordHelper();

  Alert? alert;
  String filterTitleBillId = "";
  bool _showWidgetB = false;
  Map<int, bool> checkedBillIdList = {};
  Map<int, BillRecord> billRecords = {};

  void getBillRecords() async {
    Database db = await dataHelper.database;
    Map<int, BillRecord> tmpBillRecords =
        await billRecordHelper.billRecords(db, 'isLeft = ?', [0]);
    setState(() {
      billRecords.clear();
      billRecords.addAll(tmpBillRecords);
    });
  }

  @override
  void initState() {
    alert = Alert(context: context);
    getBillRecords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final colorBottomBar = colorScheme.secondaryContainer;

    List<Widget> itemBuilder = [];
    Map<int, BillRecord> filteredBillRecords = (filterTitleBillId.isEmpty)
        ? (Map.from(billRecords)..removeWhere((k, v) => v.isLeft))
        : (Map.from(billRecords)
          ..removeWhere(
              (k, v) => !'${v.dateTime}'.contains(filterTitleBillId)));

    filteredBillRecords.forEach((k, v) {
      Widget billButton = Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: OrderSettingButton(
              content: '${v.dateTime}',
              colorScheme: colorScheme,
              isChecked: checkedBillIdList[v.id!] ?? false,
              callbackCheck: () {
                if (!checkedBillIdList.containsKey(v.id!)) {
                  checkedBillIdList.addAll({v.id!: false});
                }
                setState(() {
                  checkedBillIdList[k] = !checkedBillIdList[k]!;
                });
              },
              callbackDelete: () {
                alert!.showAlert('Delete Bill', 'Are you Sure?', true,
                    () async {
                  Database db = await dataHelper.database;
                  billRecordHelper.deleteBillRecord(k, db);
                  setState(() {
                    billRecords.remove(k);
                  });
                  checkedBillIdList.remove(k);
                });
              }),
        ),
      );
      itemBuilder.add(billButton);
    });

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: ListView(
              children: itemBuilder,
            ),
          )),
          AnimatedCrossFade(
            firstChild: SizedBox(), // Thay thế CategoryBar bằng SizedBox
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search BillId',
                ),
                onSubmitted: (text) {
                  setState(() {
                    _showWidgetB = !_showWidgetB;
                    filterTitleBillId = text;
                  });
                },
              ),
            ),
            crossFadeState: _showWidgetB
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          Container(
            height: 68,
            decoration: BoxDecoration(
                color: colorBottomBar,
                border: Border(
                    top: BorderSide(width: 1.0, color: colorScheme.primary))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.arrow_back,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(width: 42),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.search,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          setState(() {
                            _showWidgetB = !_showWidgetB;
                            filterTitleBillId = "";
                          });
                        }),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.build,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Map<int, BillRecord> billRecordsArg =
                              Map.from(billRecords)
                                ..removeWhere(
                                    (k, v) => !(checkedBillIdList[k] ?? false));
                          if (billRecordsArg.isEmpty) {
                            return;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => ListDetail40(
                                  billRecords: billRecordsArg,
                                  onlyView: false,
                                ),
                              ));
                        }),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
