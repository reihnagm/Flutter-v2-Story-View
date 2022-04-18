import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/services/video.dart';
import 'package:uuid/uuid.dart';


import 'package:story_view_app/data/models/story/story.dart';
import 'package:story_view_app/data/repository/auth/auth.dart';

import 'package:story_view_app/providers/auth/auth.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/constant.dart';

import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';
import 'package:video_editor/video_editor.dart';

class StoryRepo {
  final AuthProvider ap;
  final AuthRepo ar;
  final MediaRepo mr;
  StoryRepo({
    required this.ap,
    required this.ar,
    required this.mr
  });

  Future<List<StoryUser>?> getStory(BuildContext context) async {
    try {
      Dio dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: 20000
      );
      Response res = await dio.get("${AppConstants.baseUrl}/story");
      Map<String, dynamic> data = res.data;
      return compute(parseStoryData, data);
    } on DioError catch(e) {
      if(e.type == DioErrorType.connectTimeout) {
        ShowSnackbar.snackbar(context, "Connection timeout, please try again", "", ColorResources.error);
      } else {
        ShowSnackbar.snackbar(context, "${e.response?.statusCode} : Internal Server Error", "", ColorResources.error);
      }
    } on SocketException catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      ShowSnackbar.snackbar(context, "$e : Internal Server Error", "", ColorResources.error);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
    return [];
  } 

  Future<void> createStory(BuildContext context, {
    required List<Map<String, dynamic>> files
  }) async {
    try {
      Dio dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: 30000
      );
      for (Map<String, dynamic> file in files) {
        TextEditingController caption = file["text"];
        File f = file["file"];
        String duration = file["duration"];
        String? mimeType = lookupMimeType(f.path); 
        String fileType = mimeType!.split("/")[0];
        String? media = await mr.media(context, file: f);
        await dio.post("${AppConstants.baseUrl}/story/store", data: {
          "uid": const Uuid().v4(),
          "user_story_uid": const Uuid().v4(),
          "caption": caption.text,
          "media": media,
          "duration": duration,
          "type": fileType,
          "user_id": ap.getUid
        });
      //   VideoEditorController vec = file["video"];
      //   double start = file["video"].minTrim;
      //   double end =  file["video"].maxTrim;
      //   String s = start.toStringAsFixed(2); 
      //   String e = end.toStringAsFixed(2);  
      //   vec.updateTrim(double.parse(s), double.parse(e));
      //   vec.exportVideo(onCompleted: (File? file) async {
      //     File fi = file!;
      //     String? mediaVideo = await mr.media(context, file: fi);
      //     String? durationVideo = await VideoServices.getDuration(fi);
      //     await dio.post("${AppConstants.baseUrl}/story/store", data: {
      //       "uid": const Uuid().v4(),
      //       "user_story_uid": const Uuid().v4(),
      //       "caption": caption.text,
      //       "media": mediaVideo,
      //       "duration": durationVideo,
      //       "type": fileType,
      //       "user_id": ap.getUid
      //     });
      //   });   
      }
      Navigator.of(context).pop();
    } on DioError catch(e) {
       if(e.type == DioErrorType.connectTimeout) {
        ShowSnackbar.snackbar(context, "Connection timeout, please try again", "", ColorResources.error);
      } else {
        ShowSnackbar.snackbar(context, "${e.response?.statusCode} : Internal Server Error", "", ColorResources.error);
      }
      Navigator.of(context).pop();
    } on SocketException catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      ShowSnackbar.snackbar(context, "$e : Internal Server Error", "", ColorResources.error);
      Navigator.of(context).pop();
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      Navigator.of(context).pop();
    }
  }
}


List<StoryUser> parseStoryData(dynamic data) {
  StoryModel storyModel = StoryModel.fromJson(data);
  List<StoryUser> storyData = storyModel.data!;
  return storyData;
}