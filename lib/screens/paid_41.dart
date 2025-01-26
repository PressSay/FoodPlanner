import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/order_44.dart';
import 'package:menu_qr/screens/paid_42.dart';
import 'package:menu_qr/screens/table_35.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/services/throusand_separator_formatter.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:menu_qr/services/utils.dart';

class Paid41 extends StatefulWidget {
  const Paid41(
      {super.key,
      required this.billRecord,
      required this.isRebuild,
      required this.isImmediate});
  final BillRecord billRecord;
  final bool isRebuild;
  final bool isImmediate;

  @override
  State<Paid41> createState() => _Paid41State();
}

class _Paid41State extends State<Paid41> {
  final logger = Logger();
  final TextEditingController _controller = TextEditingController();
  bool isInit = true;

  double total = 0;
  double amountPaid = 0;
  double change = 0;

  String timeZone = "vi_VN";
  bool isTableIdChange = true;
  int indexTableRecordsList = 0;
  int indexTableRecords = 0;

  final DataHelper dataHelper = DataHelper();
  final List<PreOrderedDishRecord> preOrderedDishRecords = [];

  Future<void> getPreOrderedDishRecords() async {
    // phụ thuộc vào bộ nhớ người dùng vì cần cái này để in
    final tmpPreOrderedDishRecords = await dataHelper.preOrderedDishList(
        where: 'billId = ?', whereArgs: [widget.billRecord.id!]);
    var tmpTotal = 0.0;
    for (var element in tmpPreOrderedDishRecords) {
      tmpTotal += (element.amount * element.price);
    }
    setState(() {
      total = tmpTotal - widget.billRecord.discount;
      widget.billRecord.preOrderedDishRecords = tmpPreOrderedDishRecords;
      change = widget.billRecord.amountPaid - total;
    });
  }

  @override
  void initState() {
    if (isInit) {
      _controller.text = '${widget.billRecord.amountPaid.floor()}';
      isInit = false;
    }
    getPreOrderedDishRecords();
    super.initState();
  }

  void saveTableRebuild(
      TableRecord? newTableRecord_, int oldTableRecordId) async {
    TableRecord? oldTableRecord =
        await dataHelper.tableRecord(oldTableRecordId);
    oldTableRecord?.numOfPeople -= 1;
    newTableRecord_?.numOfPeople += 1;
    logger.d('oldTableRecord: ${oldTableRecord?.numOfPeople}, '
        'newTableRecord_: ${newTableRecord_?.numOfPeople}');
    if (newTableRecord_ != null) {
      await dataHelper.updateTableRecord(newTableRecord_);
    }
    if (oldTableRecord != null) {
      await dataHelper.updateTableRecord(oldTableRecord);
    }
  }

