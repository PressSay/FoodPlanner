import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/table_36.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/table_button.dart';
import 'package:provider/provider.dart';

class Table35 extends StatefulWidget {
  const Table35({super.key, required this.isList, required this.billId});
  final bool isList;
  final int billId;
  @override
  State<StatefulWidget> createState() => _Table35();
}

class _Table35 extends State<Table35> {
  final logger = Logger();
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final int numEleInRow = 2;
  final Map<int, TableRecord> tableRecords = {};

  String filterTitleTable = "";
  bool _showWidgetB = false;

  void getTableRecords() async {
    final Map<int, TableRecord> tmpTableRecords =
        await dataHelper.tableRecords();
    logger.d("get table_records success");
    setState(() {
      tableRecords.clear();
      tableRecords.addAll(tmpTableRecords);
    });
  }

  @override
  void initState() {
    getTableRecords();
    super.initState();
  }

  void saveBillToRam(int tableId, nameTable, BillProvider billProvider,
      List<PreOrderedDishRecord> indexDishListSorted) {
    billProvider.setBillRecord(
        0, 0, tableId, nameTable, false, false, indexDishListSorted);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final BillProvider billProvider = context.watch<BillProvider>();

    Map<int, TableRecord> filteredTableRecords =
        (filterTitleTable.isEmpty) ? tableRecords : Map.from(tableRecords)
          ..removeWhere((k, v) => !v.name.contains(filterTitleTable));
    List<Widget> itemBuilder = [Padding(padding: EdgeInsets.all(12))];
    List<Widget> itemBuilderRow = [];
    int counterEle = 0;
    filteredTableRecords.forEach((k, value) {
      if (counterEle == numEleInRow) {
        counterEle %= numEleInRow;
        itemBuilder.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: itemBuilderRow.toList()));
        itemBuilder.add(Padding(padding: EdgeInsets.all(12)));
        itemBuilderRow.clear();
      }
      Widget tableButton = TableButton(
          nameTable: value.name,
          callBack: () {
            if (widget.billId != 0) {
              Navigator.pop(context, value);
              return;
            }
            if (!widget.isList) {
              saveBillToRam(value.id!, value.name, billProvider,
                  dishProvider.indexDishListSorted);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Table36(
                    isList: widget.isList,
                    tableRecord: value,
                  ),
                )).then((onValue) {
              // 36 -> 35 phải có tableOldId và tableNewId để cập nhật
              if (onValue is List<int>) {
                logger.d('onValue $onValue');
                if (onValue.isNotEmpty) {
                  updateTableRecord(onValue);
                  logger.d("Đã cập nhật table old và table new");
                  return;
                }
                logger.d("Không cập nhật table old và table new");
              }
            });
          });
      itemBuilderRow.add(tableButton);
      if (counterEle != numEleInRow - 1) {
        itemBuilderRow.add(Padding(padding: EdgeInsets.all(20)));
      }
      counterEle += 1;
    });
    if (counterEle < numEleInRow || counterEle == numEleInRow) {
      // itemBuilderRow.add(SizedBox(width: 120));
      itemBuilder.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: itemBuilderRow.toList()));
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
                child: ListView(
              children: itemBuilder,
            )),
          ),
          AnimatedCrossFade(
              firstChild: SizedBox(),
              secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search Table',
                        filled: true,
                      ),
                      onSubmitted: (text) {
                        setState(() {
                          _showWidgetB = !_showWidgetB;
                          filterTitleTable = text;
                        });
                      })),
              crossFadeState: _showWidgetB
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200)),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            false,
            true
          ], listCallback: [
            () {
              Navigator.pop(context);
            },
            () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () {
              setState(() {
                _showWidgetB = !_showWidgetB;
                filterTitleTable = "";
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
              Icons.search,
              color: colorScheme.primary,
            )
          ])
        ],
      ),
    );
  }

  void updateTableRecord(onValue) async {
    TableRecord? tableRecord0 = await dataHelper.tableRecord(onValue[0]);
    TableRecord? tableRecord1 = await dataHelper.tableRecord(onValue[1]);
    setState(() {
      if (tableRecord0 != null) {
        tableRecords[onValue[0]] = tableRecord0;
      }
      if (tableRecord1 != null) {
        tableRecords[onValue[1]] = tableRecord1;
      }
    });
  }
}
