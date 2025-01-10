import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as excl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/screens/settings/category_setting_30.dart';
import 'package:menu_qr/screens/settings/setting_table_30.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/order_setting_button_online.dart';

class Menu29 extends StatefulWidget {
  const Menu29({super.key});

  @override
  State<Menu29> createState() => _Menu29State();
}

class _Menu29State extends State<Menu29> {
  String filterTitleMenu = "";
  String titleMenu = "";

  bool _showWidgetB = false;
  Alert? alert;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerMenu = TextEditingController();
  final Logger logger = Logger();

  final DataHelper dataHelper = DataHelper();
  final List<MenuRecord> menuRecords = [];
  final List<MenuRecord> selectedMenuRecords = [];

  @override
  void initState() {
    alert = Alert(context: context);
    getMenuRecords();
    return super.initState();
  }

  void saveMenu() async {
    final MenuRecord menuRecord =
        MenuRecord(title: titleMenu, isSelected: false);
    final int lastId = await dataHelper.insertMenuRecord(menuRecord);
    menuRecord.id = lastId;
    setState(() {
      menuRecords.add(menuRecord);
    });
    alert!.showAlert('Save Menu', 'success!', false, null);
  }

  void getMenuRecords() async {
    final List<MenuRecord> tmpMenuRecords =
        await dataHelper.menuRecords(where: null, whereArgs: null, limit: null);
    setState(() {
      menuRecords.clear();
      menuRecords.addAll(tmpMenuRecords);
    });
  }

  void reSelectMenuRecord(MenuRecord menuRecord) async {
    final List<int> indexRemove = [];
    for (int i = 0; i < selectedMenuRecords.length; i++) {
      final MenuRecord newE = selectedMenuRecords[i];
      newE.isSelected = false;
      await dataHelper.updateMenuRecord(newE);
      indexRemove.add(i);
    }
    for (int index in indexRemove) {
      selectedMenuRecords.removeAt(index);
    }
    await dataHelper.updateMenuRecord(menuRecord);
    selectedMenuRecords.add(menuRecord);
  }

  void deleteMenu(int menuId) {
    alert!.showAlert('Delete Menu', 'Are You Sure?', true, () async {
      dataHelper.deleteMenuRecord(menuId);
    });
  }

  void importData(Uint8List bytes) {
    // var bytes = pickedFile.files.first.bytes;
    var excel = excl.Excel.decodeBytes(bytes);

    int tableNumericalOrder = 1; // 3 tables
    for (var table in excel.tables.keys) {
      bool checkedFormat = false;

      for (var row in excel.tables[table]!.rows) {
        if (!checkedFormat) {
          int pFC = 0;
          bool haveBreak = false;
          List<String>? formalColumn;
          if (tableNumericalOrder == 1) {
            formalColumn = [
              "mã số", // Cần sửa lại so sánh sao cho khớp
              "tên món ăn",
              "giá",
              "mô tả",
              "đường dẫn ảnh",
              "thể loại",
              "mô tả thể loại"
            ];
          } else if (tableNumericalOrder == 2) {
            formalColumn = [
              "mã số món ăn",
              "mã số bill",
              "số lượng",
              "mã số bàn",
              "tên bàn",
              "đã thanh toán",
              "ngày giờ",
              "giảm giá",
              "là loại mang đi",
              "số tiền đã trả"
            ];
          } else {
            formalColumn = [
              "mã số bàn",
              "tên bàn",
              "mô tả",
            ];
          }
          for (var column in row) {
            String data = column?.value.toString() ?? "";
            if (formalColumn[pFC].compareTo(data) == 0) {
              pFC++;
              continue;
            } else {
              haveBreak = !haveBreak;
              break;
            }
          }
          if (!haveBreak) checkedFormat = !checkedFormat;
          if (!checkedFormat) {
            alert!.showAlert('Format excel', 'wrong format', false, null);
            return;
          }
          // import data below
          if (checkedFormat) {
            // for (excl.Data? column in row) {
            //   if (tableNumericalOrder == 1) {
            //   } else if (tableNumericalOrder == 2) {
            //   } else {}
            // }
          }
        }
      }
      tableNumericalOrder += 1;
    }
  }

  Widget editArea(ColorScheme colorScheme) {
    return Container(
        height: 188,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(width: 1.0, color: colorScheme.primary))),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                                Icons.menu,
                                size: 20,
                              )),
                          SizedBox(
                              width: 240,
                              height: 48,
                              child: TextField(
                                  key: const ValueKey('titleMenuField'),
                                  onChanged: (value) {
                                    titleMenu = value;
                                  },
                                  style: TextStyle(color: colorScheme.primary),
                                  controller: _controllerMenu,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4),
                                            bottomRight: Radius.circular(4))),
                                    labelText: 'Menu',
                                  )))
                        ])),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  maintainState: true,
                                  builder: (context) => Table30()));
                        },
                        child: Text('Table'))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            final FilePickerResult? pickedFile =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['xlsx'],
                              allowMultiple: false,
                            );
                            if (pickedFile != null) {
                              final String file =
                                  pickedFile.files.firstOrNull?.path ?? "";
                              final bytes = await File(file).readAsBytes();
                              importData(bytes);
                            }
                          },
                          child: Text('Import')),
                      SizedBox(width: 18),
                      ElevatedButton(onPressed: () {}, child: Text('Export')),
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<MenuRecord> filteredMenuRecords = (filterTitleMenu.isEmpty)
        ? menuRecords
        : menuRecords.where((e) => e.title.contains(filterTitleMenu)).toList();
    List<Widget> itemBuilderMenu = [];

    for (MenuRecord e in filteredMenuRecords) {
      itemBuilderMenu.add(Center(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: OrderSettingButtonOnl(
                  colorScheme: colorScheme,
                  isChecked: e.isSelected,
                  callbackCheck: () {
                    setState(() {
                      e.isSelected = true;
                      for (MenuRecord e1 in selectedMenuRecords) {
                        if (e1.isSelected && e.id == e1.id) {
                          e.isSelected = false;
                        }
                      }
                    });
                    reSelectMenuRecord(e);
                  },
                  callbackRebuild: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Category30(menuRecord: e)));
                  },
                  callbackDelete: () {
                    deleteMenu(e.id!);
                    setState(() {
                      menuRecords.removeWhere((e1) => e1.id == e.id);
                    });
                  },
                  content: e.title))));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: SafeArea(child: ListView(children: itemBuilderMenu))),
          editArea(colorScheme),
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search Menu',
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        filterTitleMenu = text;
                      });
                    })),
            crossFadeState: _showWidgetB
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            true,
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
                filterTitleMenu = "";
              });
            },
            () {
              if (titleMenu.isEmpty) {
                alert!.showAlert('Save Menu', 'failed!', false, null);
                return;
              }
              saveMenu();
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
            ),
            Icon(
              Icons.add,
              color: colorScheme.primary,
            )
          ]),
        ],
      ),
    );
  }
}
