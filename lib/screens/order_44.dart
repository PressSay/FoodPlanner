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
import 'package:provider/provider.dart';

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
  bool isInit = false;
  int categoryIdInScreen = 0;

  final pageSized = 40;
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final List<DishRecord> dishRecords = [];
  final logger = Logger();

  @override
  void initState() {
    alert = Alert(context: context);
    super.initState();
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

    final List<DishRecord> tmpDishRecords = await dataHelper.dishRecords(
        where: 'categoryId = ?',
        whereArgs: [dishProvider.categoryId],
        pageNum: 1,
        pageSize: pageSized);

    setState(() {
      dishRecords.clear();
      dishRecords.addAll(tmpDishRecords);
    });
    categoryIdInScreen = dishProvider.categoryId;
  }

  Future<void> getDishRecordsAtPageViewIndex(int index) async {
    final tmpDishRecords = await dataHelper.dishRecords(
        where: 'categoryId = ?',
        whereArgs: [categoryIdInScreen],
        pageNum: index,
        pageSize: pageSized);
    setState(() {
      dishRecords.clear();
      dishRecords.addAll(tmpDishRecords);
    });
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

  Widget pageViewBuilder(DishProvider dishProvider, double currentWidth) {
    return PageView.builder(itemBuilder: (context, index) {
      List<DishRecord> dishRecordsFiltered = (filterTitleDish.isEmpty)
          ? dishRecords
          : dishRecords
              .where((e) => e.title.contains(filterTitleDish))
              .toList();

      logger.d("index ${index + 1}");

      if (categoryIdInScreen != dishProvider.categoryId || !isInit) {
        getDishRecords(dishProvider);
        isInit = true;
      } else {
        getDishRecordsAtPageViewIndex(index + 1);
      }

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final BillProvider billProvider = context.watch<BillProvider>();
    final currentWidth = MediaQuery.of(context).size.width;

    if (categoryIdInScreen != dishProvider.categoryId || !isInit) {
      getDishRecords(dishProvider);
      isInit = true;
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
}
