import 'package:digital_camera_photo_geotag_mobile_application/models/route.dart';
import 'package:digital_camera_photo_geotag_mobile_application/services/connection.dart';

class RouteService {
  static Future<List<RouteModel>> getAllRoutes() async {
    // Get all routes of list
    final db = await AppConnection.db.database;
    var res = await db.query("Routes");
    List<RouteModel> list =
        res.isNotEmpty ? res.map((c) => RouteModel.fromMap(c)).toList() : [];
    return list;
  }

  static createNewRoute(RouteModel newRoute) async {
    // Insert one route to table
    print("7");
    final db = await AppConnection.db.database;
    print("8");
    var res = await db.rawInsert(
        "INSERT INTO Routes(creation_time, distance, duration, route_data, hashed_passphrase, nonce) VALUES(DATETIME(?),?,?,?,?,?)",
        [
          newRoute.creationTime,
          newRoute.distance,
          newRoute.duration,
          newRoute.routeData,
          newRoute.hashedPassphrase,
          newRoute.nonce,
        ]);
    print('yo');

    return res;
  }

  static getRouteByID(int id) async {
    // Get route by ID
    final db = await AppConnection.db.database;
    var res = await db.query("Routes", where: "route_id = ?", whereArgs: [id]);
    return res.isNotEmpty ? RouteModel.fromMap(res.first) : Null;
  }

  static updateRouteByID(RouteModel newRoute) async {
    // Update route by ID
    final db = await AppConnection.db.database;
    var res = await db.update("Routes", newRoute.toMap(),
        where: "route_id = ?", whereArgs: [newRoute.routeID]);
    return res;
  }

  static deleteRouteByID(int id) async {
    // Delete route by id
    final db = await AppConnection.db.database;
    db.delete("Routes", where: "route_id = ?", whereArgs: [id]);
  }

  static deleteAllRoutes() async {
    // Delete all routes of table
    final db = await AppConnection.db.database;
    db.delete("Routes");
  }
}
