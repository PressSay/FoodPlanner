import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar(
      {super.key, required this.categoryFunc, required this.orderFunc});
  final Function categoryFunc;
  final Function orderFunc;

  @override
  Widget build(BuildContext context) {
    double widthScreen = 324;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widthScreen * 0.5,
          height: 48,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ))),
              onPressed: () {
                categoryFunc();
              },
              child: Text("Class Category")),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: widthScreen * 0.5,
          height: 48,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ))),
              onPressed: () {
                orderFunc();
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Order"), Icon(Icons.shopping_cart)])),
        )
      ],
    );
  }
}
