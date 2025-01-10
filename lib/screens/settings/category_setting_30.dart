import 'package:flutter/material.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/screens/settings/dish_setting_31.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/setting_button.dart';

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

  bool _showWidgetB = false;
  final DataHelper dataHelper = DataHelper();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerMenu = TextEditingController();
  final TextEditingController _controllerCategory = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();
  final List<CategoryRecord> categoryRecords = [];

  @override
  void initState() {
    alert = Alert(context: context);
    _controllerMenu.text = widget.menuRecord.title;
    getCategoryRecords();
    return super.initState();
  }

  void getCategoryRecords() async {
    final List<CategoryRecord> tmpCategoryRecords = await dataHelper
        .categoryRecords(where: null, whereArgs: null, limit: null);
    setState(() {
      categoryRecords.clear();
      categoryRecords.addAll(tmpCategoryRecords);
    });
  }

  void deletedCategoryRecord(CategoryRecord categoryRecord) async {
    alert!.showAlert('Delete Category', 'Are You Sure?', true, () {
      dataHelper.deleteCategoryRecord(categoryRecord.id!);
      setState(() {
        categoryRecords.removeWhere((e1) => e1.id == categoryRecord.id);
      });
    });
  }

  void updateMenu() async {
    if (titleMenu.isEmpty) {
      alert!.showAlert('Update Menu', 'failed!', false, null);
      return;
    }
    final MenuRecord updateE = widget.menuRecord;
    updateE.title = titleMenu;
    dataHelper.updateMenuRecord(updateE);
    alert!.showAlert('Update Menu', 'success!', false, null);
  }

  void insertCategoryRecord() async {
    if (titleCategory.isEmpty || desc.isEmpty) {
      alert!.showAlert('Save Category', 'failed!', false, null);
      return;
    }
    final CategoryRecord newE = CategoryRecord(
        menuId: widget.menuRecord.id!, title: titleCategory, desc: desc);
    final int lastId = await dataHelper.insertCategoryRecord(newE);
    newE.id = lastId;
    alert!.showAlert('Save Category', 'success!', false, null);
    setState(() {
      categoryRecords.add(newE);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<CategoryRecord> filteredCategoryRecords = (filterTitleCategory.isEmpty)
        ? categoryRecords
        : categoryRecords
            .where((e) => e.title.contains(filterTitleCategory))
            .toList();
    List<Widget> itemBuilder = [];

    for (CategoryRecord e in filteredCategoryRecords) {
      itemBuilder.add(Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: SettingButton(
              colorScheme: colorScheme,
              callbackRebuild: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Dish31(
                              categoryRecord: e,
                            ))).then((onValue) {
                  setState(() {
                    if (onValue != null) e = onValue;
                  });
                });
              },
              callbackDelete: () {
                deletedCategoryRecord(e);
              },
              content: e.title),
        ),
      ));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: ListView(
              children: itemBuilder,
            ),
          )),
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
                                    labelText: 'Menu',
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
                                  updateMenu();
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
                                      labelText: 'Category',
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
                                  labelText: 'Description Category',
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
                      labelText: 'Search Category',
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        filterTitleCategory = text;
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
                filterTitleCategory = "";
              });
            },
            () {
              insertCategoryRecord();
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
