import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/services/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PdfInvoiceApi {
  static Future<File> generate(
    AppLocalizations appLocalizations,
    material.ColorScheme colorScheme,
    BillRecord billRecord,
    List<PreOrderedDishRecord> filteredDishRecords,
    List<String> info,
    String desc,
    String timeZone,
    String billName,
  ) async {
    final regularFontData =
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final boldFontData =
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    final italicFontData =
        await rootBundle.load('assets/fonts/NotoSans-Italic.ttf');
    final boldItalicFontData =
        await rootBundle.load('assets/fonts/NotoSans-BoldItalic.ttf');

    final regularFont = Font.ttf(regularFontData.buffer.asByteData());
    final boldFont = Font.ttf(boldFontData.buffer.asByteData());
    final italicFont = Font.ttf(italicFontData.buffer.asByteData());
    final boldItalicFont = Font.ttf(boldItalicFontData.buffer.asByteData());

    final themeData = ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
      boldItalic: boldItalicFont,
    );

    final pdf = Document(theme: themeData);
    final img = await rootBundle.load(info[8]);
    // final netImage = await networkImage('https://www.nfet.net/nfet.jpg');
    final imageBytes = img.buffer.asUint8List();
    Image qrImage = Image(MemoryImage(imageBytes)); // Image(netImage)

    pdf.addPage(MultiPage(
      build: (context) => [
        buildTitle(info[0], desc),
        buildContext(
            appLocalizations, info, billRecord.id!, billRecord.dateTime),
        SizedBox(height: 1 * PdfPageFormat.cm),
        buildInvoice(appLocalizations, filteredDishRecords, timeZone),
        Divider(),
        buildTotal(appLocalizations, info)
      ],
      footer: (context) => buildFooter(qrImage, info[9]),
    ));

    return PdfApi.saveDocument(name: '$billName.pdf', pdf: pdf);
  }

  static Widget buildTitle(String shopName, String desc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shopName,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.4 * PdfPageFormat.cm),
          Text(desc),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildContext(AppLocalizations appLocalizations,
      List<String> info, int billId, DateTime billDate) {
    List<double> stdSizePad = [1.0 * PdfPageFormat.mm, 2.0 * PdfPageFormat.mm];
    final dateTime = billDate;
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
            stdSizePad[0], 0.0, stdSizePad[0], stdSizePad[1]),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '${appLocalizations.billId}: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: '$billId',
            )
          ]),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
            stdSizePad[0], 0.0, stdSizePad[0], stdSizePad[1]),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '${appLocalizations.date}: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: formattedDate)
          ]),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
            stdSizePad[0], 0.0, stdSizePad[0], stdSizePad[1]),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '${appLocalizations.shopAddress}: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: info[1])
          ]),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
            stdSizePad[0], 0.0, stdSizePad[0], stdSizePad[1]),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '${appLocalizations.tableRecord}: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: info[2])
          ]),
        ),
      ),
    ]);
  }

  static Widget buildInvoice(AppLocalizations appLocalizations,
      List<PreOrderedDishRecord> filteredDishRecords, String myLocale) {
    final List<String> headers = [
      appLocalizations.name,
      appLocalizations.unitPrice,
      appLocalizations.quantity,
      appLocalizations.total
    ];
    final data = filteredDishRecords.map((item) {
      final total = item.price * item.amount;
      String totalString = NumberFormat.currency(
              locale: (myLocale.toString() == 'vi') ? 'vi_VN' : 'en_US',
              symbol: (myLocale.toString() == 'vi') ? 'đ' : '\$')
          .format(total);
      String priceString = NumberFormat.currency(
              locale: (myLocale.toString() == 'vi') ? 'vi_VN' : 'en_US',
              symbol: (myLocale.toString() == 'vi') ? 'đ' : '\$')
          .format(item.price);
      return [item.titleDish, priceString, item.amount, totalString];
    }).toList();

    return TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: BoxDecoration(color: PdfColors.grey300),
        border: null,
        cellAlignments: {
          0: Alignment.centerRight,
          1: Alignment.centerRight,
          2: Alignment.centerRight,
          3: Alignment.centerRight,
        });
  }

  static Widget buildTotal(
          AppLocalizations appLocalizations, List<String> info) =>
      Container(
          // alignment: Alignment.centerRight,
          child: Row(children: [
        Spacer(flex: 6),
        Expanded(
            flex: 4,
            child: Column(children: [
              buildText(
                  title: appLocalizations.tax, value: info[3], unite: false),
              buildText(
                  title: appLocalizations.discount,
                  value: info[4],
                  unite: false),
              buildText(
                title: '${appLocalizations.total} (${appLocalizations.tax})',
                value: info[5],
                unite: true,
              ),
              Divider(),
              buildText(
                title: appLocalizations.paid,
                value: info[6],
                unite: false,
              ),
              buildText(
                title: '',
                value: '-${info[5]}',
                unite: false,
              ),
              buildText(
                title: appLocalizations.change,
                value: info[7],
                unite: true,
              ),
              SizedBox(height: 2 * PdfPageFormat.mm),
              Container(height: 1, color: PdfColors.grey400),
              SizedBox(height: 0.5 * PdfPageFormat.mm),
              Container(height: 1, color: PdfColors.grey400),
            ]))
      ]));

  static Widget buildText(
      {required String title,
      required String value,
      double width = double.infinity,
      TextStyle? titleStyle,
      bool unite = false}) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  static Widget buildFooter(Image qrImage, String qrText) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          Container(width: 120, height: 120, child: qrImage),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(qrText, style: TextStyle(fontWeight: FontWeight.bold))
        ],
      );
}
