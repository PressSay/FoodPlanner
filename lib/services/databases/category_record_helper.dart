import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRecordHelper {
  CategoryRecordHelper();

  // CRUD below

  // Future<MenuRecord> menuRecord(int id, Database db) async {
  //   final List<Map<String, dynamic>> maps =
  //       await db.query('menu_records', where: 'id = ?', whereArgs: [id]);
  //   return MenuRecord.fromMap(maps[0]);
  // }

  Future<int?> insertCategoryRecord(
      CategoryRecord categoryRecord, Database db) async {
    await db.insert(
      'category_records',
      categoryRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<Map<String, dynamic>> maps = await db.query('category_records',
        columns: ['id'], orderBy: 'id DESC', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['id'];
    }
    return null;
  }

  Future<void> updateCategoryRecord(
      CategoryRecord categoryRecord, Database db) async {
    // Update the given menuRecord
    await db.update(
      'category_records',
      categoryRecord.toMap(),
      // Ensure that the Menu has a matching id.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [categoryRecord.id],
    );
  }

  Future<void> deleteCategoryRecord(int id, Database db) async {
    // Remove the Menu from the database.
    await db.delete(
      'category_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<CategoryRecord>> categoryRecords(
      Database db, String where, List<Object> whereArgs, int? limit) async {
    final List<Map<String, dynamic>> maps = await db.query('category_records',
        where: where, whereArgs: whereArgs, limit: limit);
    return List.generate(
        maps.length, (index) => CategoryRecord.fromMap(maps[index]));
  }
}
