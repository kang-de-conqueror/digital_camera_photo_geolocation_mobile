import 'package:digital_camera_photo_geotag_mobile_application/blocs/generic_bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class GPSAlertBloc extends BlocBase {
  // Declare controller of BLoC
  BehaviorSubject<double> _controllerValue =
      BehaviorSubject<double>.seeded(30.0);
  BehaviorSubject<String> _controllerLabel =
      BehaviorSubject<String>.seeded("30 sec");

  // Add value to stream
  Function(double) get pushValue => _controllerValue.sink.add;
  Function(String) get pushLabel => _controllerLabel.sink.add;

  // Get stream values
  Stream<double> get streamValue => _controllerValue;
  Stream<String> get streamLabel => _controllerLabel;

  // Get current value of stream
  double get currentValue => _controllerValue.stream.value;
  String get currentLabel => _controllerLabel.stream.value;

  // Constructor
  static final GPSAlertBloc _bloc = new GPSAlertBloc._internal();

  factory GPSAlertBloc() {
    return _bloc;
  }
  GPSAlertBloc._internal();

  void changeAlertValue(double value) {
    // Set new value and add to stream
    _controllerValue.sink.add(value);
  }

  void changeAlertLabel(String label) {
    // Set new value and add to stream
    if (label.compareTo("300") == 0) {
      _controllerLabel.sink.add("5 min");
    } else {
      _controllerLabel.sink.add(label + " sec");
    }
  }

  void dispose() {
    // Dispose BLoC pattern
    _controllerValue?.close();
    _controllerLabel?.close();
  }
}
