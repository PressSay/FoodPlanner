import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/services/pdf_api.dart';
import 'package:menu_qr/services/pdf_invoice_api.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';

class Paid42 extends StatefulWidget {
  const Paid42({super.key, required this.billRecord});
  final BillRecord billRecord;

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
    // int billId = billProvider.billRecord.id;
    final int billId = widget.billRecord.id!;
    final String logoPath = 'assets/images/wislam.png';
    final String logoText = 'https://wislam.ct.ws';
    final String qrImage = logoPath;
    final String qrText = logoText;

    // amountPaid = billProvider.billRecord.amountPaid;
    amountPaid = widget.billRecord.amountPaid;
    total = 0;
    widget.billRecord.preOrderedDishRecords?.forEach((element) {
      total += (element.amount * element.price);
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: ListView(children: [
                Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: itemBuilder)),
              ]),
            ),
          ),
          BottomNavigatorCustomize(listEnableBtn: [
            true,
            true,
            false,
            true
          ], listCallback: [
            () {
              Navigator.pop(context);
            },
            () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            () async {
              final pdfFile = await PdfInvoiceApi.generate(
                  colorScheme,
                  widget.billRecord,
                  widget.billRecord.preOrderedDishRecords ?? [],
                  [
                    'My Name Shop',
                    'My Address Shop',
                    widget.billRecord.nameTable,
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
            }
          ], icons: [
            Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
            Icon(Icons.home, color: colorScheme.primary),
            Icon(
              Icons.print,
              color: colorScheme.primary,
            )
          ])
        ],
      ),
    );
  }
}
