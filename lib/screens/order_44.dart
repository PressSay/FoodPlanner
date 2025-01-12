import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_button.dart';
import 'package:menu_qr/widgets/category_bar.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

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
  String filterTitleDish = "";
  bool _showWidgetB = false;
  bool isInitMenuIdAndCategoryId = false;
  bool isInited = false;
  bool isInitedLoop = false;

  int categoryIdInScreen = 0;
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final pageViewSize = 3;
  final pageSize = 40;
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final List<List<DishRecord>> dishRecords = [];
  final logger = Logger();

  late PageController _pageViewController;

  @override
  void initState() {
    alert = Alert(context: context);
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
    logger.d("currentPageIndex $currentPageIndex");

    final index = currentPageIndex;
    final newIndex = index % pageViewSize;
    final pageNum = index + 1;

    logger.d("newIndex $newIndex, iBackward $iBackward,"
        " iForward $iForward, pageNum $pageNum, "
        "previous ${pageNum - 1}, next ${pageNum + 1}");

    switch (newIndex) {
      case 0:
        if (iBackward == 0) {
          getDishRecordsAtPageViewIndex(2, pageNum - 1);
          logger.d("iBackward = 0");
        }
        if (iForward == 1) {
          getDishRecordsAtPageViewIndex(1, pageNum + 1);
          logger.d("iForward = 1");
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 1:
        if (iBackward == 1) {
          getDishRecordsAtPageViewIndex(0, pageNum - 1);
          logger.d("iBackward = 1");
        }
        if (iForward == 2) {
          getDishRecordsAtPageViewIndex(2, pageNum + 1);
          logger.d("iForward = 2");
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
      case 2:
        if (iBackward == 2) {
          getDishRecordsAtPageViewIndex(1, pageNum - 1);
          logger.d("iBackward = 1");
        }
        if (iForward == 0) {
          getDishRecordsAtPageViewIndex(0, pageNum + 1);
          logger.d("iForward = 0");
        }
        iBackward = (index - 1) % pageViewSize;
        iForward = (index + 2) % pageViewSize;
        break;
    }

    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  Future<void> getDishRecords(DishProvider dishProvider) async {
    if (!isInitMenuIdAndCategoryId && dishProvider.categoryId == 0) {
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
      isInitMenuIdAndCategoryId = false;
    }

    final List<List<DishRecord>> listTmpDishRecords = [];
    for (var i = 0; i < (pageViewSize - 1); i++) {
      final List<DishRecord> tmpDishRecords = await dataHelper.dishRecords(
          where: 'categoryId = ?',
          whereArgs: [dishProvider.categoryId],
          pageNum: i + 1,
          pageSize: pageSize);
      listTmpDishRecords.add(tmpDishRecords);
    }
    listTmpDishRecords.add([]);
    setState(() {
      dishRecords.clear();
      dishRecords.addAll(listTmpDishRecords);
    });
    categoryIdInScreen = dishProvider.categoryId;
  }

  Future<void> getDishRecordsAtPageViewIndex(int index, int pageNum) async {
    final tmpDishRecords = await dataHelper.dishRecords(
        where: 'categoryId = ?',
        whereArgs: [categoryIdInScreen],
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

  PageView pageViewBuilder(DishProvider dishProvider, double currentWidth) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return DishesView44(
            dishProvider: dishProvider,
            dishRecords:
                dishRecords.elementAtOrNull(index % pageViewSize) ?? [],
            filterTitleDish: filterTitleDish,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final BillProvider billProvider = context.watch<BillProvider>();
    final currentWidth = MediaQuery.of(context).size.width;

    if (categoryIdInScreen != dishProvider.categoryId || !isInited) {
      getDishRecords(dishProvider);
      isInited = true;
    }

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, _) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: SafeArea(
                    child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(10)),
                    Expanded(
                        child: pageViewBuilder(dishProvider, currentWidth)),
                    PageIndicator(
                      currentPageIndex: _currentPageIndex,
                      onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                      isOnDesktopAndWeb: _isOnDesktopAndWeb,
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    CategoryBar(categoryFunc: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => Category45(),
                          ));
                    }, orderFunc: () {
                      dishProvider.deleteZero();
                      if (dishProvider.indexDishList.isEmpty) {
                        return;
                      }
                      if (widget.isRebuild) {
                        saveRebuildDishes(dishProvider, billProvider);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Confirm38(isImmediate: widget.isImmediate)));
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
                          labelText: 'Search Dish',
                        ),
                        onSubmitted: (text) {
                          setState(() {
                            _showWidgetB = !_showWidgetB;
                            filterTitleDish = text;
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
                  dishProvider.clearRamWithNotify();
                },
                () {
                  setState(() {
                    _showWidgetB = !_showWidgetB;
                    filterTitleDish = "";
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
    required this.filterTitleDish,
  });
  final List<DishRecord> dishRecords;
  final DishProvider dishProvider;
  final String filterTitleDish;

  @override
  Widget build(BuildContext context) {
    final List<DishRecord> dishRecordsFiltered = (filterTitleDish.isEmpty)
        ? dishRecords
        : dishRecords.where((e) => e.title.contains(filterTitleDish)).toList();
    return ListView.builder(
        itemCount: dishRecordsFiltered.length,
        itemBuilder: (context, index) {
          final value = dishRecordsFiltered[index];
          return Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: DishButton(
                  id: value.id!,
                  categoryId: value.categoryId,
                  imagePath: value.imagePath,
                  titleCategory: dishProvider.titleCategory,
                  title: value.title,
                  desc: value.desc,
                  price: value.price));
        });
  }
}
