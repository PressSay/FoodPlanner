import 'package:flutter/material.dart';

/// Hàm tiện ích để điều hướng với hiệu ứng FadeTransition
Future<T?> navigateWithFade<T>(
  BuildContext context,
  Widget page, {
  Duration transitionDuration = const Duration(milliseconds: 200),
}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    ),
  );
}
