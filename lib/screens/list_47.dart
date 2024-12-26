import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/widgets/setting_button.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:provider/provider.dart';

class ListScreen47 extends StatefulWidget {
  const ListScreen47({super.key});

  @override
  State<ListScreen47> createState() => _ListScreen47State();
}

class _ListScreen47State extends State<ListScreen47> {
  String filterTitleBillId = "";
  final TextEditingController _controller = TextEditingController();
  bool _showWidgetB = false;
  Map<int, bool> checkedBillIdList = {};
  Map<int, BillRecord> billRecords = {};

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    BillProvider billProvider = context.watch<BillProvider>();
    List<Widget> itemBuilder = [];

    Map<int, BillRecord> filteredBillRecords = (filterTitleBillId.isEmpty)
        ? (Map.from(billProvider.billRecords)..removeWhere((k, v) => v.isLeft))
        : (Map.from(billProvider.billRecords)
          ..removeWhere(
              (k, v) => !'${v.dateTime}'.contains(filterTitleBillId)));

    filteredBillRecords.forEach((k, v) {
      Widget billButton = Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: SettingButton(
              nameBill: '${v.dateTime}',
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
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: ListView(
              children: itemBuilder,
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(), // Thay thế CategoryBar bằng SizedBox
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
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
                color: colorScheme.primaryContainer,
                border: Border(
                    top: BorderSide(width: 1.0, color: colorScheme.primary))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BottomBarButton(
                        child: Icon(
                          Icons.arrow_back,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(width: 42),
                    BottomBarButton(
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
      )),
    );
  }
}
