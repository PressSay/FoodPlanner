import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as excl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/screens/settings/category_setting_30.dart';
import 'package:menu_qr/screens/settings/setting_table_30.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/order_setting_button_online.dart';
import 'package:menu_qr/widgets/page_indicator.dart';

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
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final pageViewSize = 3;
  final pageSize = 40;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerMenu = TextEditingController();
  final Logger logger = Logger();

  final DataHelper dataHelper = DataHelper();
  final List<List<MenuRecord>> menuRecords = [];
  final List<MenuRecord> selectedMenuRecords = [];

  late PageController _pageViewController;

  @override
  void initState() {
    alert = Alert(context: context);
    getMenuRecords();
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  void getMenuRecordsAtPageViewIndex(index, pageNum) async {
    if (pageNum == 0) return;
    final where = filterTitleMenu.isNotEmpty ? 'title = ?' : null;
    final whereArgs = filterTitleMenu.isNotEmpty ? [filterTitleMenu] : null;
    final tmpDishRecords = await dataHelper.menuRecords(
        where: where,
        whereArgs: whereArgs,
        pageNum: pageNum,
        pageSize: pageSize);

    menuRecords[index].clear();
    menuRecords[index].addAll(tmpDishRecords);
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }

    final index = currentPageIndex;
    final newIndex = index % pageViewSize;
    final pageNum = index + 1;

    switch (newIndex) {
      case 0:
        if (iBackward == 0) {
          getMenuRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getMenuRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getMenuRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getMenuRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getMenuRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getMenuRecordsAtPageViewIndex(0, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
    }

    setState(() {
      _currentPageIndex = currentPageIndex % pageViewSize;
    });
  }

  void _updateCurrentPageIndex(int index) {
    // logger.d('_updateCurrentPageIndex $index');
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  PageView menuPageView(int columnSize) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return MenuSettingView29(
              columnSize: columnSize,
              menuRecords:
                  menuRecords.elementAtOrNull(index % pageViewSize) ?? [],
              checkCallback:
                  (List<MenuRecord> insideMenuRecord, int index1) async {
                final selectedMenuRecords = await dataHelper
                    .menuRecords(where: 'isSelected = ?', whereArgs: [1]);
                setState(() {
                  menuRecords[index % pageViewSize][index1].isSelected = true;
                });
                for (var e in selectedMenuRecords) {
                  logger.d("e.id ${e.id}");
                  for (var i = 0; i < insideMenuRecord.length; i++) {
                    if (e.id! == insideMenuRecord[i].id!) {
                      setState(() {
                        menuRecords[index % pageViewSize][i].isSelected = false;
                      });
                      dataHelper.updateMenuRecord(insideMenuRecord[i]);
                    }
                  }
                }
                dataHelper.updateMenuRecord(
                    menuRecords[index % pageViewSize][index1]);
              },
              rebuildCallback:
                  (List<MenuRecord> insideMenuRecords, int index1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Category30(menuRecord: insideMenuRecords[index1])));
              },
              deleteCallback: (List<MenuRecord> insideMenuRecords, int index1) {
                alert!.showAlert('Delete Menu', 'Are You Sure?', true,
                    () async {
                  dataHelper.deleteMenuRecord(insideMenuRecords[index1].id!);
                  setState(() {
                    menuRecords[index % pageViewSize].removeAt(index1);
                  });
                });
              });
        });
  }

  void saveMenu() async {
    final MenuRecord menuRecord =
        MenuRecord(title: titleMenu, isSelected: false);
    final int lastId = await dataHelper.insertMenuRecord(menuRecord);
    menuRecord.id = lastId;
    for (var i = 0; i < pageViewSize; i++) {
      if (menuRecords[i].length < pageSize) {
        setState(() {
          menuRecords[i].add(menuRecord);
        });
        break;
      }
    }
    alert!.showAlert('Save Menu', 'success!', false, null);
  }

  void getMenuRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<MenuRecord>> tmpMenuRecordsList = [];
    for (var i = 0; i < pageViewSize; i++) {
      final tmpMenuRecords = await dataHelper.menuRecords(
          where: where,
          whereArgs: whereArgs,
          pageNum: (i + 1),
          pageSize: pageSize);
      tmpMenuRecordsList.add(tmpMenuRecords);
    }
    setState(() {
      menuRecords.clear();
      menuRecords.addAll(tmpMenuRecordsList);
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
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 322).floor() - 1;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: menuPageView((columnSize == 0) ? 1 : columnSize)),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
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
                        if (text.isNotEmpty) {
                          getMenuRecords(
                              where: 'title LIKE ?', whereArgs: ['%$text%']);
                          filterTitleMenu = text;
                        }
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
                if (filterTitleMenu.isNotEmpty) {
                  getMenuRecords();
                  filterTitleMenu = "";
                }
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

class MenuSettingView29 extends StatelessWidget {
  const MenuSettingView29(
      {super.key,
      required this.columnSize,
      required this.menuRecords,
      required this.checkCallback,
      required this.rebuildCallback,
      required this.deleteCallback});
  final int columnSize;
  final List<MenuRecord> menuRecords;
  final Function checkCallback;
  final Function rebuildCallback;
  final Function deleteCallback;

  @override
  Widget build(BuildContext context) {
    final length = (menuRecords.length / columnSize).ceil();
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final int idx = index * columnSize + i;
            if (idx >= menuRecords.length) {
              break;
            }
            itemRow.add(OrderSettingButtonOnl(
              isChecked: menuRecords[idx].isSelected,
              callbackCheck: () => checkCallback(menuRecords, idx),
              callbackDelete: () => deleteCallback(menuRecords, idx),
              callbackRebuild: () => rebuildCallback(menuRecords, idx),
              content: menuRecords[idx].title,
              colorScheme: colorScheme,
            ));
            if (i < columnSize - 1) {
              itemRow.add(SizedBox(width: 20));
            }
          }
          for (; i < columnSize; i++) {
            itemRow.add(SizedBox(width: 322.0));
            if (i < columnSize - 1) {
              itemRow.add(SizedBox(width: 20));
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, children: itemRow),
          );
        });
  }
}
