import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/order_setting_button.dart';

class ListScreen47 extends StatefulWidget {
  const ListScreen47({super.key});

  @override
  State<ListScreen47> createState() => _ListScreen47State();
}

class _ListScreen47State extends State<ListScreen47> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();

  Alert? alert;
  String filterTitleBillId = "";
  bool _showWidgetB = false;
  final Map<int, bool> checkedBillIdList = {};
  final Map<int, BillRecord> billRecords = {};

  void getBillRecords() async {
    final Map<int, BillRecord> tmpBillRecords = await dataHelper.billRecords(
        where: 'isLeft = ?', whereArgs: [0], limit: null);
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
                  dataHelper.deleteBillRecord(k);
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
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            false,
            true,
            true
          ], listCallback: [
            () {
              Navigator.pop(context);
            },
            () {
              setState(() {
                _showWidgetB = !_showWidgetB;
                filterTitleBillId = "";
              });
            },
            () {
              List<int> billIdsArg = [];
              checkedBillIdList.forEach((k, v) {
                if (v) {
                  billIdsArg.add(k);
                }
              });
              if (billIdsArg.isEmpty) {
                return;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ListDetail40(
                      onlyView: false,
                      listBillId: billIdsArg,
                    ),
                  ));
            }
          ], icons: [
            Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.search,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.build,
              color: colorScheme.primary,
            )
          ]),
        ],
      ),
    );
  }
}
