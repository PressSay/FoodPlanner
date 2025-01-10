import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
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
  final Logger logger = Logger();
  String timeZone = 'vi_VN';
  BillRecord? billRecord; // lam sao de chinh gia tri default nay day
  Map<int, BillRecord> billRecords = {};
  int categoryId = 0;
  double total = 0;
  bool isInitBillId = true;
  bool isInitDishes = true;
  Alert? alert;
  List<int> tableRecordOldAndNew = [];

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

    Map<int, BillRecord> tmpBillRecords =
        await dataHelper.billRecords(where: sql, whereArgs: A);
    setState(() {
      billRecords.clear();
      billRecords.addAll(tmpBillRecords);
      isInitDishes = true;
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();

    List<Widget> listAssignment = [];
    billRecords.forEach((k, v) {
      if (isInitBillId) {
        billRecord = v;
        isInitBillId = !isInitBillId;
      }
      listAssignment.add(AssignmentButton(
          callBack: () {
            if (billRecord!.id! == k) {
              return;
            }
            setState(() {
              billRecord = v;
              isInitDishes = true;
            });
          },
          active: v.id == (billRecord?.id! ?? 0),
          colors: [
            colorScheme.primary,
            colorScheme.onPrimaryContainer,
            colorScheme.primaryContainer,
          ]));
    });
    listAssignment.add(Padding(padding: EdgeInsets.all(6)));

// nếu đúng thì khi xóa một DishCofirm hệ thống rebuild sẽ không chạy lại lệnh này
    if (isInitDishes) {
      List<PreOrderedDishRecord> preOrderedDishRecords =
          (billRecord != null) ? billRecord!.preOrderedDishRecords! : [];
// [_inddexDishListSorted] có tác dụng khi cần cập nhật bên Order44 thì bên List40 sẽ cập nhật luôn!
      dishProvider.importDataToIndexDishListSorted(preOrderedDishRecords);
      isInitDishes = false;
    }

    total = 0;
    List<Widget> itemDishBuilder = [];
    List<PreOrderedDishRecord> dishRecordSorted =
        dishProvider.indexDishListSorted;
    for (var e in dishRecordSorted) {
      if (e.categoryId != categoryId) {
        categoryId = e.categoryId;
        itemDishBuilder.add(Center(
          child: SizedBox(
              width: 345,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  e.titleCategory ?? "",
                  style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ])),
        ));
        itemDishBuilder.add(Padding(padding: EdgeInsets.all(8)));
      }
      total += e.price * e.amount;
      // if (e.imagePath.isNotEmpty) {
      //   logger.d('e.imagePath: ${e.imagePath}');
      // }
      itemDishBuilder.add(DishCofirm(
        onlyView: widget.onlyView,
        imagePath: e.imagePath,
        title: e.titleDish,
        price: e.price,
        amount: e.amount,
        callBackDel: () {
          alert!.showAlert('Delete Dish', 'Are You Sure?', true, () async {
            dataHelper.deteleDishIdAtBillId(billRecord!.id!, e.dishId);
            // BigO(n)
            dishProvider.deleteAmountSorted(e.dishId);
            billRecords[billRecord!.id!]?.preOrderedDishRecords?.clear();
            billRecords[billRecord!.id!]
                ?.preOrderedDishRecords
                ?.addAll(dishProvider.indexDishListSorted);
          });
        },
      ));
    }
    categoryId = 0;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(children: [
                Expanded(
                  child: ListView(
                    children: itemDishBuilder,
                  ),
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
                        Expanded(
                            child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: listAssignment,
                        ))
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
              dishProvider.clearRam();
              Navigator.pop(context, tableRecordOldAndNew);
            },
            () {
              // free RAM
              dishProvider.clearRam();
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
                  logger.d('old: $currenTableId, new: ${value.tableId}');
                  setState(() {
                    /* Nên đổi cách khác để xét xem tableId đã thay đổi hay chưa */
                    if (currenTableId == value.tableId) {
                      billRecords[billRecord!.id!] = value;
                    } else {
                      // nếu old khác new thì nó mới thêm vào [tableRecordOldAndNew]
                      tableRecordOldAndNew.clear();
                      tableRecordOldAndNew
                          .addAll([currenTableId, value.tableId]);
                      logger.d(
                          'widget.listBillId is null ? ${widget.listBillId == null}');
                      if (widget.listBillId == null) {
                        updateTableRecordOfPage36(currenTableId);
                        billRecords.remove(billRecord!.id!);
                        billRecord = null;
                        isInitBillId = true;
                      }
                    }
                    isInitDishes = true;
                    // 40 -> 36 -> 35
                  });
                });
              }
            },
            () {
              // check customer was left
              checkComplete(billRecord!);
              int billIdCurrent = billRecord!.id!;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid42(
                      billRecord: billRecord!,
                    ),
                  ));
              setState(() {
                billRecords.remove(billIdCurrent);
                billRecord = billRecords.values.lastOrNull;
                isInitDishes = true;
              });
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
}
