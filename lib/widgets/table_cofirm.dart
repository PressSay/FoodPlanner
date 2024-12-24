import 'package:flutter/material.dart';

class TableConfirm extends StatelessWidget {
  const TableConfirm({super.key, required this.callBack, required this.text});
  final Function callBack;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
        child: ElevatedButton(
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                )),
                maximumSize: WidgetStateProperty.all(Size(110, 50))),
            onPressed: () {
              callBack();
            },
            child: Center(
                child: Text(
                    text, // View just visibile when isLockTable have value True
                    style: TextStyle(fontSize: 14, color: colorScheme.primary),
                    overflow: TextOverflow.clip,
                    softWrap: true))));
  }
}
