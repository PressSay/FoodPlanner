import 'package:flutter/material.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:menu_qr/services/databases/data.dart';

class Category45 extends StatefulWidget {
  const Category45({super.key});

  @override
  State<StatefulWidget> createState() => _Category45();
}

class _Category45 extends State<Category45> {
  bool _showWidgetB = false;
  final TextEditingController _controller = TextEditingController();
  String filterTitleCategory = "";
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    double widthScreen = MediaQuery.sizeOf(context).width;
    Map<int, CategoryRecord> filterCategoryRecoreds = (filterTitleCategory
            .isEmpty)
        ? categoryRecords
        : Map.from(categoryRecords)
      ..removeWhere((k, v) => !v.title.contains(filterTitleCategory));
    List<Widget> itemCategoryBuilder = [];
    filterCategoryRecoreds.forEach((key, value) {
      String title = value.title;
      itemCategoryBuilder.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            height: 64,
            width: widthScreen * 0.8,
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(20),
                          bottomStart: Radius.circular(20)),
                    )),
                    minimumSize: WidgetStateProperty.all(Size(50, 50))),
                onPressed: () {},
                child: Text('$key. $title')),
          )
        ]),
      ));
    });
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
          children: itemCategoryBuilder,
        ),
      )),
      bottomNavigationBar: BottomAppBar(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        BottomBarButton(
            child: Icon(Icons.arrow_back),
            callback: () {
              Navigator.pop(context);
            }),
        Padding(padding: EdgeInsets.all(48)),
        BottomBarButton(
            child: Icon(Icons.search),
            callback: () {
              setState(() {
                _showWidgetB = !_showWidgetB;
                filterTitleCategory = "";
              });
            }),
      ])),
      floatingActionButton: AnimatedCrossFade(
        firstChild: SizedBox(), // Thay thế CategoryBar bằng SizedBox
        secondChild: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
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
        crossFadeState:
            _showWidgetB ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
