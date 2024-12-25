import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/table_cofirm.dart';
import 'package:provider/provider.dart';

class Table36 extends StatefulWidget {
  const Table36({super.key});

  @override
  State<Table36> createState() => _Table36State();
}

class _Table36State extends State<Table36> {
  final TextEditingController _controller = TextEditingController();
  String desc = "";

  void saveInfoTable(int tableId) {
    if (desc.isNotEmpty) {
      tableRecords[tableId]!.desc = desc;
    }
  }

  void saveBillToSQL(BillProvider billProvider, DishProvider dishProvider) {
    // remember reassign value billId for billProvider,
    // this allow to back and select dish again
    billProvider.billRecord.id = billProvider.lastBillId + 1;
    BillRecord newBillRecord = BillRecord(
        id: billProvider.billRecord.id,
        amountPaid: billProvider.billRecord.amountPaid,
        discount: billProvider.billRecord.discount,
        tableId: billProvider.billRecord.tableId,
        nameTable: billProvider.billRecord.nameTable,
        isLeft: billProvider.billRecord.isLeft,
        type: billProvider.billRecord.type,
        dateTime: billProvider.billRecord.dateTime);
    newBillRecord.preOrderedDishRecords =
        billProvider.preOrderedDishRecords.toList();
    billProvider.billRecords
        .addAll({billProvider.billRecord.id: newBillRecord});
    billProvider.increaseLastBillId();
    dishProvider.clearRam();
    return;
  }

  Widget warningViewBtn(bool isLock, Function callback) {
    return (isLock)
        ? TableConfirm(
            callBack: () {
              callback();
            },
            text: 'view')
        : SizedBox();
  }

  Widget warningText(bool isLock, ColorScheme colorScheme) {
    return (isLock)
        ? Text('This table is lock!\nDo you want add more.',
            style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 16))
        : SizedBox();
  }

  List<Widget> letMeSee(bool isLock, ColorScheme colorScheme,
      DishProvider dishProvider, BillProvider billProvider, int tableId) {
    List<Widget> letMeSeeVar = [
      TableConfirm(
          callBack: () {
            saveInfoTable(tableId);
            saveBillToSQL(billProvider, dishProvider);
            dishProvider.clearRam();
            billProvider.resetBillIdInRam();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          text: (isLock) ? "Add" : "Confirm"),
    ];
    letMeSeeVar.add(Padding(padding: EdgeInsets.all(14)));
    letMeSeeVar.add(TableConfirm(
        callBack: () {
          saveInfoTable(tableId);
          saveBillToSQL(billProvider, dishProvider);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Paid41(
                  billId: billProvider.billRecord.id,
                  isRebuild: false,
                ),
              ));
        },
        text: 'Prepaid'));
    return letMeSeeVar;
  }

  @override
  Widget build(BuildContext context) {
    DishProvider dishProvider = context.watch<DishProvider>();
    BillProvider billProvider = context.watch<BillProvider>();
    int tableId = billProvider.billRecord.tableId;
    TableRecord tableRecord = tableRecords[tableId]!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
          child: Center(
              child: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: TextField(
                controller: _controller,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: tableRecord.desc,
                    filled: true,
                    fillColor: colorScheme.primaryContainer),
                onChanged: (text) {
                  desc = text;
                })),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: letMeSee(tableRecords[tableId]!.isLock, colorScheme,
                dishProvider, billProvider, tableId)),
        Padding(padding: EdgeInsets.all(14)),
        warningViewBtn(tableRecords[tableId]!.isLock, () {
          saveInfoTable(tableId);
          Navigator.popUntil(context, (route) => route.isFirst);
        }),
        Padding(padding: EdgeInsets.all(12)),
        warningText(tableRecords[tableId]!.isLock, colorScheme)
      ]))),
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
        SizedBox(width: 48, height: 48),
        Padding(padding: EdgeInsets.all(48)),
      ])),
    );
  }
}
