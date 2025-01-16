import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/dish_view.dart';
import 'package:path_provider/path_provider.dart';

class Dish32 extends StatefulWidget {
  const Dish32({super.key, required this.dishRecord});
  final DishRecord dishRecord;
  @override
  State<Dish32> createState() => _Dish32State();
}

class _Dish32State extends State<Dish32> {
  Alert? alert;
  String imagePath = "";
  bool isSaved = true;

  final logger = Logger();
  final defaultImage = "assets/images/hinh-cafe-kem-banh-quy-2393351094.jpg";
  final TextEditingController _controllerDescDish = TextEditingController();
  final TextEditingController _controllerDishTitle = TextEditingController();
  final TextEditingController _controllerDishPrice = TextEditingController();

  final DataHelper dataHelper = DataHelper();

  @override
  void initState() {
    alert = Alert(context: context);
    _controllerDishTitle.text = widget.dishRecord.title;
    _controllerDescDish.text = widget.dishRecord.desc;
    _controllerDishPrice.text = widget.dishRecord.price.toString();
    imagePath = (widget.dishRecord.imagePath.isEmpty)
        ? "assets/images/hinh-cafe-kem-banh-quy-2393351094.webp"
        : widget.dishRecord.imagePath;
    super.initState();
  }

  void deleteImageTmp(String imagePath_) {
    File file = File(imagePath_);
    if (file.existsSync()) file.deleteSync();
  }

  void updateDish() async {
    double priceDish =
        double.parse(_controllerDishPrice.text.replaceAll(',', ''));
    if (_controllerDishTitle.text.isEmpty ||
        _controllerDescDish.text.isEmpty ||
        priceDish == 0) {
      alert!.showAlert('Update Dish', 'failed!', false, null);
      return;
    }
    if (imagePath.compareTo(widget.dishRecord.imagePath) != 0) {
      logger.d("delete old widget.dishRecord.imagePath");
      final oldImage = File(widget.dishRecord.imagePath);
      if (oldImage.existsSync()) await oldImage.delete();
    }
    setState(() {
      widget.dishRecord.desc = _controllerDescDish.text;
      widget.dishRecord.title = _controllerDishTitle.text;
      widget.dishRecord.price = double.tryParse(_controllerDishPrice.text) ?? 0;
    });
    widget.dishRecord.imagePath = imagePath;
    dataHelper.updateDishRecord(widget.dishRecord);
    isSaved = true;
    alert!.showAlert('Update Category', 'success!', false, null);
  }

  void uploadImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      alert!.showAlert('Upload', 'failed', false, null);
      return;
    }
    if (imagePath.isNotEmpty &&
        widget.dishRecord.imagePath.compareTo(imagePath) != 0) {
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
      // sẽ lỗi nếu như có trùng tên file ?
      final newFile = await File(file.path!).copy(tmpNewFile.path);
      setState(() {
        imagePath = newFile.path;
      });
      isSaved = false;
      logger.i('Image uploaded successfully to temporary location.');
    } catch (e) {
      alert!.showAlert('Upload', 'Error uploading image: $e', false, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget dishView = Center(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: DishView(
              id: widget.dishRecord.id!,
              categoryId: widget.dishRecord.categoryId,
              imagePath: imagePath,
              title: widget.dishRecord.title,
              desc: widget.dishRecord.desc,
              price: widget.dishRecord.price,
            )));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: ListView(
              children: [dishView],
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
                                      widget.dishRecord.title = value;
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
                                      widget.dishRecord.price =
                                          double.parse(value);
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
                                  widget.dishRecord.desc = value;
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
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            false,
            true
          ], listCallback: [
            () {
              if (imagePath.isNotEmpty && !isSaved) {
                deleteImageTmp(imagePath);
              }
              Navigator.pop(context);
            },
            () {
              if (imagePath.isNotEmpty && !isSaved) {
                deleteImageTmp(imagePath);
              }
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () {
              updateDish();
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
              Icons.save,
              color: colorScheme.primary,
            )
          ]),
        ],
      ),
    );
  }
}
