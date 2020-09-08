import 'package:digital_camera_photo_geotag_mobile_application/blocs/generic_bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class QRCodeDurationBloc extends BlocBase {
  // Declare controller of BLoC
  BehaviorSubject<String> _controllerLabel =
      BehaviorSubject<String>.seeded("5 sec");
  BehaviorSubject<double> _controllerValue =
      BehaviorSubject<double>.seeded(5.0);

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
  static final QRCodeDurationBloc _bloc = new QRCodeDurationBloc._internal();

  factory QRCodeDurationBloc() {
    return _bloc;
  }
  QRCodeDurationBloc._internal();

  void changeDurationValue(double value) {
    // Set new value and add to stream
    _controllerValue.sink.add(value);
  }

  void changeDurationLabel(String label) {
    // Set new value and add to stream
    _controllerLabel.sink.add(label + " sec");
  }

  void dispose() {
    // Dispose BLoC pattern
    _controllerValue?.close();
    _controllerLabel?.close();
  }
}
