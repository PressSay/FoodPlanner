import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_cofirm.dart';

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
  final TextEditingController _controller = TextEditingController();
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<Widget> itemDishBuilder = [Padding(padding: EdgeInsets.all(8))];
    var filterdPreOrderedDish = (filterTitleDish.isEmpty)
        ? widget.billRecord.preOrderedDishRecords ?? []
        : widget.billRecord.preOrderedDishRecords
                ?.where((e) => e.titleDish.contains(filterTitleDish))
                .toList() ??
            [];
    for (var e in filterdPreOrderedDish) {
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
      if (isInit) total += e.price * e.amount;
      itemDishBuilder.add(DishCofirm(
        onlyView: true,
        imagePath: e.imagePath,
        title: e.titleDish,
        price: e.price,
        amount: e.amount,
        callBackDel: () {},
      ));
    }
    categoryId = 0;

    if (isInit) isInit = !isInit;

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
                        filterTitleDish = text;
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
                filterTitleDish = "";
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
}
