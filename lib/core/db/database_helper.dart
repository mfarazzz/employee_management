import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/employee_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'employee_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employees(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            fromDate TEXT NOT NULL,
            toDate TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert new employee
  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('employees', employee.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all employees
  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  /// Update an existing employee
  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  /// Delete an employee by ID
  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all employee records (for testing/reset)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('employees');
  }
}
