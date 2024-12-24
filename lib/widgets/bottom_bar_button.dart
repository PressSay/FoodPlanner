import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {
  const BottomBarButton(
      {super.key, required this.child, required this.callback});
  final Function callback;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            )),
            minimumSize: WidgetStateProperty.all(Size(48, 48))),
        onPressed: () {
          callback();
        },
        child: child);
  }
}
