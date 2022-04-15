import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';

import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';

class MediaRepo {
  
  Future<String?> media(BuildContext context, {required File file}) async {
    String? mimeType = lookupMimeType(file.path); 
    String type = mimeType!.split("/")[0];
    String subtype = mimeType.split("/")[1];
    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        "media": await MultipartFile.fromFile(
          file.path, 
          filename: p.basenameWithoutExtension(file.path) + "-" + DateTime.now().toString() + "." + subtype,
          contentType: MediaType(type, subtype)
        ),
      });
      Response res = await dio.post("${AppConstants.baseUrl}/upload", data: formData);
      Map<String, dynamic> data = res.data;
      return compute(parseMedia, data);
    } on DioError catch(e) {
      ShowSnackbar.snackbar(context, "${e.response?.statusCode} : Internal Server Error (${e.response?.data})", "", Colors.redAccent);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    } 
    return "";
  }

}

String parseMedia(data) {
  return data["data"]["media"];
}