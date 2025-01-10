import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/screens/settings/dish_setting_32.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/setting_button.dart';
import 'package:path_provider/path_provider.dart';

class Dish31 extends StatefulWidget {
  const Dish31({super.key, required this.categoryRecord});
  final CategoryRecord categoryRecord;
  @override
  State<Dish31> createState() => _Dish31State();
}

class _Dish31State extends State<Dish31> {
  Alert? alert;
  String filterTitleDish = "";

  String titleDish = "";
  String descDish = "";
  double price = 0;
  String imagePath = "";

  bool _showWidgetB = false;

  final logger = Logger();
  final defaultImage = "assets/images/hinh-cafe-kem-banh-quy-2393351094.jpg";
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerCategory = TextEditingController();
  final TextEditingController _controllerDescCategory = TextEditingController();
  final TextEditingController _controllerDescDish = TextEditingController();
  final TextEditingController _controllerDishTitle = TextEditingController();
  final TextEditingController _controllerDishPrice = TextEditingController();

  final DataHelper dataHelper = DataHelper();

  final List<DishRecord> dishRecords = [];

  @override
  void initState() {
    alert = Alert(context: context);
    _controllerCategory.text = widget.categoryRecord.title;
    _controllerDescCategory.text = widget.categoryRecord.desc;
    getDishRecords();
    return super.initState();
  }

  void uploadImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      alert!.showAlert('Upload', 'failed', false, null);
      return;
    }
    if (imagePath.isNotEmpty) {
      logger.d('delete tmp image!');
      File fileDelete = File(imagePath);
      if (fileDelete.existsSync()) await fileDelete.delete();
    }
    final file = result.files.first;
    final appStorage = await getApplicationCacheDirectory();
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
    final tmpNewFile = File('${appStorage.path}/$filename');
    try {
      final newFile = await File(file.path!).copy(tmpNewFile.path);
      setState(() {
        imagePath = newFile.path;
      });
      logger.i('Image uploaded successfully to temporary location.');
    } catch (e) {
      alert!.showAlert('Upload', 'failed!', false, null);
    }
  }

  void getDishRecords() async {
    final List<DishRecord> tmpDishRecords = await dataHelper.dishRecords(
        where: 'categoryId = ?',
        whereArgs: [widget.categoryRecord.id!],
        limit: null);
    setState(() {
      dishRecords.clear();
      dishRecords.addAll(tmpDishRecords);
    });
  }

  void updateCategory() async {
    String titleCategory = _controllerCategory.text;
    String descCategory = _controllerDescCategory.text;
    if (titleCategory.isEmpty || descCategory.isEmpty) {
      alert!.showAlert('Update Category', 'failed!', false, null);
      return;
    }
    widget.categoryRecord.desc = descCategory;
    widget.categoryRecord.title = titleCategory;
    dataHelper.updateCategoryRecord(widget.categoryRecord);
    alert!.showAlert('Update Category', 'success!', false, null);
  }

  void insertDishRecord() async {
    if (titleDish.isEmpty || descDish.isEmpty || price == 0) {
      alert!.showAlert('Save Dish', 'failed!', false, null);
      return;
    }
    final DishRecord newE = DishRecord(
        categoryId: widget.categoryRecord.id!,
        imagePath: imagePath,
        title: titleDish,
        desc: descDish,
        price: price);
    final int lastId = await dataHelper.insertDishRecord(newE);
    newE.id = lastId;
    alert!.showAlert('Save Dish', 'success!', false, null);
    setState(() {
      dishRecords.add(newE);
    });
  }

  void deleteDishRecord(DishRecord dishRecord) {
    alert!.showAlert('Delete Dish', 'Are You Sure?', true, () async {
      dataHelper.deleteDishRecord(dishRecord.id!);
      if (dishRecord.imagePath == "") {
        return;
      }
      try {
        final file = File(dishRecord.imagePath);
        if (await file.exists()) await file.delete();
        alert!.showAlert('Delete Dish', 'success', false, null);
      } catch (e) {
        alert!.showAlert('Delete Dish', 'Error deleting file: $e', false, null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<DishRecord> filteredDishRecords = (filterTitleDish.isEmpty)
        ? dishRecords
        : dishRecords.where((e) => e.title.contains(filterTitleDish)).toList();
    List<Widget> itemBuilder = [];

    for (DishRecord e in filteredDishRecords) {
      itemBuilder.add(Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: SettingButton(
              colorScheme: colorScheme,
              callbackRebuild: () {
                if (imagePath.isNotEmpty) {
                  final file = File(imagePath);
                  if (file.existsSync()) file.deleteSync();
                  imagePath = "";
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Dish32(dishRecord: e)));
              },
              callbackDelete: () {
                deleteDishRecord(e);
                setState(() {
                  dishRecords.removeWhere((e1) => e1.id == e.id);
                });
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
                                labelText: 'Description Category',
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
                                      labelText: 'Category',
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
                                    updateCategory();
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
                                      labelText: 'Dish',
                                    ))),
                            SizedBox(
                                width: 80,
                                height: 48,
                                child: TextField(
                                    onChanged: (value) {
                                      price = double.parse(value);
                                    },
                                    style:
                                        TextStyle(color: colorScheme.primary),
                                    controller: _controllerDishPrice,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4))),
                                      labelText: 'price',
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  labelText: 'Description Dish',
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
                              child: Image.asset(
                                (imagePath.isEmpty) ? defaultImage : imagePath,
                                fit: BoxFit.cover,
                                width: 150, // width * 0.47
                                height: 165, // height * 0.75
                              ),
                            ),
                            /* Put Image here */
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    uploadImage();
                                  },
                                  child: Text('Upload')),
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
            true,
            true
          ], listCallback: [
            () {
              if (imagePath.isNotEmpty) {
                final file = File(imagePath);
                if (file.existsSync()) file.deleteSync();
              }
              Navigator.pop(context, widget.categoryRecord);
            },
            () {
              if (imagePath.isNotEmpty) {
                final file = File(imagePath);
                if (file.existsSync()) file.deleteSync();
              }
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () {
              setState(() {
                _showWidgetB = !_showWidgetB;
                filterTitleDish = "";
              });
            },
            () {
              insertDishRecord();
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
