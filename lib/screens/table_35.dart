import 'package:flutter/material.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/screens/table_36.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/table_button.dart';
import 'package:provider/provider.dart';

class Table35 extends StatefulWidget {
  const Table35({super.key, required this.isList});
  final bool isList;
  @override
  State<StatefulWidget> createState() => _Table35();
}

class _Table35 extends State<Table35> {
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final int numEleInRow = 2;
  final List<TableRecord> tableRecords = [];

  String filterTitleTable = "";
  bool _showWidgetB = false;

  void getTableRecords() async {
    final List<TableRecord> tmpTableRecords = await dataHelper.tableRecords();
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
        0, 0, 0, tableId, nameTable, false, false, indexDishListSorted);
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

    List<TableRecord> filteredTableRecords = (filterTitleTable.isEmpty)
        ? tableRecords
        : tableRecords.where((e) => e.name.contains(filterTitleTable)).toList();
    List<Widget> itemBuilder = [Padding(padding: EdgeInsets.all(12))];
    List<Widget> itemBuilderRow = [];
    int counterEle = 0;
    for (var value in filteredTableRecords) {
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
            if (!widget.isList) {
              saveBillToRam(value.id!, value.name, billProvider,
                  dishProvider.indexDishListSorted);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Table36(
                    isList: !widget.isList,
                    tableRecord: value,
                  ),
                ));
          });
      itemBuilderRow.add(tableButton);
      if (counterEle != numEleInRow - 1) {
        itemBuilderRow.add(Padding(padding: EdgeInsets.all(20)));
      }
      counterEle += 1;
    }
    if (counterEle < numEleInRow) {
      itemBuilderRow.add(SizedBox(width: 120));
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
                        child: Icon(
                          Icons.home,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }),
                    SizedBox(width: 42),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.search,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          setState(() {
                            _showWidgetB = !_showWidgetB;
                            filterTitleTable = "";
                          });
                        })
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
