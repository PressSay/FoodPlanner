import 'package:menu_qr/models/pre_ordered_dish.dart';

class BillRecord {
  int? id;
  // sau khi đã hoàn thành giao dịch thì tableId chỉ là liên kết lỏng lẻo
  int? tableId;
  double amountPaid;
  double discount;
  String nameTable;
  bool isLeft;
  bool type; // if true buy take away
  int dateTime;
  List<PreOrderedDishRecord>? preOrderedDishRecords;

  // // For dicountNext
  // double discountNext;
  // DateTime expireCode;
  // // QR will save bill id and secret code
  // String secretCode;
  BillRecord(
      {this.id,
      this.tableId,
      required this.amountPaid,
      required this.discount,
      required this.nameTable,
      required this.isLeft,
      required this.type,
      required this.dateTime,
      this.preOrderedDishRecords});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableId': tableId,
      'amountPaid': amountPaid,
      'discount': discount,
      'nameTable': nameTable,
      'isLeft': isLeft ? 1 : 0,
      'type': type ? 1 : 0,
      'dateTime': dateTime
    };
  }

  factory BillRecord.fromMap(Map<String, dynamic> map) {
    return BillRecord(
        id: map['id'],
        tableId: map['tableId'],
        amountPaid: map['amountPaid'],
        discount: map['discount'],
        nameTable: map['nameTable'],
        isLeft: map['isLeft'],
        type: map['type'],
        dateTime: map['dateTime']);
  }
}
