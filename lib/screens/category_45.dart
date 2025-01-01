import 'package:flutter/material.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:provider/provider.dart';

class Category45 extends StatefulWidget {
  const Category45({super.key});

  @override
  State<StatefulWidget> createState() => _Category45();
}

class _Category45 extends State<Category45> {
  bool _showWidgetB = false;
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  late final DishProvider dishProvider;
  final List<CategoryRecord> categoryRecords = [];

  void getCategoryRecords() async {
    final List<CategoryRecord> tmpCategoryRecords = await dataHelper
        .categoryRecords('menuId = ?', [dishProvider.categoryId], null);
    setState(() {
      categoryRecords.clear();
      categoryRecords.addAll(tmpCategoryRecords);
    });
  }

  @override
  void initState() {
    dishProvider = context.watch<DishProvider>();
    getCategoryRecords();
    super.initState();
  }

  String filterTitleCategory = "";
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final colorBottomBar = colorScheme.secondaryContainer;

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
                  dishProvider.setCateogryId(value.id!);
                },
                child: Text('${value.id!} . ${value.title}')),
          )
        ]),
      ));
    }
    return Scaffold(
      body: Column(
        children: [
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
                          Icons.search,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          setState(() {
                            _showWidgetB = !_showWidgetB;
                            filterTitleCategory = "";
                          });
                        }),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
