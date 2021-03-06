import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:story_view_app/utils/color_resources.dart';

import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';
import 'package:uuid/uuid.dart';

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
          filename: p.basenameWithoutExtension(file.path) + "-" + const Uuid().v4() + "." + subtype,
          contentType: MediaType(type, subtype)
        ),
      });
      Response res = await dio.post("${AppConstants.baseUrl}/upload", data: formData);
      Map<String, dynamic> data = res.data;
      return compute(parseMedia, data);
    } on DioError catch(e) {
      if(e.type == DioErrorType.other) {
        ShowSnackbar.snackbar(context, "${e.toString()} : Internal Server Error (${e.response?.data})", "", ColorResources.error);
      } else {
        ShowSnackbar.snackbar(context, "${e.response!.statusCode.toString()} : Internal Server Error (${e.response?.data})", "", ColorResources.error);
      }
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    } 
    return "";
  }

}

String parseMedia(data) {
  return data["data"]["media"];
}