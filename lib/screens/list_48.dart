import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  DateTime? dateFilter;
  bool _showWidgetB = false;
  bool _showWidgetC = false;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  Alert? alert;
  final Map<int, bool> checkedBillIdList = {};
  final Map<int, BillRecord> billRecordsArg = {};
  final List<List<BillRecord>> billRecords = [];
  final pageViewSize = 3;
  final pageSize = 40;

  late PageController _pageViewController;

  void getBillRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<BillRecord>> listTmpBillRecords = [];
    for (var i = 0; i < pageViewSize; i++) {
      final tmpBillRecords = await dataHelper.billRecords(
          where: where,
          whereArgs: whereArgs,
          pageNum: (i + 1),
          pageSize: pageSize);
      listTmpBillRecords.add(tmpBillRecords);
    }
    setState(() {
      billRecords.clear();
      billRecords.addAll(listTmpBillRecords);
    });
  }

  @override
  void initState() {
    alert = Alert(context: context);
    getBillRecords(where: 'isLeft = ?', whereArgs: [0]);
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void _updateCurrentPageIndex(int index) {
    // logger.d('_updateCurrentPageIndex $index');
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }

    final index = currentPageIndex;
    final newIndex = index % pageViewSize;
    final pageNum = index + 1;

    switch (newIndex) {
      case 0:
        if (iBackward == 0) {
          getBillRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getBillRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getBillRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getBillRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getBillRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getBillRecordsAtPageViewIndex(0, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
    }

    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  Future<void> getBillRecordsAtPageViewIndex(int index, int pageNum) async {
    if (pageNum == 0) return;
    final where =
        (dateFilter != null) ? 'dateTime = ? AND isLeft = ?' : 'isLeft = ?';
    final whereArgs =
        (dateFilter != null) ? [dateFilter!.millisecondsSinceEpoch, 0] : [0];
    final tmpBillRecords = await dataHelper.billRecords(
        where: where,
        whereArgs: whereArgs,
        pageNum: pageNum,
        pageSize: pageSize);

    billRecords[index].clear();
    billRecords[index].addAll(tmpBillRecords);
  }

  Widget pageViewBuilder(double currentWidth) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return BillsView48(
              billRecords:
                  billRecords.elementAtOrNull(index % pageViewSize) ?? [],
              checkedBillIdList: checkedBillIdList,
              callbackCheck: (List<BillRecord> inSideBillRecords, int index1) {
                setState(() {
                  if (!checkedBillIdList
                      .containsKey(inSideBillRecords[index1].id!)) {
                    checkedBillIdList
                        .addAll({inSideBillRecords[index1].id!: false});
                  }
                  checkedBillIdList[inSideBillRecords[index1].id!] =
                      !checkedBillIdList[inSideBillRecords[index1].id!]!;
                });
              },
              callbackRebuild:
                  (List<BillRecord> inSideBillRecords, int index1) {
                setState(() {
                  _showWidgetC = !_showWidgetC;
                });
              },
              callbackDelete: (List<BillRecord> inSideBillRecords, int index1) {
                alert!.showAlert('Delete Bill', 'Are you Sure?', true,
                    () async {
                  dataHelper.deleteBillRecord(inSideBillRecords[index1].id!);
                  inSideBillRecords.removeAt(index1);
                  checkedBillIdList.remove(inSideBillRecords[index1].id!);
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: pageViewBuilder(MediaQuery.of(context).size.width),
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
                child: DateTimeField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Date',
                      helperText: 'DD/MM/YYYY',
                    ),
                    dateFormat: DateFormat('dd/MM/yyyy'),
                    initialPickerDateTime: DateTime.now(),
                    mode: DateTimeFieldPickerMode.date,
                    onChanged: (DateTime? value) {
                      _showWidgetB = !_showWidgetB;
                      if (value != null) {
                        getBillRecords(
                            where: 'dateTime = ? AND isLeft = ?',
                            whereArgs: [value.millisecondsSinceEpoch, 0]);
                        dateFilter = value;
                      }
                    })),
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
                if (dateFilter != null) {
                  dateFilter = null;
                  getBillRecords(where: 'isLeft = ?', whereArgs: [0]);
                }
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

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}

class BillsView48 extends StatelessWidget {
  const BillsView48(
      {super.key,
      required this.billRecords,
      required this.checkedBillIdList,
      required this.callbackDelete,
      required this.callbackRebuild,
      required this.callbackCheck});
  final List<BillRecord> billRecords;
  final Map<int, bool> checkedBillIdList;
  final Function callbackDelete;
  final Function callbackRebuild;
  final Function callbackCheck;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
        itemCount: billRecords.length,
        itemBuilder: (context, index1) {
          final v = billRecords[index1];
          return Center(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: OrderSettingButtonOnl(
                    content: '${v.dateTime}',
                    colorScheme: colorScheme,
                    isChecked: checkedBillIdList[v.id!] ?? false,
                    callbackCheck: () => callbackCheck(billRecords, index1),
                    callbackRebuild: () => callbackRebuild(),
                    callbackDelete: () => callbackDelete(billRecords, index1),
                  )));
        });
  }
}
