import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {
  const BottomBarButton(
      {super.key,
      required this.child,
      required this.callback,
      required this.colorPrimary // border, button, shadow, spanshColor
      });
  final Function callback;
  final Widget child;
  final List<Color> colorPrimary;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(width: 1, color: colorPrimary[0])),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Material(
          color: colorPrimary[1],
          child: InkWell(
            splashColor: colorPrimary[2],
            child: child,
            onTap: () => callback(),
          ),
        ),
      ),
    );
  }
}
