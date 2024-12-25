import 'package:flutter/material.dart';

class SettingButtonOnline extends StatelessWidget {
  const SettingButtonOnline(
      {super.key,
      required this.colorScheme,
      required this.isChecked,
      required this.callbackCheck,
      required this.callbackRebuild,
      required this.callbackDelete,
      required this.nameBill});
  final ColorScheme colorScheme;
  final double sizeRadius = 8;
  final Function callbackCheck;
  final Function callbackRebuild;
  final Function callbackDelete;
  final bool isChecked;
  final String nameBill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322, // width = 320
      height: 80,
      decoration: BoxDecoration(
          border: Border.all(color: colorScheme.primary, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(sizeRadius)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey, blurRadius: 1.0, offset: Offset(1.0, 1.0))
          ]),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(sizeRadius),
                bottomLeft: Radius.circular(sizeRadius)),
            child: Material(
              color: (isChecked)
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onPrimary,
              child: InkWell(
                splashColor: (!isChecked)
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onPrimary,
                child: SizedBox(
                  width: 222, // width * 0.7 - 2
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.assignment,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 182, // width(222) - icon_size - 10
                          height: 70,
                          child: Text(
                            nameBill,
                            style: TextStyle(
                                fontSize: 16, color: colorScheme.primary),
                            overflow: TextOverflow.clip,
                            softWrap: true,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  callbackCheck();
                },
              ),
            ),
          ),
          Material(
            color: colorScheme.onSecondary,
            child: InkWell(
              splashColor: colorScheme.onSecondaryContainer,
              child: SizedBox(
                width: 46, // width * 0.15 - 2
                height: 80,
                child: Center(
                  child: Icon(
                    Icons.build,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              onTap: () {
                callbackRebuild();
              },
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(sizeRadius),
                bottomRight: Radius.circular(sizeRadius)),
            child: Material(
              color: colorScheme.onError,
              child: InkWell(
                splashColor: colorScheme.onErrorContainer,
                child: SizedBox(
                  width: 46, // width * 0.15 - 2
                  height: 80,
                  child: Center(
                    child: Icon(
                      Icons.delete,
                      color: colorScheme.error,
                    ),
                  ),
                ),
                onTap: () {
                  callbackDelete();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
