import 'package:flutter/material.dart';
import 'package:menu_qr/screens/overview_20.dart';
import 'package:menu_qr/screens/settings/menu_setting_29.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/menu_button.dart';

class Setting17 extends StatefulWidget {
  const Setting17({super.key});

  @override
  State<Setting17> createState() => _Setting17State();
}

class _Setting17State extends State<Setting17> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerAdress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SafeArea(
            child: Column(
              children: [
                Expanded(
                    child: ListView(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: Text('Name:',
                                        style: TextStyle(
                                            color: colorScheme.primary)),
                                  ),
                                  SizedBox(
                                      width: 240,
                                      child: TextField(
                                          controller: _controllerName,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Shop Name',
                                          )))
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: Text('Address:',
                                        style: TextStyle(
                                            color: colorScheme.primary)),
                                  ),
                                  SizedBox(
                                      width: 240,
                                      child: TextField(
                                          controller: _controllerAdress,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Adress Shop',
                                          )))
                                ]),
                          )
                        ])
                  ],
                )),
                Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(
                          top: BorderSide(
                              width: 1.0, color: colorScheme.primary))),
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MenuButton(
                              key: const ValueKey('ButtonMenuId'),
                              iconData: Icons.menu,
                              text: "Menu Setting",
                              navigateFunc: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        maintainState: true,
                                        builder: (context) => Menu29()));
                              },
                            ),
                            Padding(padding: EdgeInsets.all(20)),
                            MenuButton(
                                iconData: Icons.description,
                                text: "Overview",
                                navigateFunc: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          maintainState: true,
                                          builder: (context) => Overview20()));
                                })
                          ])),
                )
              ],
            ),
          )),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            false,
            false,
            true
          ], listCallback: [
            () {
              Navigator.pop(context);
            },
            () {}
          ], icons: [
            Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
            Icon(
              Icons.save,
              color: colorScheme.primary,
            )
          ])
        ],
      ),
    );
  }
}
