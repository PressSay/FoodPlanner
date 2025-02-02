import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/screens/settings/dish_setting_32.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:menu_qr/widgets/setting_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Dish31 extends StatefulWidget {
  const Dish31({super.key, required this.categoryRecord});
  final CategoryRecord categoryRecord;
  @override
  State<Dish31> createState() => _Dish31State();
}

class _Dish31State extends State<Dish31> {
  Alert? alert;
  String filterTitleDish = "";

  bool isInserted = false;

  String titleDish = "";
  String descDish = "";
  double price = 0;
  String imagePath = "";

  bool _showWidgetB = false;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final pageViewSize = 3;
  final pageSize = 40;
  final defaultImage = "assets/images/hinh-cafe-kem-banh-quy-2393351094.webp";
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerCategory = TextEditingController();
  final TextEditingController _controllerDescCategory = TextEditingController();
  final TextEditingController _controllerDescDish = TextEditingController();
  final TextEditingController _controllerDishTitle = TextEditingController();
  final TextEditingController _controllerDishPrice = TextEditingController();

  final DataHelper dataHelper = DataHelper();
  final List<List<DishRecord>> dishRecords = [];
  late PageController _pageViewController;

  @override
  void initState() {
    alert = Alert(context: context);
    _controllerCategory.text = widget.categoryRecord.title;
    _controllerDescCategory.text = widget.categoryRecord.desc;
    getDishRecords();
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void uploadImage({required String status, required String failed}) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      alert!.showAlert(status, failed, false, null);
      return;
    }
    if (imagePath.isNotEmpty) {
      File fileDelete = File(imagePath);
      if (fileDelete.existsSync() && !isInserted) await fileDelete.delete();
    }
    final file = result.files.first;

    final appStorage = (!_isOnDesktopAndWeb)
        ? Directory('/storage/emulated/0/Documents/Food Planer/Images')
        : await getApplicationDocumentsDirectory();
    if (!appStorage.existsSync()) {
      appStorage.createSync(recursive: true);
    }

