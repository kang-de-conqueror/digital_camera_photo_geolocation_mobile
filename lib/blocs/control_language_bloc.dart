import 'package:digital_camera_photo_geotag_mobile_application/blocs/generic_bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class ControlLanguageBloc extends BlocBase {
  BehaviorSubject<String> _controllerValue = BehaviorSubject<String>.seeded('English');

  Function(String) get pushValue => _controllerValue.sink.add;

  Stream<String> get streamValue => _controllerValue;

  String get currentValue => _controllerValue.stream.value;

  static final ControlLanguageBloc _bloc = new ControlLanguageBloc._internal();

  factory ControlLanguageBloc() {
    return _bloc;
  }
  ControlLanguageBloc._internal();

  void controlLanguage(String value) {
    _controllerValue.sink.add(value);
  }

  void dispose() {
    _controllerValue?.close();
  }
}
