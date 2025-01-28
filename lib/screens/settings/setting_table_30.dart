import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:menu_qr/widgets/setting_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Table30 extends StatefulWidget {
  const Table30({super.key});
  @override
  State<Table30> createState() => _Table30State();
}

class _Table30State extends State<Table30> {
  String filterTitleTable = "";
  bool _showWidgetB = false;
  Alert? alert;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;
  int indexTableRecordsList = 0;
  int indexTableRecords = 0;
  int tableId = 0;
  int numOfPeople = 0;

  final pageViewSize = 3;
  final pageSize = 40;
  final List<List<TableRecord>> tableRecordsList = [];
  final TextEditingController _controllerTableOld = TextEditingController();
  final TextEditingController _controllerDescOld = TextEditingController();
  final TextEditingController _controllerTable = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  final DataHelper dataHelper = DataHelper();
  late PageController _pageViewController;

  void getTableRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<TableRecord>> listTmpTableRecords = [];
    for (var i = 0; i < pageViewSize; i++) {
      final tmpTableRecords = await dataHelper.tableRecords(
          where: where,
          whereArgs: whereArgs,
          pageNum: (i + 1),
          pageSize: pageSize);
      listTmpTableRecords.add(tmpTableRecords);
    }
    setState(() {
      tableRecordsList.clear();
      tableRecordsList.addAll(listTmpTableRecords);
    });
  }

  void updateTableRecord(String status, String content) async {
    final TableRecord newE = TableRecord(
        id: tableId,
        name: _controllerTableOld.text,
        desc: _controllerDescOld.text,
        numOfPeople: numOfPeople);
    dataHelper.updateTableRecord(newE);
    setState(() {
      tableRecordsList[indexTableRecordsList][indexTableRecords] = newE;
    });
    alert!.showAlert(status, content, false, null);
  }

  void insertTableRecord(String statusFailed, String contentFailed,
      String status, String content) async {
    if (_controllerTable.text.isEmpty || _controllerTable.text.isEmpty) {
      alert!.showAlert(statusFailed, contentFailed, false, null);
      return;
    }
    final TableRecord newE = TableRecord(
        name: _controllerTable.text,
        desc: _controllerDesc.text,
        numOfPeople: 0);
    int lastId = await dataHelper.insertTableRecord(newE);
    if (lastId == 0) {
      alert!.showAlert(statusFailed, contentFailed, false, null);
    }
    newE.id = lastId;
    if (tableRecordsList[_currentPageIndex].length < pageSize) {
      // logger.d('e.length ${tableRecordsList[_currentPageIndex].length}');
      setState(() {
        tableRecordsList[_currentPageIndex].add(newE);
      });
    }
    alert!.showAlert(status, content, false, null);
  }

  @override
  void initState() {
    alert = Alert(context: context);
    getTableRecords();
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  Future<void> getTableRecordsAtPageViewIndex(int index, int pageNum) async {
    if (pageNum == 0) return;
    final where = filterTitleTable.isNotEmpty ? 'name LIKE ?' : null;
    final whereArgs =
        filterTitleTable.isNotEmpty ? ['%$filterTitleTable%'] : null;
    final tmpBillRecords = await dataHelper.tableRecords(
        where: where,
        whereArgs: whereArgs,
        pageNum: pageNum,
        pageSize: pageSize);

    tableRecordsList[index].clear();
    tableRecordsList[index].addAll(tmpBillRecords);
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

  PageView tablePageView(String statusDelete, String contentDelete) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return SettingTable30View(
              tableRecords:
                  tableRecordsList.elementAtOrNull(index % pageViewSize) ?? [],
              deleteCallback:
                  (List<TableRecord> insideTableRecords, int index1) {
                alert!.showAlert(statusDelete, contentDelete, true, () {
                  dataHelper.deleteTableRecord(insideTableRecords[index1].id!);
                  setState(() {
                    insideTableRecords.removeAt(index1);
                  });
                });
              },
              rebuildCallback:
                  (List<TableRecord> insideTableRecords, int index1) {
                _controllerDescOld.text = insideTableRecords[index1].desc;
                _controllerTableOld.text = insideTableRecords[index1].name;
                tableId = insideTableRecords[index1].id!;
                numOfPeople = insideTableRecords[index1].numOfPeople;
                indexTableRecordsList = index % pageViewSize;
                indexTableRecords = index1;
                // logger.d('desc ${insideTableRecords[index1].desc}, '
                //     'name ${insideTableRecords[index1].name}, '
                //     'id ${insideTableRecords[index1].id}, '
                //     'numOfPeople ${insideTableRecords[index1].numOfPeople}, '
                //     'indexTableRecordsList $indexTableRecordsList, '
                //     'indexTableRecords $indexTableRecords');
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final applocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: tablePageView(
                applocalizations.deleteRecord(applocalizations.tableRecord),
                applocalizations.areYouSure),
          )),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 1.0, color: colorScheme.primary))),
              child: ListView(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Center(
                        child: SizedBox(
                            width: 288,
                            child: TextField(
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDescOld,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: applocalizations.recordDesc(
                                      applocalizations.oldTableRecord),
                                ))),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4)),
                                  border: BorderDirectional(
                                      top: BorderSide(
                                          color: colorScheme.primary),
                                      bottom: BorderSide(
                                          color: colorScheme.primary),
                                      start: BorderSide(
                                          color: colorScheme.primary))),
                              child: Icon(
                                Icons.table_bar,
                                color: colorScheme.primary,
                                size: 20,
                              )),
                          SizedBox(
                              width: 192,
                              height: 48,
                              child: TextField(
                                  style: TextStyle(color: colorScheme.primary),
                                  controller: _controllerTableOld,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only()),
                                    labelText: applocalizations
                                        .title(applocalizations.oldTableRecord),
                                  ))),
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4)),
                            child: Material(
                              color: colorScheme.onPrimary,
                              child: InkWell(
                                splashColor: colorScheme.onPrimaryContainer,
                                child: SizedBox(
                                  width: 48, // width * 0.15 - 2
                                  height: 48,
                                  child: Center(
                                    child: Icon(
                                      Icons.save,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  updateTableRecord(applocalizations.update,
                                      applocalizations.success);
                                },
                              ),
                            ),
                          )
                        ]),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4)),
                                    border: BorderDirectional(
                                        top: BorderSide(
                                            color: colorScheme.primary),
                                        bottom: BorderSide(
                                            color: colorScheme.primary),
                                        start: BorderSide(
                                            color: colorScheme.primary))),
                                child: Icon(
                                  Icons.table_bar,
                                  color: colorScheme.primary,
                                  size: 20,
                                )),
                            SizedBox(
                                width: 240,
                                height: 48,
                                child: TextField(
                                    style:
                                        TextStyle(color: colorScheme.primary),
                                    controller: _controllerTable,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4))),
                                      labelText: applocalizations
                                          .title(applocalizations.tableRecord),
                                    )))
                          ])),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Center(
                        child: SizedBox(
                            width: 288,
                            child: TextField(
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDesc,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: applocalizations
                                      .recordDesc(applocalizations.tableRecord),
                                ))),
                      )),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: TextField(
                    controller: _controllerDescOld,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          applocalizations.search(applocalizations.tableRecord),
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        if (text.isNotEmpty) {
                          getTableRecords(
                              where: 'name LIKE ?', whereArgs: ['%$text%']);
                          filterTitleTable = text;
                        }
                      });
                    })),
            crossFadeState: _showWidgetB
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            true,
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
            },
            () {
              insertTableRecord(applocalizations.save, applocalizations.failed,
                  applocalizations.save, applocalizations.success);
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
            ),
            Icon(
              Icons.add,
              color: colorScheme.primary,
            )
          ])
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

class SettingTable30View extends StatelessWidget {
  const SettingTable30View(
      {super.key,
      required this.tableRecords,
      required this.deleteCallback,
      required this.rebuildCallback});
  final List<TableRecord> tableRecords;
  final Function deleteCallback;
  final Function rebuildCallback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
        itemCount: tableRecords.length,
        itemBuilder: (context, index) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: SettingButton(
                  colorScheme: colorScheme,
                  callbackRebuild: () => rebuildCallback(tableRecords, index),
                  callbackDelete: () => deleteCallback(tableRecords, index),
                  content: tableRecords[index].name),
            ),
          );
        });
  }
}
