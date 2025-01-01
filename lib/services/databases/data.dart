import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/models/table_record.dart';

int lastDishId = 5;
int lastCategoryId = 2;

Map<int, CategoryRecord> categoryRecords = {
  1: CategoryRecord(
      id: 1,
      title: "Thức uống yêu thích",
      desc: "Thức uống nhiều người kêu",
      menuId: 1),
  2: CategoryRecord(
      id: 2,
      title: "Thức uống luxury",
      desc: "Thức uống cao cấp được những người giàu săn đón",
      menuId: 1),
};

Map<int, DishRecord> dishRecords = {
  1: DishRecord(
      id: 1,
      imagePath: 'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
      title: 'cafe',
      desc: 'hương vị thơm ngon dễ chịu, đậm đà!',
      price: 19000.0,
      categoryId: 1),
  2: DishRecord(
      id: 2,
      imagePath: 'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
      title: 'libton',
      desc: 'hương vị thơm ngon dễ chịu, dịu nhẹ!',
      price: 15000.0,
      categoryId: 1),
  3: DishRecord(
      id: 3,
      imagePath: 'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
      title: 'món mới',
      desc: 'món ăn mới lạ',
      price: 25000.0,
      categoryId: 1),
  4: DishRecord(
      id: 4,
      imagePath: 'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
      title: 'món khác',
      desc: 'món ăn khác',
      price: 30000.0,
      categoryId: 2),
  5: DishRecord(
      id: 5,
      imagePath: 'assets/images/hinh-cafe-kem-banh-quy-2393351094.webp',
      title: 'món mới nữa',
      desc: 'món ăn mới nữa',
      price: 28000.0,
      categoryId: 2)
};

Map<int, TableRecord> tableRecords = {
  1: TableRecord(
      id: 1,
      name: "Bàn dãy cuối bàn số 1",
      desc: "Bàn có người ăn chùa",
      numOfPeople: 0),
  2: TableRecord(
      id: 2, name: "Bàn VIP", desc: "Bàn dành cho khách VIP", numOfPeople: 0),
  3: TableRecord(id: 3, name: "Bàn tròn", desc: "Bàn tròn lớn", numOfPeople: 0),
  4: TableRecord(id: 4, name: "Bàn góc", desc: "Bàn góc cạnh", numOfPeople: 0),
  5: TableRecord(
      id: 5, name: "Bàn ngoài trời", desc: "Bàn có view đẹp", numOfPeople: 0),
  6: TableRecord(
      id: 6, name: "Bàn gia đình", desc: "Bàn rộng rãi", numOfPeople: 0),
  7: TableRecord(id: 7, name: "Bàn bar", desc: "Bàn cao", numOfPeople: 0),
  // 8: TableRecord(id: 8, name: "Bàn họp", desc: "Bàn dành cho cuộc họp")
};
