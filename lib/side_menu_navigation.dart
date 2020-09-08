import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:digital_camera_photo_geotag_mobile_application/utils/coefficient.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/gps_alert_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/gps_acceptable_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/qr_code_duration_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_connection_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_metric_system_bloc.dart';
import 'package:digital_camera_photo_geotag_mobile_application/blocs/control_language_bloc.dart';

class SideMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SideMenu();
  }
}

class _SideMenu extends State<SideMenu> {
  // Declare BLoC pattern of setting side menu
  GPSAcceptableBloc _acceptableBloc;
  GPSAlertBloc _alertBloc;
  QRCodeDurationBloc _durationBloc;
  ControlConnectionBloc _connectionBloc;
  ControlMetricSystemBloc _metricBloc;
  ControlLanguageBloc _languageBloc;

  List<String> _dropdownMenuItems;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Init BLoC pattern of setting side menu
    _acceptableBloc = GPSAcceptableBloc();
    _alertBloc = GPSAlertBloc();
    _durationBloc = QRCodeDurationBloc();
    _connectionBloc = ControlConnectionBloc();
    _metricBloc = ControlMetricSystemBloc();
    _languageBloc = ControlLanguageBloc();

    _dropdownMenuItems = ['English', 'France', 'Japanese', 'Vietnamese', 'German'];
  }

  Container _buildDrawerHeader() {
    return new Container(
        height: 100,
        child: DrawerHeader(
          padding: EdgeInsets.only(top: 20, left: 20),
          child: Text("DSLR Photo Geotag",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15.0)),
          decoration: BoxDecoration(color: Colors.blue),
        ));
  }

  // Build GPS Acceptable Accuracy
  Column _buildGPSAcceptableSetting() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
            padding: const EdgeInsets.only(left: 16),
            child: Text("GPS acceptable accuracy",
                style: TextStyle(fontWeight: FontWeight.bold))),
        new StreamBuilder(
            // Must using StreamBuilder to listen change of setting
            stream: _acceptableBloc.streamValue,
            builder: (context, snapshot1) => StreamBuilder(
                stream: _acceptableBloc.streamLabel,
                builder: (context, snapshot2) => new Slider(
                    min: 5,
                    max: 400,
                    divisions: 79,
                    value: snapshot1.hasData
                        ? snapshot1.data
                        : _acceptableBloc.currentValue,
                    label: snapshot2.hasData
                        ? snapshot2.data
                        : _acceptableBloc.currentLabel,
                    onChanged: (double newRating) {
                      _acceptableBloc.changeAcceptableValue(newRating);
                      if (_metricBloc.currentValue) {
                        _acceptableBloc.changeAcceptableLabel(
                            newRating.round().toString(),
                            _metricBloc.currentValue);
                      } else {
                        newRating = Coefficient.convertMeterToMile(newRating);
                        _acceptableBloc.changeAcceptableLabel(
                            newRating.toStringAsFixed(3),
                            _metricBloc.currentValue);
                      }
                    }))),
        new Container(
          padding: const EdgeInsets.only(left: 16, right: 22),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new StreamBuilder(
                  // Must using StreamBuilder to listen change of setting
                  stream: _acceptableBloc.streamMinLabel,
                  builder: (context, snapshot) => new Text(snapshot.hasData
                      ? snapshot.data
                      : _acceptableBloc.currentMinLabel)),
              new StreamBuilder(
                  // Must using StreamBuilder to listen change of setting
                  stream: _acceptableBloc.streamMaxLabel,
                  builder: (context, snapshot) => new Text(snapshot.hasData
                      ? snapshot.data
                      : _acceptableBloc.currentMaxLabel))
            ],
          ),
        )
      ],
    );
  }

  // Build GPS Alert Accuracy
  Column _buildGPSAlertSetting() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "GPS accuraccy alert",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        new StreamBuilder(
            // Must using StreamBuilder to listen change of setting
            stream: _alertBloc.streamValue,
            builder: (context, snapshot1) => StreamBuilder(
                stream: _alertBloc.streamLabel,
                builder: (context, snapshot2) => new Slider(
                    min: 10,
                    max: 300,
                    divisions: 58,
                    value: snapshot1.hasData
                        ? snapshot1.data
                        : _alertBloc.currentValue,
                    label: snapshot2.hasData
                        ? snapshot2.data
                        : _alertBloc.currentLabel,
                    onChanged: (double newRating) {
                      _alertBloc.changeAlertValue(newRating);
                      _alertBloc.changeAlertLabel(newRating.round().toString());
                    }))),
        new Container(
          padding: const EdgeInsets.only(left: 16, right: 22),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[new Text("10 sec"), new Text("5 min")],
          ),
        )
      ],
    );
  }

  // Build QR Code generation duration time
  Column _buildQRCodeDurationSetting() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "QR code duration generation",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        new StreamBuilder(
            // Must using StreamBuilder to listen change of setting
            stream: _durationBloc.streamValue,
            builder: (context, snapshot1) => StreamBuilder(
                stream: _durationBloc.streamLabel,
                builder: (context, snapshot2) => new Slider(
                    min: 5,
                    max: 30,
                    divisions: 20,
                    value: snapshot1.hasData
                        ? snapshot1.data
                        : _durationBloc.currentValue,
                    label: snapshot2.hasData
                        ? snapshot2.data
                        : _durationBloc.currentLabel,
                    onChanged: (double newRating) {
                      _durationBloc.changeDurationValue(newRating);
                      _durationBloc
                          .changeDurationLabel(newRating.round().toString());
                    }))),
        new Container(
          padding: const EdgeInsets.only(left: 16, right: 22),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[new Text("5 sec"), new Text("30 sec")],
          ),
        )
      ],
    );
  }

  // Build control wifi connection
  _buildWifiConnectionSetting() {
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                "Wi-fi network synchronous",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          new Container(
            padding: const EdgeInsets.only(left: 16, right: 22),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text("Automatically sync only Wi-fi connected")),
                new StreamBuilder(
                    // Must using StreamBuilder to listen change of setting
                    stream: _connectionBloc.streamValue,
                    builder: (context, snapshot) => new Checkbox(
                        value: snapshot.hasData
                            ? snapshot.data
                            : _connectionBloc.currentValue,
                        onChanged: (bool value) {
                          _connectionBloc.controlConnection(value);
                        }))
              ],
            ),
          )
        ]);
  }

  // Build ontrol unit system
  Column _buildMetricSystemSetting() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "System of measurement",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        new Container(
          padding: const EdgeInsets.only(left: 16, right: 22),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text("Metric system")),
              new StreamBuilder(
                  // Must using StreamBuilder to listen change of setting
                  stream: _metricBloc.streamValue,
                  builder: (context, snapshot) => new Switch(
                      value: snapshot.hasData
                          ? snapshot.data
                          : _metricBloc.currentValue,
                      onChanged: (bool value) {
                        _metricBloc.controlMetricSystem(value);
                        _acceptableBloc.changeMinMaxLabel(value);
                      }))
            ],
          ),
        )
      ],
    );
  }

  Column _buildLanguageSetting(){
    // Render and control the language 
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20.0,),
        new StreamBuilder(
          stream: _languageBloc.streamValue,
          builder: (context, snapshot) => new DropdownButton(
            value: snapshot.hasData
                ? snapshot.data 
                : _languageBloc.currentValue,
            items: _dropdownMenuItems.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            onChanged: (language) {
              _languageBloc.controlLanguage(language);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      padding: EdgeInsets.only(top: 0),
      children: <Widget>[
        _buildDrawerHeader(),
        new Column(
          children: <Widget>[
            _buildGPSAcceptableSetting(),
            _buildGPSAlertSetting(),
            _buildQRCodeDurationSetting(),
            _buildWifiConnectionSetting(),
            _buildMetricSystemSetting(),
            _buildLanguageSetting(),
          ],
        )
      ],
    );
  }
}
