import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/throusand_separator_formatter.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:provider/provider.dart';

class Paid41 extends StatefulWidget {
  const Paid41({super.key});

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

  void changeMoney(text) {
    setState(() {
      double moneyCustomer =
          (text.isEmpty) ? 0.0 : double.parse(text.replaceAll(',', ''));
      change = moneyCustomer - total;
    });
  }

  void saveBill(BillProvider billProvider) {
    billProvider.billRecord.amountPaid = change + total;
    return;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    BillProvider billProvider = context.watch<BillProvider>();
    int tableId = billProvider.billRecord.tableId;
    int billId = billProvider.billRecord.id;
    String typeCustomer =
        (billProvider.billRecord.type) ? "Buy take away" : "Sit in place";
    String tableName = (tableId == 0) ? 'None' : tableRecords[tableId]!.name;

    amountPaid = billProvider.billRecord.amountPaid;
    total = 0;
    for (var element in billProvider.preOrderedDishRecords) {
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
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
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
                    text: '$billId',
                    style: TextStyle(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold))
              ]),
            ),
          ),
        ],
      )),
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
              Icons.save,
            ),
            callback: () {
              saveBill(billProvider);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Paid42(),
                  ));
            }),
      ])),
    );
  }
}
