import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:duration/duration.dart';
import 'package:location/location.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:localstorage/localstorage.dart';
import 'package:random_string/random_string.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:digital_camera_photo_geotag_mobile_application/models/route.dart';
import 'package:digital_camera_photo_geotag_mobile_application/utils/coefficient.dart';
import 'package:digital_camera_photo_geotag_mobile_application/services/encryption.dart';
import 'package:digital_camera_photo_geotag_mobile_application/side_menu_navigation.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/gps_alert_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/gps_acceptable_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/controllers/route_service.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/qr_code_duration_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_connection_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_metric_system_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RecordingRouteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RecordingRouteScreenState();
  }
}

class _RecordingRouteScreenState extends State<RecordingRouteScreen> {
  // Get time duration of QR code generation
  QRCodeDurationBloc _durationBloc;

  // Get acceptable accuraccy of GPS
  GPSAcceptableBloc _acceptableBloc;

  // Get alert accuraccy of GPS
  GPSAlertBloc _alertBloc;

  // Get control connection
  ControlConnectionBloc _connectionBloc;

  // Get control metric system
  ControlMetricSystemBloc _metricBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  IconData _appbarDrawerIcon = Icons.menu;
  IconData _appbarEndIcon = Icons.location_on;

  // Hash of the passphrase that was in use when
  final LocalStorage storage = new LocalStorage('mobile_database');
  String hashedPassphrase;
  // Photographer traveled distance
  double totalDistance = 0;

  // Accuracy of GPS data threshold, default = 100m
  double accuracyThreshold;

  // Photographer traveled time
  int duration = 0;

  // The time stamp that will be store in the QR code;
  int timeInQR = new DateTime.now().millisecondsSinceEpoch;
  String encryptedQRData;
  // Time interval in setting
  double timeInterval;

  // Time interval of alert accuraccy of GPS
  double alertTimeInterval;

  // Current filled part of time gauge
  double currentPercent = 0.0;

  // State of recording, including - recording, paused, stoped,
  String recordingState = "recording";

  // random nonce
  var randomNonce = randomAlphaNumeric(7);

  Color iconColor = Colors.green.shade500;

  // Full route data
  List routeData = [];

  // A fragment in route
  List fragmentData = [];

  String distance;

  String formattedDuration;

  // Distingue between metric and imperial system
  bool isMetricSystem;

  // Check has wifi connection
  bool isWifiConnected;

  Timer timer;

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData locationData;

  int lowAccuracyDuration = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // Init BLoC pattern
    _acceptableBloc = GPSAcceptableBloc();
    _alertBloc = GPSAlertBloc();
    _durationBloc = QRCodeDurationBloc();
    _connectionBloc = ControlConnectionBloc();
    _metricBloc = ControlMetricSystemBloc();

    // Get current value of each BLoC
    accuracyThreshold = _acceptableBloc.currentValue;
    alertTimeInterval = _alertBloc.currentValue;
    timeInterval = _durationBloc.currentValue;
    isWifiConnected = _connectionBloc.currentValue;
    isMetricSystem = _metricBloc.currentValue;

    // Go back to previous screen if location-access-permisison is not provided
    getPermission().then((isPermitted) {
      if (isPermitted) {
        // Update displayed duration every second
        timer = Timer.periodic(
            Duration(seconds: 1), (Timer t) => updateEverySecond());
      } else {
        AppSettings.openAppSettings();
        Navigator.of(context).pop();
      }
    });

