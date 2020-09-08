import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:connectivity/connectivity.dart';
import 'package:random_string/random_string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:digital_camera_photo_geotag_mobile_application/screen_home.dart';
import 'package:digital_camera_photo_geotag_mobile_application/models/route.dart';
import 'package:digital_camera_photo_geotag_mobile_application/utils/coefficient.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/gps_acceptable_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/controllers/route_service.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_metric_system_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_language_bloc.dart';

class RouteDetailsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RouteDetailsScreenState();
  }
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  // Declare google map controller, map type and set of marker
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};

  List allRouteData = [];

  bool isWifiConnected;

  // Declare BLoC pattern
  GPSAcceptableBloc _acceptableBloc;
  ControlMetricSystemBloc _metricBloc;
  bool isMetricSystem;

  ControlLanguageBloc _languageBloc;
  String selectedLanguage;

  String distance;

  String formattedDuration;

  Icon cloudStatus = Icon(Icons.cloud);

  DateFormat dateFormat;

  void _changeMapType(String type) {
    // Change topographic of map by type
    switch (type) {
      case "road":
        setState(() {
          _currentMapType = MapType.normal;
        });
        break;
      case "satellite":
        setState(() {
          _currentMapType = MapType.satellite;
        });
        break;
      case "terrain":
        setState(() {
          _currentMapType = MapType.terrain;
        });
        break;
    }
    Navigator.of(context).pop();
  }

  GestureDetector _createMapType(String type) {
    // Create map type box
    return new GestureDetector(
        onTap: () => _changeMapType(type),
        child: new Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.017),
          padding: EdgeInsets.all(5.0),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: new Image.asset("assets/icons/" + type + ".png",
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.12)),
              new Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: new Text(
                  type.substring(0, 1).toUpperCase() + type.substring(1),
                  style: new TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ));
  }

  void _showMapTypeDialog() {
    // Show dialog of map type box
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                _createMapType("road"),
                _createMapType("satellite"),
                _createMapType("terrain")
              ]));
        });
  }

  // Build distance text and time text
  Row _buildTopTextRouteDetails(String distance, String formattedDuration) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Column(
          children: <Widget>[
            // Distance text
            Text(
              "DISTANCE",
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _toogleDistanceUnitSystem,
              child: Text(
                "$distance",
                style: TextStyle(fontSize: 25.0),
              ),
            ),
          ],
        ),
        new Column(
          children: <Widget>[
            // Time text
            Text(
              "TIME",
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$formattedDuration",
              style: TextStyle(fontSize: 25.0),
            )
          ],
        ),
      ],
    );
  }

  void _toogleDistanceUnitSystem() {
    // Toogle change distance unit system
    setState(() {
      if (isMetricSystem) {
        _metricBloc.controlMetricSystem(false);
        _acceptableBloc.changeMinMaxLabel(false);
      } else {
        _metricBloc.controlMetricSystem(true);
        _acceptableBloc.changeMinMaxLabel(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isWifiConnected = true;
    // Init BLoC pattern
    _languageBloc = ControlLanguageBloc();
    _acceptableBloc = GPSAcceptableBloc();
    _metricBloc = ControlMetricSystemBloc();

    // Check wifi has connected or not
    _checkWifiConnection();
    initializeDateFormatting();
  }

  _checkWifiConnection() async {
    // Check wifi has connected or not, not include wireless
    var connectivityResult = await (new Connectivity().checkConnectivity());
    bool connectedToWifi = (connectivityResult == ConnectivityResult.wifi);
    if (connectedToWifi) {
      setState(() {
        isWifiConnected = true;
      });
    } else {
      setState(() {
        isWifiConnected = false;
      });
    }

    // Must add post frame to check wifi connection before show data
    if (!isWifiConnected) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showDialogTurnOnWifi());
    }
  }

  _showDialogTurnOnWifi() {
    // Show dialog to delete selected route
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Announcement!!!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber)),
              content: Text("Turn on wifi to see your route in google map!"),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK")),
              ]);
        });
  }

  // Build app bar
  AppBar _buildAppBarRouteDetails(RouteModel route) {
    DateTime datetime = DateTime.parse(route.creationTime);
    dateFormat = new DateFormat.yMMMMd(languagePack[_languageBloc.currentValue]);
    return new AppBar(
      title: new Text(
        dateFormat.format(datetime) + "\n" + new DateFormat('EEEE HH:mm', languagePack[_languageBloc.currentValue]).format(datetime),
        style: new TextStyle(fontSize: 18.0),
      ),
      actions: <Widget>[
        new Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: new IconButton(icon: cloudStatus, onPressed: null),
        ),
        new IconButton(
          padding: EdgeInsets.only(right: 20.0),
          icon: Icon(Icons.delete),
          onPressed: () {
            _showDialogDeleteSelectedRoute(route);
          },
        ),
      ],
    );
  }

  _showDialogDeleteSelectedRoute(RouteModel route) {
    // Show dialog to delete selected route
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Delete this routes?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              content: Text("Are you sure you want to delete this routes?"),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("CANCEL")),
                new FlatButton(
                    onPressed: () {
                      RouteService.deleteRouteByID(route.routeID);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ));
                    },
                    child: Text("OK"))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    // Get data from another screen
    final RouteModel route = ModalRoute.of(context).settings.arguments;

    // Get list data of a route
    List routeData = jsonDecode(route.routeData);

    // Get first point of the route
    LatLng sourceLocation =
        LatLng(routeData[0][0]['latitude'], routeData[0][0]['longitude']);
    selectedLanguage = _languageBloc.currentValue;

    void setMapMarkers() {
      // Set marker for each coordinates of route
      for (int i = 0; i < routeData.length; i++) {
        for (int j = 0; j < routeData[i].length; j++) {
          setState(() {
            _markers.add(Marker(
                // Get random marker id
                markerId: MarkerId(randomNumeric(3) + randomNumeric(2)),
                position: new LatLng(
                    routeData[i][j]['latitude'], routeData[i][j]['longitude']),
                icon: BitmapDescriptor.defaultMarker));
            allRouteData.add(routeData[i][j]);
          });
        }
      }
    }

    void _onMapCreated(GoogleMapController controller) {
      // Create map by controller
      _controller.complete(controller);
      setMapMarkers();
    }

    _showScreenWithConnectionCondition() {
      // If wifi has connected, show map. Otherwise, show list data with easy to read
      if (isWifiConnected) {
        // _buildGoogleMap();
        return new Expanded(
          // If you want to show google map without error, please put it in Expanded Widget
            child: Column(
          children: <Widget>[
            new Expanded(
                child: new GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer())
              ].toSet(),
              onMapCreated: _onMapCreated,
              // Turn on full option of google map
              indoorViewEnabled: true,
              mapToolbarEnabled: true,
              myLocationButtonEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              trafficEnabled: true,
              zoomGesturesEnabled: true,
              tiltGesturesEnabled: true,
              myLocationEnabled: true,
              compassEnabled: true,

              // Set markers
              markers: _markers,

              // Set map type, default: normal type
              mapType: _currentMapType,
              initialCameraPosition: CameraPosition(
                zoom: 11.0,
                target: sourceLocation != null ? sourceLocation : LatLng(0, 0),
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Add button map on google map
                new Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  margin: new EdgeInsets.all(15.0),
                  child: FloatingActionButton(
                    heroTag: "btnMap",
                    onPressed: _showMapTypeDialog,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.map, size: 42.0),
                  ),
                ),
                // Add button key of route on google map
                new Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.2,
                    margin: new EdgeInsets.all(15.0),
                    child: Tooltip(
                      padding: EdgeInsets.all(10.0),
                      message: "Route ID\n${route.cloudUUID}",
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: Border.all(
                            width: 1.0,
                          )),
                      child: FloatingActionButton(
                          heroTag: "btnKey",
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          backgroundColor: Colors.blue,
                          onPressed: () {},
                          child: const Icon(
                            Icons.vpn_key,
                            size: 42.0,
                          )),
                    )),
              ],
            )
          ],
        ));
      } else {
        return new Expanded(
          // If you want to show list data of route without format error, please put it in Expanded Widget
            child: new Container(
                child: ListView.separated(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: allRouteData.length,
          itemBuilder: (BuildContext context, int index) {
            var dateTime = DateTime.parse(DateTime.fromMillisecondsSinceEpoch(allRouteData[index]['fix_time']).toIso8601String());
            var formatDate = new DateFormat.MMMMd(languagePack[_languageBloc.currentValue]);
            return new Container(
              color: Colors.blue[400],
              child: new ListTile(
                title: new Text(
                  formatDate.format(dateTime) + ", " + new DateFormat('HH:mm:ss', languagePack[_languageBloc.currentValue]).format(dateTime),
                  style: new TextStyle(color: Colors.white),
                ),
                leading: new Icon(Icons.add_location),
                trailing: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      child: new RichText(
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: 'Lat: ',
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            new TextSpan(
                                text: '${allRouteData[index]['latitude']}',
                                style: new TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    new Container(
                        child: new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: 'Long: ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          new TextSpan(
                              text: '${allRouteData[index]['longitude']}',
                              style: new TextStyle(color: Colors.white)),
                        ],
                      ),
                    )),
                    new Container(
                        child: new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: 'Alt: ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          new TextSpan(
                              text: '${allRouteData[index]['altitude']}',
                              style: new TextStyle(color: Colors.white)),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        )));
      }
    }

    // Get current value of metric system
    isMetricSystem = _metricBloc.currentValue;

    // Format duration time
    formattedDuration =
        prettyDuration(aSecond * route.duration, abbreviated: true)
            .replaceAll(',', '');
    if (formattedDuration.contains('h') && formattedDuration.contains('m')) {
      // Only keep Hour and Minute
      formattedDuration = formattedDuration.split('m')[0] + "m";
    } else if (formattedDuration.contains('h') &&
        !formattedDuration.contains('m')) {
      formattedDuration = formattedDuration.split('h')[0] + "h";
    }

    // Display distance format per unit system
    if (isMetricSystem) {
      double distanceInMeter = route.distance;
      if (distanceInMeter > 1000){
        // display in kilometer
        String distanceInKilometer = (distanceInMeter / 1000).toStringAsFixed(1);
        distance = "$distanceInKilometer km";
      } else {
        distance = "$distanceInMeter m";
      }
    } else {
      double milesDistance = double.parse(
          (Coefficient.convertMeterToMile(route.distance)).toStringAsFixed(3));
      distance = "$milesDistance miles";
    }

    if (route.cloudUUID != null) {
      cloudStatus = Icon(Icons.cloud_done);
    }

    return Scaffold(
        appBar: _buildAppBarRouteDetails(route),
        body: new Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _buildTopTextRouteDetails(distance, formattedDuration),
              _showScreenWithConnectionCondition(),
            ])));
  }
}
