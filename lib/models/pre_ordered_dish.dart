class PreOrderedDishRecord {
  int dishId; // sau khi đã hoàn thành giao dịch thì dishId chỉ là liên kết lỏng lẻo
  int billId;
  int categoryId;
  String titleDish;
  int amount;
  double price;
  String imagePath;

  PreOrderedDishRecord(
      {required this.dishId,
      required this.categoryId,
      required this.billId,
      required this.titleDish,
      required this.amount,
      required this.price,
      required this.imagePath});
}
