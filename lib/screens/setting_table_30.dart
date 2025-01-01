import 'package:flutter/material.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/setting_button.dart';

class Table30 extends StatefulWidget {
  const Table30({super.key});
  @override
  State<Table30> createState() => _Table30State();
}

class _Table30State extends State<Table30> {
  String filterTitleTable = "";
  bool _showWidgetB = false;
  Alert? alert;
  int tableId = 0;
  int numOfPeople = 0;

  final List<TableRecord> tableRecords = [];
  final TextEditingController _controllerTableOld = TextEditingController();
  final TextEditingController _controllerDescOld = TextEditingController();
  final TextEditingController _controllerTable = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  final DataHelper dataHelper = DataHelper();

  void getTableRecords() async {
    final List<TableRecord> tmpTableRecords = await dataHelper.tableRecords();
    setState(() {
      tableRecords.clear();
      tableRecords.addAll(tmpTableRecords);
    });
  }

  void updateTableRecord() async {
    final TableRecord newE = TableRecord(
        id: tableId,
        name: _controllerTableOld.text,
        desc: _controllerDescOld.text,
        numOfPeople: numOfPeople);
    dataHelper.updateTableRecord(newE);
    alert!.showAlert('Update Table', 'success!', false, null);
  }

  void insertTableRecord() async {
    if (_controllerTable.text.isEmpty || _controllerTable.text.isEmpty) {
      alert!.showAlert('Insert Table', 'failed!', false, null);
      return;
    }
    final TableRecord newE = TableRecord(
        name: _controllerTable.text,
        desc: _controllerDesc.text,
        numOfPeople: 0);
    dataHelper.insertTableRecord(newE);
    alert!.showAlert('Insert Table', 'success!', false, null);
  }

  @override
  void initState() {
    alert = Alert(context: context);
    getTableRecords();
    super.initState();
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

    List<TableRecord> filteredTableRecords = (filterTitleTable.isEmpty)
        ? tableRecords
        : tableRecords
            .where((e) => filterTitleTable.contains(filterTitleTable))
            .toList();
    List<Widget> itemBuilder = [];
    for (TableRecord e in filteredTableRecords) {
      itemBuilder.add(Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: SettingButton(
              colorScheme: colorScheme,
              callbackRebuild: () {
                _controllerDescOld.text = e.desc;
                _controllerDescOld.text = e.name;
                tableId = e.id!;
                numOfPeople = e.numOfPeople;
              },
              callbackDelete: () {
                alert!.showAlert('Delete Table Record', 'Are You Sure', true,
                    () async {
                  dataHelper.deleteTableRecord(e.id!);
                });
                setState(() {
                  tableRecords.removeWhere((e1) => e1.id == e.id);
                });
              },
              content: e.name),
        ),
      ));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: ListView(
              children: itemBuilder,
            ),
          )),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 1.0, color: colorScheme.primary))),
              child: ListView(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Center(
                        child: SizedBox(
                            width: 288,
                            child: TextField(
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDescOld,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: 'Description Table Old',
                                ))),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4)),
                                  border: BorderDirectional(
                                      top: BorderSide(
                                          color: colorScheme.primary),
                                      bottom: BorderSide(
                                          color: colorScheme.primary),
                                      start: BorderSide(
                                          color: colorScheme.primary))),
                              child: Icon(
                                Icons.table_bar,
                                size: 20,
                              )),
                          SizedBox(
                              width: 192,
                              height: 48,
                              child: TextField(
                                  style: TextStyle(color: colorScheme.primary),
                                  controller: _controllerTableOld,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only()),
                                    labelText: 'Table Old',
                                  ))),
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4)),
                            child: Material(
                              color: colorScheme.onPrimary,
                              child: InkWell(
                                splashColor: colorScheme.onPrimaryContainer,
                                child: SizedBox(
                                  width: 48, // width * 0.15 - 2
                                  height: 48,
                                  child: Center(
                                    child: Icon(
                                      Icons.save,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  updateTableRecord();
                                },
                              ),
                            ),
                          )
                        ]),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4)),
                                    border: BorderDirectional(
                                        top: BorderSide(
                                            color: colorScheme.primary),
                                        bottom: BorderSide(
                                            color: colorScheme.primary),
                                        start: BorderSide(
                                            color: colorScheme.primary))),
                                child: Icon(
                                  Icons.table_bar,
                                  size: 20,
                                )),
                            SizedBox(
                                width: 240,
                                height: 48,
                                child: TextField(
                                    style:
                                        TextStyle(color: colorScheme.primary),
                                    controller: _controllerTable,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4))),
                                      labelText: 'Table',
                                    )))
                          ])),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Center(
                        child: SizedBox(
                            width: 288,
                            child: TextField(
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDesc,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: 'Description Table',
                                ))),
                      )),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: TextField(
                    controller: _controllerDescOld,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search Table',
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
            duration: const Duration(milliseconds: 200),
          ),
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
                        }),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.add,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          insertTableRecord();
                        })
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
