import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/table_cofirm.dart';
import 'package:provider/provider.dart';

class Table36 extends StatefulWidget {
  const Table36({super.key, required this.isList, required this.tableId});
  final bool isList;
  final int tableId;
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

  void viewBillInTable(int tableId, BillProvider billProvider) {
    Map<int, BillRecord> billRecords = Map.from(billProvider.billRecords)
      ..removeWhere((k, v) {
        return !(v.tableId == tableId && !v.isLeft);
      });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListDetail40(
                  billRecords: billRecords,
                  isViewFromTable: true,
                )));
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
    List<Widget> letMeSeeVar = [];
    if (widget.isList) {
      letMeSeeVar.add(
        TableConfirm(
            callBack: () {
              saveInfoTable(tableId);
              saveBillToSQL(billProvider, dishProvider);
              dishProvider.clearRam();
              billProvider.resetBillIdInRam();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            text: (isLock) ? "Add" : "Confirm"),
      );
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
    }
    return letMeSeeVar;
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
    DishProvider dishProvider = context.watch<DishProvider>();
    BillProvider billProvider = context.watch<BillProvider>();
    TableRecord tableRecord = tableRecords[widget.tableId]!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
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
                  children: letMeSee(tableRecords[widget.tableId]!.isLock,
                      colorScheme, dishProvider, billProvider, widget.tableId)),
              Padding(padding: EdgeInsets.all(14)),
              warningViewBtn(tableRecords[widget.tableId]!.isLock, () {
                saveInfoTable(widget.tableId);
                viewBillInTable(widget.tableId, billProvider);
              }),
              Padding(padding: EdgeInsets.all(12)),
              warningText(tableRecords[widget.tableId]!.isLock, colorScheme)
            ])),
          )),
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
                        child: Icon(Icons.home, color: colorScheme.primary),
                        callback: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }),
                    SizedBox(width: 42),
                    SizedBox(width: 42)
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
