class DishRecord {
  int id;
  int? categoryId;
  String imagePath;
  String title;
  String desc;
  double price;

  DishRecord(
      {required this.id,
      required this.imagePath,
      required this.title,
      required this.desc,
      required this.price,
      this.categoryId});
}
