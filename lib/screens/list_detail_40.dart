import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/assignment_button.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:provider/provider.dart';

class ListDetail40 extends StatefulWidget {
  const ListDetail40(
      {super.key, required this.billRecords, required this.onlyView});
  final Map<int, BillRecord> billRecords; // billRecords must not empty
  final bool onlyView;
  @override
  State<ListDetail40> createState() => _ListDetail40State();
}

class _ListDetail40State extends State<ListDetail40> {
  String timeZone = 'vi_VN';
  BillRecord? billRecord; // lam sao de chinh gia tri default nay day
  int categoryId = 0;
  double total = 0;
  bool isInitBillId = true;
  bool isInitDishes = true;
  Alert? alert;

  final DataHelper dataHelper = DataHelper();

  @override
  void initState() {
    alert = Alert(context: context);
    super.initState();
  }

  Widget rebuildBtn(ColorScheme colorScheme, List<Color> colorBottomBarBtn) {
    return (!widget.onlyView)
        ? BottomBarButton(
            colorPrimary: colorBottomBarBtn,
            child: Icon(
              Icons.build,
              color: colorScheme.primary,
            ),
            callback: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid41(
                      billRecord: billRecord!,
                      isRebuild: true,
                      isImmediate: false,
                    ),
                  ));
            })
        : SizedBox(width: 48);
  }

  void checkComplete(BillRecord billRecord) async {
    final TableRecord? tableRecord =
        await dataHelper.tableRecord(billRecord.tableId ?? 0);
    billRecord.isLeft = true;
    dataHelper.updateBillRecord(billRecord);
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
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final colorBottomBar = colorScheme.secondaryContainer;
    final DishProvider dishProvider = context.watch<DishProvider>();

    List<Widget> listAssignment = [];
    widget.billRecords.forEach((k, v) {
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
      dishProvider.importDataToIndexDishListSorted(widget
              .billRecords[billRecord!.id!]?.preOrderedDishRecords
              ?.toList() ??
          []);
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
                  categoryRecords[categoryId]!.title,
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
      itemDishBuilder.add(DishCofirm(
        onlyView: widget.onlyView,
        imagePath: e.imagePath,
        title: e.titleDish,
        price: e.price,
        amount: e.amount,
        callBackDel: () {
          alert!.showAlert('Delete Dish', 'Are You Sure?', true, () async {
            dataHelper.deteleDishIdAtBillId(billRecord!.id!, e.dishId);
            dishProvider.deleteAmountSorted(e.dishId);
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
                infoPrice(colorScheme, billRecord!.amountPaid, total),
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
          Container(
            height: 68,
            decoration: BoxDecoration(
                color: colorBottomBar,
                border: Border(
                    top: BorderSide(width: 1.0, color: colorScheme.primary))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(Icons.arrow_back),
                        callback: () {
                          Navigator.pop(context);
                          if (widget.onlyView) return;
                          dishProvider.clearRam();
                        }),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.home,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          if (widget.onlyView) return;
                        }),
                    rebuildBtn(colorScheme, colorBottomBarBtn),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.check,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          // check customer was left
                          checkComplete(billRecord!);
                          //
                          setState(() {
                            widget.billRecords.remove(billRecord!.id);
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => Paid42(
                                  billRecord: billRecord!,
                                  isRebuild: true,
                                ),
                              ));
                        }),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
