import 'package:flutter/material.dart';
import 'package:menu_qr/screens/overview_20.dart';
import 'package:menu_qr/screens/settings/menu_setting_29.dart';
import 'package:menu_qr/services/alert.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:menu_qr/widgets/menu_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting17 extends StatefulWidget {
  const Setting17({super.key});

  @override
  State<Setting17> createState() => _Setting17State();
}

class _Setting17State extends State<Setting17> {
  Alert? alert;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerAdress = TextEditingController();
  final TextEditingController _controllerTax = TextEditingController();
  final TextEditingController _controllerDiscount = TextEditingController();

  @override
  void initState() {
    alert = Alert(context: context);
    loadData();
    super.initState();
  }

  Future<void> saveData({
    required String name,
    required String address,
    required double tax,
    required double discount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('address', address);
    await prefs.setDouble('tax', tax);
    await prefs.setDouble('discount', discount);

    alert!.showAlert('Success', 'Data saved successfully', false, null);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _controllerName.text = prefs.getString('name') ?? '';
    _controllerAdress.text = prefs.getString('address') ?? '';
    _controllerTax.text = prefs.getDouble('tax').toString() ?? '';
    _controllerDiscount.text = prefs.getDouble('discount').toString() ?? '';
  }

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
                                            labelText: 'Shop Address',
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
                                    child: Text('Tax:',
                                        style: TextStyle(
                                            color: colorScheme.primary)),
                                  ),
                                  SizedBox(
                                      width: 240,
                                      child: TextField(
                                          controller: _controllerTax,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Tax %',
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
                                    child: Text('Discount:',
                                        style: TextStyle(
                                            color: colorScheme.primary)),
                                  ),
                                  SizedBox(
                                      width: 240,
                                      child: TextField(
                                          controller: _controllerDiscount,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Discount %',
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
            () {
              if (_controllerName.text.isEmpty &&
                  _controllerAdress.text.isEmpty &&
                  _controllerTax.text.isEmpty &&
                  _controllerDiscount.text.isEmpty) {
                alert!
                    .showAlert('Error', "Please fill all fields", false, null);
              }
              double tmpTax = 0;
              double tmpDiscount = 0;
              try {
                tmpTax = double.parse(_controllerTax.text);
                tmpDiscount = double.parse(_controllerDiscount.text);
              } catch (e) {
                tmpTax = 0;
                tmpDiscount = 0;
              }
              saveData(
                  name: _controllerName.text,
                  address: _controllerAdress.text,
                  tax: tmpTax,
                  discount: tmpDiscount);
            }
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
