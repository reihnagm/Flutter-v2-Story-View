import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:story_view_app/data/models/auth/auth.dart';

import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';

class AuthRepo {

  Future<AuthData> signIn(BuildContext context, {
    required String phone, 
    required String pass
  }) async {
    try {
      Dio dio = Dio();
      Response res = await dio.post("${AppConstants.baseUrl}/auth/sign-in", data: {
        "phone": phone,
        "pass": pass
      });
      Map<String, dynamic> data = res.data;
      return compute(parseSignIn, data);
    } on DioError catch(e) {
      ShowSnackbar.snackbar(context, e.toString(), "", Colors.redAccent);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    } 
    return authData!;
  }
  

}

AuthData? authData;

AuthData parseSignIn(data) {
  AuthModel authModel = AuthModel.fromJson(data);
  return authModel.data!;
}