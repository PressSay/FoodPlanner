import 'package:flutter/material.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';

class BottomNavigatorCustomize extends StatelessWidget {
  const BottomNavigatorCustomize(
      {super.key,
      required this.listEnableBtn,
      required this.listCallback,
      required this.icons});
  final List<bool> listEnableBtn;
  final List<Function> listCallback;
  final List<Widget> icons;

  List<Widget> itemBuilder(ColorScheme colorScheme, BuildContext context) {
    final colorBottomBarBtn = [
      colorScheme.primary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary
    ];
    final List<Widget> widgets = [];
    int i = 0;
    if (listEnableBtn.length != 4) {
      return widgets;
    }
    for (var e in listEnableBtn) {
      final currentIndex = i;
      Function? callback = listCallback.elementAtOrNull(currentIndex);
      if (!e) {
        widgets.add(SizedBox(width: 42));
        if (listCallback.length == 4) {
          i++;
        }
        continue;
      }
      widgets.add(BottomBarButton(
          colorPrimary: colorBottomBarBtn,
          child: icons[currentIndex],
          callback: () {
            if (callback != null) {
              callback();
            }
          }));
      i++;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorBottomBar = colorScheme.secondaryContainer;

    return Container(
        height: 68,
        decoration: BoxDecoration(
            color: colorBottomBar,
            border: Border(
                top: BorderSide(width: 1.0, color: colorScheme.primary))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: itemBuilder(colorScheme, context)),
        ));
  }
}
