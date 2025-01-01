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
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
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
  int categoryIdInScreen = 0;
  bool isInit = false;

  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final List<DishRecord> dishRecords = [];

  @override
  void initState() {
    alert = Alert(context: context);
    super.initState();
  }

  Future<List<DishRecord>> getDishRecords(DishProvider dishProvider) async {
    if (!isInitMenuIdAndCategoryId) {
      final List<MenuRecord> menuRecordSeleted =
          await dataHelper.menuRecords('isSelected = ?', [1], 1);
      if (menuRecordSeleted.isEmpty) {
        alert!.showAlert('Dish', 'no dish to show', false, null);
        isInitMenuIdAndCategoryId = false;
        return [];
      }
      final List<CategoryRecord> categoryRecords = await dataHelper
          .categoryRecords('menuId = ?', [menuRecordSeleted[0].id!], 1);
      dishProvider.setMenuId(menuRecordSeleted[0].id!);
      dishProvider.setCateogryId(categoryRecords[0].id!);
      isInitMenuIdAndCategoryId = false;
    }
    final List<DishRecord> tmpDishRecords = await dataHelper.dishRecords(
        'categoryId = ?', [dishProvider.categoryId], null);
    setState(() {
      dishRecords.clear();
      dishRecords.addAll(tmpDishRecords);
    });
    categoryIdInScreen = dishProvider.categoryId;
    return dishRecords;
  }

  void saveRebuildDishes(DishProvider dishProvider) async {
    final List<PreOrderedDishRecord> dishRecordSorted = dishProvider
        .indexDishList.entries
        .map((element) => element.value)
        .toList();
    dishRecordSorted.sort((a, b) {
      return a.categoryId - b.categoryId;
    });
    dishProvider.importDataToIndexDishListSorted(dishRecordSorted);
    // storage to database
    dataHelper.insertDishesAtBillId(
        dishProvider.indexDishListSorted, widget.billRecord!.id!);
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

    // if (categoryIdInScreen != dishProvider.categoryId || !isInit) {
    //   getDishRecords(dishProvider);
    //   isInit = true;
    // }
    // final currentWidth = MediaQuery.of(context).size.width;
    // Add item to listview
    List<DishRecord> dishRecordsFiltered = (filterTitleDish.isEmpty)
        ? dishRecords
        : dishRecords.where((e) => e.title.contains(filterTitleDish)).toList();
    List<Widget> itemDishBuilder = [];

    for (var value in dishRecordsFiltered) {
      itemDishBuilder.add(Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: DishButton(
              id: value.id!,
              categoryId: value.categoryId,
              imagePath: value.imagePath,
              title: value.title,
              desc: value.desc,
              price: value.price)));
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
                        child: FutureBuilder<List<DishRecord>>(
                            future: getDishRecords(dishProvider),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading breeds...");
                              }
                              return ListView(
                                children: itemDishBuilder,
                              );
                            })),
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
                        saveRebuildDishes(dishProvider);
                        Navigator.pop(context);
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
              Container(
                height: 68,
                decoration: BoxDecoration(
                    color: colorBottomBar,
                    border: Border(
                        top: BorderSide(
                            width: 1.0, color: colorScheme.primary))),
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
                            colorPrimary: [
                              colorScheme.error,
                              colorScheme.errorContainer,
                              colorScheme.onError
                            ],
                            child: Icon(
                              Icons.delete,
                              color: colorScheme.error,
                            ),
                            callback: () {
                              dishProvider.clearRamWithNotify();
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
                                filterTitleDish = "";
                              });
                            })
                      ]),
                ),
              )
            ],
          ),
        ));
  }
}
