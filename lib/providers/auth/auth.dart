import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view_app/data/models/auth/auth.dart';

import 'package:story_view_app/data/repository/auth/auth.dart';
import 'package:story_view_app/main.dart';
import 'package:story_view_app/services/navigation.dart';

enum LoginStatus { idle, loading, loaded, empty, error }

class AuthProvider with ChangeNotifier {
  final AuthRepo ar;
  final SharedPreferences sp;
  final NavigationService ns;
  AuthProvider({
    required this.ar,
    required this.sp,
    required this.ns
  });

  LoginStatus _loginStatus = LoginStatus.idle;
  LoginStatus get loginStatus => _loginStatus;

  void writeData(AuthData authData) {
    sp.setBool("login", true);
    sp.setString("user", jsonEncode({
      "uid": authData.uid,
      "fullname": authData.fullname,
      "pic": authData.pic,
      "phone": authData.phone,
    }));
  }

  void clearData() {
    sp.setBool("login", false);
    sp.remove("user");
  }

  void setStateLoginStatus(LoginStatus loginStatus) {
    _loginStatus = loginStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> signIn(BuildContext context, {required String phone, required String pass}) async {
    setStateLoginStatus(LoginStatus.loading);
    try {
      AuthData authData = await ar.signIn(context, phone: phone, pass: pass);
      writeData(authData);
      ns.pushNav(context, const HomeScreen());
      setStateLoginStatus(LoginStatus.loaded);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateLoginStatus(LoginStatus.error);
    }
  }

  bool get isLogggedIn {
    return sp.getBool("login") ?? false;
  }

  String get getUid {
    Map<String, dynamic> data = json.decode(sp.getString("user")!);
    return data["uid"] ?? "-";
  }

  String get getFullname {
    Map<String, dynamic> data = json.decode(sp.getString("user")!);
    return data["fullname"] ?? "-";
  }

  String get getPic {
    Map<String, dynamic> data = json.decode(sp.getString("user")!);
    return data["pic"] ?? "-";
  }

  String get getPhone {
    Map<String, dynamic> data = json.decode(sp.getString("user")!);
    return data["phone"] ?? "-";
  }

}