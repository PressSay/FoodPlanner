import 'package:menu_qr/models/table_record.dart';
import 'package:sqflite/sqflite.dart';

class TableRecordHelper {
  TableRecordHelper();

  // CRUD below

  // Future<MenuRecord> menuRecord(int id, Database db) async {
  //   final List<Map<String, dynamic>> maps =
  //       await db.query('menu_records', where: 'id = ?', whereArgs: [id]);
  //   return MenuRecord.fromMap(maps[0]);
  // }

  Future<int?> insertTableRecord(TableRecord tableRecord, Database db) async {
    await db.insert(
      'table_records',
      tableRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<Map<String, dynamic>> maps = await db.query('table_records',
        columns: ['id'], orderBy: 'id DESC', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['id'];
    }
    return null;
  }

  Future<void> updateTableRecord(TableRecord tableRecord, Database db) async {
    // Update the given menuRecord
    await db.update(
      'table_records',
      tableRecord.toMap(),
      // Ensure that the Menu has a matching id.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [tableRecord.id],
    );
  }

  Future<void> deleteTableRecord(int id, Database db) async {
    // Remove the Menu from the database.
    await db.delete(
      'table_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<TableRecord>> tableRecords(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query('table_records');
    return List.generate(
        maps.length, (index) => TableRecord.fromMap(maps[index]));
  }
}
