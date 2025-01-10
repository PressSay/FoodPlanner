import 'package:flutter/material.dart';

class Alert {
  final BuildContext context;
  Alert({required this.context});

  void showAlert(
      String title, String content, bool isConfirm, Function? confirm) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    List<Widget> itemBuilder = [
      TextButton(
        child: Text((isConfirm) ? 'Cancel' : 'Ok',
            style: TextStyle(color: colorScheme.primary)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
    if (isConfirm) {
      itemBuilder.add(
        TextButton(
          child: Text('Ok', style: TextStyle(color: colorScheme.primary)),
          onPressed: () {
            confirm!();
            Navigator.of(context).pop();
          },
        ),
      );
    }
    showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(content),
                  ],
                ),
              ),
              actions: itemBuilder);
        });
  }
}
