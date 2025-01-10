import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/order_setting_button_online.dart';

class ListOnline48 extends StatefulWidget {
  const ListOnline48({super.key});

  @override
  State<ListOnline48> createState() => _ListOnline48State();
}

class _ListOnline48State extends State<ListOnline48> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();

  String filterTitleBillId = "";
  bool _showWidgetB = false;
  bool _showWidgetC = false;

  Alert? alert;
  final Map<int, bool> checkedBillIdList = {};
  final Map<int, BillRecord> billRecordsArg = {};
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
    // this List Will be online
    Map<int, BillRecord> filteredBillRecords = (filterTitleBillId.isEmpty)
        ? (Map.from(billRecords)..removeWhere((k, v) => v.isLeft))
        : (Map.from(billRecords)
          ..removeWhere(
              (k, v) => !'${v.dateTime}'.contains(filterTitleBillId)));

    filteredBillRecords.forEach((k, v) {
      Widget billButton = Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: OrderSettingButtonOnl(
              content: '${v.dateTime}',
              colorScheme: colorScheme,
              isChecked: checkedBillIdList[k] ?? false,
              callbackCheck: () {
                setState(() {
                  if (!checkedBillIdList.containsKey(k)) {
                    checkedBillIdList.addAll({k: false});
                    billRecordsArg.addAll({k: v});
                  }
                  checkedBillIdList[k] = !checkedBillIdList[k]!;
                });
              },
              callbackRebuild: () {
                setState(() {
                  _showWidgetC = !_showWidgetC;
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
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            )),
                            minimumSize: WidgetStateProperty.all(Size(80, 80))),
                        onPressed: () {},
                        child: Icon(
                          Icons.flag,
                          size: 30,
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              )),
                              minimumSize:
                                  WidgetStateProperty.all(Size(80, 80))),
                          onPressed: () {},
                          child: Icon(Icons.local_shipping, size: 30)),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            )),
                            minimumSize: WidgetStateProperty.all(Size(80, 80))),
                        onPressed: () {},
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 30,
                        )),
                  ],
                )),
            crossFadeState: _showWidgetC
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search BillId',
                    fillColor: colorScheme.primaryContainer),
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
