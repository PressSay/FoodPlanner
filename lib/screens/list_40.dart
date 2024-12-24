import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/assignment_button.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';
import 'package:provider/provider.dart';

class ListScreen40 extends StatefulWidget {
  const ListScreen40({super.key});

  @override
  State<ListScreen40> createState() => _ListScreen40State();
}

class _ListScreen40State extends State<ListScreen40> {
  String timeZone = 'vi_VN';
  int billId = 1;
  int categoryId = 0;
  double total = 0;

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
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    DishProvider dishProvider = context.watch<DishProvider>();
    List<Widget> itemDishBuilder = [Padding(padding: EdgeInsets.all(8))];
    List<Widget> testWidgets = [];
    billRecords.forEach((k, v) {
      testWidgets.add(AssignmentButton(callBack: () {}, colors: [
        colorScheme.primary,
        colorScheme.onPrimaryContainer,
        colorScheme.primaryContainer,
      ]));
    });
    testWidgets.add(Padding(padding: EdgeInsets.all(6)));

    BillRecord billRecord = billRecords[billId]!;
    billRecord.preOrderedDishRecords?.forEach((e) {
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
        imagePath: e.imagePath,
        title: e.titleDish,
        price: e.price,
        amount: e.amount,
        callBackDel: () {
          dishProvider.deleteAmount(e.dishId);
        },
      ));
    });
    categoryId = 0;

    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: ListView(
            children: [],
          ),
        ),
        infoPrice(colorScheme, 0, 240000),
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
                  children: testWidgets,
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
              Navigator.pop(context);
            }),
        BottomBarButton(
            child: Icon(
              Icons.home,
            ),
            callback: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
        Padding(padding: EdgeInsets.all(48)),
        BottomBarButton(
            child: Icon(
              Icons.credit_card,
            ),
            callback: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (BuildContext context) => Paid42(),
              //     ));
            }),
      ])),
    );
  }
}
