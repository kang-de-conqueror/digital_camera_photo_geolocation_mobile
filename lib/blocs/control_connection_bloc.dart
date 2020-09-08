import 'package:digital_camera_photo_geotag_mobile_application/blocs/generic_bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class ControlConnectionBloc extends BlocBase {
  // Declare controller of BLoC
  BehaviorSubject<bool> _controllerValue = BehaviorSubject<bool>.seeded(true);

  // Add value to stream
  Function(bool) get pushValue => _controllerValue.sink.add;

  // Get stream values
  Stream<bool> get streamValue => _controllerValue;

  // Get current value of stream
  bool get currentValue => _controllerValue.stream.value;

  // Constructor
  static final ControlConnectionBloc _bloc = new ControlConnectionBloc._internal();

  factory ControlConnectionBloc() {
    return _bloc;
  }
  ControlConnectionBloc._internal();

  void controlConnection(bool value) {
    // Set new value and add to stream
    _controllerValue.sink.add(value);
  }

  void dispose() {
    // Dispose BLoC pattern
    _controllerValue?.close();
  }
}
