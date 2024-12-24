import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar(
      {super.key, required this.categoryFunc, required this.orderFunc});
  final Function categoryFunc;
  final Function orderFunc;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.sizeOf(context).width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: (widthScreen - 40) * 0.5,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  )),
                  minimumSize: WidgetStateProperty.all(
                      Size((widthScreen - 40) * 0.5, 46))),
              onPressed: () {
                categoryFunc();
              },
              child: Text("Class Category")),
        ),
        Padding(padding: EdgeInsets.all(5)),
        ElevatedButton(
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                )),
                minimumSize: WidgetStateProperty.all(
                    Size((widthScreen - 40) * 0.5, 46))),
            onPressed: () {
              orderFunc();
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Order"), Icon(Icons.shopping_cart)]))
      ],
    );
  }
}
