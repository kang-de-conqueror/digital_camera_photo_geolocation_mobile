import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:digital_camera_photo_geotag_mobile_application/models/route.dart';
import 'package:digital_camera_photo_geotag_mobile_application/services/webservice.dart';
import 'package:digital_camera_photo_geotag_mobile_application/services/encryption.dart';
import 'package:digital_camera_photo_geotag_mobile_application/screen_route_details.dart';
import 'package:digital_camera_photo_geotag_mobile_application/side_menu_navigation.dart';
import 'package:digital_camera_photo_geotag_mobile_application/screen_recording_route.dart';
import 'package:digital_camera_photo_geotag_mobile_application/controllers/route_service.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_connection_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_language_bloc.dart';

var languagePack = {
  'English': 'en',
  'France': 'fr',
  'Japanese': 'ja',
  'Vietnamese': 'vi',
  'German': 'de',
};

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // Declare Global Scaffold Key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Declare future of list routes
  Future<List<RouteModel>> future;

  // Declare list routes
  List<RouteModel> _routeList;

  // Declare
  List _selectedRoute = List();

  String _appbarTitle = "All Routes";
  var _appbarDrawerIcon = Icons.menu;
  var _appbarEndIcon;

  ControlConnectionBloc _connectionBloc;
  bool isWifiConnected;
  ControlLanguageBloc _languageBloc;
  DateFormat dateFormat;

  @override
  void initState() {
    super.initState();
    _connectionBloc = ControlConnectionBloc();
    _languageBloc = ControlLanguageBloc();
    initializeDateFormatting();
  }

  void _onRouteSelected(bool selected, id) {
    // Change selected route
    if (selected) {
      if (!_selectedRoute.contains(id)) {
        setState(() {
          _selectedRoute.add(id);
        });
      }
    } else {
      setState(() {
        _selectedRoute.remove(id);
      });
    }

    // Return default state of screen
    if (_selectedRoute.length == 0) {
      setState(() {
        _appbarDrawerIcon = Icons.menu;
        _appbarEndIcon = null;
        _appbarTitle = "All Routes";
      });
    } else {
      setState(() {
        _appbarDrawerIcon = Icons.cancel;
        _appbarEndIcon = Icons.delete;
        _appbarTitle = "Selected ${_selectedRoute.length}";
      });
    }
  }

  _handleDrawerButton() {
    // Change drawer button when screen state change
    if (_appbarDrawerIcon == Icons.menu) {
      _scaffoldKey.currentState.openDrawer();
    } else if (_appbarDrawerIcon == Icons.cancel) {
      setState(() {
        _selectedRoute.clear();
        _appbarDrawerIcon = Icons.menu;
        _appbarEndIcon = null;
        _appbarTitle = "All Routes";
      });
    }
  }

  _showDialogDeleteSelectedRoute() {
    // Show dialog to delete selected route
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Delete ${_selectedRoute.length} routes?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              content: Text("Are you sure you want to delete these routes?"),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("CANCEL")),
                new FlatButton(onPressed: _deleteRoute, child: Text("OK"))
              ]);
        });
  }

  _showDialogCannotShowDetail() {
    // Show dialog to delete selected route
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text("Announcement!!!",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber)),
              content: new Text("Your recording route do not have anything!"),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("OK")),
              ]);
        });
  }

  _deleteRoute() {
    // Deleted selected route
    setState(() {
      for (var i = 0; i < _routeList.length; i++) {
        for (var j = 0; j < _selectedRoute.length; j++) {
          if (_routeList[i].routeID == _selectedRoute[j]) {
            RouteService.deleteRouteByID(_selectedRoute[j]);
          }
        }
      }
      _selectedRoute.clear();
      _appbarDrawerIcon = Icons.menu;
      _appbarEndIcon = null;
      _appbarTitle = "All Routes";
    });
    Navigator.of(context).pop();
  }

  _uploadQueuedRoutes() {
    // Upload queued routes to server
    future.then((routes) {
      for (RouteModel route in routes) {
        // Upload a queued route to server
        if (route.cloudUUID == null && isWifiConnected) {
          String encryptedData = Encryption.encryptData(
              route.routeData, Encryption.hashMD5Data(route.nonce));
          WebService.postRoute(encryptedData, route.distance, route.duration)
              .then((response) {
            // Add cloudUUID to the corresponding local route
            if (response.statusCode == 200) {
              route.cloudUUID =
                  json.decode(response.body)["route_id"].split("-")[0];
              RouteService.updateRouteByID(route);
            }
          }).catchError((error) {
            // Error.showError(context, error);
          });
        }
      }
    });
  }

  Container _buildListRoute() {
    // Return list of recorded route
    return new Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.15),
        child: new ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _routeList.length,
            itemBuilder: (BuildContext context, int index) {
              RouteModel route = _routeList[index];
              // Change cloud icon base on its status
              var cloudStatus = Icon(Icons.cloud);
              if (route.cloudUUID != null) {
                cloudStatus = Icon(Icons.cloud_done);
              }

              DateTime datetime = DateTime.parse(route.creationTime);

              return new Container(
                  child: new ListTile(
                title: new Center(
                  child: StreamBuilder(
                      stream: _languageBloc.streamValue,
                      // initialData: _languageBloc.currentValue,
                      builder: (context, snapshot) {
                        dateFormat = new DateFormat.yMMMMd(
                            languagePack[_languageBloc.currentValue]);
                        return new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(
                                dateFormat.format(datetime) + " " +
                                    new DateFormat('HH:mm:ss').format(datetime),
                                style: new TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045),
                              ),
                            ]);
                      }),
                ),
                leading: new Checkbox(
                    value: _selectedRoute.contains(route.routeID),
                    onChanged: (bool selected) {
                      _onRouteSelected(selected, route.routeID);
                    }),
                onLongPress: () {
                  _onRouteSelected(true, route.routeID);
                },
                onTap: () {
                  if (route.distance == 0) {
                    _showDialogCannotShowDetail();
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RouteDetailsScreen(),
                            settings: RouteSettings(arguments: route)));
                  }
                },
                trailing: new IconButton(icon: cloudStatus, onPressed: null),
              ));
            }));
  }

  // Build circle loading indicator
  Center _buildLoadingState() {
    return new Center(
        child: new Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new Container(
            margin: EdgeInsets.only(top: 10.0),
            child: new Text("Loading..."),
          )
        ],
      ),
    ));
  }

  // Build button navigate to recording screen
  Container _buildButtonRecording() {
    return new Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.width * 0.2,
      margin: new EdgeInsets.only(top: 15.0),
      child: new FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RecordingRouteScreen())).then((value) {
            setState(() {});
          });
        },
        child: new Icon(
          Icons.play_arrow,
          size: 42.0,
        ),
      ),
    );
  }

  // Build app bar
  AppBar _buildAppBarHome() {
    return new AppBar(
      leading: new IconButton(
          icon: new Icon(_appbarDrawerIcon), onPressed: _handleDrawerButton),
      title: Text(_appbarTitle),
      actions: <Widget>[
        IconButton(
            icon: Icon(_appbarEndIcon),
            onPressed: (_appbarEndIcon == null)
                ? null
                : _showDialogDeleteSelectedRoute)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isWifiConnected = _connectionBloc.currentValue;

    future = RouteService.getAllRoutes();
    _uploadQueuedRoutes();
    return Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBarHome(),
        body: new FutureBuilder<List<RouteModel>>(
          future: future,
          builder:
              (BuildContext context, AsyncSnapshot<List<RouteModel>> snapshot) {
            // If has data, show it. Otherwise, loading state
            if (snapshot.hasData) {
              _routeList = snapshot.data;
              return _buildListRoute();
            } else {
              return _buildLoadingState();
            }
          },
        ),
        drawer: new Drawer(
          child: new SideMenu(),
        ),
        floatingActionButton: _buildButtonRecording());
  }
}
