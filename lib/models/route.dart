import 'dart:convert';

RouteModel fromJson(String str) {
  // Input json string to get route object
  final jsonData = json.decode(str);
  return RouteModel.fromMap(jsonData);
}

String toJson(RouteModel data) {
  // Input route object to get json string
  final dyn = data.toMap();
  return json.encode(dyn);
}

class RouteModel {
  // Properties
  final int routeID;
  String cloudUUID;
  String creationTime;
  double distance;
  int duration;
  String routeData;
  String hashedPassphrase;
  String nonce;

  // Constructor
  RouteModel({
      this.routeID,
      this.cloudUUID,
      this.creationTime,
      this.distance,
      this.duration,
      this.routeData,
      this.hashedPassphrase,
      this.nonce,
  });

  // Convert route model from json to object
  factory RouteModel.fromMap(Map<String, dynamic> json) => new RouteModel(
      routeID: json["route_id"],
      cloudUUID: json["cloud_UUID"],
      creationTime: json["creation_time"],
      distance: json["distance"],
      duration: json["duration"],
      routeData: json["route_data"],
      hashedPassphrase: json["hashed_passphrase"],
      nonce: json["nonce"],
  );

  // Convert object to json
  Map<String, dynamic> toMap() => {
      "route_id": routeID,
      "cloud_UUID": cloudUUID,
      "creation_time": creationTime,
      "distance": distance,
      "duration": duration,
      "route_data": routeData,
      "hashed_passphrase": hashedPassphrase,
      "nonce": nonce,
  };
}
