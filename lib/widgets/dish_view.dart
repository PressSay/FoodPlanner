import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:provider/provider.dart';

class DishView extends StatelessWidget {
  const DishView(
      {super.key,
      required this.id,
      required this.categoryId,
      required this.imagePath,
      required this.title,
      required this.desc,
      required this.price});
  final int id;
  final int categoryId;
  final String imagePath;
  final String title;
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
    final myLocale = Localizations.localeOf(context);
    String priceDisplayToStr = NumberFormat.currency(
            locale: (myLocale.toString() == 'vi') ? 'vi_VN' : 'en_US',
            symbol: (myLocale.toString() == 'vi') ? 'đ' : '\$')
        .format(price);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(20),
                          bottomStart: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1.0,
                            offset: Offset(1.0, 1.0))
                      ])),
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
                          child: (imagePath.isNotEmpty)
                              ? Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                  width: 150, // width * 0.47
                                  height: 165, // height * 0.75
                                )
                              : Image.asset(
                                  'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
                                  fit: BoxFit.cover,
                                  width: 150, // width * 0.47
                                  height: 165,
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
                              Text('Description:',
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
      ],
    );
  }
}
