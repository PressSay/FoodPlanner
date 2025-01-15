import 'package:flutter/foundation.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class DishProvider extends ChangeNotifier {
  int _categoryId = 0;
  String _titleCategory = "";
  int _menuId = 0;
  double _total = 0;
  double _discount = 0;
  double _tax = 0;

  final Map<int, PreOrderedDishRecord> _indexDishList = {};
  // [_indexDishListSorted] có tác dụng import vào Database
  final List<PreOrderedDishRecord> _indexDishListSorted = [];

  double get total => _total;
  double get discount => _discount;
  double get tax => _tax;
  Map<int, PreOrderedDishRecord> get indexDishList => _indexDishList;
  List<PreOrderedDishRecord> get indexDishListSorted => _indexDishListSorted;

  void setTotalAndDiscountAndTax(double total, double discount, double tax) {
    _total = total;
    _discount = discount;
    _tax = tax;
  }

  void setCateogry(int categoryId, String titleCategory) {
    _categoryId = categoryId;
    _titleCategory = titleCategory;
    notifyListeners();
  }

  void setMenuId(int menuId) {
    _menuId = menuId;
  }

  int get categoryId => _categoryId;

  String get titleCategory => _titleCategory;

  int get menuId => _menuId;

  void importDataToIndexDishList(
      List<PreOrderedDishRecord> preOrderedDishRecords) {
    _indexDishList.clear();
    for (var e in preOrderedDishRecords) {
      _indexDishList.addAll({e.dishId: e});
    }
  }

  void importDataToIndexDishListSorted(
      List<PreOrderedDishRecord> preOrderedDishRecords) {
    _indexDishListSorted.clear();
    _indexDishListSorted.addAll(preOrderedDishRecords);
    _indexDishListSorted.sort((a, b) {
      return a.categoryId - b.categoryId;
    });
  }

  // table will be 0 if user choose order imediately
  void increaseAmount(int id, int categoryId, double price,
      String titleCategory_, String title, String imagePath) {
    // List<int> newElement = [categoryIndex, dishIndex, amount, table];
    if (!_indexDishList.containsKey(id)) {
      _indexDishList.addAll({
        id: PreOrderedDishRecord(
            amount: 0,
            billId: 0,
            categoryId: categoryId,
            titleCategory: titleCategory_,
            titleDish: title,
            dishId: id,
            price: price,
            imagePath: imagePath)
      });
    }
    _indexDishList[id]!.amount += 1;
    notifyListeners();
  }

  void decreaseAmount(int id, int categoryId, double price,
      String titleCategory_, String title, String imagePath) {
    if (!_indexDishList.containsKey(id)) {
      _indexDishList.addAll({
        id: PreOrderedDishRecord(
            amount: 0,
            billId: 0,
            categoryId: categoryId,
            titleCategory: titleCategory_,
            titleDish: title,
            dishId: id,
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
    // notifyListeners();
  }

  void deleteEmptyIndexDishList() {
    _indexDishList.removeWhere((k, v) => v.amount == 0);
  }

  int amount(int id) {
    return _indexDishList[id]?.amount ?? 0;
  }

  void clearIndexListWithNotify() {
    _indexDishList.clear();
    notifyListeners();
  }

  void clearIndexListRam() {
    _indexDishList.clear();
  }
}
