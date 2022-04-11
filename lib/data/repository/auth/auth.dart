import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:story_view_app/utils/constant.dart';

class AuthRepo {

  Future<void> signIn(BuildContext context, {
    required String phone, 
    required String password
  }) async {
    try {
      Dio dio = Dio();
      Response res = await dio.post("${AppConstants.baseUrl}/auth/sign-in", data: {
        
      });

    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    } 
  }

}