  Widget bottomNavigationBar(
      DishProvider dishProvider, ColorScheme colorScheme) {
    final listEnableBtn = [widget.isRebuild, true, widget.isRebuild, true];
    final listCallback = [
      () {
        dishProvider.clearIndexListRam();
        widget.billRecord.preOrderedDishRecords?.clear();
        Map<String, dynamic> onValue = {
          'billRecord': widget.billRecord,
          'indexTableRecords': indexTableRecords,
          'indexTableRecordsList': indexTableRecordsList
        };
        Navigator.pop(context, onValue);
      },
      () {
        dishProvider.clearIndexListRam();
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      () {
        dishProvider.importDataToIndexDishList(
            widget.billRecord.preOrderedDishRecords!);
        navigateWithFade(
                context,
                Order44(
                    billRecord: widget.billRecord,
                    isRebuild: true,
                    isImmediate: true))
            .then((value) {
          if (value == null) return;
          getPreOrderedDishRecords();
        });
      },
      () {
        saveBill();
        if (widget.isRebuild) {
          Navigator.pop(context, widget.billRecord);
        } else {
          navigateWithFade(
              context,
              Paid42(
                billRecord: widget.billRecord,
              ));
        }
      }
    ];
    final icons = [
      Icon(Icons.arrow_back, color: colorScheme.primary),
      Icon(Icons.home, color: colorScheme.primary),
      Icon(Icons.build, color: colorScheme.primary),
      Icon(Icons.save, color: colorScheme.primary)
    ];

    return BottomNavigatorCustomize(
        listEnableBtn: listEnableBtn, listCallback: listCallback, icons: icons);
  }

  void changeMoney(text) {
    double moneyCustomer =
        (text.isEmpty) ? 0.0 : double.parse(text.replaceAll(',', ''));
    setState(() {
      amountPaid =
          (moneyCustomer != 0) ? moneyCustomer : widget.billRecord.amountPaid;
      change = moneyCustomer - total;
    });
  }

  void saveBill() {
    widget.billRecord.amountPaid =
        (amountPaid != 0) ? amountPaid : widget.billRecord.amountPaid;
    dataHelper.updateBillRecord(widget.billRecord);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final String typeCustomer =
        (widget.billRecord.type) ? "Buy take away" : "Sit in place";
    final appLocalizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          dishProvider.clearIndexListRam();
          widget.billRecord.preOrderedDishRecords?.clear();
          Map<String, dynamic> onValue = {
            'billRecord': widget.billRecord,
            'indexTableRecords': indexTableRecords,
            'indexTableRecordsList': indexTableRecordsList
          };
          final navigator = Navigator.of(context);
          navigator.pop(onValue);
          return;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: ListView(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${appLocalizations.date}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: '${widget.billRecord.dateTime}',
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
                                text: '${appLocalizations.tableRecord}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: widget.billRecord.nameTable,
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
                                text: '${appLocalizations.tax}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    moneyFormat(widget.billRecord.tax * total),
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
                                text: '${appLocalizations.discount}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: moneyFormat(widget.billRecord.discount),
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
                                text: '${appLocalizations.total}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: moneyFormat(total),
                                style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ),
                      ),
                      Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                          child: Row(
                            children: [
                              Text('${appLocalizations.paid}: ',
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
                                        fillColor:
                                            colorScheme.secondaryContainer,
                                        focusColor: colorScheme.secondary)),
                              ))
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${appLocalizations.change}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: moneyFormat(change),
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
                                text: '${appLocalizations.type}: ',
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
                                text: '${appLocalizations.billId}: ',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: '${widget.billRecord.id!}',
                                style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: ElevatedButton(
                            onPressed: () {
                              navigateWithFade(
                                  context,
                                  Table35(
                                    isList: true,
                                    billId: widget.billRecord.id!,
                                  )).then((onValue) {
                                if (onValue is Map<String, dynamic>) {
                                  TableRecord tableRecordTmp =
                                      onValue['tableRecord'];
                                  indexTableRecords =
                                      onValue['indexTableRecords'];
                                  indexTableRecordsList =
                                      onValue['indexTableRecordsList'];
                                  isTableIdChange = tableRecordTmp.id !=
                                      widget.billRecord.tableId!;
                                  logger.d(
                                      'onValue.id != widget.billRecord.tableId! '
                                      '$isTableIdChange');
                                  if (isTableIdChange) {
                                    saveTableRebuild(tableRecordTmp,
                                        widget.billRecord.tableId!);
                                    setState(() {
                                      widget.billRecord.tableId =
                                          tableRecordTmp.id;
                                      widget.billRecord.nameTable =
                                          tableRecordTmp.name;
                                    });
                                    dataHelper
                                        .updateBillRecord(widget.billRecord);
                                    return;
                                  }
                                }
                              });
                              isTableIdChange = false;
                            },
                            child: Text(appLocalizations.changeTableRecord)),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: ElevatedButton(
                            onPressed: () {
                              var onValueDate = TableRecord(
                                  id: 0,
                                  name: "none",
                                  desc: "",
                                  numOfPeople: 0);
                              isTableIdChange =
                                  onValueDate.id != widget.billRecord.tableId!;
                              logger.d(
                                  'onValue.id != widget.billRecord.tableId! $isTableIdChange');
                              if (isTableIdChange) {
                                saveTableRebuild(
                                    onValueDate, widget.billRecord.tableId!);
                                setState(() {
                                  widget.billRecord.tableId = onValueDate.id;
                                  widget.billRecord.nameTable =
                                      onValueDate.name;
                                });
                                dataHelper.updateBillRecord(widget.billRecord);
                                return;
                              }
                              isTableIdChange = false;
                            },
                            child: Text(appLocalizations.unlinkTableRecord)),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            bottomNavigationBar(dishProvider, colorScheme)
          ],
        ),
      ),
    );
  }

  String moneyFormat(double money) {
    return NumberFormat.currency(locale: timeZone).format(money);
  }
}
