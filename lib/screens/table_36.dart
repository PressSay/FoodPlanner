import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/list_detail_40.dart';
import 'package:menu_qr/screens/paid_41.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/table_cofirm.dart';
import 'package:provider/provider.dart';

class Table36 extends StatefulWidget {
  const Table36(
      {super.key,
      required this.isList,
      required this.tableRecord,
      required this.oldIndexTableRecordsList,
      required this.oldIndexTableRecords});
  final bool isList;
  final TableRecord tableRecord;
  final int oldIndexTableRecordsList;
  final int oldIndexTableRecords;

  @override
  State<Table36> createState() => _Table36State();
}

class _Table36State extends State<Table36> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final logger = Logger();
  final onValueData = {
    'oldId': 0,
    'newId': 0,
    'oldIndexTableRecordsList': 0,
    'oldIndexTableRecords': 0,
    'newIndexTableRecordsList': 0,
    'newIndexTableRecords': 0
  };

  Alert? alert;
  String desc = "";

  @override
  void initState() {
    alert = Alert(context: context);
    super.initState();
  }

  Future<void> saveInfoTable() async {
    if (desc.isNotEmpty) widget.tableRecord.desc = desc;
    dataHelper.updateTableRecord(widget.tableRecord);
  }

  void viewBillInTable(BillProvider billProvider) async {
    navigateListDetail40(!widget.isList);
  }

  void navigateListDetail40(isView) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListDetail40(
                  onlyView: isView,
                  tableRecord: widget.tableRecord,
                  oldIndexTableRecordsList: widget.oldIndexTableRecordsList,
                  oldIndexTableRecords: widget.oldIndexTableRecords,
                ))).then((onValue) {
      logger.d('${widget.tableRecord.numOfPeople}, onValue: $onValue');
      if (onValue is Map<String, int>) {
        onValueData['oldId'] = onValue['oldId'] ?? 0;
        onValueData['newId'] = onValue['newId'] ?? 0;
        onValueData['oldIndexTableRecordsList'] =
            onValue['oldIndexTableRecordsList'] ?? 0;
        onValueData['oldIndexTableRecords'] =
            onValue['oldIndexTableRecords'] ?? 0;
        onValueData['newIndexTableRecordsList'] =
            onValue['newIndexTableRecordsList'] ?? 0;
        onValueData['newIndexTableRecords'] =
            onValue['newIndexTableRecords'] ?? 0;
        setState(() {
          _controller.text = widget.tableRecord.desc;
        });
      }
      // 40 -> 36 -> 35
    });
  }

  void saveBillToSQL(BillProvider billProvider, DishProvider dishProvider,
      bool wantNavigateToPaid41) async {
    // remember reassign value billId for billProvider,
    // this allow to back and select dish again
    final BillRecord newBillRecord = BillRecord(
        tax: billProvider.billRecord.tax,
        amountPaid: billProvider.billRecord.amountPaid,
        discount: billProvider.billRecord.discount,
        tableId: billProvider.billRecord.tableId,
        nameTable: billProvider.billRecord.nameTable,
        isLeft: billProvider.billRecord.isLeft,
        type: billProvider.billRecord.type,
        dateTime: billProvider.billRecord.dateTime);
    final lastId = await dataHelper.insertBillRecord(newBillRecord);
    newBillRecord.id = lastId;
    newBillRecord.preOrderedDishRecords = await dataHelper.insertDishesAtBillId(
        billProvider.billRecord.preOrderedDishRecords!, lastId);
    dishProvider.clearIndexListRam();
    widget.tableRecord.numOfPeople += 1;
    await saveInfoTable();
    if (wantNavigateToPaid41) {
      navigateToPaid41(newBillRecord);
    }
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
    return (numOfPeople > 0)
        ? TableConfirm(
            callBack: () {
              callback();
            },
            text: (widget.isList) ? 'view/prepair' : 'view')
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
    if (!widget.isList) {
      confirmPaidVar.add(
        TableConfirm(
            callBack: () {
              saveBillToSQL(billProvider, dishProvider, false);
              dishProvider.clearIndexListRam();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            text: (numOfPeople != 0) ? "Add" : "Confirm"),
      );
      confirmPaidVar.add(Padding(padding: EdgeInsets.all(14)));
      confirmPaidVar.add(TableConfirm(
          callBack: () {
            saveBillToSQL(billProvider, dishProvider, true);
          },
          text: 'Prepaid'));
    }
    return confirmPaidVar;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                viewBillInTable(billProvider);
              }),
              Padding(padding: EdgeInsets.all(12)),
              warningText(widget.tableRecord.numOfPeople, colorScheme)
            ])),
          )),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            false,
            widget.isList
          ], listCallback: [
            () {
              Navigator.pop(context, onValueData);
              // 36 -> 35
            },
            () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () {
              saveInfoTable();
              alert!.showAlert("Update Table", 'success!', false, null);
            }
          ], icons: [
            Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
            Icon(Icons.home, color: colorScheme.primary),
            Icon(Icons.save, color: colorScheme.primary)
          ])
        ],
      ),
    );
  }
}
