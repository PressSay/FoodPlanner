import 'package:flutter/material.dart';

class AssignmentButton extends StatelessWidget {
  const AssignmentButton(
      {super.key, required this.callBack, required this.colors});

  final Function callBack;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12, top: 8, bottom: 8),
      height: 48.0,
      child: SizedBox.fromSize(
        size: Size(48, 48), // button width and height
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Material(
            color: colors[2], // button color
            child: InkWell(
              splashColor: colors[1],
              // splash color
              onTap: () {},
              // button pressed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.assignment,
                    color: colors[0],
                  ), // icon
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
