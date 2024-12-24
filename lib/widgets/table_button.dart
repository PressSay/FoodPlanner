import 'package:flutter/material.dart';

class TableButton extends StatelessWidget {
  const TableButton(
      {super.key, required this.nameTable, required this.callBack});
  final String nameTable;
  final Function callBack;
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
            maximumSize: WidgetStateProperty.all(Size(120, 120))),
        onPressed: () {
          callBack();
        },
        child: Center(
          child: Text(
            nameTable,
            style: TextStyle(fontSize: 16, color: colorScheme.primary),
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
    );
  }
}
