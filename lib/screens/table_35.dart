import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/table_36.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:menu_qr/widgets/table_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:menu_qr/services/utils.dart';

class Table35 extends StatefulWidget {
  const Table35({super.key, required this.isList, required this.billId});
  final bool isList;
  final int billId;
  @override
  State<StatefulWidget> createState() => _Table35();
}

class _Table35 extends State<Table35> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final int numEleInRow = 2;
  final List<List<TableRecord>> tableRecordsList = [];
  late PageController _pageViewController;

  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;
  int indexTableRecordsList = 0;
  int indexTableRecords = 0;

  final pageViewSize = 3;
  final pageSize = 40;

  String filterTitleTable = "";
  bool _showWidgetB = false;

  void getTableRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<TableRecord>> listTmpTableRecords = [];
    for (var i = 0; i < pageViewSize; i++) {
      final tmpTableRecords = await dataHelper.tableRecords(
          where: where,
          whereArgs: whereArgs,
          pageNum: (i + 1),
          pageSize: pageSize);
      listTmpTableRecords.add(tmpTableRecords);
      // logger.d('getTableRecords $i');
    }
    setState(() {
      tableRecordsList.clear();
      tableRecordsList.addAll(listTmpTableRecords);
    });
  }

  @override
  void initState() {
    getTableRecords();
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void saveBillToRam(int tableId, nameTable, BillProvider billProvider,
      DishProvider dishProvider) {
    final tax = dishProvider.tax;
    final discount = dishProvider.discount;
    billProvider.setBillRecord(tax, 0, discount, tableId, nameTable, false,
        false, dishProvider.indexDishListSorted);
  }

  Future<void> getTableRecordsAtPageViewIndex(int index, int pageNum) async {
    if (pageNum == 0) return;
    final where = filterTitleTable.isNotEmpty ? 'name LIKE ?' : null;
    final whereArgs =
        filterTitleTable.isNotEmpty ? ['%$filterTitleTable%'] : null;

    final tmpTableRecords = await dataHelper.tableRecords(
        where: where,
        whereArgs: whereArgs,
        pageNum: pageNum,
        pageSize: pageSize);

    tableRecordsList[index].clear();
    tableRecordsList[index].addAll(tmpTableRecords);
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
          getTableRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getTableRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getTableRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getTableRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getTableRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getTableRecordsAtPageViewIndex(0, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
    }

    setState(() {
      _currentPageIndex = currentPageIndex % pageViewSize;
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

  PageView tableRecordPageView(
      BillProvider billProvider, DishProvider dishProvider) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return Table35View(
              tableRecords:
                  tableRecordsList.elementAtOrNull(index % pageViewSize) ?? [],
              columnSize: numEleInRow,
              callback: (List<TableRecord> tableRecords, int index1) {
                final value = tableRecords[index1];
                indexTableRecordsList = index % pageViewSize;
                indexTableRecords = index1;
                if (widget.billId != 0) {
                  Map<String, dynamic> onValue = {
                    'tableRecord': value,
                    'indexTableRecordsList': indexTableRecordsList,
                    'indexTableRecords': indexTableRecords
                  };
                  Navigator.pop(context, onValue);
                  return;
                }
                if (!widget.isList) {
                  saveBillToRam(
                      value.id!, value.name, billProvider, dishProvider);
                }
                navigateWithFade(
                  context,
                  Table36(
                    isList: widget.isList,
                    tableRecord: value,
                    oldIndexTableRecordsList: indexTableRecordsList,
                    oldIndexTableRecords: indexTableRecords,
                  ),
                ).then((onValue) {
                  // 36 -> 35 phải có tableOldId và tableNewId để cập nhật
                  if (onValue is Map<String, int>) {
                    final oldId = onValue['oldId']!;
                    final newId = onValue['newId']!;
                    final oldIndexTableRecordsList =
                        onValue['oldIndexTableRecordsList']!;
                    final oldIndexTableRecords =
                        onValue['oldIndexTableRecords']!;
                    final newIndexTableRecordsList =
                        onValue['newIndexTableRecordsList']!;
                    final newIndexTableRecords =
                        onValue['newIndexTableRecords']!;
                    // logger.d('oldId: $oldId, newId: $newId, '
                    //     'oldIndexTableRecordsList: $oldIndexTableRecordsList, '
                    //     'oldIndexTableRecords: $oldIndexTableRecords, '
                    //     'newIndexTableRecordsList: $newIndexTableRecordsList, '
                    //     'newIndexTableRecords: $newIndexTableRecords');
                    if (onValue.isNotEmpty) {
                      updateTableRecord(
                          oldIndexTableRecordsList: oldIndexTableRecordsList,
                          oldIndexTableRecords: oldIndexTableRecords,
                          newIndexTableRecordsList: newIndexTableRecordsList,
                          newIndexTableRecords: newIndexTableRecords,
                          oldId: oldId,
                          newId: newId);
                      // logger.d("Đã cập nhật table old và table new");
                      return;
                    }
                    // logger.d("Không cập nhật table old và table new");
                  }
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final BillProvider billProvider = context.watch<BillProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
                child: tableRecordPageView(billProvider, dishProvider)),
          ),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
          AnimatedCrossFade(
              firstChild: SizedBox(),
              secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: appLocalizations
                            .search(appLocalizations.tableRecord),
                        filled: true,
                      ),
                      onSubmitted: (text) {
                        setState(() {
                          _showWidgetB = !_showWidgetB;
                          if (text.isNotEmpty) {
                            filterTitleTable = text;
                            getTableRecords(
                                where: 'name LIKE ?', whereArgs: ['%$text%']);
                          }
                        });
                      })),
              crossFadeState: _showWidgetB
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200)),
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
                if (filterTitleTable.isNotEmpty) {
                  getTableRecords();
                  filterTitleTable = "";
                }
              });
            }
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
          ])
        ],
      ),
    );
  }

  void updateTableRecord(
      {required int oldIndexTableRecordsList,
      required int oldIndexTableRecords,
      required int newIndexTableRecordsList,
      required int newIndexTableRecords,
      required int oldId,
      required int newId}) async {
    TableRecord? tableRecordOld = await dataHelper.tableRecord(oldId);
    TableRecord? tableRecordNew = await dataHelper.tableRecord(newId);
    setState(() {
      if (tableRecordOld != null) {
        TableRecord oldTableRecord =
            tableRecordsList[oldIndexTableRecordsList][oldIndexTableRecords];
        if ((oldTableRecord.id ?? 0) == oldId) {
          tableRecordsList[oldIndexTableRecordsList][oldIndexTableRecords] =
              tableRecordOld;
        }
      }
      if (tableRecordNew != null) {
        TableRecord newTableRecord =
            tableRecordsList[newIndexTableRecordsList][newIndexTableRecords];
        if ((newTableRecord.id ?? 0) == newId) {
          tableRecordsList[newIndexTableRecordsList][newIndexTableRecords] =
              tableRecordNew;
        }
      }
    });
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

class Table35View extends StatelessWidget {
  const Table35View(
      {super.key,
      required this.tableRecords,
      required this.columnSize,
      required this.callback});
  final List<TableRecord> tableRecords;
  final int columnSize;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    final length = (tableRecords.length / columnSize).ceil();

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final newIndex = index * columnSize + i;
            // trường hợp cuối cùng
            if (newIndex >= tableRecords.length) {
              break;
            }
            final tableButton = TableButton(
              nameTable: tableRecords[newIndex].name,
              callBack: () => callback(tableRecords, newIndex),
            );
            itemRow.add(tableButton);
            if (i != columnSize - 1) {
              itemRow.add(const SizedBox(width: 20));
            }
          }
          for (; i < columnSize; i++) {
            itemRow.add(const SizedBox(width: 120));
            if (i != columnSize - 1) {
              itemRow.add(const SizedBox(width: 20));
            }
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: itemRow,
            ),
          );
        });
  }
}
