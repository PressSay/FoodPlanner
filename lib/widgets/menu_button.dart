import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton(
      {super.key,
      required this.iconData,
      required this.text,
      required this.navigateFunc});
  final IconData iconData;
  final String text;
  final Function navigateFunc;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text),
        Padding(padding: EdgeInsets.all(4)),
        ElevatedButton(
          style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              )),
              minimumSize: WidgetStateProperty.all(Size(120, 120))),
          onPressed: () {
            navigateFunc();
          },
          child: Icon(
            iconData,
            size: 42,
          ),
        ),
      ],
    );
  }
}
