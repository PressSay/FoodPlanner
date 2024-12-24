import 'package:flutter/material.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/screens/category_45.dart';
import 'package:menu_qr/screens/confirm_38.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/widgets/dish_button.dart';
import 'package:menu_qr/widgets/category_bar.dart';
import 'package:provider/provider.dart';
import 'package:menu_qr/services/databases/data.dart';

class Order44 extends StatefulWidget {
  const Order44({super.key, required this.isImmediate});
  final bool isImmediate;
  final iconSize = 24;
  @override
  State<StatefulWidget> createState() => _Order44();
}

class _Order44 extends State<Order44> {
  String filterTitleDish = "";
  bool _showWidgetB = false;
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // final currentWidth = MediaQuery.of(context).size.width;
    DishProvider dishProvider = context.watch<DishProvider>();
    // Add item to listview
    Map<int, DishRecord> dishRecordsFiltered =
        (filterTitleDish.isEmpty) ? dishRecords : Map.from(dishRecords)
          ..removeWhere((k, v) => !v.title.contains(filterTitleDish));
    List<Widget> itemDishBuilder = [];
    dishRecordsFiltered.forEach((key, value) {
      itemDishBuilder.add(Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Center(
            child: DishButton(
                id: key,
                categoryId: value.categoryId!,
                imagePath: value.imagePath,
                title: value.title,
                desc: value.desc,
                price: value.price),
          )));
    });

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, _) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          body: SafeArea(
              child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Expanded(
                  child: ListView(
                children: itemDishBuilder,
              )),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Confirm38(isImmediate: widget.isImmediate)));
              }),
              Padding(padding: EdgeInsets.all(8)),
            ],
          )),
          bottomNavigationBar: BottomAppBar(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                BottomBarButton(
                    child: Icon(Icons.arrow_back),
                    callback: () {
                      Navigator.pop(context);
                    }),
                BottomBarButton(
                    child: Icon(
                      Icons.delete,
                      color: colorScheme.error,
                    ),
                    callback: () {
                      dishProvider.clearRamWithNotify();
                    }),
                // BottomBarButton(
                //     child: Icon(Icons.next_plan),
                //     callback: () {
                //       Navigator.pop(context);
                //     }),
                Padding(padding: EdgeInsets.all(48)),
                BottomBarButton(
                    child: Icon(Icons.search),
                    callback: () {
                      setState(() {
                        _showWidgetB = !_showWidgetB;
                        filterTitleDish = "";
                      });
                    })
              ])),
          floatingActionButton: AnimatedCrossFade(
            firstChild: SizedBox(),
            secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search Dish',
                        filled: true,
                        fillColor: colorScheme.primaryContainer),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ));
  }
}
