import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_view_app/data/models/auth/auth.dart';

import 'package:story_view_app/data/repository/auth/auth.dart';
import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/main.dart';

import 'package:story_view_app/services/navigation.dart';

enum LoginStatus { idle, loading, loaded, empty, error }
enum RegisterStatus { idle, loading, loaded, empty,  error }

class AuthProvider with ChangeNotifier {
  final AuthRepo ar;
  final MediaRepo mr; 
  final SharedPreferences sp;
  final NavigationService ns;
  AuthProvider({
    required this.mr,
    required this.ar,
    required this.sp,
    required this.ns
  });

  LoginStatus _loginStatus = LoginStatus.idle;
  LoginStatus get loginStatus => _loginStatus;

  RegisterStatus _registerStatus = RegisterStatus.idle;
  RegisterStatus get registerStatus => _registerStatus;

  void writeData(AuthData authData) {
    sp.setBool("login", true);
    sp.setString("user", jsonEncode({
      "uid": authData.uid,
      "fullname": authData.fullname,
      "pic": authData.pic,
      "phone": authData.phone,
    }));
  }

  void logout() {
    clearData();
  }

  void clearData() {
    sp.setBool("login", false);
    sp.remove("user");
  }

  void setStateLoginStatus(LoginStatus loginStatus) {
    _loginStatus = loginStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateRegisterStatus(RegisterStatus registerStatus) {
    _registerStatus = registerStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> signIn(BuildContext context, {required String phone, required String pass}) async {
    setStateLoginStatus(LoginStatus.loading);
    try {
      AuthData authData = await ar.signIn(context, phone: phone, pass: pass);
      writeData(authData);
      ns.pushNavReplacement(context, HomeScreen(key: UniqueKey()));
      setStateLoginStatus(LoginStatus.loaded);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateLoginStatus(LoginStatus.error);
    }
  }

  Future<void> signUp(BuildContext context, {
    required String fullname, 
    required String phone,
    required String pass,
    required File pic
  }) async {
    setStateRegisterStatus(RegisterStatus.loading);
    try {
      String? media = await mr.media(context, file: pic);
      AuthData authData = await ar.signUp(context, 
        fullname: fullname,
        phone: phone,
        pass: pass,
        pic: media!
      );
      writeData(authData);
      setStateRegisterStatus(RegisterStatus.loaded);
      ns.pushNavReplacement(context, HomeScreen(key: UniqueKey()));
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateRegisterStatus(RegisterStatus.error);
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