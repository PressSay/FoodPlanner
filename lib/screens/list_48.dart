import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/order_setting_button_online.dart';
import 'package:provider/provider.dart';

class ListOnline48 extends StatefulWidget {
  const ListOnline48({super.key});

  @override
  State<ListOnline48> createState() => _ListOnline48State();
}

class _ListOnline48State extends State<ListOnline48> {
  String filterTitleBillId = "";
  final TextEditingController _controller = TextEditingController();
  bool _showWidgetB = false;
  bool _showWidgetC = false;

  Map<int, bool> checkedBillIdList = {};
  Map<int, BillRecord> billRecords = {};

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final colorBottomBar = colorScheme.secondaryContainer;

    BillProvider billProvider = context.watch<BillProvider>();
    List<Widget> itemBuilder = [];

    // this List Will be online
    Map<int, BillRecord> filteredBillRecords = (filterTitleBillId.isEmpty)
        ? (Map.from(billProvider.billRecords)..removeWhere((k, v) => v.isLeft))
        : (Map.from(billProvider.billRecords)
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
                    billRecords.addAll({k: v});
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
                billProvider.removeBillRecordAtId(k);
                billRecords.removeWhere((k1, v1) => k == k1);
                checkedBillIdList.removeWhere((k1, v1) => k == k1);
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
          Container(
            height: 56,
            decoration: BoxDecoration(
                color: colorBottomBar,
                border: Border(
                    top: BorderSide(width: 1.0, color: colorScheme.primary))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          billRecords.removeWhere((k, v) {
                            return !checkedBillIdList[k]!;
                          });
                          checkedBillIdList.removeWhere((k, v) {
                            return !checkedBillIdList[k]!;
                          });
                          if (billRecords.isEmpty ||
                              checkedBillIdList.isEmpty) {
                            return;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => ListDetail40(
                                  billRecords: billRecords,
                                  isViewFromTable: false,
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
