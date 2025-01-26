import 'package:flutter/material.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/screens/category_45.dart';
import 'package:menu_qr/screens/confirm_38.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/services/utils.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_button.dart';
import 'package:menu_qr/widgets/category_bar.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Order44 extends StatefulWidget {
  const Order44(
      {super.key,
      required this.isImmediate,
      required this.isRebuild,
      this.billRecord});
  final bool isImmediate;
  final bool isRebuild;
  final BillRecord? billRecord;
  final iconSize = 24;

  @override
  State<StatefulWidget> createState() => _Order44();
}

class _Order44 extends State<Order44> {
  Alert? alert;
  bool _showWidgetB = false;
  bool isInitMenuIdAndCategoryId = false;
  bool isInited = false;
  bool isInitedLoop = false;

  int categoryIdInScreen = 0;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  String titleFilter = "";

  final pageViewSize = 3;
  final pageSize = 40;
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final List<List<DishRecord>> dishRecords = [];
  late PageController _pageViewController;

  @override
  void initState() {
    alert = Alert(context: context);
    DishProvider dishProvider = context.read<DishProvider>();
    getDishRecords(
      dishProvider: dishProvider,
    );
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
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
      _currentPageIndex = currentPageIndex;
    });
  }

  Future<void> getDishRecords(
      {required DishProvider dishProvider,
      String? where,
      List<Object?>? whereArgs}) async {
    if (!isInitMenuIdAndCategoryId) {
      final List<MenuRecord> menuRecordSeleted = await dataHelper.menuRecords(
          where: 'isSelected = ?', whereArgs: [1], limit: 1);
      if (menuRecordSeleted.isEmpty) {
        alert!.showAlert('Dish', 'no dish to show', false, null);
        isInitMenuIdAndCategoryId = false;
        return;
      }

      final List<CategoryRecord> categoryRecords =
          await dataHelper.categoryRecords(
              where: 'menuId = ?',
              whereArgs: [menuRecordSeleted[0].id!],
              limit: 1);
      dishProvider.setMenuId(menuRecordSeleted[0].id!);
      dishProvider.setCateogry(
          categoryRecords[0].id!, categoryRecords[0].title);
      categoryIdInScreen = categoryRecords[0].id!;
      isInitMenuIdAndCategoryId = true;
    }

    categoryIdInScreen = (dishProvider.categoryId == 0)
        ? categoryIdInScreen
        : dishProvider.categoryId;
    final List<List<DishRecord>> listTmpDishRecords = [];
    for (var i = 0; i < pageViewSize; i++) {
      final List<DishRecord> tmpDishRecords = await dataHelper.dishRecords(
          where: 'categoryId = ?${(where != null) ? ' AND $where' : ''}',
          whereArgs: [categoryIdInScreen, ...(whereArgs ?? [])],
          pageNum: i + 1,
          pageSize: pageSize);
      listTmpDishRecords.add(tmpDishRecords);
    }
    listTmpDishRecords.add([]);
    setState(() {
      dishRecords.clear();
      dishRecords.addAll(listTmpDishRecords);
    });
  }

  Future<void> getDishRecordsAtPageViewIndex(int index, int pageNum) async {
    if (pageNum == 0) return;
    final where = titleFilter.isNotEmpty
        ? 'categoryId = ? AND title LIKE ?'
        : 'categoryId = ?';
    final whereArgs = titleFilter.isNotEmpty
        ? [categoryIdInScreen, '%$titleFilter%']
        : [categoryIdInScreen];
    final tmpDishRecords = await dataHelper.dishRecords(
        where: where,
        whereArgs: whereArgs,
        pageNum: pageNum,
        pageSize: pageSize);

    dishRecords[index].clear();
    dishRecords[index].addAll(tmpDishRecords);
  }

  void saveRebuildDishes(DishProvider dishProvider, BillProvider billProvider) {
    final List<PreOrderedDishRecord> dishRecordSorted = dishProvider
        .indexDishList.entries
        .map((element) => element.value)
        .toList();
    dishRecordSorted.sort((a, b) {
      return a.categoryId - b.categoryId;
    });

    widget.billRecord?.preOrderedDishRecords?.clear();
    widget.billRecord?.preOrderedDishRecords?.addAll(dishRecordSorted);
    // storage to database
    dataHelper.insertDishesAtBillId(dishRecordSorted, widget.billRecord!.id!);
    Navigator.pop(context, dishRecordSorted);
  }

  void _updateCurrentPageIndex(int index) {
    // logger.d('_updateCurrentPageIndex $index');
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  PageView pageViewBuilder(DishProvider dishProvider, int columnSize) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return DishesView44(
            dishProvider: dishProvider,
            dishRecords:
                dishRecords.elementAtOrNull(index % pageViewSize) ?? [],
            columnSize: columnSize,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final BillProvider billProvider = context.watch<BillProvider>();
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 320).floor() - 1;
    final appLocalizations = AppLocalizations.of(context)!;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) {
          if (!didPop) {
            final navigator = Navigator.of(context);
            navigator.pop();
            // logger.d("order 44");
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: SafeArea(
                    child: Column(
                  children: [
                    Expanded(
                        child: pageViewBuilder(
                            dishProvider, (columnSize == 0) ? 1 : columnSize)),
                    PageIndicator(
                      currentPageIndex: _currentPageIndex,
                      onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                      isOnDesktopAndWeb: _isOnDesktopAndWeb,
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    CategoryBar(categoryFunc: () {
                      navigateWithFade(context, Category45()).then((onValue) {
                        if (categoryIdInScreen != dishProvider.categoryId) {
                          getDishRecords(dishProvider: dishProvider);
                        }
                      });
                    }, orderFunc: () {
                      dishProvider.deleteEmptyIndexDishList();
                      if (dishProvider.indexDishList.isEmpty) {
                        return;
                      }
                      if (widget.isRebuild) {
                        saveRebuildDishes(dishProvider, billProvider);
                        return;
                      }
                      navigateWithFade(
                          context, Confirm38(isImmediate: widget.isImmediate));
                    }),
                    Padding(padding: EdgeInsets.all(8)),
                  ],
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
                          labelText: appLocalizations
                              .search(appLocalizations.dishTitle),
                        ),
                        onSubmitted: (text) {
                          setState(() {
                            _showWidgetB = !_showWidgetB;
                            if (text.isNotEmpty) {
                              getDishRecords(
                                  dishProvider: dishProvider,
                                  where: 'title LIKE ?',
                                  whereArgs: ['%$text%']);
                              titleFilter = text;
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
                false,
                true
              ], listCallback: [
                () {
                  Navigator.pop(context);
                },
                () {
                  dishProvider.clearIndexListWithNotify();
                },
                () {
                  setState(() {
                    _showWidgetB = !_showWidgetB;
                    if (titleFilter.isNotEmpty) {
                      getDishRecords(dishProvider: dishProvider);
                      titleFilter = "";
                    }
                  });
                }
              ], icons: [
                Icon(
                  Icons.arrow_back,
                  color: colorScheme.primary,
                ),
                Icon(
                  Icons.delete,
                  color: colorScheme.error,
                ),
                Icon(
                  Icons.search,
                  color: colorScheme.primary,
                )
              ])
            ],
          ),
        ));
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

class DishesView44 extends StatelessWidget {
  const DishesView44({
    super.key,
    required this.dishRecords,
    required this.dishProvider,
    required this.columnSize,
  });
  final List<DishRecord> dishRecords;
  final DishProvider dishProvider;
  final int columnSize;

  @override
  Widget build(BuildContext context) {
    final length = (dishRecords.length / columnSize).ceil();
    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          final List<Widget> itemRow = [];
          var i = 0;
          for (; i < columnSize; i++) {
            final newIndex = index * columnSize + i;
            if (newIndex >= dishRecords.length) {
              break;
            }
            itemRow.add(DishButton(
                id: dishRecords[newIndex].id!,
                categoryId: dishRecords[newIndex].categoryId,
                imagePath: dishRecords[newIndex].imagePath,
                titleCategory: dishProvider.titleCategory,
                title: dishRecords[newIndex].title,
                desc: dishRecords[newIndex].desc,
                price: dishRecords[newIndex].price));
            if (i != columnSize - 1) {
              itemRow.add(SizedBox(width: 20));
            }
          }
          for (; i < columnSize; i++) {
            itemRow.add(SizedBox(width: 320));
            if (i != columnSize - 1) {
              itemRow.add(SizedBox(width: 20));
            }
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: itemRow,
            ),
          );
        });
  }
}
