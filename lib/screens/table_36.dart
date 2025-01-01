import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/table_cofirm.dart';
import 'package:provider/provider.dart';

class Table36 extends StatefulWidget {
  const Table36({super.key, required this.isList, required this.tableRecord});
  final bool isList;
  final TableRecord tableRecord;
  @override
  State<Table36> createState() => _Table36State();
}

class _Table36State extends State<Table36> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();

  Alert? alert;
  String desc = "";

  @override
  void initState() {
    alert = Alert(context: context);
    super.initState();
  }

  void saveInfoTable() async {
    if (desc.isNotEmpty) {
      widget.tableRecord.desc = desc;
      dataHelper.updateTableRecord(widget.tableRecord);
    }
  }

  void viewBillInTable() async {
    Map<int, BillRecord> billRecords = await dataHelper.billRecords(
        'tableId = ?', [widget.tableRecord.id!], null);
    navigateListDetail40(billRecords);
  }

  void navigateListDetail40(Map<int, BillRecord> billRecords) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListDetail40(
                  billRecords: billRecords,
                  onlyView: widget.isList,
                )));
  }

  void saveBillToSQL(
      BillProvider billProvider, DishProvider dishProvider) async {
    // remember reassign value billId for billProvider,
    // this allow to back and select dish again
    final BillRecord newBillRecord = BillRecord(
        id: billProvider.billRecord.id,
        amountPaid: billProvider.billRecord.amountPaid,
        discount: billProvider.billRecord.discount,
        tableId: billProvider.billRecord.tableId,
        nameTable: billProvider.billRecord.nameTable,
        isLeft: billProvider.billRecord.isLeft,
        type: billProvider.billRecord.type,
        dateTime: billProvider.billRecord.dateTime);
    final int lastId = await dataHelper.insertBillRecord(newBillRecord) ?? 0;
    if (lastId == 0) {
      alert!.showAlert('Insert Bill', 'failed', false, null);
      return;
    }
    newBillRecord.id = lastId;
    newBillRecord.preOrderedDishRecords = await dataHelper.insertDishesAtBillId(
        billProvider.billRecord.preOrderedDishRecords!, lastId);
    widget.tableRecord.numOfPeople += 1;
    dishProvider.clearRam();
    navigateToPaid41(newBillRecord);
    return;
  }

  void navigateToPaid41(BillRecord billRecord) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Paid41(
            billRecord: billRecord,
            isRebuild: false,
            isImmediate: false,
          ),
        ));
  }

  Widget warningViewBtn(int numOfPeople, Function callback) {
    return (numOfPeople != 0)
        ? TableConfirm(
            callBack: () {
              callback();
            },
            text: 'view')
        : SizedBox();
  }

  Widget warningText(int numOfPeople, ColorScheme colorScheme) {
    return (numOfPeople != 0)
        ? Text('This table is lock!\nDo you want add more.',
            style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 16))
        : SizedBox();
  }

  List<Widget> confirmPaid(int numOfPeople, ColorScheme colorScheme,
      DishProvider dishProvider, BillProvider billProvider) {
    final List<Widget> confirmPaidVar = [];
    if (widget.isList) {
      confirmPaidVar.add(
        TableConfirm(
            callBack: () {
              saveBillToSQL(billProvider, dishProvider);
              saveInfoTable();
              dishProvider.clearRam();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            text: (numOfPeople != 0) ? "Add" : "Confirm"),
      );
      confirmPaidVar.add(Padding(padding: EdgeInsets.all(14)));
      confirmPaidVar.add(TableConfirm(
          callBack: () {
            saveBillToSQL(billProvider, dishProvider);
            saveInfoTable();
          },
          text: 'Prepaid'));
    }
    return confirmPaidVar;
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
    final BillProvider billProvider = context.watch<BillProvider>();

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
                          hintText: widget.tableRecord.desc,
                          filled: true,
                          fillColor: colorScheme.primaryContainer),
                      onChanged: (text) {
                        desc = text;
                      })),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: confirmPaid(widget.tableRecord.numOfPeople,
                      colorScheme, dishProvider, billProvider)),
              Padding(padding: EdgeInsets.all(14)),
              warningViewBtn(widget.tableRecord.numOfPeople, () {
                saveInfoTable();
                viewBillInTable();
              }),
              Padding(padding: EdgeInsets.all(12)),
              warningText(widget.tableRecord.numOfPeople, colorScheme)
            ])),
          )),
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
