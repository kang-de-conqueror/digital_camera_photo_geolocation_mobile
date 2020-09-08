import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_lib;

class AppConnection {
  // Create constructor
  AppConnection._();
  // Declare static to use anywhere of application
  static final AppConnection db = AppConnection._();

  // Declare database
  Database _database;

  Future<Database> get database async {
    // Get database to use. If not existed, create new one
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    // Database file exist in local device folder
    var db_path = await getDatabasesPath();
    String path = path_lib.join(db_path, 'cards.db');

    return await openDatabase(path,
        version: 1, onOpen: (db) {}, onCreate: createTableRoutes);
  }

  createTableRoutes(Database database, int version) async {
    await database.execute("CREATE TABLE Routes("
        "route_id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "cloud_UUID TEXT,"
        "creation_time TEXT,"
        "distance REAL,"
        "duration INTEGER,"
        "route_data TEXT,"
        "hashed_passphrase TEXT,"
        "nonce TEXT"
        ")");
  }

  Future closeConnection() async {
    // Must close connection after execute any transaction
    var conn = await database;
    return conn.close();
  }
}
