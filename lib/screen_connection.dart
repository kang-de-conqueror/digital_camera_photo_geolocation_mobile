import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:digital_camera_photo_geotag_mobile_application/services/encryption.dart';

class ConnectionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConnectionScreenState();
  }
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  // Declare storage of mobile's databse
  final LocalStorage storage = new LocalStorage('mobile_database');
  // Declare form's key to get state of form
  final _formKey = GlobalKey<FormState>();
  // Text controller of TextFormField
  final textController = TextEditingController();

  static const ratioWidth = 0.3;

  String _buttonText = "Continue";
  bool _obscureText = true;
  bool _buttonDisabled = true;

  Column _buildConnectionLogoAndLabel() {
    // This widget contain logo and label of application
    return Column(children: <Widget>[
      new Container(
        margin: const EdgeInsets.only(top: 50.0, bottom: 20.0),
        child: Image.asset("assets/logos/main.png",
            width: MediaQuery.of(context).size.width * ratioWidth),
      ),
      new Text(
        "Geo DSLR",
        style: new TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      )
    ]);
  }

  Container _buildConnectionTextFormField() {
    // This widget contain text form field
    return new Container(
        margin: const EdgeInsets.only(top: 40.0),
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: new TextFormField(
            validator: _checkValidateInput,
            controller: textController,
            onChanged: _onChangedText,
            obscureText: _obscureText,
            decoration: new InputDecoration(
                contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                suffix: new IconButton(
                    icon: new Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: _controlHideShowPassphrase),
                errorStyle: new TextStyle(fontSize: 20.0),
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.blue)),
                hintText: "Passphrase",
                labelText: "Passphrase",
                labelStyle: new TextStyle(fontSize: 20.0))));
  }

  Container _buildConnectionSubmitButton() {
    // This widget contain submit button
    return new Container(
        padding: const EdgeInsets.all(20.0),
        child: new ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          height: 50.0,
          child: new RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            onPressed: _buttonDisabled ? null : _handlePassphrase,
            child: Text(
              "$_buttonText",
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ));
  }

  bool _checkPassphraseDeclared() {
    // Check passphrase was defined or not
    return (storage.getItem("passphrase") != null) ? true : false;
  }

  String _checkValidateInput(String value) {
    // Check valid if passphrase equal with locally storage passphrase
    if (_checkPassphraseDeclared()) {
      if (value != storage.getItem("passphrase")) {
        return "Invalid passphrase";
      }
    }
    return null;
  }

  _handlePassphrase() {
    // Handle "Continue" and "Reset" button
    if (_buttonText == "Continue") {
      if (_checkPassphraseDeclared()) {
        _checkMatchPassphrase();
      } else {
        storage.setItem("passphrase", textController.text);
        storage.setItem(
            "hash_passphrase", Encryption.hashMD5Data(textController.text));
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else if (_buttonText == "Reset") {
      _showDialogResetPassphrase();
    }
  }

  _checkMatchPassphrase() {
    // Check current input's text is match with locally storage passphrase
    if (textController.text == storage.getItem("passphrase")) {
      storage.setItem("passphrase", textController.text);
      storage.setItem(
          "hash_passphrase", Encryption.hashMD5Data(textController.text));
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      if (!_formKey.currentState.validate()) {
        setState(() {
          _buttonText = "Reset";
        });
      }
    }
  }

  _showDialogResetPassphrase() {
    // Show dialog to reset passphrase
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text("Warning!",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              content: Text("Do you really want to reset your passphrase?"),
              actions: <Widget>[
                new FlatButton(onPressed: _resetPassphrase, child: Text("Yes")),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("No"))
              ]);
        });
  }

  _resetPassphrase() {
    // Reset passphrase of user

    // Reset key "passphrase" of local storage
    storage.deleteItem("passphrase");

    // Reset TextFormField
    _formKey.currentState.reset();
    textController.text = '';

    setState(() {
      _buttonText = 'Continue';
    });
    Navigator.of(context).pop();
  }

  void _onChangedText(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _buttonDisabled = false;
      });
      // Reset TextFormField when user enter non-empty passphrase
      if (_buttonText == "Reset") {
        _formKey.currentState.reset();
        textController.text = '';
        setState(() {
          _buttonText = "Continue";
        });
      }
    }
    // Disable button when it's empty
    else {
      setState(() {
        _buttonDisabled = true;
      });
    }
  }

  void _controlHideShowPassphrase() {
    // Control hide or show passphrase
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Form(
      key: _formKey,
      child: new Column(children: <Widget>[
        _buildConnectionLogoAndLabel(),
        _buildConnectionTextFormField(),
        _buildConnectionSubmitButton()
      ]),
    ));
  }
}
