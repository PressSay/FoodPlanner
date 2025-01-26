import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Category45 extends StatefulWidget {
  const Category45({super.key});

  @override
  State<StatefulWidget> createState() => _Category45();
}

class _Category45 extends State<Category45> {
  bool _showWidgetB = false;
  bool isInit = false;
  String filterTitleCategory = "";
  int iBackward = (1 - 1) % 3; // pageViewSize;
  int iForward = (1 + 1) % 3; //pageViewSize;
  int _currentPageIndex = 0;

  final pageViewSize = 3;
  final pageSize = 40;
  final TextEditingController _controller = TextEditingController();
  final DataHelper dataHelper = DataHelper();
  final List<List<CategoryRecord>> categoryRecords = [];
  late PageController _pageViewController;

  void getCategoryRecords(
      {required DishProvider dishProvider,
      String? where,
      List<Object?>? whereArgs}) async {
    final List<List<CategoryRecord>> tmpCategoryRecordsList = [];
    for (var i = 0; i < pageViewSize; i++) {
      final List<CategoryRecord> tmpCategoryRecords =
          await dataHelper.categoryRecords(
              where: 'menuId = ? ${where != null ? 'AND $where' : ''}',
              whereArgs: [dishProvider.menuId, ...?whereArgs],
              pageNum: (i + 1),
              pageSize: pageSize);
      tmpCategoryRecordsList.add(tmpCategoryRecords);
    }
    setState(() {
      categoryRecords.clear();
      categoryRecords.addAll(tmpCategoryRecordsList);
    });
  }

  @override
  void initState() {
    final dishProvider = context.read<DishProvider>();
    getCategoryRecords(dishProvider: dishProvider);
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  Future<void> getCategoryRecordsAtPageViewIndex(int index, int pageNum) async {
    if (pageNum == 0) return;
    final where = filterTitleCategory.isNotEmpty ? 'title = ?' : null;
    final whereArgs =
        filterTitleCategory.isNotEmpty ? [filterTitleCategory] : null;
    final tmpDishRecords = await dataHelper.categoryRecords(
        where: 'menuId = ? ${where != null ? 'AND $where' : ''}',
        whereArgs: [context.read<DishProvider>().menuId, ...?whereArgs],
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
      _currentPageIndex = currentPageIndex;
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

  PageView categoryPageView(DishProvider dishProvider, int columnSize) {
    return PageView.builder(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        itemBuilder: (context, index) {
          return CategoryView45(
            categoryRecords:
                categoryRecords.elementAtOrNull(index % pageViewSize) ?? [],
            columnSize: columnSize,
            callback: (CategoryRecord e) {
              dishProvider.setCateogry(e.id!, e.title);
              Navigator.pop(context);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DishProvider dishProvider = context.watch<DishProvider>();
    final currentWidth = MediaQuery.of(context).size.width;
    final columnSize = (currentWidth / 288).floor() - 1;
    final appLocalizations = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final navigator = Navigator.of(context);
          navigator.pop();
        }
      },
      child: Scaffold(
        body: Column(children: [
          Expanded(
            child: SafeArea(
              child: categoryPageView(
                  dishProvider, (columnSize == 0) ? 1 : columnSize),
            ),
          ),
          PageIndicator(
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(), // Thay thế CategoryBar bằng SizedBox
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText:
                        appLocalizations.search(appLocalizations.categoryTitle),
                    fillColor: colorScheme.primaryContainer),
                onSubmitted: (text) {
                  setState(() {
                    _showWidgetB = !_showWidgetB;
                    if (text.isNotEmpty) {
                      getCategoryRecords(
                          dishProvider: dishProvider,
                          where: 'title LIKE ? AND menuId = ?',
                          whereArgs: ['%$text%', dishProvider.menuId]);
                      filterTitleCategory = text;
                    }
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
                if (filterTitleCategory.isNotEmpty) {
                  getCategoryRecords(dishProvider: dishProvider);
                  filterTitleCategory = "";
                }
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

class CategoryView45 extends StatelessWidget {
  const CategoryView45(
      {super.key,
      required this.categoryRecords,
      required this.callback,
      required this.columnSize});
  final List<CategoryRecord> categoryRecords;
  final int columnSize;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    final length = (categoryRecords.length / columnSize).ceil();

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
            itemRow.add(SizedBox(
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
                  onPressed: () => callback(categoryRecords[idx]),
                  child: Text(
                      '${categoryRecords[idx].id!} . ${categoryRecords[idx].title}')),
            ));
            if (i < columnSize - 1) {
              itemRow.add(SizedBox(width: 20));
            }
          }
          for (; i < columnSize; i++) {
            itemRow.add(SizedBox(width: 288.0));
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
