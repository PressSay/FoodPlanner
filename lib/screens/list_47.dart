import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/order_setting_button.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListScreen47 extends StatefulWidget {
  const ListScreen47({super.key});

  @override
  State<ListScreen47> createState() => _ListScreen47State();
}

class _ListScreen47State extends State<ListScreen47> {
  Alert? alert;
  DateTime? dateFilter;
  bool _showWidgetB = false;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final DataHelper dataHelper = DataHelper();
  final pageViewSize = 3;
  final pageSize = 40;
  final Map<int, bool> checkedBillIdList = {};
  final List<List<BillRecord>> billRecords = [];

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

  Widget pageViewBuilder(double currentWidth, int columnSize) {
    final appLocalizations = AppLocalizations.of(context)!;

    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return BillsView47(
              columnSize: columnSize,
              billRecords: billRecords.elementAtOrNull(index % pageViewSize) ??
                  [], // truyền mảng là truyền tham chiếu
              checkedBillIdList: checkedBillIdList,
              callbackRebuild:
                  (List<BillRecord> inSideBillRecords, int index1) {
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
              callbackDelete: (List<BillRecord> inSideBillRecords, int index1) {
                alert!.showAlert(
                    appLocalizations.deleteRecord(appLocalizations.billRecord),
                    appLocalizations.areYouSure,
                    true, () async {
                  dataHelper.deleteBillRecord(inSideBillRecords[index1].id!);
                  setState(() {
                    billRecords[index % pageViewSize].removeAt(index1);
                  });
                  checkedBillIdList.remove(inSideBillRecords[index1].id!);
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 322).floor() - 1;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: pageViewBuilder(
                currentWidth, (columnSize == 0) ? 1 : columnSize),
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
                child: DateTimeField(
                    value: dateFilter,
                    decoration: const InputDecoration(
                      helperText: 'DD/MM/YYYY',
                    ),
                    dateFormat: DateFormat('dd/MM/yyyy'),
                    initialPickerDateTime: DateTime.now(),
                    mode: DateTimeFieldPickerMode.date,
                    onChanged: (DateTime? value) {
                      _showWidgetB = !_showWidgetB;
                      if (value != null) {
                        getBillRecords(
                            where: "STRFTIME('%Y-%m-%d', datetime) = ? "
                                "AND isLeft = ?",
                            whereArgs: [
                              DateFormat('yyyy-MM-dd').format(value),
                              0
                            ]);
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
              navigateWithFade(
                      context,
                      ListDetail40(
                        onlyView: false,
                        listBillId: billIdsArg,
                      ))
                  .then((_) =>
                      getBillRecords(where: 'isLeft = ?', whereArgs: [0]));
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
      required this.columnSize,
      required this.billRecords,
      required this.checkedBillIdList,
      required this.callbackDelete,
      required this.callbackRebuild});
  final int columnSize;
  final List<BillRecord> billRecords;
  final Map<int, bool> checkedBillIdList;
  final Function callbackDelete;
  final Function callbackRebuild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final length = (billRecords.length / columnSize).ceil();

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index1) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final idx = (index1 * columnSize) + i;
            if (idx >= billRecords.length) break;
            final v = billRecords[idx];

            itemRow.add(OrderSettingButton(
                content: '${v.dateTime}',
                colorScheme: colorScheme,
                isChecked: checkedBillIdList[v.id!] ?? false,
                callbackCheck: () => callbackRebuild(billRecords, idx),
                callbackDelete: () => callbackDelete(billRecords, idx)));
            if (i != columnSize - 1) itemRow.add(const SizedBox(width: 20));
          }
          for (; i < columnSize; i++) {
            itemRow.add(const SizedBox(width: 322));
            if (i != columnSize - 1) itemRow.add(const SizedBox(width: 20));
          }
          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemRow));
        });
  }
}
