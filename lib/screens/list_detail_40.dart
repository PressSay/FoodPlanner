import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/assignment_button.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:provider/provider.dart';

class ListDetail40 extends StatefulWidget {
  const ListDetail40(
      {super.key,
      required this.onlyView,
      this.listBillId,
      this.tableRecord}); // billRecords must not empty
  final bool onlyView;
  final List<int>? listBillId;
  final TableRecord? tableRecord;
  @override
  State<ListDetail40> createState() => _ListDetail40State();
}

class _ListDetail40State extends State<ListDetail40> {
  String timeZone = 'vi_VN';
  BillRecord? billRecord; // lam sao de chinh gia tri default nay day
  List<BillRecord> billRecords = [];
  int indexBillIdCurrent = 0;
  int categoryId = 0;
  double total = 0;
  bool isInitBillId = true;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;
  Alert? alert;
  late PageController _pageViewController;

  final List<List<PreOrderedDishRecord>> preOrderedDishRecords = [];
  final pageViewSize = 3;
  final pageSize = 40;
  final List<int> tableRecordOldAndNew = [];
  final DataHelper dataHelper = DataHelper();

  void getBillRecords() async {
    List<int> A;
    String sql;
    if (widget.listBillId == null && widget.tableRecord != null) {
      A = [widget.tableRecord!.id!, 0];
      sql = 'tableId = ? and isLeft = ?';
    } else {
      A = widget.listBillId ?? [];
      // Chuyển danh sách A thành chuỗi các giá trị ngăn cách bởi dấu phẩy
      String placeholders = A.map((e) => '?').join(',');
      // Tạo câu truy vấn
      sql = 'id IN ($placeholders)';
    }

    List<BillRecord> tmpBillRecords =
        await dataHelper.billRecords(where: sql, whereArgs: A);
    setState(() {
      billRecords.clear();
      billRecords.addAll(tmpBillRecords);
      isInitBillId = true;
    });
  }

