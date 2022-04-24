import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/data/models/story/story.dart';
import 'package:story_view_app/data/repository/auth/auth.dart';

import 'package:story_view_app/providers/auth/auth.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/constant.dart';

import 'package:story_view_app/services/navigation.dart';

import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';

class StoryRepo {
  final AuthProvider ap;
  final AuthRepo ar;
  final MediaRepo mr;
  final NavigationService ns;
  StoryRepo({
    required this.ap,
    required this.ar,
    required this.mr,
    required this.ns
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
      if(e.type == DioErrorType.other) {
        ShowSnackbar.snackbar(context, e.toString(), "", ColorResources.error);
      } else {
        ShowSnackbar.snackbar(context, "${e.response?.data.toString()} : Internal Server Error", "", ColorResources.error);
      }
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
    return [];
  } 

  Future<void> createStory(BuildContext context, {
    required String caption,
    required String media,
    required String duration,
    required String type,
    required String backgroundColor,
    required String textColor
  }) async {
    try {
      Dio dio = Dio();
      await dio.post("${AppConstants.baseUrl}/story/store", data: {
        "uid": const Uuid().v4(),
        "user_story_uid": const Uuid().v4(),
        "backgroundColor": backgroundColor,
        "textColor": textColor,
        "caption": caption,
        "media": media,
        "duration": duration,
        "type": type,
        "user_id": ap.getUid
      }); 
    } on DioError catch(e) {
       if(e.type == DioErrorType.other) {
        ShowSnackbar.snackbar(context, e.toString(), "", ColorResources.error);
        Navigator.of(context).pop();
      } else {
        ShowSnackbar.snackbar(context, "${e.response?.data.toString()} : Internal Server Error", "", ColorResources.error);
        Navigator.of(context).pop();
      }
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