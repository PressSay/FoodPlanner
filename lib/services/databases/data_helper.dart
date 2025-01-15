import 'dart:io';

import 'package:logger/logger.dart';
import 'package:menu_qr/models/bill_record.dart';
import 'package:menu_qr/models/category_record.dart';
import 'package:menu_qr/models/dish_record.dart';
import 'package:menu_qr/models/menu_record.dart';
import 'package:menu_qr/models/pre_ordered_dish.dart';
import 'package:menu_qr/models/table_record.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DataHelper {
  static const String sqlMenuRecords = 'menu_records';
  static const String sqlBillRecords = "bill_records";
  static const String sqlDishRecords = 'dish_records';
  static const String sqlCategoryRecords = 'category_records';
  static const String sqlPreOrderedDishRecords = 'pre_ordered_dish';
  static const String sqlTableRecords = "table_records";
  static const String sqlTmpDishRecord = "tmp_dish_records";

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
    // delete this if you want to use sqflite on mobile
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // delete this if you want to use sqflite on mobile

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
      FOREIGN KEY (menuId) REFERENCES $sqlMenuRecords(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE $sqlDishRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      price REAL,
      imagePath TEXT,
      categoryId INTEGER,
      FOREIGN KEY (categoryId) REFERENCES $sqlCategoryRecords(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE $sqlTableRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      desc TEXT,
      numOfPeople INTEGER
    )''');

    await db.execute('''CREATE TABLE $sqlBillRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tax REAL,
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
      titleCategory TEXT,
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
      sqlMenuRecords,
      menuRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateMenuRecord(MenuRecord menuRecord) async {
    final db = await _dataHelper.database;
    // Update the given menuRecord
    await db.update(
      sqlMenuRecords,
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
    SELECT $sqlDishRecords.* from $sqlMenuRecords JOIN $sqlCategoryRecords ON 
    $sqlCategoryRecords.menuId = $sqlMenuRecords.id JOIN $sqlDishRecords ON 
    categoryId = $sqlCategoryRecords.id WHERE $sqlMenuRecords.id = ?
    ''';
    final maps = await db.rawQuery(sql, [id]);
    for (var e in maps) {
      File image = File(e['imagePath'].toString());
      if (image.existsSync()) {
        image.deleteSync();
      }
    }
    // Remove the Menu from the database.
    await db.delete(
      sqlMenuRecords,
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
    int? pageNum,
    int? pageSize,
  }) async {
    final db = await _dataHelper.database;
    try {
      final query = StringBuffer('SELECT * FROM $sqlMenuRecords');
      final queryParams = [];

      if (where != null && whereArgs != null) {
        query.write(' WHERE $where');
        queryParams.addAll(whereArgs);
      }

      if (pageNum != null && pageSize != null) {
        final offset = (pageNum - 1) * pageSize;
        query.write(' LIMIT ? OFFSET ?');
        queryParams.addAll([pageSize, offset]);
      } else if (limit != null) {
        query.write(' LIMIT ?');
        queryParams.add(limit);
      }

      final maps = await db.rawQuery(query.toString(), queryParams);

      return List.generate(
          maps.length, (index) => MenuRecord.fromMap(maps[index]));
    } catch (e) {
      return []; // Or rethrow, depending on your error handling strategy
    }
  }

// category_helper

  Future<int> insertCategoryRecord(CategoryRecord categoryRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      sqlCategoryRecords,
      categoryRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateCategoryRecord(CategoryRecord categoryRecord) async {
    final db = await _dataHelper.database;
    // Update the given menuRecord
    await db.update(
      sqlCategoryRecords,
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
    SELECT $sqlDishRecords.* FROM $sqlCategoryRecords JOIN $sqlDishRecords ON 
    categoryId = $sqlCategoryRecords.id WHERE $sqlCategoryRecords.id = ?
    ''';
    final maps = await db.rawQuery(sqlQuery, [id]);
    for (var e in maps) {
      File image = File(e['imagePath'].toString());
      if (image.existsSync()) {
        image.deleteSync();
      }
    }
    // Remove the Menu from the database.
    await db.delete(
      sqlCategoryRecords,
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<CategoryRecord>> categoryRecords({
    String? where,
    List<Object?>? whereArgs,
    int? limit,
    int? pageNum,
    int? pageSize,
  }) async {
    final db = await _dataHelper.database;
    try {
      final offset = (pageNum != null && pageSize != null)
          ? (pageNum - 1) * pageSize
          : null;
      final maps = await db.query(sqlCategoryRecords,
          where: where,
          whereArgs: whereArgs,
          limit: pageSize ?? limit,
          offset: offset);

      return List.generate(
          maps.length, (index) => CategoryRecord.fromMap(maps[index]));
    } catch (e) {
      return []; // Or throw the exception, depending on your error handling strategy
    }
  }

// dish_helper

  Future<int> insertDishRecord(DishRecord dishRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      sqlDishRecords,
      dishRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateDishRecord(DishRecord dishRecord) async {
    final db = await _dataHelper.database;
    // Update the given menuRecord
    await db.update(
      sqlDishRecords,
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
      sqlDishRecords,
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<List<DishRecord>> dishRecords(
      {String? where,
      List<Object?>? whereArgs,
      int? limit,
      int? pageNum,
      int? pageSize}) async {
    final db = await _dataHelper.database;
    try {
      if (pageNum != null && pageSize != null) {
        final offset = (pageNum - 1) * pageSize;

        // Use parameterized query to prevent SQL injection
        final List<Map<String, dynamic>> maps = await db.query(
          sqlDishRecords,
          where: where,
          whereArgs: whereArgs,
          limit: pageSize,
          offset: offset,
        );

        return List.generate(
          maps.length,
          (index) => DishRecord.fromMap(maps[index]),
        );
      } else {
        final List<Map<String, dynamic>> maps = await db.query(
          sqlDishRecords,
          where: where,
          whereArgs: whereArgs,
          limit: limit,
        );
        return List.generate(
          maps.length,
          (index) => DishRecord.fromMap(maps[index]),
        );
      }
    } catch (e) {
      // Handle the error appropriately, e.g., return an empty list or rethrow
      return []; // Or throw an exception
    }
  }

// bill_helper

  Future<void> deteleDishIdAtBillId(int billId, int dishId) async {
    final db = await _dataHelper.database;
    await db.delete(sqlPreOrderedDishRecords,
        where: 'billId = ? and dishId = ?',
        // Pass the Menu's id as a whereArg to prevent SQL injection.
        whereArgs: [billId, dishId]);
  }

  Future<List<PreOrderedDishRecord>> insertDishesAtBillId(
      List<PreOrderedDishRecord> preOrderedDishRecords, int billId) async {
    final db = await _dataHelper.database;
    final sqlPreOrderedDish =
        '''SELECT * FROM $sqlPreOrderedDishRecords WHERE billId = ? 
    AND dishId NOT IN (SELECT dishId from $sqlPreOrderedDishRecords JOIN 
    $sqlDishRecords ON id = dishId WHERE billId = ?)''';
    final mapPreOrderedDishNotExisted =
        await db.rawQuery(sqlPreOrderedDish, [billId, billId]);
    final preOrderedDishNotExisted = List.generate(
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
      'titleCategory',
      'titleDish',
      'amount',
      'price',
      'imagePath'
    ];
    List<List<dynamic>> values = data
        .map((item) => columns.map((column) => item[column]).toList())
        .toList();

    String deleteSql =
        '''DELETE FROM $sqlPreOrderedDishRecords WHERE billId = ? AND 
        dishId IN (SELECT dishId FROM $sqlPreOrderedDishRecords JOIN 
        $sqlDishRecords ON id = dishId WHERE billId = ?)''';
    List<dynamic> deleteArgs = [billId, billId];
    await db.rawDelete(deleteSql, deleteArgs);

    // Tạo câu truy vấn
    final sql =
        '''INSERT INTO $sqlPreOrderedDishRecords(${columns.join(',')}) VALUES
    ${values.map((row) => '(${row.map((value) => '?').join(',')})').join(',')}''';
    // Thực thi truy vấn
    await db.rawInsert(sql, values.expand((i) => i).toList());
    final List<Map<String, dynamic>> maps = await db.query(
        sqlPreOrderedDishRecords,
        where: 'billId = ?',
        whereArgs: [billId]);
    return List.generate(
        maps.length, (index) => PreOrderedDishRecord.fromMap(maps[index]));
  }

  // CRUD BillRecord below

  Future<BillRecord?> billRecord(int id) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query(sqlBillRecords, where: 'id = ?', whereArgs: [id]);
    final List<Map<String, dynamic>> preOrderedDishRecordsMaps = await db
        .query(sqlPreOrderedDishRecords, where: 'billId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final billRecord = BillRecord.fromMap(maps[0]);
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
      sqlBillRecords,
      billRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateBillRecord(BillRecord billRecord) async {
    final db = await _dataHelper.database;
    // Update the given menuRecord
    await db.update(
      sqlBillRecords,
      billRecord.toMap(),
      // Ensure that the Menu has a matching id.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [billRecord.id],
    );
  }

  Future<void> deleteBillRecord(int billId) async {
    final db = await _dataHelper.database;
    // Remove the Menu from the database.
    await db.delete(
      sqlBillRecords,
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Menu's id as a whereArg to prevent SQL injection.
      whereArgs: [billId],
    );
    final sql = "UPDATE table_records SET numOfPeople = (numOfPeople-1) "
        "WHERE numOfPeople > 0 AND id = "
        "(SELECT tableId FROM bill_records WHERE id = ?)";
    await db.rawUpdate(sql, [billId]);
  }

  Future<List<BillRecord>> billRecords({
    String? where,
    List<Object?>? whereArgs,
    int? limit,
    int? pageNum,
    int? pageSize,
  }) async {
    final db = await _dataHelper.database;
    try {
      final offset = (pageSize != null && pageNum != null)
          ? (pageNum - 1) * pageSize
          : null;
      final maps = await db.query(sqlBillRecords,
          where: where,
          whereArgs: whereArgs,
          limit: pageSize ?? limit,
          offset: offset);

      if (maps.isEmpty) return [];

      final billRecords = List.generate(
        maps.length,
        (index) => BillRecord.fromMap(maps[index]),
      );

      return billRecords;
    } catch (e) {
      // Handle the error appropriately, e.g., return an empty map or rethrow
      return []; // Or throw an exception
    }
  }

  Future<List<PreOrderedDishRecord>> preOrderedDishList(
      {String? where,
      List<Object?>? whereArgs,
      int? limit,
      int? pageNum,
      int? pageSize}) async {
    final db = await _dataHelper.database;
    final offset =
        (pageSize != null && pageNum != null) ? (pageNum - 1) * pageSize : null;
    final maps = await db.query(sqlPreOrderedDishRecords,
        where: where,
        whereArgs: whereArgs,
        limit: pageSize ?? limit,
        offset: offset);
    return List.generate(
        maps.length, (index) => PreOrderedDishRecord.fromMap(maps[index]));
  }

  Future<double> revenueBillRecord(int id) async {
    final db = await _dataHelper.database;
    final sql = "SELECT SUM(price * amount) AS "
        "revenue FROM $sqlPreOrderedDishRecords WHERE billId = ?";
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [id]);
    var value = maps.elementAtOrNull(0)?['revenue'];
    return double.parse(value.toString());
  }

// table_helper

  Future<TableRecord?> tableRecord(int id) async {
    final db = await _dataHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query(sqlTableRecords, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return TableRecord.fromMap(maps[0]);
    return null;
  }

  Future<int> insertTableRecord(TableRecord tableRecord) async {
    final db = await _dataHelper.database;
    final id = await db.insert(
      sqlTableRecords,
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
        sqlTableRecords,
        tableRecord.toMap(),
        // Ensure that the Menu has a matching id.
        where: 'id = ?',
        // Pass the Menu's id as a whereArg to prevent SQL injection.
        whereArgs: [tableRecord.id],
      );

      await db.rawUpdate(
        'UPDATE $sqlBillRecords SET nameTable = ? WHERE tableId = ?',
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
        sqlTableRecords,
        where: 'id = ?',
        whereArgs: [id],
      );

      // Cập nhật các bản ghi hóa đơn liên quan
      await db.rawUpdate(
        'UPDATE $sqlBillRecords SET tableId = ? WHERE tableId = ?',
        [0, id],
      );
    } catch (e) {
      // Xử lý các ngoại lệ tiềm năng (ví dụ: lỗi cơ sở dữ liệu)

      // Có thể ném lại ngoại lệ hoặc xử lý nó một cách phù hợp
      // dựa trên nhu cầu của ứng dụng.
      rethrow;
    }
  }

  Future<Map<int, TableRecord>> tableRecords({
    int? pageNum,
    int? pageSize,
  }) async {
    final db = await _dataHelper.database;
    try {
      final query = StringBuffer('SELECT * FROM $sqlTableRecords');
      final queryParams = [];

      // Handle pagination with limit and offset
      if (pageNum != null && pageSize != null) {
        final offset = (pageNum - 1) * pageSize;
        query.write(' LIMIT ? OFFSET ?');
        queryParams.addAll([pageSize, offset]);
      }

      final maps = await db.rawQuery(query.toString(), queryParams);

      return Map<int, TableRecord>.fromIterable(
        maps.map((e) => TableRecord.fromMap(e)).toList(),
        key: (e) => e.id,
      );
    } catch (e) {
      // Handle the error appropriately, e.g., return an empty map or rethrow
      return {}; // Or throw an exception
    }
  }

  Future<List<TableRecord>> listTypeTableRecords(
      {String? where,
      List<Object?>? whereArgs,
      int? pageNum,
      int? pageSize,
      int? limit}) async {
    final db = await _dataHelper.database;
    try {
      final offset = (pageSize != null && pageNum != null)
          ? (pageNum - 1) * pageSize
          : null;
      final maps = await db.query(sqlTableRecords,
          where: where,
          whereArgs: whereArgs,
          limit: pageSize ?? limit,
          offset: offset);

      return List.generate(
          maps.length, (index) => TableRecord.fromMap(maps[index]));
    } catch (e) {
      // Handle the error appropriately, e.g., return an empty map or rethrow
      return []; // Or throw an exception
    }
  }

// tmpDishRecordHelper
}