  updateTableRecordOfPage36(int tableId) async {
    TableRecord? newE = await dataHelper.tableRecord(tableId);
    if (newE != null) {
      widget.tableRecord?.numOfPeople = newE.numOfPeople;
    }
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

  void checkComplete(BillRecord billRecord) async {
    final TableRecord? tableRecord =
        (billRecord.tableId == 0 || billRecord.tableId == null)
            ? null
            : await dataHelper.tableRecord(billRecord.tableId!);
    billRecord.isLeft = true;
    dataHelper.updateBillRecord(billRecord);

    alert!.showAlert('Update Bill', 'success', false, null);
    if (tableRecord == null) {
      return;
    }
    tableRecord.numOfPeople =
        (tableRecord.numOfPeople > 0) ? tableRecord.numOfPeople - 1 : 0;
    dataHelper.updateTableRecord(tableRecord);
  }

  Widget infoPrice(ColorScheme colorScheme, double paid, double total) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(width: 1.0, color: colorScheme.primary),
                bottom: BorderSide(width: 1.0, color: colorScheme.primary))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(children: [
                Text(
                  "Paid:",
                  style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Text(NumberFormat.currency(locale: timeZone).format(paid),
                    style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold))
              ])),
          Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                Text(
                  "Tax(5%):",
                  style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Text(
                    NumberFormat.currency(locale: timeZone)
                        .format(total * 0.05),
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
                Text(NumberFormat.currency(locale: timeZone).format(total),
                    style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold))
              ])),
          Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                Text(
                  "Change:",
                  style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Text(
                    NumberFormat.currency(locale: timeZone)
                        .format(paid - total),
                    style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold))
              ])),
        ]));
  }

  void getPreOrderedDishRecords(int billId) async {
    final List<List<PreOrderedDishRecord>> listTmpPreOrderedDishRecords = [];
    var tmpTotal = 0.0;
    for (var i = 0; i < pageViewSize; i++) {
      final tmpPreOrderedDishRecords = await dataHelper.preOrderedDishList(
          where: 'billId = ?',
          whereArgs: [billId],
          pageNum: (i + 1),
          pageSize: pageSize);
      for (PreOrderedDishRecord e in tmpPreOrderedDishRecords) {
        tmpTotal = tmpTotal + e.amount * e.price;
      }
      listTmpPreOrderedDishRecords.add(tmpPreOrderedDishRecords);
    }
    setState(() {
      total = tmpTotal;
      preOrderedDishRecords.clear();
      preOrderedDishRecords.addAll(listTmpPreOrderedDishRecords);
    });
  }

  ListView assigmentsListView(ColorScheme colorScheme) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        // vì Assigment không thể nào vượt quá con số interger được
        itemCount: billRecords.length,
        itemBuilder: (context, index) {
          if (isInitBillId) {
            billRecord = billRecords[index];
            indexBillIdCurrent = index;
            getPreOrderedDishRecords(billRecords[index].id!);
            isInitBillId = false;
          }

          return AssignmentButton(
              callBack: () {
                if (billRecord!.id! == billRecords[index].id!) {
                  return;
                }
                setState(() {
                  billRecord = billRecords[index];
                  indexBillIdCurrent = index;
                  getPreOrderedDishRecords(billRecords[index].id!);
                });
              },
              active: (billRecord != null)
                  ? billRecords[index].id == billRecord!.id!
                  : false,
              colors: [
                colorScheme.primary,
                colorScheme.onPrimaryContainer,
                colorScheme.primaryContainer,
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(children: [
                Expanded(
                  child: dishPageView(),
                ),
                PageIndicator(
                  currentPageIndex: _currentPageIndex,
                  onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                  isOnDesktopAndWeb: _isOnDesktopAndWeb,
                ),
                infoPrice(colorScheme, billRecord?.amountPaid ?? 0, total),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: colorScheme.primary)),
                    child: Row(
                      children: [
                        Expanded(child: assigmentsListView(colorScheme))
                      ],
                    ),
                  ),
                )
              ]),
            ),
          ),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            !widget.onlyView,
            true
          ], listCallback: [
            () {
              // 40 -> 36 -> 35
              dishProvider.clearIndexListRam();
              Navigator.pop(context, tableRecordOldAndNew);
            },
            () {
              // free RAM
              dishProvider.clearIndexListRam();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () async {
              if (billRecord != null) {
                // vì sao không dùng BillRecord.copy vì khi qua trang chỉnh sửa sẽ không lưu lại preOrderedDishes
                // BillRecord billRecordCopy = BillRecord.copy(billRecord!);
                int currenTableId = billRecord!.tableId!;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Paid41(
                        billRecord: billRecord!,
                        isRebuild: true,
                        isImmediate: false,
                      ),
                    )).then((value) {
                  getPreOrderedDishRecords(value.id);
                  setState(() {
                    /* Nên đổi cách khác để xét xem tableId đã thay đổi hay chưa */
                    if (currenTableId == value.tableId) {
                      billRecords[indexBillIdCurrent] = value;
                    } else {
                      // nếu old khác new thì nó mới thêm vào [tableRecordOldAndNew]
                      tableRecordOldAndNew.clear();
                      tableRecordOldAndNew
                          .addAll([currenTableId, value.tableId]);
                      if (widget.listBillId == null) {
                        updateTableRecordOfPage36(currenTableId);
                        billRecords
                            .removeWhere((e1) => e1.id! == billRecord!.id!);
                        setState(() {
                          billRecord = billRecords.firstOrNull;
                          if (billRecord != null) {
                            getPreOrderedDishRecords(billRecord!.id!);
                          }
                        });
                      }
                    }
                    // 40 -> 36 -> 35
                  });
                });
              }
            },
            () {
              // check customer was left
              checkComplete(billRecord!);
              // int billIdCurrent = billRecord!.id!;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid42(
                      billRecord: billRecord!,
                    ),
                  )).then((value) {});
              setState(() {
// bigO(n) nhưng n có giới hạn theo người dùng select Bill của trang trước đó
                // billRecords.removeWhere((e) => e.id! == billIdCurrent);
                billRecords.removeAt(indexBillIdCurrent);
                billRecord = billRecords.lastOrNull;
              });
              if (billRecord != null) {
                getPreOrderedDishRecords(billRecord!.id!);
              }
            }
          ], icons: [
            Icon(Icons.arrow_back),
            Icon(
              Icons.home,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.build,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.check,
              color: colorScheme.primary,
            )
          ]),
        ],
      ),
    );
  }

  void _updateCurrentPageIndex(int index) {
    // logger.d('_updateCurrentPageIndex $index');
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
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

  void getpreOrderedDishRecordsAtPageViewIndex(int index, int pageNum) async {
    final tmpBillRecords = await dataHelper.preOrderedDishList(
        where: 'billId = ?',
        whereArgs: [billRecord?.id ?? 0],
        pageNum: pageNum,
        pageSize: pageSize);
    preOrderedDishRecords[index].clear();
    preOrderedDishRecords[index].addAll(tmpBillRecords);
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
          getpreOrderedDishRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getpreOrderedDishRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getpreOrderedDishRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getpreOrderedDishRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getpreOrderedDishRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getpreOrderedDishRecordsAtPageViewIndex(0, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
    }

    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  PageView dishPageView() {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return ListDetailView40(
              preOrderedDishRecords:
                  preOrderedDishRecords.elementAtOrNull(index % pageViewSize) ??
                      [],
              onlyView: widget.onlyView,
              deleteCallback: (List<PreOrderedDishRecord> records, int index1) {
                alert!.showAlert('Delete Dish', 'Are You Sure?', true,
                    () async {
                  dataHelper.deteleDishIdAtBillId(
                      billRecord!.id!, records[index1].dishId);
                  // BigO(n)
                  setState(() {
                    records.removeAt(index1);
                  });
                  if (records.isEmpty && index1 == 0) {
                    getPreOrderedDishRecords(billRecord?.id ?? 0);
                  }
                });
              });
        });
  }
}

class ListDetailView40 extends StatelessWidget {
  const ListDetailView40(
      {super.key,
      required this.preOrderedDishRecords,
      required this.onlyView,
      required this.deleteCallback});
  final List<PreOrderedDishRecord> preOrderedDishRecords;
  final bool onlyView;
  final Function deleteCallback;

  @override
  Widget build(BuildContext context) {
    var categoryId = 0;
    return ListView.builder(
        itemCount: preOrderedDishRecords.length,
        itemBuilder: (context, index) {
          final colorScheme = Theme.of(context).colorScheme;
          final e = preOrderedDishRecords[index];
          final dishCofirm = DishCofirm(
            onlyView: onlyView,
            imagePath: e.imagePath,
            title: e.titleDish,
            price: e.price,
            amount: e.amount,
            callBackDel: () => deleteCallback(preOrderedDishRecords, index),
          );
          if (e.categoryId != categoryId) {
            categoryId = e.categoryId;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: Center(
                    child: SizedBox(
                        width: 345,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                e.titleCategory,
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ])),
                  ),
                ),
                dishCofirm
              ],
            );
          }

          return dishCofirm;
        });
  }
}
