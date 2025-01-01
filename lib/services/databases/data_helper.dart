import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataHelper {
  static const String menuRecords = 'menu_records';
  static const String billRecords = "bill_records";
  static const String dishRecords = 'dish_records';
  static const String categoryRecords = 'category_records';
  static const String preOrderedDishRecords = 'pre_ordered_dish';
  static const String tableRecords = "table_records";

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
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'flutter_sqflite_database.db');
    return await openDatabase(path,
        onCreate: _onCreate,
        version: 1,
        onConfigure: (db) async =>
            await db.execute('PRAGMA foreign_keys = ON'));
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $menuRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      isSelected INTEGER
    )''');

    await db.execute('''CREATE TABLE $categoryRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      menuId INTEGER,
      FOREIGN KEY (menuId) REFERENCES $menuRecords(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE $dishRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      price REAL,
      imagePath TEXT,
      categoryId INTEGER,
      FOREIGN KEY (categoryId) REFERENCES $categoryRecords(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE $categoryRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      desc TEXT,
      isLock INTEGER,
    )''');

    await db.execute('''CREATE TABLE $billRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      desc TEXT,
      amountPaid REAL,
      discount REAL,
      tableId INTEGER,
      nameTable TEXT,
      isLeft INTEGER,
      type INTEGER,
      dateTime INTEGER, -- Store as milliseconds since Unix epoch
    )''');

    await db.execute('''CREATE TABLE $preOrderedDishRecords (
      dishId INTEGER,
      billId INTEGER,
      categoryId INTEGER,
      title TEXT,
      price REAL,
      amount INTEGER,
      imagePath TEXT,
      -- FOREIGN KEY (dishId) REFERENCES $dishRecords(id) ON DELETE CASCADE,
      FOREIGN KEY (billId) REFERENCES $billRecords(id) ON DELETE CASCADE,
      PRIMARY KEY (dishId, billId), -- Composite primary key
      UNIQUE (dishId, billId) -- Ensure no duplicates
    )''');
  }
}
