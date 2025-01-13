import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          splashRadius: 16.0,
          padding: EdgeInsets.zero,
          onPressed: () {
            if (currentPageIndex == 0) {
              return;
            }
            onUpdateCurrentPageIndex(currentPageIndex - 1);
          },
          icon: const Icon(
            Icons.arrow_left_rounded,
            size: 32.0,
          ),
        ),
        IconButton(
          splashRadius: 16.0,
          padding: EdgeInsets.zero,
          onPressed: () {
            onUpdateCurrentPageIndex(currentPageIndex + 1);
          },
          icon: const Icon(
            Icons.arrow_right_rounded,
            size: 32.0,
          ),
        ),
      ],
    );
  }
}
