import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/list_24.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:menu_qr/widgets/setting_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class List23 extends StatefulWidget {
  const List23({super.key});
  @override
  State<List23> createState() => _List23State();
}

class _List23State extends State<List23> {
  final Logger logger = Logger();
  DateTime? filterDateTime;
  String titleBillRecord = "";
  bool _showWidgetB = false;
  Alert? alert;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final pageViewSize = 3;
  final pageSize = 40;
  final DataHelper dataHelper = DataHelper();
  final List<List<BillRecord>> billRecordsList = [];
  late PageController _pageViewController;

  void getBillRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<BillRecord>> tmpBillRecordsList = [];
    for (var i = 0; i < pageViewSize; i++) {
      final tmpBillRecords = await dataHelper.billRecords(
          where: where,
          whereArgs: whereArgs,
          pageNum: (i + 1),
          pageSize: pageSize);
      tmpBillRecordsList.add(tmpBillRecords);
    }
    setState(() {
      billRecordsList.clear();
      billRecordsList.addAll(tmpBillRecordsList);
    });
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

  Future<void> getBillRecordsAtPageViewIndex(int index, int pageNum) async {
    if (pageNum == 0) return;
    final where = filterDateTime != null ? 'dateTime = ?' : null;
    final whereArgs = filterDateTime != null
        ? [filterDateTime!.millisecondsSinceEpoch]
        : null;
    final tmpBillRecords = await dataHelper.billRecords(
        where: where,
        whereArgs: whereArgs,
        pageNum: pageNum,
        pageSize: pageSize);

    billRecordsList[index].clear();
    billRecordsList[index].addAll(tmpBillRecords);
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

  void _updateCurrentPageIndex(int index) {
    // logger.d('_updateCurrentPageIndex $index');
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  PageView billPageView(int columnSize) {
    final appLocalizations = AppLocalizations.of(context)!;
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return List23View(
              columnSize: columnSize,
              billRecords:
                  billRecordsList.elementAtOrNull(index % pageViewSize) ?? [],
              deleteCallback: (List<BillRecord> billRecords, int index1) {
                alert!.showAlert(
                    appLocalizations.deleteRecord(appLocalizations.billRecord),
                    appLocalizations.areYouSure,
                    true, () async {
                  dataHelper.deleteBillRecord(billRecords[index1].id!);
                  setState(() {
                    billRecordsList[index % pageViewSize].removeAt(index1);
                  });
                });
              },
              rebuildCallback: (List<BillRecord> billRecords, int index1) {
                navigateWithFade(
                    context,
                    List24(
                        billRecord: billRecordsList[index % pageViewSize]
                            [index1]));
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 320).floor() - 1;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
                  child: billPageView((columnSize == 0) ? 1 : columnSize))),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: DateTimeField(
                    value: filterDateTime,
                    decoration: const InputDecoration(
                      helperText: 'DD/MM/YYYY',
                    ),
                    dateFormat: DateFormat('dd/MM/yyyy'),
                    initialPickerDateTime: DateTime.now(),
                    mode: DateTimeFieldPickerMode.date,
                    onChanged: (DateTime? value) {
                      if (value != null) {
                        setState(() {
                          getBillRecords(
                            where: "STRFTIME('%Y-%m-%d', datetime) = ?",
                            whereArgs: [DateFormat('yyyy-MM-dd').format(value)],
                          );
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
                if (filterDateTime != null) {
                  getBillRecords();
                  filterDateTime = null;
                }
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

class List23View extends StatelessWidget {
  const List23View(
      {super.key,
      required this.billRecords,
      required this.deleteCallback,
      required this.rebuildCallback,
      required this.columnSize});
  final Function deleteCallback;
  final Function rebuildCallback;
  final List<BillRecord> billRecords;
  final int columnSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final length = (billRecords.length / columnSize).ceil();

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final idx = (index * columnSize) + i;
            if (idx >= billRecords.length) break;

            itemRow.add(SettingButton(
              colorScheme: colorScheme,
              callbackRebuild: () => rebuildCallback(billRecords, idx),
              callbackDelete: () => deleteCallback(billRecords, idx),
              content: billRecords[idx].dateTime.toString(),
            ));
            if (i != columnSize - 1) {
              itemRow.add(const SizedBox(width: 20));
            }
          }
          for (; i < columnSize; i++) {
            itemRow.add(const SizedBox(width: 322));
            if (i != columnSize - 1) {
              itemRow.add(const SizedBox(width: 20));
            }
          }
          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: itemRow,
              ));
        });
  }
}
