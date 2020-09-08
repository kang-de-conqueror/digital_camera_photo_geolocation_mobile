import 'package:digital_camera_photo_geotag_mobile_application/blocs/generic_bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class ControlMetricSystemBloc extends BlocBase {
  // Declare controller of BLoC
  BehaviorSubject<bool> _controllerValue = BehaviorSubject<bool>.seeded(true);

  // Add value to stream
  Function(bool) get pushValue => _controllerValue.sink.add;

  // Get stream values
  Stream<bool> get streamValue => _controllerValue;

  // Get current value of stream
  bool get currentValue => _controllerValue.stream.value;

  // Constructor
  static final ControlMetricSystemBloc _bloc = new ControlMetricSystemBloc._internal();

  factory ControlMetricSystemBloc() {
    return _bloc;
  }
  ControlMetricSystemBloc._internal();

  void controlMetricSystem(bool value) {
    // Set new value and add to stream
    _controllerValue.sink.add(value);
  }

  void dispose() {
    // Dispose BLoC pattern
    _controllerValue?.close();
  }
}
