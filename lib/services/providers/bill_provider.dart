import 'package:flutter/foundation.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';

class BillProvider extends ChangeNotifier {
  final BillRecord _billRecord = BillRecord(
      id: 0,
      amountPaid: 0,
      discount: 0,
      tableId: 0,
      nameTable: "",
      type: true,
      isLeft: false,
      preOrderedDishRecords: [],
      dateTime: DateTime.now().millisecondsSinceEpoch);

  void setBillRecord(
      int id,
      double amountPaid,
      double discount,
      int tableId,
      String nameTable,
      bool isLeft,
      bool type,
      List<PreOrderedDishRecord> preOrderedDishRecords) {
    _billRecord.id = id;
    _billRecord.amountPaid = amountPaid;
    _billRecord.discount = discount;
    _billRecord.tableId = tableId;
    _billRecord.nameTable = nameTable;
    _billRecord.isLeft = isLeft;
    _billRecord.type = type;
    _billRecord.preOrderedDishRecords!.clear();
    for (var e in preOrderedDishRecords) {
      _billRecord.preOrderedDishRecords!.add(PreOrderedDishRecord(
        dishId: e.dishId,
        billId: e.billId,
        categoryId: e.categoryId,
        amount: e.amount,
        titleDish: e.titleDish,
        price: e.price,
        imagePath: e.imagePath,
      ));
    }
    notifyListeners();
  }

  BillRecord get billRecord => _billRecord;
}
