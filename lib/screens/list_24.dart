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

  PageView preOrderedDishPageView() {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return List24View(
            columnSize: 3,
            preOrderedDishRecords: preOrderedDishRecordsList
                    .elementAtOrNull(index % pageViewSize) ??
                [],
            filterTitleDish: filterTitleDish,
          );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: preOrderedDishPageView(),
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
      required this.preOrderedDishRecords,
      required this.filterTitleDish});
  final List<PreOrderedDishRecord> preOrderedDishRecords;
  final String filterTitleDish;
  final int columnSize;

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    final length = (preOrderedDishRecords.length / columnSize).ceil();
    final List<List<Widget>> previousRow = [];
    final Map<String, dynamic> categoryData = {'title': '', 'categoryId': 0};
    logger.d('length $length, preOrderedDishRecords.length '
        '${preOrderedDishRecords.length}');

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          // khi thay đổi title sẽ return một column chứa Row title và row item
          // điều kiện thứ 1: Mỗi một index chỉ có tối đa 3 lần đi tới nếu quá phải tạo thêm column
          // điều kiện thứ 2: remainItemList chỉ có phần tử khi thay đổi titleCategory
          // điều kiện thứ 3: khi lưu vào remainItemList thì chắc chắn phải tạo một column dư ra

          // nếu lưu vào remainColumnList thì điều gì sẽ xẩy ra nếu đi tơi phần tử cuối cùng;
          // thử nghiệm 1 xẩy ra khi không còn thay đổi titleCategory:
          /*
          ta sẽ thêm remainList còn lại theo logic vòng lạp sau: (giả sử có columnSize = 3)
          1. remainList còn 2 và có thêm 3 index thõa điều kiện
          ta sẽ thêm 2 item của remainList và 1 index thỏa điệu kiện hàng 1
          2. 2 index thõa điều kiện còn lại sẽ thêm vào remainList (vấn đề xẩy khi)
          2.1 nếu không có vòng lạp tiếp theo thì sẽ ra sau:
          2.2 nếu có vòng lạp tiếp theo thì có thể giải quyết
          => phải tìm ra xem có vòng lặp tiếp theo không.
          nếu không thì sẽ thêm 2 index thỏa điều kiện vào hàng thứ 2 và trả về giá trị column
          */
          // thử nghiệm 2 xẩy ra khi có thay đổi titleCategory
          /*
          1. remainList còn lại 2 và có thêm 3 index thõa điệu kiện và ở vị trí thứ 1 của index đó
          có thay đổi titleCategory
          2. B1. thêm 2 item của remainList vào hàng 1, xóa remainList thêm 3 index thỏa điệu vào remainList
          B2. Kiểm tra xem có phải là vòng lập cuối cùng hay không
          nếu đúng sẽ tạo cột thêm 3 item thỏa điệu vào hàng 2
          nếu sai quay lại B1
          */

          final List<List<Widget>> itemRows = [];
          if (previousRow.isNotEmpty) {
            logger.d('previousRow.lastOrNull.length = '
                '${previousRow.lastOrNull?.length}');
            itemRows.add(previousRow.last);
          } else {
            itemRows.add([]);
          }

          logger.d('itemRows[itemRows.length - 1].length = '
              '${itemRows[itemRows.length - 1].length}');

          final Map<String, dynamic> previousData = {
            'isLastItemInCategory': false,
          };

          final List<Widget> itemColumn = [];

          final isLastLoop =
              (index * columnSize + columnSize) >= preOrderedDishRecords.length;

          logger.d('isLastLoop $isLastLoop');

          var i = 0;
          for (; i < columnSize; i++) {
            final newIndex = index * columnSize + i;

            if (newIndex >= preOrderedDishRecords.length) {
              break;
            }
            final e = preOrderedDishRecords[newIndex];

            final dishCofirm = DishCofirm(
                onlyView: true,
                imagePath: e.imagePath,
                title: e.titleDish,
                price: e.price,
                amount: e.amount,
                callBackDel: () {});
            var columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
            logger.d('columnSizeE = $columnSizeE');
            if (columnSizeE != columnSize && previousRow.isNotEmpty) {
              itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
            }
            itemRows[itemRows.length - 1].add(dishCofirm);
            final isLastItemInCategory = (preOrderedDishRecords
                        .elementAtOrNull(newIndex + 1)
                        ?.categoryId ??
                    e.categoryId) !=
                e.categoryId;
            previousData['isLastItemInCategory'] = isLastItemInCategory;
            columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
            if (columnSizeE == columnSize && previousRow.isNotEmpty) {
              itemColumn.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemRows[itemRows.length - 1]));
              itemRows.add([]);
              previousRow.clear();
              continue;
            }
            if (e.categoryId != categoryData['categoryId']) {
              categoryData['categoryId'] = e.categoryId;
              categoryData['title'] = e.titleCategory;
              // cần phải xét nó có phải là phần tử cuối cùng trong danh mục không
              itemColumn.add(Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text(e.titleCategory)],
                ),
              ));
              logger.d('title != categoryId, i = $i, (columnSize - 1) = '
                  '${(columnSize - 1)}');
              // if ((length > 1 && !isLastLoop && i < (columnSize - 1)) ||
              //     index == 0) {
              //   logger.d('add Row success');
              //   itemColumn.add(Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: itemRows[itemRows.length - 1]));
              // }
            }
            if (isLastItemInCategory ||
                (newIndex == preOrderedDishRecords.length - 1)) {
              itemColumn.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemRows[itemRows.length - 1]));
              columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
              final remainColumn = columnSize - columnSizeE;

              if (itemRows[itemRows.length - 1].length == 1) {
                itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
              }

              for (var j = 0; j < remainColumn; j++) {
                itemRows[itemRows.length - 1].add(const SizedBox(width: 345));
                if (j != remainColumn - 1) {
                  itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
                }
              }
              columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
              logger.d('remainColumn $remainColumn, index i = $i');
              // tạo một Row mới
              itemRows.add([]);
            }
            if (i != columnSize - 1 &&
                itemRows[itemRows.length - 1].isNotEmpty &&
                previousRow.isEmpty) {
              itemRows[itemRows.length - 1].add(const SizedBox(width: 20));
            }
            logger.d('e.titleDish = ${e.titleDish}, '
                'isLastItemInCategory = $isLastItemInCategory '
                'index $index');
          }

          if (!isLastLoop) {
            if (itemRows[itemRows.length - 1].length != columnSize) {
              previousRow.add(itemRows[itemRows.length - 1]);
              logger.d('previousRow has value\n '
                  'previousRow is Empty: ${previousRow.isEmpty}\n '
                  'previousRow.last.length: ${previousRow.last.length}\n ');
              // itemColumn.removeLast();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: itemColumn,
            );
          }
          if (itemRows[itemRows.length - 1].isEmpty) {
            itemRows.removeLast();
          }
          final columnSizeE = (itemRows[itemRows.length - 1].length / 2).ceil();
          final remainColumn = columnSize - columnSizeE;
          logger.d(
              'last loop remainColumn = $remainColumn, columnSize $columnSizeE '
              'itemRows[itemRows.length - 1].length ${itemRows[itemRows.length - 1].length}');
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
