import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:menu_qr/widgets/page_indicator.dart';

class List24 extends StatefulWidget {
  const List24({super.key, required this.billRecord});
  final BillRecord billRecord;
  @override
  State<StatefulWidget> createState() => _List24();
}

class _List24 extends State<List24> {
  int categoryId = 0;
  double total = 0;
  String timeZone = 'vi_VN';
  String filterTitleDish = "";
  bool _showWidgetB = false;
  bool isInit = true;
  Alert? alert;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final logger = Logger();
  final dataHelper = DataHelper();
  final pageViewSize = 3;
  final pageSize = 40;
  final List<List<PreOrderedDishRecord>> preOrderedDishRecordsList = [];
  final TextEditingController _controller = TextEditingController();
  late PageController _pageViewController;

  void getPreOrderedDishRecords(
      {String? where, List<Object?>? whereArgs}) async {
    logger.d('billId = ${widget.billRecord.id ?? 0}');
    final List<List<PreOrderedDishRecord>> tmpPreOrderedDishRecordsList = [];
    var tmpTotal = 0.0;
    for (var i = 0; i < pageViewSize; i++) {
      final tmpPreOrderedDishRecord = await dataHelper.preOrderedDishList(
          where: 'billId = ? ${(where != null ? 'AND $where' : "")}',
          whereArgs: [widget.billRecord.id!, ...(whereArgs ?? [])],
          pageNum: (i + 1),
          pageSize: pageSize);
      for (var e in tmpPreOrderedDishRecord) {
        tmpTotal = tmpTotal + e.price * e.amount;
      }
      tmpPreOrderedDishRecordsList.add(tmpPreOrderedDishRecord);
    }

    setState(() {
      preOrderedDishRecordsList.clear();
      preOrderedDishRecordsList.addAll(tmpPreOrderedDishRecordsList);
      total = tmpTotal - widget.billRecord.discount;
    });
  }

