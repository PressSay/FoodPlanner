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
      dateTime: DateTime.now());
  final List<PreOrderedDishRecord> _preOrderedDishRecords = [];

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

  BillRecord get billRecord {
    return _billRecord;
  }

  List<PreOrderedDishRecord> get preOrderedDishRecords {
    return _preOrderedDishRecords;
  }

  void saveBill(Map<int, PreOrderedDishRecord> indexDishList) {
    _preOrderedDishRecords.clear();
    indexDishList.forEach((k, v) {
      _preOrderedDishRecords.add(PreOrderedDishRecord(
        dishId: k,
        billId: _billRecord.id,
        amount: v.amount,
        titleDish: v.titleDish,
        price: v.price,
        imagePath: v.imagePath,
        categoryId: v.categoryId,
      ));
    });
  }
}
