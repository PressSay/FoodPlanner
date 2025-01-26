import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/services/databases/data_helper.dart';
import 'package:menu_qr/services/pdf_api.dart';
import 'package:menu_qr/services/pdf_invoice_api.dart';
import 'package:menu_qr/widgets/bottom_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Paid42 extends StatefulWidget {
  const Paid42({super.key, required this.billRecord});
  final BillRecord billRecord;

  @override
  State<Paid42> createState() => _Paid42State();
}

class _Paid42State extends State<Paid42> {
  final TextEditingController _controller = TextEditingController();
  final String logoImage = 'assets/images/wislam.png';
  final String logoText = 'https://wislam.ct.ws';
  final dataHelper = DataHelper();

  String descFromShop = "";
  String timeZone = "vi_VN";
  String nameShop = "";
  String addressShop = "";

  double total = 0;
  double amountPaid = 0;

  List<Widget> infoCustomer(
      ColorScheme colorScheme,
      String taxString,
      String discountString,
      String totalString,
      String amountPaidString,
      String changeString,
      int billId) {
    final appLocalizations = AppLocalizations.of(context)!;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '${appLocalizations.shopName}: ',
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
                text: '${appLocalizations.shopAddress}: ',
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
                text: '${appLocalizations.tax}: ',
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
                text: '${appLocalizations.discount}: ',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
            TextSpan(
                text: discountString,
                style: TextStyle(
                    color: colorScheme.secondary, fontWeight: FontWeight.bold))
          ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: '${appLocalizations.total}: ',
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
                text: '${appLocalizations.paid}: ',
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
                text: '${appLocalizations.change}: ',
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
                text: '${appLocalizations.billId}: ',
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
                    child: Text('${AppLocalizations.of(context)!.qrCode}:',
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

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final address = prefs.getString('address');
    final tmpPreOrderedDishRecords = await dataHelper.preOrderedDishList(
        where: 'billId = ?', whereArgs: [widget.billRecord.id!]);

    var tmpTotal = 0.0;
    for (var element in tmpPreOrderedDishRecords) {
      tmpTotal += (element.amount * element.price);
    }

    amountPaid = widget.billRecord.amountPaid;
    setState(() {
      nameShop = name ?? "";
      addressShop = address ?? "";
      total = tmpTotal;
      widget.billRecord.preOrderedDishRecords = tmpPreOrderedDishRecords;
      amountPaid = widget.billRecord.amountPaid;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Column contentView(ColorScheme colorScheme) {
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
              labelText: AppLocalizations.of(context)!
                  .recordDesc(AppLocalizations.of(context)!.billRecord),
              filled: true,
              fillColor: colorScheme.primaryContainer)),
    );

    List<Widget> itemBuilder = infoCustomer(
        colorScheme,
        moneyFormat(widget.billRecord.tax * total),
        moneyFormat(widget.billRecord.discount),
        moneyFormat(total - widget.billRecord.discount),
        moneyFormat(amountPaid),
        moneyFormat(amountPaid - (total - widget.billRecord.discount)),
        widget.billRecord.id!);
    itemBuilder.add(descFieldW);
    itemBuilder.addAll(qrCode(colorScheme, logoImage, logoText));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: itemBuilder);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final navigator = Navigator.of(context);
          widget.billRecord.preOrderedDishRecords?.clear();
          navigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: ListView(children: [
                  Padding(
                      padding: EdgeInsets.all(12),
                      child: contentView(colorScheme)),
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
                widget.billRecord.preOrderedDishRecords?.clear();
                Navigator.pop(context);
              },
              () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              () async {
                final pdfFile = await PdfInvoiceApi.generate(
                    AppLocalizations.of(context)!,
                    colorScheme,
                    widget.billRecord,
                    widget.billRecord.preOrderedDishRecords ?? [],
                    [
                      nameShop,
                      addressShop,
                      widget.billRecord.nameTable,
                      moneyFormat(widget.billRecord.tax * total),
                      moneyFormat(widget.billRecord.discount),
                      moneyFormat(total - widget.billRecord.discount),
                      moneyFormat(amountPaid),
                      moneyFormat(
                          amountPaid - (total - widget.billRecord.discount)),
                      logoImage,
                      logoText
                    ],
                    descFromShop,
                    timeZone,
                    "Bill-${widget.billRecord.id!}");
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
      ),
    );
  }

  String moneyFormat(double money) {
    return NumberFormat.currency(locale: timeZone).format(money);
  }
}
