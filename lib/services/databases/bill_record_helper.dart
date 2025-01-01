import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:sqflite/sqflite.dart';

class BillRecordHelper {
  BillRecordHelper();

  Future<void> deteleDishIdAtBillId(int billId, int dishId, Database db) async {
    await db.delete('pre_ordered_dish',
        where: 'billId = ? and dishId = ?',
        // Pass the Menu's id as a whereArg to prevent SQL injection.
        whereArgs: [billId, dishId]);
  }

  Future<List<PreOrderedDishRecord>> insertDishesAtBillId(Database db,
      List<PreOrderedDishRecord> preOrdereddishRecords, int billId) async {
    await db.delete(
      'pre_ordered_dish',
      // Use a `where` clause to delete a specific breed.
      where: 'billId = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [billId],
    );
    List<Map<String, dynamic>> data =
        preOrdereddishRecords.map((e) => e.toMap(billId)).toList();
    List<String> columns = [
      'dishId',
      'billId',
      'categoryId',
      'titleDish',
      'amount',
      'price',
      'imagePath'
    ];
    List<List<dynamic>> values = data
        .map((item) => columns.map((column) => item[column]).toList())
        .toList();
// Tạo câu truy vấn
    String sql = '''INSERT INTO pre_ordered_dish(${columns.join(',')}) VALUES
    ${values.map((row) => '(${row.map((value) => '?').join(',')})').join(',')}''';
// Thực thi truy vấn
    await db.rawInsert(sql, values.expand((i) => i).toList());
    final List<Map<String, dynamic>> maps = await db.query('pre_ordered_dish');
    return List.generate(
        maps.length, (index) => PreOrderedDishRecord.fromMap(maps[index]));
  }

  // CRUD BillRecord below

  Future<BillRecord> billRecord(int id, Database db) async {
    final List<Map<String, dynamic>> maps =
        await db.query('bill_records', where: 'id = ?', whereArgs: [id]);
    final List<Map<String, dynamic>> preOrderedDishRecordsMaps = await db
        .query('pre_ordered_dish', where: 'billId = ?', whereArgs: [id]);
    BillRecord billRecord = BillRecord.fromMap(maps[0]);
    billRecord.preOrderedDishRecords = List.generate(
        preOrderedDishRecordsMaps.length,
        (index) =>
            PreOrderedDishRecord.fromMap(preOrderedDishRecordsMaps[index]));
    return billRecord;
  }

  Future<int?> insertBillRecord(BillRecord billRecord, Database db) async {
    await db.insert(
      'bill_records',
      billRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<Map<String, dynamic>> maps = await db.query('bill_records',
        columns: ['id'], orderBy: 'id DESC', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['id'];
    }
    return null;
  }

  Future<void> updateBillRecord(BillRecord billRecord, Database db) async {
    // Update the given menuRecord
    await db.update(
      'bill_records',
      billRecord.toMap(),
      // Ensure that the Menu has a matching id.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [billRecord.id],
    );
  }

  Future<void> deleteBillRecord(int id, Database db) async {
    // Remove the Menu from the database.
    await db.delete(
      'bill_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<Map<int, BillRecord>> billRecords(
      Database db, String where, List<Object> whereArgs) async {
    final List<Map<String, dynamic>> maps =
        await db.query('bill_records', where: where, whereArgs: whereArgs);
    final List<BillRecord> tmpBillRecords = List.generate(maps.length, (index) {
      BillRecord billRecord = BillRecord.fromMap(maps[index]);
      return billRecord;
    });
    Map<int, BillRecord> billRecords = {};
    for (BillRecord e in tmpBillRecords) {
      final List<Map<String, dynamic>> preOrderedDishRecordsMaps = await db
          .query('pre_ordered_dish', where: 'billId = ?', whereArgs: [e.id!]);
      e.preOrderedDishRecords = List.generate(
          preOrderedDishRecordsMaps.length,
          (index1) =>
              PreOrderedDishRecord.fromMap(preOrderedDishRecordsMaps[index1]));
      billRecords.addAll({e.id!: e});
    }
    return billRecords;
  }
}
