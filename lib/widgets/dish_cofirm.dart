import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DishCofirm extends StatelessWidget {
  const DishCofirm(
      {super.key,
      required this.onlyView,
      required this.imagePath,
      required this.title,
      required this.price,
      required this.amount,
      required this.callBackDel});
  final bool onlyView;
  final String imagePath;
  final String title;
  final double price;
  final int amount;
  final Function callBackDel;
  final double widthBarDish = 345;
  final double heightBarDish = 90;

  String formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  Widget deleteBtn(ColorScheme colorScheme) {
    return (onlyView)
        ? SizedBox()
        : Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
                onPressed: () {
                  callBackDel();
                },
                icon: Icon(
                  Icons.delete,
                  color: colorScheme.primary,
                )),
            Padding(padding: EdgeInsets.all(4))
          ]));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final myLocale = Localizations.localeOf(context);
    final priceDisplayToStr = NumberFormat.currency(
            locale: (myLocale.toString() == 'vi') ? 'vi_VN' : 'en_US',
            symbol: (myLocale.toString() == 'vi') ? 'đ' : '\$')
        .format(price);
    return Center(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Stack(children: [
        Column(children: [
          Container(
              width: widthBarDish,
              height: 27 /* heightBarDish * 0.3 */,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                border: Border.all(width: 1.0, color: colorScheme.primary),
                borderRadius:
                    BorderRadiusDirectional.only(topEnd: Radius.circular(20)),
              )),
          Container(
              width: widthBarDish,
              height: 62.99 /* heightBarDish * 0.7 */,
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 1, color: colorScheme.primary),
                    left: BorderSide(width: 1, color: colorScheme.primary),
                    right: BorderSide(width: 1, color: colorScheme.primary)),
              ))
        ]),
        Positioned(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
            ),
            child: (imagePath.isNotEmpty)
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: 86.25 /* widthBarDish * 0.25 */,
                    height: 76.5 /* heightBarDish * 0.85 */,
                  )
                : Image.asset(
                    'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
                    fit: BoxFit.cover,
                    width: 86.25 /* widthBarDish * 0.25 */,
                    height: 76.5 /* heightBarDish * 0.85 */,
                  ),
          ),
        ),
        Positioned(
            child: Column(children: [
          SizedBox(
              height: 27 /* heightBarDish * 0.3 */,
              width: widthBarDish,
              child: Row(children: [
                SizedBox(width: 86.25 /* widthBarDish * 0.25 */),
                SizedBox(
                    width: 258.75 /* widthBarDish * 0.75 */,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))
                        ]))
              ])),
          SizedBox(
              height: 62.99 /* heightBarDish * 0.7 */,
              width: widthBarDish,
              child: Row(children: [
                SizedBox(
                  width: 86.25 /* widthBarDish * 0.25 */,
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  border: Border.all(
                                      width: 1.0,
                                      color: colorScheme.primaryContainer),
                                  borderRadius: BorderRadiusDirectional.only(
                                      topEnd: Radius.circular(8),
                                      bottomStart: Radius.circular(8))),
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(priceDisplayToStr,
                                      style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold))))
                        ])),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          border: Border.all(
                              width: 1.0, color: colorScheme.primaryContainer),
                          borderRadius: BorderRadiusDirectional.only(
                              topEnd: Radius.circular(8),
                              bottomStart: Radius.circular(8))),
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(formatNumber(amount),
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))))
                ]),
                deleteBtn(colorScheme)
              ]))
        ]))
      ]),
    ));
  }
}
