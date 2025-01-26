import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DishButton extends StatelessWidget {
  const DishButton(
      {super.key,
      required this.id,
      required this.categoryId,
      required this.imagePath,
      required this.titleCategory,
      required this.title,
      required this.desc,
      required this.price});
  final int id;
  final int categoryId;
  final String imagePath;
  final String title;
  final String titleCategory;
  final String desc;
  final double price;
  final double width = 320;
  final double height = 220;
  final double halfWidth = 160;
  final double halfHeight = 110;
  final int amountDisplay = 0;

  String formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    DishProvider dishProvider = context.watch<DishProvider>();
    String priceDisplayToStr =
        NumberFormat.currency(locale: 'vi_VN').format(price);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                  width: width,
                  height: halfHeight,
                  decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1.0,
                            offset: Offset(1.0, 1.0))
                      ])),
              Container(
                  width: width,
                  height: halfHeight,
                  decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadiusDirectional.only(
                          bottomStart: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1.0,
                            offset: Offset(1.0, 1.0))
                      ]))
            ],
          ),
        ),
        Positioned(
            child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: halfWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                          child: Image.asset(
                            (imagePath.isEmpty)
                                ? 'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp'
                                : imagePath,
                            fit: BoxFit.cover,
                            width: 150, // width * 0.47
                            height: 165, // height * 0.75
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                      width: halfWidth,
                      child: Column(children: [
                        Padding(padding: EdgeInsets.all(4.0)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(title,
                                  style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold))
                            ]),
                        Padding(padding: EdgeInsets.all(2.0)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${AppLocalizations.of(context)!.dishDesc}:',
                                  style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold))
                            ]),
                        Padding(padding: EdgeInsets.all(2.0)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: halfWidth,
                                height:
                                    132, // không được vượt quá halfHeight + 22
                                child: Text(
                                  desc,
                                  style: TextStyle(
                                      fontSize: 16, color: colorScheme.primary),
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                ),
                              )
                            ]),
                      ]))
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: halfWidth,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(priceDisplayToStr,
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold)),
                        ])),
                SizedBox(
                    width: halfWidth,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(formatNumber(dishProvider.amount(id)),
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold)),
                        ]))
              ],
            )
          ],
        )),
        Positioned(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                TextButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.only(
                              topEnd: Radius.circular(20)),
                        )),
                        maximumSize:
                            WidgetStateProperty.all(Size(width, halfHeight))),
                    onPressed: () {
                      dishProvider.increaseAmount(id, categoryId, price,
                          titleCategory, title, imagePath);
                    },
                    child: SizedBox(
                      height: halfHeight,
                      width: width,
                    )),
                TextButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.only(
                              bottomStart: Radius.circular(20)),
                        )),
                        maximumSize:
                            WidgetStateProperty.all(Size(width, halfHeight))),
                    onPressed: () {
                      dishProvider.decreaseAmount(id, categoryId, price,
                          titleCategory, title, imagePath);
                    },
                    child: SizedBox(
                      height: halfHeight,
                      width: width,
                    ))
              ],
            )
          ],
        ))
      ],
    );
  }
}
