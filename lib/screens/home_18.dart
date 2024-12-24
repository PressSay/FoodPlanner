import 'package:flutter/material.dart';
import 'package:menu_qr/screens/list_40.dart';
import 'package:menu_qr/widgets/bar_button.dart';
import 'package:menu_qr/widgets/menu_button.dart';
import 'package:menu_qr/screens/order_44.dart';

class Home18 extends StatefulWidget {
  const Home18({super.key});

  @override
  State<StatefulWidget> createState() => _Home18();
}

class _Home18 extends State<Home18> {
  int isDark = 0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    double heightScreen = MediaQuery.sizeOf(context).height;
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      Padding(
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            BarButton(
              iconData: Icons.notifications,
              navigateFunc: () {},
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    isDark++;
                  });
                },
                child: Text('$isDark')),
            BarButton(iconData: Icons.person, navigateFunc: () {})
          ])),
      Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(children: [
            Center(
              child: Text('The star of the store'),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('1.45M'), Icon(Icons.star)])
          ])),
      Container(
          height: heightScreen * 0.7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
              border: Border(
                  top: BorderSide(
                      width: 1.0, color: colorScheme.onPrimaryContainer))),
          child: ListView(children: [
            Padding(
                padding: EdgeInsets.fromLTRB(30, 25, 30, 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MenuButton(
                    iconData: Icons.table_bar,
                    text: "Table Unclock",
                    navigateFunc: () {},
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  MenuButton(
                      iconData: Icons.adb,
                      text: "Order online List",
                      navigateFunc: () {})
                ])),
            Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MenuButton(
                    iconData: Icons.assignment,
                    text: "Order Offline List",
                    navigateFunc: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ListScreen40(),
                          ));
                    },
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  MenuButton(
                      iconData: Icons.storefront,
                      text: "Start Order",
                      navigateFunc: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Order44(isImmediate: false),
                            ));
                      })
                ])),
            Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MenuButton(
                    iconData: Icons.settings,
                    text: "Setting",
                    navigateFunc: () {},
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  MenuButton(
                      iconData: Icons.payment,
                      text: "Buy Take Away",
                      navigateFunc: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Order44(isImmediate: true),
                            ));
                      })
                ]))
          ]))
    ])));
  }
}
