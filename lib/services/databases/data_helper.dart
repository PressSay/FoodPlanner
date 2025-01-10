import 'dart:io';

import 'package:logger/logger.dart';
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
  final logger = Logger();
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
      titleDish TEXT,
      price REAL,
      amount INTEGER,
      imagePath TEXT,
      -- Dont need dishID foreign key because when dishId delete billid will not delete with them
      -- FOREIGN KEY (dishId) REFERENCES $sqlDishRecords(id) ON DELETE CASCADE,
      FOREIGN KEY (billId) REFERENCES $sqlBillRecords(id) ON DELETE CASCADE,
      PRIMARY KEY (dishId, billId), -- Composite primary key
      UNIQUE (dishId, billId) -- Ensure no duplicates
    )''');
  }
  // menu_helper

  Future<int> insertMenuRecord(MenuRecord menuRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      'menu_records',
      menuRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
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
    final sql = '''
    SELECT dish_records.* from menu_records JOIN category_records ON 
    category_records.menuId = menu_records.id JOIN dish_records ON 
    categoryId = category_records.id WHERE menu_records.id = ?
    ''';
    final maps = await db.rawQuery(sql, [id]);
    final dishRecords = maps.map((e) => DishRecord.fromMap(e)).toList();
    for (var e in dishRecords) {
      File file = File(e.imagePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    // Remove the Menu from the database.
    await db.delete(
      'menu_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<MenuRecord>> menuRecords({
    String? where,
    List<Object>? whereArgs,
    int? limit,
  }) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'menu_records',
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
    return List.generate(
      maps.length,
      (index) => MenuRecord.fromMap(maps[index]),
    );
  }

  // category_helper

  Future<int> insertCategoryRecord(CategoryRecord categoryRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      'category_records',
      categoryRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
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
    final sqlQuery = '''
    SELECT dish_records.* FROM category_records JOIN dish_records ON 
    categoryId = category_records.id WHERE category_records.id = ?
    ''';
    final maps = await db.rawQuery(sqlQuery, [id]);
    for (var e in maps) {
      File image = File(e['imagePath'].toString());
      logger.d(image);
      if (image.existsSync()) {
        image.deleteSync();
      }
    }
    // Remove the Menu from the database.
    await db.delete(
      'category_records',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<CategoryRecord>> categoryRecords({
    String? where,
    List<Object>? whereArgs,
    int? limit,
  }) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category_records',
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
    return List.generate(
      maps.length,
      (index) => CategoryRecord.fromMap(maps[index]),
    );
  }

  // dish_helper

  Future<int> insertDishRecord(DishRecord dishRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      'dish_records',
      dishRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
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

  Future<List<DishRecord>> dishRecords({
    String? where,
    List<Object>? whereArgs,
    int? limit,
  }) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dish_records',
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
    return List.generate(
      maps.length,
      (index) => DishRecord.fromMap(maps[index]),
    );
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
      List<PreOrderedDishRecord> preOrderedDishRecords, int billId) async {
    final db = await _dataHelper.database;
    var sqlPreOrderedDish = '''SELECT * FROM pre_ordered_dish WHERE billId = ? 
    AND dishId NOT IN (SELECT dishId from pre_ordered_dish JOIN 
    dish_records ON id = dishId WHERE billId = ?)''';
    var mapPreOrderedDishNotExisted =
        await db.rawQuery(sqlPreOrderedDish, [billId, billId]);
    var preOrderedDishNotExisted = List.generate(
      mapPreOrderedDishNotExisted.length,
      (index) =>
          PreOrderedDishRecord.fromMap(mapPreOrderedDishNotExisted[index]),
    );

    List<Map<String, dynamic>> data = preOrderedDishRecords
        .where(
            (e) => !preOrderedDishNotExisted.any((e1) => e.dishId == e1.dishId))
        .map((e) => e.toMap(billId))
        .toList();

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

    String deleteSql = '''DELETE FROM pre_ordered_dish WHERE billId = ? AND 
        dishId IN (SELECT dishId FROM pre_ordered_dish JOIN 
        dish_records ON id = dishId WHERE billId = ?)''';
    List<dynamic> deleteArgs = [billId, billId];
    await db.rawDelete(deleteSql, deleteArgs);

    logger.d("delete pre_ordered_dish $deleteSql\n $deleteArgs");
// Tạo câu truy vấn
    String sql = '''INSERT INTO pre_ordered_dish(${columns.join(',')}) VALUES
    ${values.map((row) => '(${row.map((value) => '?').join(',')})').join(',')}''';
// Thực thi truy vấn
    await db.rawInsert(sql, values.expand((i) => i).toList());
    final List<Map<String, dynamic>> maps = await db
        .query('pre_ordered_dish', where: 'billId = ?', whereArgs: [billId]);
    return List.generate(
        maps.length, (index) => PreOrderedDishRecord.fromMap(maps[index]));
  }

  // CRUD BillRecord below

  Future<BillRecord?> billRecord(int id) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('bill_records', where: 'id = ?', whereArgs: [id]);
    final List<Map<String, dynamic>> preOrderedDishRecordsMaps = await db
        .query('pre_ordered_dish', where: 'billId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      BillRecord billRecord = BillRecord.fromMap(maps[0]);
      billRecord.preOrderedDishRecords = List.generate(
          preOrderedDishRecordsMaps.length,
          (index) =>
              PreOrderedDishRecord.fromMap(preOrderedDishRecordsMaps[index]));
      return billRecord;
    }
    return null;
  }

  Future<int> insertBillRecord(BillRecord billRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      'bill_records',
      billRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
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

  Future<Map<int, BillRecord>> billRecords({
    String? where,
    List<Object>? whereArgs,
    int? limit,
  }) async {
    final db = await _dataHelper.database;

    final query = StringBuffer('SELECT * FROM bill_records');
    final queryParams = [];

    if (where != null && whereArgs != null) {
      query.write(' WHERE $where');
      queryParams.addAll(whereArgs);
    }

    if (limit != null) {
      query.write(' LIMIT $limit');
    }

    final maps = await db.rawQuery(query.toString(), queryParams);

    final billRecords = Map<int, BillRecord>.fromIterable(
        maps.map((e) => BillRecord.fromMap(e)).toList(),
        key: (e) => e.id!);

    for (var billRecord in billRecords.values) {
      final preOrderedDishRecordsMaps = await db.rawQuery(
        'SELECT * FROM pre_ordered_dish FULL JOIN '
        'category_records ON categoryId = id WHERE billId = ?',
        [billRecord.id!],
      );
      billRecord.preOrderedDishRecords = preOrderedDishRecordsMaps
          .map((e) => PreOrderedDishRecord.fromMap(e))
          .toList();
    }

    return billRecords;
  }

  Future<double> revenueBillRecord(int id) async {
    final db = await _dataHelper.database;
    String sql = "SELECT SUM(price * amount) AS "
        "revenue FROM pre_ordered_dish WHERE billId = ?";
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [id]);
    var value = maps.elementAtOrNull(0)?['revenue'];
    return double.parse(value.toString());
  }

  // table_helper

  Future<TableRecord?> tableRecord(int id) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('table_records', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return TableRecord.fromMap(maps[0]);
    return null;
  }

  Future<int> insertTableRecord(TableRecord tableRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      'table_records',
      tableRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateTableRecord(TableRecord tableRecord) async {
    final db = await _dataHelper.database;
    // Update the given menuRecord
    try {
      await db.update(
        'table_records',
        tableRecord.toMap(),
        // Ensure that the Menu has a matching id.
        where: 'id = ?',
        // Pass the Menu's id as a whereArg to prevent SQL injection.
        whereArgs: [tableRecord.id],
      );

      await db.rawUpdate(
        'UPDATE bill_records SET nameTable = ? WHERE tableId = ?',
        [tableRecord.name, tableRecord.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTableRecord(int id) async {
    final db = await _dataHelper.database;

    try {
      // Xóa bản ghi bàn từ cơ sở dữ liệu.
      await db.delete(
        'table_records',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Cập nhật các bản ghi hóa đơn liên quan
      await db.rawUpdate(
        'UPDATE bill_records SET tableId = ? WHERE tableId = ?',
        [0, id],
      );
    } catch (e) {
      // Xử lý các ngoại lệ tiềm năng (ví dụ: lỗi cơ sở dữ liệu)

      // Có thể ném lại ngoại lệ hoặc xử lý nó một cách phù hợp
      // dựa trên nhu cầu của ứng dụng.
      rethrow;
    }
  }

  Future<Map<int, TableRecord>> tableRecords() async {
    final db = await _dataHelper.database;

    final List<TableRecord> tableRecords = await db
        .query('table_records')
        .then((maps) => maps.map((e) => TableRecord.fromMap(e)).toList());

    final mapTableRecords =
        Map<int, TableRecord>.fromIterable(tableRecords, key: (e) => e.id!);

    return mapTableRecords;
  }
}
