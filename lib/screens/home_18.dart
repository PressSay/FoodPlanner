import 'package:flutter/material.dart';
import 'package:menu_qr/screens/list_47.dart';
import 'package:menu_qr/screens/overview_20.dart';
import 'package:menu_qr/screens/settings/setting_17.dart';
import 'package:menu_qr/screens/table_35.dart';
import 'package:menu_qr/widgets/bar_button.dart';
import 'package:menu_qr/widgets/menu_button.dart';
import 'package:menu_qr/screens/order_44.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:menu_qr/services/utils.dart';

class Home18 extends StatefulWidget {
  const Home18(
      {super.key, required this.changeToLight, required this.changeToDark});
  final Function changeToLight;
  final Function changeToDark;

  @override
  State<StatefulWidget> createState() => _Home18();
}

class _Home18 extends State<Home18> {
  String shopName = '';
  bool isDark = false;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shopName = prefs.getString('name') ?? '';
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

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
              iconData: Icons.dark_mode,
              navigateFunc: () {
                if (!isDark) {
                  widget.changeToDark();
                  isDark = true;
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            BarButton(
                iconData: Icons.light_mode,
                navigateFunc: () {
                  if (isDark) {
                    widget.changeToLight();
                    isDark = false;
                  }
                })
          ])),
      Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(children: [
            Center(
              child: Text(AppLocalizations.of(context)!.hello),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(shopName),
              Icon(
                Icons.star,
                color: colorScheme.primary,
              )
            ])
          ])),
      Container(
          height: heightScreen * 0.7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                  top: BorderSide(width: 1.0, color: colorScheme.primary))),
          child: ListView(key: const ValueKey('scrollViewHome'), children: [
            Padding(
                padding: EdgeInsets.fromLTRB(30, 25, 30, 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MenuButton(
                    iconData: Icons.table_bar,
                    text: AppLocalizations.of(context)!.tableUnlock,
                    navigateFunc: () {
                      navigateWithFade(
                          context, Table35(isList: true, billId: 0));
                    },
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  MenuButton(
                      iconData: Icons.description,
                      text: AppLocalizations.of(context)!.overview,
                      navigateFunc: () {
                        navigateWithFade(context, Overview20());
                      })
                ])),
            Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MenuButton(
                    iconData: Icons.assignment,
                    text: AppLocalizations.of(context)!.billList,
                    navigateFunc: () {
                      navigateWithFade(
                        context,
                        ListScreen47(),
                      );
                    },
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  MenuButton(
                      iconData: Icons.storefront,
                      text: AppLocalizations.of(context)!.order,
                      navigateFunc: () {
                        navigateWithFade(
                          context,
                          Order44(
                            isImmediate: false,
                            isRebuild: false,
                          ),
                        );
                      })
                ])),
            Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MenuButton(
                    key: const ValueKey('Setting'),
                    iconData: Icons.settings,
                    text: AppLocalizations.of(context)!.setting,
                    navigateFunc: () {
                      navigateWithFade(context, Setting17());
                    },
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  MenuButton(
                      iconData: Icons.payment,
                      text: AppLocalizations.of(context)!.buyTakeAway,
                      navigateFunc: () {
                        navigateWithFade(
                            context,
                            Order44(
                              isImmediate: true,
                              isRebuild: false,
                            ));
                      })
                ]))
          ]))
    ])));
  }
}
