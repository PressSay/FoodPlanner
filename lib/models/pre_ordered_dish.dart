class PreOrderedDishRecord {
  int dishId;
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