    // Get hashed passphrase from local storage
    hashedPassphrase = storage.getItem('hash_passphrase');
    encryptedQRData =
        Encryption.encryptData("$timeInQR-$randomNonce", hashedPassphrase);
    super.initState();
  }

  Future<bool> getPermission() async {
    // Ask for turnning on GPS
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    // Ask for turning on Permission to access location for this app
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return false;
      }
    }

    return true;
  }

  void changeGPSIconColor(accuracy) {
    // Change GPS icon color per accuracy
    if (accuracy <= accuracyThreshold / 10) {
      iconColor = Colors.green;
    } else if (accuracy <= accuracyThreshold / 2) {
      iconColor = Colors.lightBlueAccent;
    } else if (accuracy <= accuracyThreshold) {
      iconColor = Colors.orange;
    } else {
      iconColor = Colors.red;
    }
  }

  _showAlertDialogLowGPSAccuracy() {
    // Show dialog warning of low accuracy
    showDialog(
      context: context,
      child: AlertDialog(
          title: Text("Warning!",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text(
              "Cannot record route due to low GPS accuracy. You will be redirected to Home Screen. Try again later."),
          actions: <Widget>[
            new FlatButton(
                onPressed: () => _stopRecording(false), child: Text("OK")),
          ]),
    ).then((val) {
      _stopRecording(false);
    });
  }

  _playSoundAlert() {
    // Play an alert sound (no looping)
    FlutterRingtonePlayer.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: false, // Android only - API >= 28
      volume: 0.1, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  void handleGPSData() {
    // Generate new QR code every x second (default is 5)
    timeInQR = new DateTime.now().millisecondsSinceEpoch;
    if (duration != 0 && duration % timeInterval.round() == 0) {
      // Encrypt QR data before showing it on screen, using passphrase as a secret key
      encryptedQRData =
          Encryption.encryptData("$timeInQR-$randomNonce", hashedPassphrase);
    }

    // Handle GPS data
    location.getLocation().then((locationData) {
      // Alert and don't record if first GPS accuracy is low
      if (duration < timeInterval &&
          locationData.accuracy >= accuracyThreshold) {
        _changeRecordingState("paused");
        _showAlertDialogLowGPSAccuracy();
      }

      changeGPSIconColor(locationData.accuracy);

      if (locationData.accuracy < accuracyThreshold &&
          (duration - 1) % timeInterval.round() == 0) {
        // Reset low-accuracy-duration counter
        lowAccuracyDuration = 0;
        if (fragmentData.length > 0) {
          var lastRoute = fragmentData.last;

          // Icrement distance when user is moving
          Geolocator()
              .distanceBetween(lastRoute['latitude'], lastRoute['longitude'],
                  locationData.latitude, locationData.longitude)
              .then((val) {
            totalDistance += val.round();
          });
        }

        // Add location to fragment
        fragmentData.add({
          "latitude": locationData.latitude,
          "longitude": locationData.longitude,
          "altitude": locationData.altitude,
          "accuracy": locationData.accuracy,
          "fix_time": timeInQR
        });
      } else if (lowAccuracyDuration >= alertTimeInterval) {
        // Play alert sound and reset counter
        lowAccuracyDuration = 1;
        _playSoundAlert();
      } else if (locationData.accuracy >= accuracyThreshold) {
        // Increment the counter when the accuracy is low
        lowAccuracyDuration += 1;
      }
    });
  }

  void updateEverySecond() {
    // Algorithm update time every second
    if (recordingState == "recording") {
      handleGPSData();
      setState(() {
        duration++;
        int roundedTimeInterval = timeInterval.round();
        // Calculate current percent to display in the recording route
        currentPercent = (duration % roundedTimeInterval) / roundedTimeInterval;
      });
    }
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

  void _changeRecordingState(newState) {
    // Change status of recording
    setState(() {
      recordingState = newState;
    });
  }

  void prepareToCloseScreen() {
    // Close screen after finish recording
    timer.cancel();

    // Turn the nonce into 32-chars hash
    RouteService.createNewRoute(RouteModel(
      creationTime: new DateTime.now().toString(),
      distance: totalDistance,
      duration: duration,
      routeData: jsonEncode(routeData),
      hashedPassphrase: hashedPassphrase,
      nonce: randomNonce,
    )).then((val){
      Navigator.pop(context);
    });
  }

  // Build Pause and Play buttons
  Container _buildDisplayStartPauseRecordingButton() {
    if (recordingState == "recording") {
      // Pause button
      return new Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.35,
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          heroTag: 'btnPause',
          onPressed: _pauseRecording,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.pause, color: Colors.white, size: 42.0),
        ),
      );
    } else {
      // Play/ Resume button
      return new Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.35,
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          heroTag: 'btnResume',
          onPressed: _resumeRecording,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.play_circle_filled,
              color: Colors.white, size: 42.0),
        ),
      );
    }
  }

  // Build Stop button
  Container _buildStopRecordingButton() {
    return new Container(
      width: MediaQuery.of(context).size.width * 0.35,
      height: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        heroTag: 'btnStop',
        onPressed: () => _stopRecording(true),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop, color: Colors.white, size: 42.0),
      ),
    );
  }

  // Build distance text and time text of route recording
  Row _buildTopTextRecording(String distance, String formattedDuration) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Column(
          children: [
            // Distance text
            new Text(
              "DISTANCE",
              style: new TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            new GestureDetector(
              onTap: _toogleDistanceUnitSystem,
              child: new Text(
                "$distance",
                style: new TextStyle(fontSize: 25.0),
              ),
            ),
          ],
        ),
        new Column(
          children: [
            // Time text
            new Text(
              "TIME",
              style: new TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            new Text(
              "$formattedDuration",
              style: TextStyle(fontSize: 25.0),
            )
          ],
        ),
      ],
    );
  }

  QrImage _buildQRImage(String encryptedQRData) {
    return new QrImage(
      data: encryptedQRData,
      version: 10,
      size: MediaQuery.of(context).size.width * 0.8,
    );
  }

  void _stopRecording(isStoppedCorrectly) {
    // Action stop recording route
    if (fragmentData.length > 0 && isStoppedCorrectly) {
      routeData.add(fragmentData);
      prepareToCloseScreen();
    } else if (isStoppedCorrectly) {
      prepareToCloseScreen();
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }

  // Build progress time indicator
  Container _buildProgressBar() {
    return new Container(
      margin: EdgeInsets.only(top: 10.0),
      child: new LinearPercentIndicator(
        alignment: MainAxisAlignment.center,
        width: (MediaQuery.of(context).size.width) * 0.8,
        lineHeight: 10.0,
        percent: currentPercent,
        progressColor: Colors.blue,
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Build app bar
  AppBar _buildAppBarRecordingRoute() {
    return new AppBar(
      title: new Center(
        child: new Text("Recording Route"),
      ),
      leading: new IconButton(
          icon: new Icon(_appbarDrawerIcon), onPressed: _handleDrawerButton),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(_appbarEndIcon),
          color: iconColor,
          onPressed: () {},
        )
      ],
    );
  }

  void _pauseRecording() {
    // Pause recording route
    routeData.add(fragmentData);
    fragmentData = [];
    _changeRecordingState("paused");
  }

  void _resumeRecording() {
    // Resume recording route
    _changeRecordingState("recording");
  }

  void _handleDrawerButton() {
    // Side Navigation Bar Icon
    if (_appbarDrawerIcon == Icons.menu) {
      _scaffoldKey.currentState.openDrawer();
    } else if (_appbarDrawerIcon == Icons.cancel) {
      setState(() {
        _appbarDrawerIcon = Icons.menu;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen changes of data by BLoC pattern
    _acceptableBloc.streamValue.listen((data) {
      setState(() {
        accuracyThreshold = data;
      });
    });

    _alertBloc.streamValue.listen((data) {
      setState(() {
        alertTimeInterval = data;
      });
    });

    _durationBloc.streamValue.listen((data) {
      setState(() {
        timeInterval = data;
      });
    });

    _connectionBloc.streamValue.listen((data) {
      setState(() {
        isWifiConnected = data;
      });
    });

    _metricBloc.streamValue.listen((data) {
      setState(() {
        isMetricSystem = data;
      });
    });

    // Convert time unit from seconds to human-readable
    formattedDuration = prettyDuration(aSecond * duration, abbreviated: true)
        .replaceAll(',', '');
    if (formattedDuration.contains('h') && formattedDuration.contains('m')) {
      // Only keep Hour and Minute
      formattedDuration = formattedDuration.split('m')[0] + "m";
    } else if (formattedDuration.contains('h') &&
        !formattedDuration.contains('m')) {
      formattedDuration = formattedDuration.split('h')[0] + "h";
    }

    // Check unit system
    if (isMetricSystem) {
      // display in meter
      if (totalDistance > 1000) {
        // display in kilometer
        String distanceInKilometer = (totalDistance / 1000).toStringAsFixed(1);
        distance = "$distanceInKilometer km";
      } else {
        distance = "$totalDistance m";
      }
    } else {
      double milesDistance = double.parse(
          (Coefficient.convertMeterToMile(totalDistance)).toStringAsFixed(3));
      distance = "$milesDistance miles";
    }

    return new Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBarRecordingRoute(),
        drawer: new Drawer(
          child: new SideMenu(),
        ),
        body: new SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: new Column(children: [
                  _buildTopTextRecording(distance, formattedDuration),
                  _buildQRImage(encryptedQRData),
                  _buildProgressBar(),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStopRecordingButton(),
                      _buildDisplayStartPauseRecordingButton(),
                    ],
                  )
                ]))));
  }
}
