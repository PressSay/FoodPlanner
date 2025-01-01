import 'package:menu_qr/models/menu_record.dart';
import 'package:sqflite/sqflite.dart';

class MenuRecordHelper {
  MenuRecordHelper();

  // CRUD below

  // Future<MenuRecord> menuRecord(int id, Database db) async {
  //   final List<Map<String, dynamic>> maps =
  //       await db.query('menu_records', where: 'id = ?', whereArgs: [id]);
  //   return MenuRecord.fromMap(maps[0]);
  // }

  Future<int?> insertMenuRecord(MenuRecord menuRecord, Database db) async {
    await db.insert(
      'menu_records',
      menuRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<Map<String, dynamic>> maps = await db.query('category_records',
        columns: ['id'], orderBy: 'id DESC', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['id'];
    }
    return null;
  }

  Future<void> updateMenuRecord(MenuRecord menuRecord, Database db) async {
    // Update the given menuRecord
    await db.update(
      'menu_records',
      menuRecord.toMap(),
      // Ensure that the Menu has a matching id.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [menuRecord.id],
    );
  }

  Future<void> deleteMenuRecord(int id, Database db) async {
    // Remove the Menu from the database.
    await db.delete(
      'menu_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<MenuRecord>> menuRecords(
      Database db, String where, List<Object> whereArgs, int? limit) async {
    final List<Map<String, dynamic>> maps = await db.query('menu_records',
        where: '', whereArgs: whereArgs, limit: limit);
    return List.generate(
        maps.length, (index) => MenuRecord.fromMap(maps[index]));
  }
}
