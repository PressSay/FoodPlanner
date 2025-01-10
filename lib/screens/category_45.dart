import 'package:flutter/material.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:provider/provider.dart';

class Category45 extends StatefulWidget {
  const Category45({super.key});

  @override
  State<StatefulWidget> createState() => _Category45();
}

class _Category45 extends State<Category45> {
  bool _showWidgetB = false;
  bool isInit = false;

  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final List<CategoryRecord> categoryRecords = [];

  void getCategoryRecords(DishProvider dishProvider) async {
    final List<CategoryRecord> tmpCategoryRecords =
        await dataHelper.categoryRecords(
            where: 'menuId = ?', whereArgs: [dishProvider.menuId], limit: null);
    setState(() {
      categoryRecords.clear();
      categoryRecords.addAll(tmpCategoryRecords);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  String filterTitleCategory = "";
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();

    if (!isInit) {
      getCategoryRecords(dishProvider);
      isInit = true;
    }

    List<CategoryRecord> filterCategoryRecoreds = (filterTitleCategory.isEmpty)
        ? categoryRecords
        : categoryRecords
            .where((e) => e.title.contains(filterTitleCategory))
            .toList();

    List<Widget> itemCategoryBuilder = [];
    for (var value in filterCategoryRecoreds) {
      itemCategoryBuilder.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            height: 64,
            width: 288.0, // 320 * 0.9
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(20),
                          bottomStart: Radius.circular(20)),
                    )),
                    minimumSize: WidgetStateProperty.all(Size(50, 50))),
                onPressed: () {
                  dishProvider.setCateogry(value.id!, value.title);
                  Navigator.pop(context);
                },
                child: Text('${value.id!} . ${value.title}')),
          )
        ]),
      ));
    }
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: ListView(
                children: itemCategoryBuilder,
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: SizedBox(), // Thay thế CategoryBar bằng SizedBox
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search Category',
                  fillColor: colorScheme.primaryContainer),
              onSubmitted: (text) {
                setState(() {
                  _showWidgetB = !_showWidgetB;
                  filterTitleCategory = text;
                });
              },
            ),
          ),
          crossFadeState: _showWidgetB
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        BottomNavigatorCustomize(listEnableBtn: [
          true,
          false,
          false,
          true
        ], listCallback: [
          () {
            Navigator.pop(context);
          },
          () {
            setState(() {
              _showWidgetB = !_showWidgetB;
              filterTitleCategory = "";
            });
          }
        ], icons: [
          Icon(
            Icons.arrow_back,
            color: colorScheme.primary,
          ),
          Icon(
            Icons.search,
            color: colorScheme.primary,
          )
        ]),
      ]),
    );
  }
}
