import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_view_app/data/repository/auth/auth.dart';

enum LoginStatus { idle, loading, empty, error }

class AuthProvider with ChangeNotifier {
  final AuthRepo ar;
  final SharedPreferences sp;
  AuthProvider({
    required this.ar,
    required this.sp
  });

  LoginStatus _loginStatus = LoginStatus.idle;
  LoginStatus get loginStatus => _loginStatus;

  void setStateLoginStatus(LoginStatus loginStatus) {
    _loginStatus = loginStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> signIn(BuildContext context, ) async {
    try {
      // await ar
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }

}