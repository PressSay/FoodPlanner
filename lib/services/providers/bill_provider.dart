import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';

import '../databases/data.dart';

class BillProvider extends ChangeNotifier {
  final logger = Logger();

  final BillRecord _billRecord = BillRecord(
      id: 0,
      amountPaid: 0,
      discount: 0,
      tableId: 0,
      nameTable: "",
      type: true,
      isLeft: false,
      dateTime: DateTime.now());
  final List<PreOrderedDishRecord> _preOrderedDishRecords = [];

  void resetBillIdInRam() {
    _billRecord.id = 0;
  }

  void setBillRecord(int id, double amountPaid, double discount, int tableId,
      String nameTable, bool isLeft, bool type) {
    _billRecord.id = id;
    _billRecord.amountPaid = amountPaid;
    _billRecord.discount = discount;
    _billRecord.tableId = tableId;
    _billRecord.nameTable = nameTable;
    _billRecord.isLeft = isLeft;
    _billRecord.type = type;
    notifyListeners();
  }

  BillRecord get billRecord => _billRecord;

  List<PreOrderedDishRecord> get preOrderedDishRecords =>
      _preOrderedDishRecords;

  void saveBill(List<PreOrderedDishRecord> indexDishListSorted) {
    _preOrderedDishRecords.clear();
    for (var e in indexDishListSorted) {
      _preOrderedDishRecords.add(PreOrderedDishRecord(
        dishId: e.dishId,
        billId: e.billId,
        amount: e.amount,
        titleDish: e.titleDish,
        price: e.price,
        imagePath: e.imagePath,
        categoryId: e.categoryId,
      ));
    }
  }

  // database method

  final Map<int, BillRecord> _billRecords = {
    1: BillRecord(
        id: 1,
        nameTable: "Bàn dãy cuối bàn số 1",
        tableId: 1,
        isLeft: false,
        type: false,
        dateTime: DateTime.now(),
        amountPaid: 200000,
        discount: 0,
        preOrderedDishRecords: [
          PreOrderedDishRecord(
              dishId: 1,
              billId: 1,
              titleDish: dishRecords[1]!.title,
              amount: 3,
              price: dishRecords[1]!.price,
              categoryId: dishRecords[1]!.categoryId!,
              imagePath: dishRecords[1]!.imagePath),
          PreOrderedDishRecord(
              dishId: 2,
              billId: 1,
              titleDish: dishRecords[2]!.title,
              amount: 4,
              price: dishRecords[2]!.price,
              categoryId: dishRecords[2]!.categoryId!,
              imagePath: dishRecords[2]!.imagePath),
          PreOrderedDishRecord(
              dishId: 3,
              billId: 1,
              titleDish: dishRecords[3]!.title,
              amount: 5,
              price: dishRecords[3]!.price,
              categoryId: dishRecords[3]!.categoryId!,
              imagePath: dishRecords[3]!.imagePath),
        ]),
    2: BillRecord(
        id: 2,
        nameTable: "Bàn dãy cuối bàn số 1",
        tableId: 1,
        isLeft: false,
        type: false,
        dateTime: DateTime.now(),
        amountPaid: 300000,
        discount: 0,
        preOrderedDishRecords: [
          PreOrderedDishRecord(
              dishId: 1,
              billId: 2,
              titleDish: dishRecords[1]!.title,
              amount: 3,
              price: dishRecords[1]!.price,
              categoryId: dishRecords[1]!.categoryId!,
              imagePath: dishRecords[1]!.imagePath),
          PreOrderedDishRecord(
              dishId: 3,
              billId: 2,
              titleDish: dishRecords[3]!.title,
              amount: 5,
              price: dishRecords[3]!.price,
              categoryId: dishRecords[3]!.categoryId!,
              imagePath: dishRecords[3]!.imagePath),
        ])
  };

  int _lastBillId = 2;

  void increaseLastBillId() {
    _lastBillId += 1;
  }

  int get lastBillId => _lastBillId;

  Map<int, BillRecord> get billRecords => _billRecords;

  void removeDishIdAtBillId(int dishId, int billId) {
    _billRecords[billId]
        ?.preOrderedDishRecords
        ?.removeWhere((e) => e.dishId == dishId);
    notifyListeners(); // thống báo cho list_detail cập nhật lại giá
  }

  void saveDishesAtBillId(
      List<PreOrderedDishRecord> indexDishListSorted, int billId) {
    _billRecords[billId]!.preOrderedDishRecords!.clear();

    for (var e in indexDishListSorted) {
      _billRecords[billId]!.preOrderedDishRecords!.add(PreOrderedDishRecord(
            dishId: e.dishId,
            billId: e.billId,
            amount: e.amount,
            titleDish: e.titleDish,
            price: e.price,
            imagePath: e.imagePath,
            categoryId: e.categoryId,
          ));
    }
    notifyListeners(); // thống báo cho list_detail cập nhật lại giá
  }

  void savePaidMoneyAtBillId(int billId, double paid) {
    _billRecords[billId]!.amountPaid = paid;
    notifyListeners();
  }
}
