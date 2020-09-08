import 'package:digital_camera_photo_geotag_mobile_application/blocs/generic_bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class GPSAcceptableBloc extends BlocBase {
  // Declare controller of BLoC
  BehaviorSubject<double> _controllerValue =
      BehaviorSubject<double>.seeded(100.0);
  BehaviorSubject<String> _controllerLabel =
      BehaviorSubject<String>.seeded("100 m");
  BehaviorSubject<String> _controllerMinLabel =
      BehaviorSubject<String>.seeded("5 m");
  BehaviorSubject<String> _controllerMaxLabel =
      BehaviorSubject<String>.seeded("400 m");

  // Add value to stream
  Function(double) get pushValue => _controllerValue.sink.add;
  Function(String) get pushLabel => _controllerLabel.sink.add;
  Function(String) get pushMinLabel => _controllerMinLabel.sink.add;
  Function(String) get pushMaxLabel => _controllerMaxLabel.sink.add;

  // Get stream values
  Stream<double> get streamValue => _controllerValue;
  Stream<String> get streamLabel => _controllerLabel;
  Stream<String> get streamMinLabel => _controllerMinLabel;
  Stream<String> get streamMaxLabel => _controllerMaxLabel;

  // Get current value of stream
  double get currentValue => _controllerValue.stream.value;
  String get currentLabel => _controllerLabel.stream.value;
  String get currentMinLabel => _controllerMinLabel.stream.value;
  String get currentMaxLabel => _controllerMaxLabel.stream.value;

  // Constructor
  static final GPSAcceptableBloc _bloc = new GPSAcceptableBloc._internal();

  factory GPSAcceptableBloc() {
    return _bloc;
  }
  GPSAcceptableBloc._internal();

  void changeAcceptableValue(double value) {
    // Set new value and add to stream
    _controllerValue.sink.add(value);
  }

  void changeAcceptableLabel(String label, bool isMetricSystem) {
    // Set new value and add to stream
    if (isMetricSystem) {
      _controllerLabel.sink.add(label + " m");
    } else {
      _controllerLabel.sink.add(label + " miles");
    }
  }

  void changeMinMaxLabel(bool isMetricSystem) {
    // Set new value and add to stream
    if (isMetricSystem) {
      _controllerMinLabel.sink.add("5 m");
      _controllerMaxLabel.sink.add("400 m");
    } else {
      _controllerMinLabel.sink.add("0.003 miles");
      _controllerMaxLabel.sink.add("0.249 miles");
    }
  }

  void dispose() {
    // Dispose BLoC pattern
    _controllerValue?.close();
    _controllerLabel?.close();
    _controllerMinLabel?.close();
    _controllerMaxLabel?.close();
  }
}
