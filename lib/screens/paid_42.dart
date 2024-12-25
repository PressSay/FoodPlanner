import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/services/databases/data.dart';
import 'package:menu_qr/services/pdf_api.dart';
import 'package:menu_qr/services/pdf_invoice_api.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/widgets/bottom_bar_button.dart';
import 'package:provider/provider.dart';

class Paid42 extends StatefulWidget {
  const Paid42({super.key, required this.billId});
  final int billId;

  @override
  State<Paid42> createState() => _Paid42State();
}

class _Paid42State extends State<Paid42> {
  final TextEditingController _controller = TextEditingController();
  String descFromShop = "";
  String timeZone = "vi_VN";
  String nameShop = "My Shop";
  String addressShop = "My Address Shop";
  double total = 0;
  double tax = 0;
  double amountPaid = 0;

  List<Widget> infoCustomer(
      ColorScheme colorScheme,
      String taxString,
      String totalString,
      String amountPaidString,
      String changeString,
      int billId) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Name shop: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: nameShop,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]),
        ),
      ),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Address shop: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: addressShop,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Tax(5%): ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: taxString,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Total: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: totalString,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Amount paid: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: amountPaidString,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Change: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: changeString,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Bill Id: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: '$billId',
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
    ];
  }

  List<Widget> qrCode(ColorScheme colorScheme, String qrImage, String qrText) {
    return [
      Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                    child: Text('My code:',
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                    child: Image.asset(
                      qrImage,
                      fit: BoxFit.cover,
                      width: 150, // width * 0.47
                      height: 165, // height * 0.75
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                    child: Text(qrText,
                        style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold)))
              ])
            ]))
      ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    BillProvider billProvider = context.watch<BillProvider>();
    // int billId = billProvider.billRecord.id;
    int billId = widget.billId;
    String logoPath = 'assets/images/wislam.png';
    String logoText = 'https://wislam.ct.ws';
    String qrImage = logoPath;
    String qrText = logoText;

    // amountPaid = billProvider.billRecord.amountPaid;
    BillRecord? billRecord = billProvider.billRecords[billId];
    amountPaid = billRecord?.amountPaid ?? 0;
    total = 0;
    billRecord?.preOrderedDishRecords?.forEach((element) {
      int dishId = element.dishId;
      DishRecord dishRecord = dishRecords[dishId]!;
      total += (element.amount * dishRecord.price);
    });
    tax = total * 0.05;
    double change = amountPaid - total;

    String totalString = NumberFormat.currency(locale: timeZone).format(total);
    String taxString = NumberFormat.currency(locale: timeZone).format(tax);
    String changeString =
        NumberFormat.currency(locale: timeZone).format(change);
    String amountPaidString =
        NumberFormat.currency(locale: timeZone).format(amountPaid);

    Widget descFieldW = Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 28.0),
      child: TextField(
          onChanged: (value) {
            descFromShop = value;
          },
          controller: _controller,
          minLines: 4,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
              filled: true,
              fillColor: colorScheme.primaryContainer)),
    );

    List<Widget> itemBuilder = infoCustomer(colorScheme, taxString, totalString,
        amountPaidString, changeString, billId);
    itemBuilder.add(descFieldW);
    itemBuilder.addAll(qrCode(colorScheme, logoPath, logoText));

    return Scaffold(
        body: SafeArea(
            child: ListView(children: [
          Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: itemBuilder)),
        ])),
        bottomNavigationBar: BottomAppBar(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              BottomBarButton(
                  child: Icon(Icons.arrow_back),
                  callback: () {
                    Navigator.pop(context);
                  }),
              BottomBarButton(
                  child: Icon(
                    Icons.home,
                  ),
                  callback: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
              Padding(padding: EdgeInsets.all(48)),
              BottomBarButton(
                  child: Icon(
                    Icons.print,
                  ),
                  callback: () async {
                    final pdfFile = await PdfInvoiceApi.generate(
                        colorScheme,
                        billProvider.billRecord,
                        billProvider.preOrderedDishRecords,
                        [
                          'My Name Shop',
                          'My Address Shop',
                          billProvider.billRecord.nameTable,
                          taxString,
                          totalString,
                          amountPaidString,
                          changeString,
                          qrImage,
                          qrText
                        ],
                        descFromShop,
                        timeZone,
                        "Bill-$billId");
                    PdfApi.openFile(pdfFile);
                  }),
            ])));
  }
}
