import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/assignment_button.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:provider/provider.dart';

class ListDetail40 extends StatefulWidget {
  const ListDetail40({super.key, required this.billRecords});
  final Map<int, BillRecord> billRecords;
  @override
  State<ListDetail40> createState() => _ListDetail40State();
}

class _ListDetail40State extends State<ListDetail40> {
  String timeZone = 'vi_VN';
  int billId = 0; // lam sao de chinh gia tri default nay day
  int categoryId = 0;
  double total = 0;
  bool isInitBillId = true;
  bool isInitDishes = true;

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
    BillProvider billProvider = context.watch<BillProvider>();
    DishProvider dishProvider = context.watch<DishProvider>();

    List<Widget> listAssignment = [];

    widget.billRecords.forEach((k, v) {
      if (isInitBillId) {
        billId = k;
        isInitBillId = !isInitBillId;
      }
      listAssignment.add(AssignmentButton(
          callBack: () {
            if (billId == k) {
              return;
            }
            setState(() {
              billId = k;
              isInitDishes = true;
            });
          },
          active: v.id == billId,
          colors: [
            colorScheme.primary,
            colorScheme.onPrimaryContainer,
            colorScheme.primaryContainer,
          ]));
    });
    listAssignment.add(Padding(padding: EdgeInsets.all(6)));

    // nếu đúng thì khi xóa một DishCofirm hệ thống rebuild sẽ không chạy lại lệnh này
    if (isInitDishes) {
      dishProvider.importDataToIndexDishListSorted(
          widget.billRecords[billId]?.preOrderedDishRecords?.toList() ?? []);
      isInitDishes = false;
    }

    total = 0;
    List<Widget> itemDishBuilder = [];
    List<PreOrderedDishRecord> dishRecordSorted =
        dishProvider.indexDishListSorted;
    for (var e in dishRecordSorted) {
      if (dishRecords[e.dishId]!.categoryId! != categoryId) {
        categoryId = dishRecords[e.dishId]!.categoryId!;
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
        imagePath: e.imagePath,
        title: e.titleDish,
        price: e.price,
        amount: e.amount,
        callBackDel: () {
          dishProvider.deleteAmountSorted(e.dishId);
          billProvider.removeDishIdAtBillId(e.dishId, billId);
        },
      ));
    }
    categoryId = 0;

    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: ListView(
            children: itemDishBuilder,
          ),
        ),
        infoPrice(colorScheme,
            billProvider.billRecords[billId]?.amountPaid ?? 0, total),
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: colorScheme.primary)),
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
      ])),
      bottomNavigationBar: BottomAppBar(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        BottomBarButton(
            child: Icon(Icons.arrow_back),
            callback: () {
              dishProvider.clearRam();
              Navigator.pop(context);
            }),
        BottomBarButton(
            child: Icon(
              Icons.home,
            ),
            callback: () {
              billProvider.resetBillIdInRam();
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
        BottomBarButton(
            child: Icon(
              Icons.build,
            ),
            callback: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid41(
                      billId: billId,
                      isRebuild: true,
                    ),
                  ));
            }),
        BottomBarButton(
            child: Icon(
              Icons.check,
            ),
            callback: () {
              billProvider.checkLeftBillId(billId);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid42(
                      billId: billId,
                      isRebuild: true,
                    ),
                  ));
            }),
      ])),
    );
  }
}
