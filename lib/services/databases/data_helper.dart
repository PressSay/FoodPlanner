import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DataHelper {
  static const String sqlMenuRecords = 'menu_records';
  static const String sqlBillRecords = "bill_records";
  static const String sqlDishRecords = 'dish_records';
  static const String sqlCategoryRecords = 'category_records';
  static const String sqlPreOrderedDishRecords = 'pre_ordered_dish';
  static const String sqlTableRecords = "table_records";

  static final DataHelper _dataHelper = DataHelper._internal();
  factory DataHelper() => _dataHelper;
  DataHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'flutter_sqflite_database.db');
    return await openDatabase(path,
        onCreate: _onCreate,
        version: 1,
        onConfigure: (db) async =>
            await db.execute('PRAGMA foreign_keys = ON'));
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $sqlMenuRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      isSelected INTEGER
    )''');

    await db.execute('''CREATE TABLE $sqlCategoryRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      menuId INTEGER,
      FOREIGN KEY (menuId) REFERENCES $sqlCategoryRecords(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE $sqlDishRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      price REAL,
      imagePath TEXT,
      categoryId INTEGER,
      FOREIGN KEY (categoryId) REFERENCES $sqlDishRecords(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE $sqlTableRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      desc TEXT,
      numOfPeople INTEGER
    )''');

    await db.execute('''CREATE TABLE $sqlBillRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      amountPaid REAL,
      discount REAL,
      tableId INTEGER,
      nameTable TEXT,
      isLeft INTEGER,
      type INTEGER,
      dateTime INTEGER -- Store as milliseconds since Unix epoch
    )''');

    await db.execute('''CREATE TABLE $sqlPreOrderedDishRecords (
      dishId INTEGER,
      billId INTEGER,
      categoryId INTEGER,
      title TEXT,
      price REAL,
      amount INTEGER,
      imagePath TEXT,
      -- FOREIGN KEY (dishId) REFERENCES $sqlDishRecords(id) ON DELETE CASCADE,
      FOREIGN KEY (billId) REFERENCES $sqlBillRecords(id) ON DELETE CASCADE,
      PRIMARY KEY (dishId, billId), -- Composite primary key
      UNIQUE (dishId, billId) -- Ensure no duplicates
    )''');
  }
  // menu_helper

  Future<int?> insertMenuRecord(MenuRecord menuRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> updateMenuRecord(MenuRecord menuRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> deleteMenuRecord(int id) async {
    final db = await _dataHelper.database;
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
      String? where, List<Object>? whereArgs, int? limit) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        (where == null && whereArgs == null && limit == null)
            ? await db.query('menu_records')
            : (where == null && whereArgs == null && limit != null)
                ? await db.query('menu_records', limit: limit)
                : await db.query('menu_records',
                    where: where, whereArgs: whereArgs, limit: limit);
    return List.generate(
        maps.length, (index) => MenuRecord.fromMap(maps[index]));
  }

  // category_helper

  Future<int?> insertCategoryRecord(CategoryRecord categoryRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> updateCategoryRecord(CategoryRecord categoryRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> deleteCategoryRecord(int id) async {
    final db = await _dataHelper.database;
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
      String? where, List<Object>? whereArgs, int? limit) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        (where == null && whereArgs == null && limit == null)
            ? await db.query('category_records')
            : (where == null && whereArgs == null && limit != null)
                ? await db.query('category_records', limit: limit)
                : await db.query('category_records',
                    where: where, whereArgs: whereArgs, limit: limit);
    return List.generate(
        maps.length, (index) => CategoryRecord.fromMap(maps[index]));
  }

  // dish_helper

  Future<int?> insertDishRecord(DishRecord dishRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> updateDishRecord(DishRecord dishRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> deleteDishRecord(int id) async {
    final db = await _dataHelper.database;
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
      String? where, List<Object>? whereArgs, int? limit) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        (where == null && whereArgs == null && limit == null)
            ? await db.query('dish_records')
            : (where == null && whereArgs == null && limit != null)
                ? await db.query('dish_records', limit: limit)
                : await db.query('dish_records',
                    where: where, whereArgs: whereArgs);
    return List.generate(
        maps.length, (index) => DishRecord.fromMap(maps[index]));
  }

  // bill_helper

  Future<void> deteleDishIdAtBillId(int billId, int dishId) async {
    final db = await _dataHelper.database;
    await db.delete('pre_ordered_dish',
        where: 'billId = ? and dishId = ?',
        // Pass the Menu's id as a whereArg to prevent SQL injection.
        whereArgs: [billId, dishId]);
  }

  Future<List<PreOrderedDishRecord>> insertDishesAtBillId(
      List<PreOrderedDishRecord> preOrdereddishRecords, int billId) async {
    final db = await _dataHelper.database;
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

  Future<BillRecord> billRecord(int id) async {
    final db = await _dataHelper.database;
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

  Future<int?> insertBillRecord(BillRecord billRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> updateBillRecord(BillRecord billRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> deleteBillRecord(int id) async {
    final db = await _dataHelper.database;
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
      String? where, List<Object>? whereArgs, int? limit) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        (where == null && whereArgs == null && limit == null)
            ? await db.query('bill_records')
            : (where == null && whereArgs == null && limit != null)
                ? await db.query('bill_records', limit: limit)
                : await db.query('bill_records',
                    where: where, whereArgs: whereArgs);
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

  // table_helper

  Future<TableRecord?> tableRecord(int id) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('table_records', where: 'id = ?', whereArgs: [id]);
    return TableRecord.fromMap(maps[0]);
  }

  Future<int?> insertTableRecord(TableRecord tableRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> updateTableRecord(TableRecord tableRecord) async {
    final db = await _dataHelper.database;
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

  Future<void> deleteTableRecord(int id) async {
    final db = await _dataHelper.database;
    // Remove the Menu from the database.
    await db.delete(
      'table_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<TableRecord>> tableRecords() async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('table_records');
    return List.generate(
        maps.length, (index) => TableRecord.fromMap(maps[index]));
  }
}
