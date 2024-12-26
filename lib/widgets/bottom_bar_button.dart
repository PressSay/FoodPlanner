import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {
  const BottomBarButton(
      {super.key, required this.child, required this.callback});
  final Function callback;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(width: 1, color: colorScheme.primary),
          boxShadow: [
            BoxShadow(
                color: Colors.grey, blurRadius: 1.0, offset: Offset(1.0, 1.0))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Material(
          color: colorScheme.secondaryContainer,
          child: InkWell(
            splashColor: colorScheme.inversePrimary,
            child: child,
            onTap: () => callback(),
          ),
        ),
      ),
    );
  }
}
