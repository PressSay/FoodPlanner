import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/screens/table_35.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:provider/provider.dart';
import 'package:menu_qr/services/databases/data.dart';

class Confirm38 extends StatefulWidget {
  const Confirm38({super.key, required this.isImmediate});
  final bool isImmediate;
  @override
  State<StatefulWidget> createState() => _Confirm38();
}

class _Confirm38 extends State<Confirm38> {
  int categoryId = 0;
  double total = 0;
  String timeZone = 'vi_VN';
  bool isAddedDishRecordSorted = false;
  final logger = Logger();

  void saveBillImmediately(
      BillProvider billProvider, DishProvider dishProvider) {
    billProvider.billRecord.id = billProvider.lastBillId + 1;
    BillRecord newBillRecord = BillRecord(
        id: billProvider.billRecord.id,
        amountPaid: billProvider.billRecord.amountPaid,
        discount: billProvider.billRecord.discount,
        tableId: 0,
        nameTable: "không",
        isLeft: billProvider.billRecord.isLeft,
        type: billProvider.billRecord.type,
        dateTime: billProvider.billRecord.dateTime);

    newBillRecord.preOrderedDishRecords = [];
    billProvider.billRecords
        .addAll({billProvider.billRecord.id: newBillRecord});
    billProvider.saveDishesAtBillId(
        dishProvider.indexDishListSorted, billProvider.billRecord.id);
    billProvider.increaseLastBillId();
    dishProvider.clearRam();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Paid41(
                  billId: newBillRecord.id,
                  isRebuild: false,
                )));
    logger.d(newBillRecord.preOrderedDishRecords);
    return;
  }

  @override
  Widget build(BuildContext context) {
    total = 0;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final colorBottomBar = colorScheme.secondaryContainer;

    DishProvider dishProvider = context.watch<DishProvider>();
    BillProvider billProvider = context.watch<BillProvider>();

    List<Widget> itemDishBuilder = [Padding(padding: EdgeInsets.all(8))];
    List<MapEntry<int, PreOrderedDishRecord>> dishRecordSorted =
        dishProvider.indexDishList.entries.toList();
    dishRecordSorted.sort((a, b) {
      return dishRecords[a.key]!.categoryId! - dishRecords[b.key]!.categoryId!;
    });

    if (!isAddedDishRecordSorted) {
      dishProvider.clearIndexDishListSorted();
    }
    for (var e in dishRecordSorted) {
      if (!isAddedDishRecordSorted) {
        dishProvider.addIndexDishListSorted(e.value);
      }
      if (dishRecords[e.key]!.categoryId! != categoryId) {
        categoryId = dishRecords[e.key]!.categoryId!;
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
      DishRecord dishRecord = dishRecords[e.key]!;
      total += dishRecord.price * e.value.amount;
      itemDishBuilder.add(DishCofirm(
        imagePath: dishRecord.imagePath,
        title: dishRecord.title,
        price: dishRecord.price,
        amount: e.value.amount,
        callBackDel: () {
          dishProvider.deleteAmount(e.key);
          dishProvider.deleteAmountSorted(e.key);
        },
      ));
    }
    if (!isAddedDishRecordSorted) {
      isAddedDishRecordSorted = true;
    }
    categoryId = 0;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView(
                      children: itemDishBuilder,
                    ),
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
                                      .format(0.0),
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
          Container(
            height: 56,
            decoration: BoxDecoration(
                color: colorBottomBar,
                border: Border(
                    top: BorderSide(width: 1.0, color: colorScheme.primary))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.arrow_back,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.pop(context);
                        }),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.home,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(Icons.qr_code, color: colorScheme.primary),
                        callback: () {}),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.list_alt,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          if (widget.isImmediate) {
                            saveBillImmediately(billProvider, dishProvider);
                            return;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => Table35(
                                        isList: false,
                                      )));
                        }),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
