import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/screens/settings/dish_setting_31.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:menu_qr/widgets/setting_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Category30 extends StatefulWidget {
  const Category30({super.key, required this.menuRecord});
  final MenuRecord menuRecord;

  @override
  State<Category30> createState() => _Category30State();
}

class _Category30State extends State<Category30> {
  Alert? alert;
  String filterTitleCategory = "";
  String titleMenu = "";
  String titleCategory = "";
  String desc = "";
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  bool _showWidgetB = false;
  final pageViewSize = 3;
  final pageSize = 40;
  final DataHelper dataHelper = DataHelper();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerMenu = TextEditingController();
  final TextEditingController _controllerCategory = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();
  final List<List<CategoryRecord>> categoryRecords = [];
  late PageController _pageViewController;

  final logger = Logger();

  @override
  void initState() {
    alert = Alert(context: context);
    _controllerMenu.text = widget.menuRecord.title;
    getCategoryRecords();
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void getCategoryRecords({String? where, List<Object?>? whereArgs}) async {
    final List<List<CategoryRecord>> tmpCategoryRecordsList = [];
    for (var i = 0; i < pageViewSize; i++) {
      final List<CategoryRecord> tmpCategoryRecords =
          await dataHelper.categoryRecords(
              where: 'menuId = ? ${where != null ? 'AND $where' : ''}',
              whereArgs: [widget.menuRecord.id!, ...?whereArgs],
              pageNum: (i + 1),
              pageSize: pageSize);
      tmpCategoryRecordsList.add(tmpCategoryRecords);
    }
    setState(() {
      categoryRecords.clear();
      categoryRecords.addAll(tmpCategoryRecordsList);
    });
  }

  void updateMenu(
      {required String status,
      required String failed,
      required String success}) async {
    if (titleMenu.isEmpty) {
      alert!.showAlert(status, failed, false, null);
      return;
    }
    final MenuRecord updateE = widget.menuRecord;
    updateE.title = titleMenu;
    dataHelper.updateMenuRecord(updateE);
    alert!.showAlert(status, success, false, null);
  }

  void insertCategoryRecord(
      {required String status,
      required String failed,
      required String success}) async {
    if (titleCategory.isEmpty || desc.isEmpty) {
      alert!.showAlert(status, failed, false, null);
      return;
    }
    final CategoryRecord newE = CategoryRecord(
        menuId: widget.menuRecord.id!, title: titleCategory, desc: desc);
    final int lastId = await dataHelper.insertCategoryRecord(newE);
    newE.id = lastId;
    alert!.showAlert(status, success, false, null);

    for (var i = 0; i < pageViewSize; i++) {
      if (categoryRecords[i].length < pageSize) {
        setState(() {
          categoryRecords[i].add(newE);
        });
        break;
      }
    }
  }

  void getCategoryRecordsAtPageViewIndex(index, pageNum) async {
    if (pageNum == 0) return;
    final where = filterTitleCategory.isNotEmpty ? 'title = ?' : null;
    final whereArgs =
        filterTitleCategory.isNotEmpty ? [filterTitleCategory] : null;
    final tmpDishRecords = await dataHelper.categoryRecords(
        where: 'menuId = ? ${where != null ? 'AND $where' : ''}',
        whereArgs: [widget.menuRecord.id!, ...?whereArgs],
        pageNum: pageNum,
        pageSize: pageSize);

    categoryRecords[index].clear();
    categoryRecords[index].addAll(tmpDishRecords);
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
          getCategoryRecordsAtPageViewIndex(2, pageNum - 1);
        }
        if (iForward == 1) {
          getCategoryRecordsAtPageViewIndex(1, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getCategoryRecordsAtPageViewIndex(0, pageNum - 1);
        }
        if (iForward == 2) {
          getCategoryRecordsAtPageViewIndex(2, pageNum + 1);
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getCategoryRecordsAtPageViewIndex(1, pageNum - 1);
        }
        if (iForward == 0) {
          getCategoryRecordsAtPageViewIndex(0, pageNum + 1);
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

  void navigateToDish31(int index, int index1) {
    navigateWithFade(
        context,
        Dish31(
          categoryRecord: categoryRecords[index][index1],
        )).then((onValue) {
      setState(() {
        if (onValue != null) {
          categoryRecords[index][index1] = onValue;
        }
      });
    });
  }

  PageView categoryPageView(int columnSize) {
    final appLocalizations = AppLocalizations.of(context)!;
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return CategorySettingView30(
              categoryRecords:
                  categoryRecords.elementAtOrNull(index % pageViewSize) ?? [],
              rebuildCallback:
                  (List<CategoryRecord> insideCategoryRecords, int index1) {
                logger.d("category: ${insideCategoryRecords[index1].id ?? 0}");
                navigateToDish31(index % pageViewSize, index1);
              },
              deleteCallback:
                  (List<CategoryRecord> insideCategoryRecords, int index1) {
                alert!.showAlert(
                    appLocalizations
                        .deleteRecord(appLocalizations.categoryTitle),
                    appLocalizations.areYouSure,
                    true, () {
                  dataHelper
                      .deleteCategoryRecord(insideCategoryRecords[index1].id!);
                  setState(() {
                    categoryRecords[index % pageViewSize].removeAt(index1);
                  });
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: categoryPageView((columnSize == 0) ? 1 : columnSize)),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 1.0, color: colorScheme.primary))),
              child: ListView(
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
                              width: 192,
                              height: 48,
                              child: TextField(
                                  onChanged: (value) {
                                    titleMenu = value;
                                  },
                                  style: TextStyle(color: colorScheme.primary),
                                  controller: _controllerMenu,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only()),
                                    labelText: appLocalizations.oldMenuTitle,
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
                                  updateMenu(
                                      status: appLocalizations.update,
                                      failed: appLocalizations.failed,
                                      success: appLocalizations.success);
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
                                  Icons.category,
                                  size: 20,
                                )),
                            SizedBox(
                                width: 240,
                                height: 48,
                                child: TextField(
                                    onChanged: (value) =>
                                        {titleCategory = value},
                                    style:
                                        TextStyle(color: colorScheme.primary),
                                    controller: _controllerCategory,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4))),
                                      labelText: appLocalizations.categoryTitle,
                                    )))
                          ])),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Center(
                        child: SizedBox(
                            width: 288,
                            child: TextField(
                                onChanged: (value) {
                                  desc = value;
                                },
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDesc,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: appLocalizations.recordDesc(
                                      appLocalizations.categoryTitle),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: appLocalizations
                          .search(appLocalizations.categoryTitle),
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        if (text.isNotEmpty) {
                          getCategoryRecords(
                              where: 'title LIKE ?', whereArgs: ['%$text%']);
                          filterTitleCategory = text;
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
                if (filterTitleCategory.isNotEmpty) {
                  getCategoryRecords();
                  filterTitleCategory = "";
                }
              });
            },
            () {
              insertCategoryRecord(
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

class CategorySettingView30 extends StatelessWidget {
  const CategorySettingView30(
      {super.key,
      required this.categoryRecords,
      required this.rebuildCallback,
      required this.deleteCallback,
      required this.columnSize});
  final List<CategoryRecord> categoryRecords;
  final int columnSize;
  final Function rebuildCallback;
  final Function deleteCallback;

  @override
  Widget build(BuildContext context) {
    final length = (categoryRecords.length / columnSize).ceil();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final int idx = index * columnSize + i;
            if (idx >= categoryRecords.length) {
              break;
            }
            itemRow.add(SettingButton(
              colorScheme: colorScheme,
              callbackRebuild: () => rebuildCallback(categoryRecords, idx),
              callbackDelete: () => deleteCallback(categoryRecords, idx),
              content: categoryRecords[idx].title,
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
