import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/screens/table_35.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Confirm38 extends StatefulWidget {
  const Confirm38({super.key, required this.isImmediate});
  final bool isImmediate;
  @override
  State<StatefulWidget> createState() => _Confirm38();
}

class _Confirm38 extends State<Confirm38> {
  String timeZone = 'vi_VN';
  bool isAddedDishRecordSorted = false;
  int offset = 1;
  double tax = 0;
  double systemDiscount = 0;
  double discount = 0;

  int _currentPageIndex = 0;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;

  // độ rộng [preOrderedDishRecords] có thể vô cực
  // và phải cộng với bộ nhớ map của chính nó
  final List<List<PreOrderedDishRecord>> preOrderedDishRecordsView = [
    [],
    [],
    []
  ];
  final dataHelper = DataHelper();
  final pageViewSize = 3;
  final pageSize = 40;
  late PageController _pageViewController;
  late final int lastLength;
  late final int pageViewNumInt;
  final TextEditingController _controller = TextEditingController();

  double total = 0;

  void getPreOrderedDishRecordSorted(DishProvider dishProvider) {
    var tmpTotal = 0.0;
    dishProvider.importDataToIndexDishListSorted(
        dishProvider.indexDishList.values.toList());
    pageViewNumInt =
        (dishProvider.indexDishListSorted.length / pageSize).ceil();
    lastLength = dishProvider.indexDishListSorted.length % pageSize;
    // logger.d("pageViewNumInt $pageViewNumInt, lastLength $lastLength");
    for (var i = 0; i < pageViewSize; i++) {
      // trường hợp đặc biệt khi chỉ có 1 trang
      if ((i + 1) > pageViewNumInt) break;
      final offset = i * pageSize;
      var end = pageSize + offset;
      end = (end > lastLength && lastLength != 0) ? lastLength : end;
      // logger.d("offset $offset, end $end");
      if (end == 0) break;
      preOrderedDishRecordsView[i]
          .addAll(dishProvider.indexDishListSorted.getRange(offset, end));
      for (var e in preOrderedDishRecordsView[i]) {
        tmpTotal = tmpTotal + e.amount * e.price;
      }
    }
    total = tmpTotal;
  }

  @override
  void initState() {
    final DishProvider dishProvider = context.read<DishProvider>();
    loadData(dishProvider);
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void saveBillImmediately(DishProvider dishProvider) async {
    BillRecord newBillRecord = BillRecord(
        amountPaid: 0,
        discount: discount,
        tax: tax,
        tableId: 0,
        nameTable: "none",
        isLeft: false,
        type: widget.isImmediate,
        dateTime: DateTime.now());
    int lastId = await dataHelper.insertBillRecord(newBillRecord);
    newBillRecord.preOrderedDishRecords = await dataHelper.insertDishesAtBillId(
        dishProvider.indexDishListSorted, lastId);
    newBillRecord.id = lastId;
    dishProvider.clearIndexListRam();
    navigateToPaid41Immediately(newBillRecord);
  }

  void navigateToPaid41Immediately(BillRecord billRecord) {
    navigateWithFade(
        context,
        Paid41(
          billRecord: billRecord,
          isRebuild: false,
          isImmediate: widget.isImmediate,
        ));
  }

  void getPreOrderdDishRecordsAtPageViewIndex(int index, int pageNum) {
    final dishProvider = context.read<DishProvider>();
    if (pageNum == 0) return;
    preOrderedDishRecordsView[index].clear();
    if (pageNum > pageViewNumInt) return;
    final offset = (pageNum - 1) * pageSize;
    var end = pageSize + offset;
    end = (end > lastLength && lastLength != 0) ? lastLength : end;
    if (end == 0) return;
    preOrderedDishRecordsView[index]
        .addAll(dishProvider.indexDishListSorted.getRange(offset, end));
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
          getPreOrderdDishRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getPreOrderdDishRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getPreOrderdDishRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getPreOrderdDishRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getPreOrderdDishRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getPreOrderdDishRecordsAtPageViewIndex(0, pageNum + 1);
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

  PageView preOrderedDishPageView(DishProvider dishProvider, int columnSize) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return Confirm38View(
            columnSize: columnSize,
            preOrderedDishRecords:
                preOrderedDishRecordsView[index % pageViewSize],
            deleteCallback:
                (List<PreOrderedDishRecord> preOrderedDishRecords, int index1) {
              final e = preOrderedDishRecords[index1];
              setState(() {
                total -= (preOrderedDishRecords[index1].amount *
                    preOrderedDishRecords[index1].price);
                preOrderedDishRecordsView[index % pageViewSize]
                    .removeAt(index1);
              });
              dishProvider.deleteAmount(e.dishId);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final dishProvider = context.watch<DishProvider>();
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 320).floor() - 1;
    final appLocalizations = AppLocalizations.of(context)!;
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
                          dishProvider, (columnSize == 0) ? 1 : columnSize)),
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
                                appLocalizations.discount,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              SizedBox(
                                  width: 100,
                                  child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Discount Absolute',
                                      ),
                                      onChanged: (value) => setState(() {
                                            try {
                                              discount = double.parse(value);
                                            } catch (e) {
                                              discount = 0;
                                            }
                                          }))),
                              Padding(padding: EdgeInsets.all(6)),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      discount = systemDiscount;
                                      _controller.text = discount.toString();
                                    });
                                  },
                                  child:
                                      Text(appLocalizations.useSystemDiscount))
                            ])),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Row(children: [
                              Text(
                                appLocalizations.tax,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              Text(
                                  NumberFormat.currency(locale: timeZone)
                                      .format(total * tax),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold))
                            ])),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Row(children: [
                              Text(
                                appLocalizations.total,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              Text(
                                  NumberFormat.currency(locale: timeZone)
                                      .format(total - discount),
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
            () {},
            () {
              if (widget.isImmediate) {
                saveBillImmediately(dishProvider);
                return;
              }
              dishProvider.setTotalAndDiscountAndTax(total, discount, tax);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Table35(
                            isList: false,
                            billId: 0,
                          )));
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
            Icon(Icons.qr_code, color: colorScheme.primary),
            Icon(
              Icons.list_alt,
              color: colorScheme.primary,
            )
          ]),
        ],
      ),
    );
  }

  Future<void> loadData(DishProvider dishProvider) async {
    final prefs = await SharedPreferences.getInstance();
    final tax = prefs.getDouble('tax');
    final discount = prefs.getDouble('discount');
    getPreOrderedDishRecordSorted(dishProvider);

    setState(() {
      this.tax = ((tax ?? 0) / 100);
      systemDiscount = total * ((discount ?? 0) / 100);
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

class Confirm38View extends StatelessWidget {
  const Confirm38View(
      {super.key,
      required this.columnSize,
      required this.preOrderedDishRecords,
      required this.deleteCallback});
  final List<PreOrderedDishRecord> preOrderedDishRecords;
  final Function deleteCallback;
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
                onlyView: false,
                imagePath: e.imagePath,
                title: e.titleDish,
                price: e.price,
                amount: e.amount,
                callBackDel: () =>
                    deleteCallback(preOrderedDishRecords, newIndex));

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
