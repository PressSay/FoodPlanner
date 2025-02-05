import 'package:menu_qr/models/category_record.dart';

class DishRecord {
  int? id;
  int categoryId;
  String imagePath;
  String title;
  String desc;
  double price;
  DateTime? timeStamp;
  CategoryRecord? category;

  DishRecord(
      {this.id,
      required this.categoryId,
      required this.imagePath,
      required this.title,
      required this.desc,
      required this.price,
      this.timeStamp,
      this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'price': price,
      'imagePath': imagePath,
      'categoryId': categoryId,
      'timeStamp': timeStamp?.toString() ?? DateTime.now().toString()
    };
  }

  factory DishRecord.fromMap(Map<String, dynamic> map) {
    return DishRecord(
        id: map['id'],
        title: map['title'],
        desc: map['desc'],
        price: map['price'],
        imagePath: map['imagePath'],
        categoryId: map['categoryId'],
        timeStamp: DateTime.parse(map['timeStamp']));
  }
}
