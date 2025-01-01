import 'package:menu_qr/models/dish_record.dart';
import 'package:sqflite/sqflite.dart';

class DishRecordHelper {
  DishRecordHelper();

  // CRUD below

  // Future<MenuRecord> menuRecord(int id, Database db) async {
  //   final List<Map<String, dynamic>> maps =
  //       await db.query('menu_records', where: 'id = ?', whereArgs: [id]);
  //   return MenuRecord.fromMap(maps[0]);
  // }

  Future<int?> insertDishRecord(DishRecord dishRecord, Database db) async {
    await db.insert(
      'dish_records',
      dishRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<Map<String, dynamic>> maps = await db.query('dish_records',
        columns: ['id'], orderBy: 'id DESC', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['id'];
    }
    return null;
  }

  Future<void> updateDishRecord(DishRecord dishRecord, Database db) async {
    // Update the given menuRecord
    await db.update(
      'dish_records',
      dishRecord.toMap(),
      // Ensure that the Menu has a matching id.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [dishRecord.id],
    );
  }

  Future<void> deleteDishRecord(int id, Database db) async {
    // Remove the Menu from the database.
    await db.delete(
      'dish_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<DishRecord>> dishRecords(
      Database db, String where, List<Object> whereArgs) async {
    final List<Map<String, dynamic>> maps =
        await db.query('dish_records', where: where, whereArgs: whereArgs);
    return List.generate(
        maps.length, (index) => DishRecord.fromMap(maps[index]));
  }
}
