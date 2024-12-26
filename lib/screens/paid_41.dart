import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/screens/order_44.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/services/throusand_separator_formatter.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:provider/provider.dart';

class Paid41 extends StatefulWidget {
  const Paid41({super.key, required this.billId, required this.isRebuild});
  final int billId;
  final bool isRebuild;

  @override
  State<Paid41> createState() => _Paid41State();
}

class _Paid41State extends State<Paid41> {
  final TextEditingController _controller = TextEditingController();
  double total = 0;
  double tax = 0;
  double amountPaid = 0;
  double change = 0;
  String timeZone = "vi_VN";

  List<Widget> bottomNavigationBar(BillProvider billProvider,
      DishProvider dishProvider, ColorScheme colorScheme) {
    List<Widget> bottomNavWidgets = [];
    if (widget.isRebuild) {
      bottomNavWidgets.add(BottomBarButton(
          child: Icon(
            Icons.arrow_back,
            color: colorScheme.primary,
          ),
          callback: () {
            Navigator.pop(context);
          }));
    }
    bottomNavWidgets.add(
      BottomBarButton(
          child: Icon(Icons.home, color: colorScheme.primary),
          callback: () {
            billProvider.resetBillIdInRam();
            Navigator.popUntil(context, (route) => route.isFirst);
          }),
    );
    int quantityElePadding = (widget.isRebuild) ? 0 : 1;
    for (int i = 0; i < quantityElePadding; i++) {
      bottomNavWidgets.add(Padding(padding: const EdgeInsets.all(48)));
    }
    if (widget.isRebuild) {
      bottomNavWidgets.add(BottomBarButton(
          child: Icon(Icons.build, color: colorScheme.primary),
          callback: () {
            dishProvider.importDataToIndexDishList(billProvider
                .billRecords[widget.billId]!.preOrderedDishRecords!);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Order44(
                      billId: widget.billId,
                      isRebuild: true,
                      isImmediate: true),
                ));
          }));
    }
    bottomNavWidgets.add(
      BottomBarButton(
          child: Icon(Icons.save, color: colorScheme.primary),
          callback: () {
            saveBill(billProvider);
            if (widget.isRebuild) {
              Navigator.pop(context);
              return;
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Paid42(
                    billId: widget.billId,
                    isRebuild: !widget.isRebuild,
                  ),
                ));
          }),
    );
    return bottomNavWidgets;
  }

  void changeMoney(text) {
    setState(() {
      double moneyCustomer =
          (text.isEmpty) ? 0.0 : double.parse(text.replaceAll(',', ''));
      change = moneyCustomer - total;
    });
  }

  void saveBill(BillProvider billProvider) {
    billProvider.savePaidMoneyAtBillId(widget.billId, total + change);
    return;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    BillProvider billProvider = context.watch<BillProvider>();
    DishProvider dishProvider = context.watch<DishProvider>();
    BillRecord billRecord = billProvider.billRecords[widget.billId]!;
    int tableId = billRecord.tableId;
    String typeCustomer = (billRecord.type) ? "Buy take away" : "Sit in place";
    String tableName = (tableId == 0) ? 'None' : tableRecords[tableId]!.name;

    amountPaid = billRecord.amountPaid;
    total = 0;
    for (var element in billRecord.preOrderedDishRecords!) {
      int dishId = element.dishId;
      DishRecord dishRecord = dishRecords[dishId]!;
      total += (element.amount * dishRecord.price);
    }
    tax = total * 0.05;

    String totalString = NumberFormat.currency(locale: timeZone).format(total);
    String taxString = NumberFormat.currency(locale: timeZone).format(tax);
    String changeString =
        NumberFormat.currency(locale: timeZone).format(change);

    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Date: ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '${billRecord.dateTime}',
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Table name: ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: tableName,
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Tax(5%): ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: taxString,
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Total: ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: totalString,
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                  child: Row(
                    children: [
                      Text('Amount paid: ',
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                          child: SizedBox(
                        height: 48,
                        child: TextField(
                            onChanged: (text) {
                              changeMoney(text);
                            },
                            onSubmitted: (text) {
                              changeMoney(text);
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DecimalFormatter(),
                            ],
                            controller: _controller,
                            decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                filled: true,
                                fillColor: colorScheme.secondaryContainer,
                                focusColor: colorScheme.secondary)),
                      ))
                    ],
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Change: ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: changeString,
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Type: ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: typeCustomer,
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Bill Id: ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '${widget.billId}',
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              border: Border(
                  top: BorderSide(width: 1.0, color: colorScheme.primary))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: bottomNavigationBar(
                    billProvider, dishProvider, colorScheme)),
          ),
        )
      ])),
    );
  }
}
