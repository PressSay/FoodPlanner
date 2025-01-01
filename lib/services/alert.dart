import 'package:flutter/material.dart';

class Alert {
  final BuildContext context;
  Alert({required this.context});

  void showAlert(
      String title, String content, bool isConfirm, Function? confirm) {
    List<Widget> itemBuilder = [
      TextButton(
        child: Text((isConfirm) ? 'Cancel' : 'Ok'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
    if (isConfirm) {
      itemBuilder.add(
        TextButton(
          child: const Text('Ok'),
          onPressed: () => confirm!(),
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
              actions: <Widget>[
                TextButton(
                    child: const Text(''),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Perform some action after pressing OK
                    }),
              ]);
        });
  }
}
