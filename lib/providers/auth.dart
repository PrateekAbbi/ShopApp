import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String? email,
    String? password,
    String? urlSegment,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final url = Uri.parse(
      "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAsQBHvWeHq9vdfKCUROw_WS7pZhJAaMGk",
    );

    try {
      final data = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      final decodedData = json.decode(data.body);
      if (decodedData["error"] != null) {
        throw HttpException(decodedData["error"]["message"]);
      }
      _token = decodedData["idToken"];
      _userId = decodedData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(decodedData["expiresIn"]),
        ),
      );
      _autoLogout();
      notifyListeners();

      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate!.toIso8601String(),
      });
      prefs.setString("userData", userData);
    } catch (err) {
      rethrow;
    }
  }

  Future<void> signUp(String? email, String? password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> logIn(String? email, String? password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    prefs.clear();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("userData")) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString("userData")!) as Map<String, dynamic>;

    final expiryDate =
        DateTime.parse(extractedUserData["expiryDate"] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData["token"] as String;
    _userId = extractedUserData["userId"] as String;
    _expiryDate = DateTime.parse(extractedUserData["expiryDate"] as String);
    notifyListeners();
    _autoLogout();
    return true;
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
