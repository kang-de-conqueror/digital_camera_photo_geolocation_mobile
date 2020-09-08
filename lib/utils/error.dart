import 'package:flutter/material.dart';

class Error {
  static showError(BuildContext context, String error) {
    showDialog(
        context: context,
        builder: (BuildContext newContext) {
          return AlertDialog(
              title: new Text("Error",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              content: new Text(error),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(newContext).pop();
                    },
                    child: new Text("OK")),
              ]);
        });
  }
}
