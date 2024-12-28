import 'package:flutter/material.dart';
import 'package:menu_qr/screens/dish_setting_32.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/setting_button.dart';

class Dish31 extends StatefulWidget {
  const Dish31({super.key});

  @override
  State<Dish31> createState() => _Dish31State();
}

class _Dish31State extends State<Dish31> {
  String filterTitleMenu = "";
  bool _showWidgetB = false;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerCategory = TextEditingController();
  final TextEditingController _controllerDescCategory = TextEditingController();
  final TextEditingController _controllerDishTitle = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final colorBottomBar = colorScheme.secondaryContainer;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: ListView(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: SettingButton(
                        colorScheme: colorScheme,
                        callbackRebuild: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => Dish32()));
                        },
                        callbackDelete: () {},
                        content: "Hello"),
                  ),
                )
              ],
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
                                  Icons.menu,
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
                                  onTap: () {},
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
                                minLines: 3,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.primary),
                                controller: _controllerDescCategory,
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
          AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search Menu',
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        filterTitleMenu = text;
                      });
                    })),
            crossFadeState: _showWidgetB
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          Container(
            height: 56,
            decoration: BoxDecoration(
                color: colorBottomBar,
                border: Border(
                    top: BorderSide(width: 1.0, color: colorScheme.primary))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.search,
                          color: colorScheme.primary,
                        ),
                        callback: () {
                          setState(() {
                            _showWidgetB = !_showWidgetB;
                            filterTitleMenu = "";
                          });
                        }),
                    BottomBarButton(
                        colorPrimary: colorBottomBarBtn,
                        child: Icon(
                          Icons.add,
                          color: colorScheme.primary,
                        ),
                        callback: () {})
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
