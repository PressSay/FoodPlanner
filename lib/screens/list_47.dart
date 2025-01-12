import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/order_setting_button.dart';
import 'package:menu_qr/widgets/page_indicator.dart';

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
  bool isInit = false;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final pageViewSize = 3;
  final pageSize = 40;

  final Map<int, bool> checkedBillIdList = {};
  final List<List<BillRecord>> billRecords = [];

  final logger = Logger();

  late PageController _pageViewController;

  void getBillRecords() async {
    final List<List<BillRecord>> listTmpBillRecords = [];
    for (var i = 0; i < pageViewSize; i++) {
      final tmpBillRecords = await dataHelper.billRecordsTypeListOnly(
          where: 'isLeft = ?',
          whereArgs: [0],
          pageNum: (i + 1),
          pageSize: pageSize);
      listTmpBillRecords.add(tmpBillRecords);
    }
    setState(() {
      billRecords.clear();
      billRecords.addAll(listTmpBillRecords);
    });
    isInit = true;
  }

  @override
  void initState() {
    alert = Alert(context: context);
    getBillRecords();
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
    logger.d("currentPageIndex $currentPageIndex");

    final index = currentPageIndex;
    final newIndex = index % pageViewSize;
    final pageNum = index + 1;

    logger.d("newIndex $newIndex, iBackward $iBackward,"
        " iForward $iForward, pageNum $pageNum, "
        "previous ${pageNum - 1}, next ${pageNum + 1}");

    switch (newIndex) {
      case 0:
        if (iBackward == 0) {
          getBillRecordsAtPageViewIndex(2, pageNum - 1);
          logger.d("iBackward = 0");
        }
        if (iForward == 1) {
          getBillRecordsAtPageViewIndex(1, pageNum + 1);
          logger.d("iForward = 1");
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getBillRecordsAtPageViewIndex(0, pageNum - 1);
          logger.d("iBackward = 1");
        }
        if (iForward == 2) {
          getBillRecordsAtPageViewIndex(2, pageNum + 1);
          logger.d("iForward = 2");
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getBillRecordsAtPageViewIndex(1, pageNum - 1);
          logger.d("iBackward = 1");
        }
        if (iForward == 0) {
          getBillRecordsAtPageViewIndex(0, pageNum + 1);
          logger.d("iForward = 0");
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
    final tmpBillRecords = await dataHelper.billRecordsTypeListOnly(
        where: 'isLeft = ?',
        whereArgs: [0],
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
          return BillsView47(
              billRecords:
                  billRecords.elementAtOrNull(index % pageViewSize) ?? [],
              filterTitleBillId: filterTitleBillId,
              checkedBillIdList: checkedBillIdList,
              callbackRebuild: (int billId) {
                setState(() {
                  if (!checkedBillIdList.containsKey(billId)) {
                    checkedBillIdList.addAll({billId: false});
                  }
                  checkedBillIdList[billId] = !checkedBillIdList[billId]!;
                });
              },
              callbackDelete: (List<BillRecord> inSideBillRecords, int billId) {
                alert!.showAlert('Delete Bill', 'Are you Sure?', true,
                    () async {
                  dataHelper.deleteBillRecord(billId);
                  setState(() {
                    inSideBillRecords.removeAt(index);
                  });
                  checkedBillIdList.remove(billId);
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: pageViewBuilder(currentWidth),
          )),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
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

class BillsView47 extends StatelessWidget {
  const BillsView47(
      {super.key,
      required this.billRecords,
      required this.filterTitleBillId,
      required this.checkedBillIdList,
      required this.callbackDelete,
      required this.callbackRebuild});
  final List<BillRecord> billRecords;
  final String filterTitleBillId;
  final Map<int, bool> checkedBillIdList;
  final Function callbackDelete;
  final Function callbackRebuild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredBillRecords = (filterTitleBillId.isNotEmpty)
        ? billRecords
            .where((element) =>
                element.dateTime.toString().contains(filterTitleBillId))
            .toList()
        : billRecords.toList();

    return ListView.builder(
        itemCount: filteredBillRecords.length,
        itemBuilder: (context, index1) {
          final v = filteredBillRecords[index1];
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: OrderSettingButton(
                  content: '${v.dateTime}',
                  colorScheme: colorScheme,
                  isChecked: checkedBillIdList[v.id!] ?? false,
                  callbackCheck: () => callbackRebuild(v.id!),
                  callbackDelete: () => callbackDelete(billRecords, v.id!)),
            ),
          );
        });
  }
}