    final filename =
        '${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
    final tmpNewFile = File('${appStorage.path}/$filename');
    try {
      final newFile = await File(file.path!).copy(tmpNewFile.path);
      setState(() {
        imagePath = newFile.path;
      });
    } catch (e) {
      alert!.showAlert(status, failed, false, null);
    }
  }

  void getDishRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<DishRecord>> dishRecordsList = [];
    for (var i = 0; i < pageViewSize; i++) {
      final List<DishRecord> tmpDishRecords = await dataHelper.dishRecords(
          where: 'categoryId = ? ${where != null ? 'AND $where' : ''}',
          whereArgs: [widget.categoryRecord.id!, ...?whereArgs],
          pageNum: (i + 1),
          pageSize: pageSize);
      dishRecordsList.add(tmpDishRecords);
    }
    setState(() {
      dishRecords.clear();
      dishRecords.addAll(dishRecordsList);
    });
  }

  void updateCategory(
      {required String status,
      required String failed,
      required String success}) async {
    String titleCategory = _controllerCategory.text;
    String descCategory = _controllerDescCategory.text;
    if (titleCategory.isEmpty || descCategory.isEmpty) {
      alert!.showAlert(status, failed, false, null);
      return;
    }
    widget.categoryRecord.desc = descCategory;
    widget.categoryRecord.title = titleCategory;
    dataHelper.updateCategoryRecord(widget.categoryRecord);
    alert!.showAlert(status, success, false, null);
  }

  void insertDishRecord(
      {required String status,
      required String failed,
      required String success}) async {
    if (titleDish.isEmpty || descDish.isEmpty || price == 0) {
      alert!.showAlert(status, failed, false, null);
      return;
    }
    final DishRecord newE = DishRecord(
        categoryId: widget.categoryRecord.id!,
        imagePath: imagePath,
        title: titleDish,
        desc: descDish,
        price: price);
    final int lastId = await dataHelper.insertDishRecord(newE);
    isInserted = true;
    newE.id = lastId;
    for (var i = 0; i < pageViewSize; i++) {
      if (dishRecords[i].length < pageSize) {
        setState(() {
          dishRecords[i].add(newE);
        });
        break;
      }
    }
    alert!.showAlert(status, success, false, null);
  }

  void getDishRecordsAtPageViewIndex(index, pageNum) async {
    if (pageNum == 0) return;
    final where = filterTitleDish.isNotEmpty ? 'title = ?' : null;
    final whereArgs = filterTitleDish.isNotEmpty ? [filterTitleDish] : null;
    final tmpDishRecords = await dataHelper.dishRecords(
        where: 'categoryId = ? ${where != null ? 'AND $where' : ''}',
        whereArgs: [widget.categoryRecord.id!, ...?whereArgs],
        pageNum: pageNum,
        pageSize: pageSize);

    dishRecords[index].clear();
    dishRecords[index].addAll(tmpDishRecords);
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
          getDishRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getDishRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getDishRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getDishRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getDishRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getDishRecordsAtPageViewIndex(0, pageNum + 1);
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
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  PageView dishPageView(int columnSize) {
    final appLocalizations = AppLocalizations.of(context)!;
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return DishSettingView31(
              dishRecords:
                  dishRecords.elementAtOrNull(index % pageViewSize) ?? [],
              rebuildCallback:
                  (List<DishRecord> insideDishRecords, int index1) {
                if (imagePath.isNotEmpty) {
                  final file = File(imagePath);
                  if (file.existsSync() && !isInserted) file.deleteSync();
                  imagePath = "";
                }
                navigateWithFade(
                    context, Dish32(dishRecord: insideDishRecords[index1]));
              },
              deleteCallback: (List<DishRecord> insideDishRecords, int index1) {
                alert!.showAlert(
                    appLocalizations.deleteRecord(appLocalizations.dishTitle),
                    appLocalizations.areYouSure,
                    true, () async {
                  dataHelper.deleteDishRecord(insideDishRecords[index1].id!);
                  if (insideDishRecords[index1].imagePath == "") {
                    return;
                  }
                  try {
                    final file = File(insideDishRecords[index1].imagePath);
                    if (await file.exists()) await file.delete();
                    setState(() {
                      dishRecords[index % pageViewSize].removeAt(index1);
                    });
                    alert!.showAlert(
                        appLocalizations
                            .deleteRecord(appLocalizations.dishTitle),
                        appLocalizations.success,
                        false,
                        null);
                  } catch (e) {
                    alert!.showAlert(
                        appLocalizations
                            .deleteRecord(appLocalizations.dishTitle),
                        '${appLocalizations.error} $e',
                        false,
                        null);
                  }
                });
              },
              columnSize: columnSize);
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 322).floor() - 1;
    final appLocalizations = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (imagePath.isNotEmpty && !isInserted) {
            final file = File(imagePath);
            if (file.existsSync()) file.deleteSync();
          }
          final navigator = Navigator.of(context);
          navigator.pop(widget.categoryRecord);
          return;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: dishPageView((columnSize == 0) ? 1 : columnSize)),
            PageIndicator(
              currentPageIndex: _currentPageIndex,
              onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              isOnDesktopAndWeb: _isOnDesktopAndWeb,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            width: 1.0, color: colorScheme.primary))),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Center(
                        child: SizedBox(
                            width: 288,
                            child: TextField(
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDescCategory,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: appLocalizations.recordDesc(
                                      appLocalizations.oldCategoryTitle),
                                ))),
                      ),
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
                                    Icons.category,
                                    color: colorScheme.primary,
                                    size: 20,
                                  )),
                              SizedBox(
                                  width: 192,
                                  height: 48,
                                  child: TextField(
                                      style:
                                          TextStyle(color: colorScheme.primary),
                                      controller: _controllerCategory,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only()),
                                        labelText:
                                            appLocalizations.oldCategoryTitle,
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
                                      updateCategory(
                                          status: appLocalizations.update,
                                          failed: appLocalizations.failed,
                                          success: appLocalizations.success);
                                    },
                                  ),
                                ),
                              )
                            ])),
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
                                    Icons.dining_sharp,
                                    color: colorScheme.primary,
                                    size: 20,
                                  )),
                              SizedBox(
                                  width: 160,
                                  height: 48,
                                  child: TextField(
                                      onChanged: (value) {
                                        titleDish = value;
                                      },
                                      style:
                                          TextStyle(color: colorScheme.primary),
                                      controller: _controllerDishTitle,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only()),
                                        labelText: appLocalizations.dishTitle,
                                      ))),
                              SizedBox(
                                  width: 80,
                                  height: 48,
                                  child: TextField(
                                      onChanged: (value) {
                                        try {
                                          price = double.parse(value);
                                        } catch (e) {
                                          price = 0;
                                        }
                                      },
                                      style:
                                          TextStyle(color: colorScheme.primary),
                                      controller: _controllerDishPrice,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                bottomRight:
                                                    Radius.circular(4))),
                                        labelText: appLocalizations.dishPrice,
                                      )))
                            ])),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Center(
                          child: SizedBox(
                              width: 288,
                              child: TextField(
                                  onChanged: (value) {
                                    descDish = value;
                                  },
                                  minLines: 3,
                                  maxLines: null,
                                  style: TextStyle(color: colorScheme.primary),
                                  controller: _controllerDescDish,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    labelText: appLocalizations
                                        .recordDesc(appLocalizations.dishTitle),
                                  ))),
                        )),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0),
                                ),
                                child: (imagePath.isNotEmpty)
                                    ? Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                        width: 150, // width * 0.47
                                        height: 165, // height * 0.75
                                      )
                                    : Image.asset(
                                        'assets/images/'
                                        'hinh-cafe-kem-banh-quy-2393351094.webp',
                                        fit: BoxFit.cover,
                                        width: 150, // width * 0.47
                                        height: 165,
                                      ),
                              ),
                              /* Put Image here */
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      uploadImage(
                                          status: appLocalizations.upload,
                                          failed: appLocalizations.failed);
                                    },
                                    child: Text(appLocalizations.upload)),
                              )
                            ])),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: SizedBox(),
              secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText:
                            appLocalizations.search(appLocalizations.dishTitle),
                      ),
                      onSubmitted: (text) {
                        setState(() {
                          _showWidgetB = !_showWidgetB;
                          if (text.isNotEmpty) {
                            getDishRecords(
                                where: 'title LIKE ?', whereArgs: ['%$text%']);
                            filterTitleDish = text;
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
                if (imagePath.isNotEmpty && !isInserted) {
                  final file = File(imagePath);
                  if (file.existsSync()) file.deleteSync();
                }
                Navigator.pop(context, widget.categoryRecord);
              },
              () {
                if (imagePath.isNotEmpty && !isInserted) {
                  final file = File(imagePath);
                  if (file.existsSync()) file.deleteSync();
                }
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              () {
                setState(() {
                  _showWidgetB = !_showWidgetB;
                  if (filterTitleDish.isNotEmpty) {
                    getDishRecords();
                    filterTitleDish = "";
                  }
                });
              },
              () {
                insertDishRecord(
                    status: appLocalizations.save,
                    failed: appLocalizations.failed,
                    success: appLocalizations.success);
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
      ),
    );
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
}

class DishSettingView31 extends StatelessWidget {
  const DishSettingView31(
      {super.key,
      required this.dishRecords,
      required this.rebuildCallback,
      required this.deleteCallback,
      required this.columnSize});
  final List<DishRecord> dishRecords;
  final int columnSize;
  final Function rebuildCallback;
  final Function deleteCallback;

  @override
  Widget build(BuildContext context) {
    final length = (dishRecords.length / columnSize).ceil();
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final int idx = index * columnSize + i;
            if (idx >= dishRecords.length) {
              break;
            }
            itemRow.add(SettingButton(
                colorScheme: colorScheme,
                callbackRebuild: () => rebuildCallback(dishRecords, idx),
                callbackDelete: () => deleteCallback(dishRecords, idx),
                content: dishRecords[idx].title));
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
