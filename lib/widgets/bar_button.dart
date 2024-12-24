import 'package:flutter/material.dart';

class BarButton extends StatelessWidget {
  const BarButton(
      {super.key, required this.iconData, required this.navigateFunc});

  final IconData iconData;
  final Function navigateFunc;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          )),
          minimumSize: WidgetStateProperty.all(Size(50, 50))),
      onPressed: () {
        navigateFunc();
      },
      child: Icon(iconData),
    );
  }
}
