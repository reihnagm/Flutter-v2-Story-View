import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:story_view_app/data/models/auth/auth.dart';
import 'package:story_view_app/utils/color_resources.dart';

import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';
import 'package:uuid/uuid.dart';

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
      if(e.type == DioErrorType.other) {
        ShowSnackbar.snackbar(context, e.toString(), "", ColorResources.error);
      } else {
        ShowSnackbar.snackbar(context, e.response!.data.toString(), "", ColorResources.error);
      }
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    } 
    return authData!;
  }

  Future<AuthData> signUp(BuildContext context, {
    required String fullname, 
    required String phone,
    required String pass,
    required String pic
  }) async {
    try {
      Dio dio = Dio();
      Response res = await dio.post("${AppConstants.baseUrl}/auth/sign-up", data: {
        "uid": const Uuid().v4(),
        "fullname": fullname,
        "phone": phone,
        "pass": pass, 
        "pic": pic,
      });
      Map<String, dynamic> data = res.data;
      return compute(parseSignUp, data);
    } on DioError catch(e) {
      if(e.type == DioErrorType.other) {
        ShowSnackbar.snackbar(context, e.toString(), "", ColorResources.error);
      } else {
        ShowSnackbar.snackbar(context, e.response!.data.toString(), "", ColorResources.error);
      }
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

AuthData parseSignUp(data) {
  AuthModel authModel = AuthModel.fromJson(data);
  return authModel.data!;
}