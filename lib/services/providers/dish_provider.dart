import 'package:flutter/foundation.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class DishProvider extends ChangeNotifier {
  final Map<int, PreOrderedDishRecord> _indexDishList = {};

  Map<int, PreOrderedDishRecord> get indexDishList => _indexDishList;

  // table will be 0 if user choose order imediately
  void increaseAmount(
      int id, int categoryId, double price, String title, String imagePath) {
    // List<int> newElement = [categoryIndex, dishIndex, amount, table];
    if (!_indexDishList.containsKey(id)) {
      _indexDishList.addAll({
        id: PreOrderedDishRecord(
            amount: 0,
            billId: 0,
            titleDish: title,
            dishId: id,
            categoryId: categoryId,
            price: price,
            imagePath: imagePath)
      });
    }
    _indexDishList[id]!.amount += 1;
    notifyListeners();
  }

  void decreaseAmount(
      int id, int categoryId, double price, String title, String imagePath) {
    if (!_indexDishList.containsKey(id)) {
      _indexDishList.addAll({
        id: PreOrderedDishRecord(
            amount: 0,
            billId: 0,
            titleDish: title,
            dishId: id,
            categoryId: categoryId,
            price: price,
            imagePath: imagePath)
      });
    }
    _indexDishList[id]!.amount =
        (_indexDishList[id]!.amount == 0) ? 0 : _indexDishList[id]!.amount - 1;
    notifyListeners();
  }

  void deleteAmount(int id) {
    if (!_indexDishList.containsKey(id)) {
      return;
    }
    _indexDishList.remove(id);
    notifyListeners();
  }

  void deleteZero() {
    _indexDishList.removeWhere((k, v) => v.amount == 0);
  }

  int amount(int id) {
    return _indexDishList[id]?.amount ?? 0;
  }

  void clearRamWithNotify() {
    _indexDishList.clear();
    notifyListeners();
  }

  void clearRam() {
    _indexDishList.clear();
  }
}