  @override
  void initState() {
    getPreOrderedDishRecords();
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  Future<void> getPreOrderdDishRecordsAtPageViewIndex(
      {required int index, required int pageNum}) async {
    if (pageNum == 0) return;
    final tmpPreOrderedDishRecord = await dataHelper.preOrderedDishList(
        where: 'billId = ? '
            '${(filterTitleDish.isNotEmpty ? 'AND ' 'titleDish LIKE ?' : "")}',
        whereArgs: [
          widget.billRecord.id!,
          ...(filterTitleDish.isNotEmpty ? ['%$filterTitleDish%'] : [])
        ],
        pageNum: pageNum,
        pageSize: pageSize);
    preOrderedDishRecordsList[index].clear();
    preOrderedDishRecordsList[index].addAll(tmpPreOrderedDishRecord);
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
          getPreOrderdDishRecordsAtPageViewIndex(
              index: 2, pageNum: pageNum - 1);
        }
        if (iForward == 1) {
          getPreOrderdDishRecordsAtPageViewIndex(
              index: 1, pageNum: pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getPreOrderdDishRecordsAtPageViewIndex(
              index: 0, pageNum: pageNum - 1);
        }
        if (iForward == 2) {
          getPreOrderdDishRecordsAtPageViewIndex(
              index: 2, pageNum: pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getPreOrderdDishRecordsAtPageViewIndex(
              index: 1, pageNum: pageNum - 1);
          logger.d("index $index");
        }
        if (iForward == 0) {
          getPreOrderdDishRecordsAtPageViewIndex(
              index: 0, pageNum: pageNum + 1);
          logger.d("index $index");
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
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  PageView preOrderedDishPageView(int columnSize) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return List24View(
            columnSize: columnSize,
            preOrderedDishRecords: preOrderedDishRecordsList
                    .elementAtOrNull(index % pageViewSize) ??
                [],
          );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: preOrderedDishPageView(
                        (columnSize == 0) ? 1 : columnSize),
                  ),
                  PageIndicator(
                    currentPageIndex: _currentPageIndex,
                    onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                    isOnDesktopAndWeb: _isOnDesktopAndWeb,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                width: 1.0, color: colorScheme.primary))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                            child: Row(children: [
                              Text(
                                "Discount:",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              Text(
                                  NumberFormat.currency(locale: timeZone)
                                      .format(widget.billRecord.discount),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold))
                            ])),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Row(children: [
                              Text(
                                "Tax:",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              Text(
                                  NumberFormat.currency(locale: timeZone)
                                      .format(widget.billRecord.tax),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold))
                            ])),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Row(children: [
                              Text(
                                "Toltal:",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              Text(
                                  NumberFormat.currency(locale: 'vi_VN')
                                      .format(total),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold))
                            ])),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search Dish',
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        if (text.isNotEmpty) {
                          getPreOrderedDishRecords(
                              where: 'titleDish LIKE ?',
                              whereArgs: ['%$text%']);
                          filterTitleDish = text;
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid42(
                      billRecord: widget.billRecord,
                    ),
                  ));
            },
            () {
              setState(() {
                _showWidgetB = !_showWidgetB;
                if (filterTitleDish.isNotEmpty) {
                  getPreOrderedDishRecords();
                  filterTitleDish = "";
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
              Icons.print,
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

class List24View extends StatelessWidget {
  const List24View(
      {super.key,
      required this.columnSize,
      required this.preOrderedDishRecords});
  final List<PreOrderedDishRecord> preOrderedDishRecords;
  final int columnSize;

  @override
  Widget build(BuildContext context) {
    final length = (preOrderedDishRecords.length / columnSize).ceil();
    final List<List<Widget>> previousRow = [];
    final colorScheme = Theme.of(context).colorScheme;
    var categoryId = 0;
    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          var isRow = false;
          final List<List<Widget>> itemRows = [];
          if (previousRow.isNotEmpty) {
            itemRows.add(previousRow.last);
            isRow = true;
          } else {
            itemRows.add([]);
          }

          final List<Widget> itemColumn = [];
          final isLastLoop =
              (index * columnSize + columnSize) >= preOrderedDishRecords.length;

          var i = 0;
          for (; i < columnSize; i++) {
            final newIndex = index * columnSize + i;

            if (newIndex >= preOrderedDishRecords.length) {
              break;
            }
            final e = preOrderedDishRecords[newIndex];
            final isLastItemInCategory = (preOrderedDishRecords
                        .elementAtOrNull(newIndex + 1)
                        ?.categoryId ??
                    e.categoryId) !=
                e.categoryId;
            final dishCofirm = DishCofirm(
                onlyView: true,
                imagePath: e.imagePath,
                title: e.titleDish,
                price: e.price,
                amount: e.amount,
                callBackDel: () {});

            var columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();

            if (isRow && previousRow.isNotEmpty && columnSize > 1) {
              // vì sao 18 thêm môt SizedBox 20
              itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
              isRow = false;
            }
            itemRows[itemRows.length - 1].add(dishCofirm);
            isRow = true;
            columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();

            if (e.categoryId != categoryId) {
              categoryId = e.categoryId;

              itemColumn.add(Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(e.titleCategory,
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))
                    ],
                  )));
            }

            if (columnSizeE == columnSize) {
              itemColumn.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemRows[itemRows.length - 1]));
              itemRows.add([]);
              previousRow.clear();
              continue;
            }

            if (isLastItemInCategory ||
                (newIndex == preOrderedDishRecords.length - 1)) {
              itemColumn.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemRows[itemRows.length - 1]));
              columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
              final remainColumn = columnSize - columnSizeE;

              if (isRow && remainColumn > 0) {
                itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
              }

              for (var j = 0; j < remainColumn; j++) {
                itemRows[itemRows.length - 1].add(const SizedBox(width: 345));
                if (j != remainColumn - 1) {
                  itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
                }
              }
              itemRows.add([]);
              previousRow.clear();
            }
            if (i != columnSize - 1 &&
                itemRows[itemRows.length - 1].isNotEmpty &&
                previousRow.isEmpty) {
              itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
            }
          }

          if (itemRows[itemRows.length - 1].isEmpty) {
            itemRows.removeLast();
          }

          if (!isLastLoop) {
            final columnSizeE =
                (itemRows[itemRows.length - 1].length / 2).ceil();

            if (columnSizeE != columnSize) {
              previousRow.add(itemRows[itemRows.length - 1]);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: itemColumn,
            );
          }

          final columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
          final remainColumn = columnSize - columnSizeE;
          for (var j = 0; j < remainColumn; j++) {
            itemRows[itemRows.length - 1].add(const SizedBox(width: 345));
            if (i != remainColumn - 1) {
              itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: itemColumn,
          );
        });
  }
}
