import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class Encryption {
  // Hash data using MD5 algorithm

  static String hashMD5Data(data) {
    var bytes = utf8.encode(data); // data being hashed
    var digest = md5.convert(bytes);
    return "$digest";
  }

  static String encryptData(data, secretKey) {
    // Encrypt data using Fernet algo

    final key = Key.fromUtf8(secretKey);

    // Encode to 32 URL safe 64 bit key
    final b64key = Key.fromUtf8(base64Url.encode(key.bytes));
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);

    // Encrypt data
    final encrypted = encrypter.encrypt(data);
    return "${encrypted.base64}";
  }
}
