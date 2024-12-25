import 'package:menu_qr/models/pre_ordered_dish.dart';

class BillRecord {
  int id;
  double amountPaid;
  double discount;
  int tableId; // sau khi đã hoàn thành giao dịch thì tableId chỉ là liên kết lỏng lẻo
  String nameTable;
  bool isLeft;
  bool type; // if true buy take away
  DateTime dateTime;
  List<PreOrderedDishRecord>? preOrderedDishRecords;

  // // For dicountNext
  // double discountNext;
  // DateTime expireCode;
  // // QR will save bill id and secret code
  // String secretCode;
  BillRecord(
      {required this.id,
      required this.amountPaid,
      required this.discount,
      required this.tableId,
      required this.nameTable,
      required this.isLeft,
      required this.type,
      required this.dateTime,
      this.preOrderedDishRecords});
}
