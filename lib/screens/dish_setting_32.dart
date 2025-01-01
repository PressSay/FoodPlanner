import 'package:flutter/material.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/databases/dish_record_helper.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/dish_view.dart';
import 'package:sqflite/sqflite.dart';

class Dish32 extends StatefulWidget {
  const Dish32({super.key, required this.dishRecord});
  final DishRecord dishRecord;
  @override
  State<Dish32> createState() => _Dish32State();
}

class _Dish32State extends State<Dish32> {
  Alert? _alert;
  String imagePath = "";

  final TextEditingController _controllerDescDish = TextEditingController();
  final TextEditingController _controllerDishTitle = TextEditingController();
  final TextEditingController _controllerDishPrice = TextEditingController();

  final DataHelper dataHelper = DataHelper();
  final DishRecordHelper dishRecordHelper = DishRecordHelper();

  @override
  void initState() {
    _alert = Alert(context: context);
    _controllerDishTitle.text = widget.dishRecord.title;
    _controllerDescDish.text = widget.dishRecord.desc;
    _controllerDishPrice.text = widget.dishRecord.price.toString();
    imagePath = (widget.dishRecord.imagePath.isEmpty)
        ? "assets/images/hinh-cafe-kem-banh-quy-2393351094.webp"
        : widget.dishRecord.imagePath;
    super.initState();
  }

  void updateDish() async {
    if (widget.dishRecord.title.isEmpty ||
        widget.dishRecord.desc.isEmpty ||
        widget.dishRecord.price == 0 ||
        widget.dishRecord.imagePath.isEmpty) {
      _alert!.showAlert('Update Dish', 'failed!', false, null);
      return;
    }
    Database db = await dataHelper.database;
    dishRecordHelper.updateDishRecord(widget.dishRecord, db);
    _alert!.showAlert('Update Category', 'success!', false, null);
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
                                    controller: _controllerDishTitle,
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
                                "assets/images/hinh-cafe-kem-banh-quy-2393351094.jpg",
                                fit: BoxFit.cover,
                                width: 150, // width * 0.47
                                height: 165, // height * 0.75
                              ),
                            ),
                            /* Put Image here */
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: ElevatedButton(
                                  onPressed: () {}, child: Text('Upload')),
                            )
                          ])),
                ],
              ),
            ),
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
                          Icons.home,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }),
                    SizedBox(width: 48),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.save,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          updateDish();
                        })
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
