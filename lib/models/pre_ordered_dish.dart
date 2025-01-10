class PreOrderedDishRecord {
  int dishId; // sau khi đã hoàn thành giao dịch thì dishId chỉ là liên kết lỏng lẻo
  int billId;
  int categoryId; // dùng để sắp xếp
  String titleCategory; // dùng để hiển thị
  String titleDish;
  int amount;
  double price;
  String imagePath;

  PreOrderedDishRecord(
      {required this.dishId,
      required this.billId,
      required this.categoryId,
      required this.titleCategory,
      required this.titleDish,
      required this.amount,
      required this.price,
      required this.imagePath});

  Map<String, dynamic> toMap(int newBillId) {
    return {
      'dishId': dishId,
      'billId': newBillId,
      'categoryId': categoryId,
      'titleCategory': titleCategory,
      'titleDish': titleDish,
      'amount': amount,
      'price': price,
      'imagePath': imagePath,
    };
  }

  factory PreOrderedDishRecord.fromMap(Map<String, dynamic> map) {
    return PreOrderedDishRecord(
      dishId: map['dishId'],
      billId: map['billId'],
      categoryId: map['categoryId'],
      titleCategory: map['titleCategory'],
      titleDish: map['titleDish'],
      amount: map['amount'],
      price: map['price'],
      imagePath: map['imagePath'],
    );
  }
}
