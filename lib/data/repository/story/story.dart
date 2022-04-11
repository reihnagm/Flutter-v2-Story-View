import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:story_view_app/data/models/story/story.dart';
import 'package:uuid/uuid.dart';

import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';

class StoryRepo {

  Future<List<StoryData>?> getStory(BuildContext context) async {
    try {
      Dio dio = Dio();
      Response res = await dio.get("${AppConstants.baseUrl}/story");
      Map<String, dynamic> data = res.data;
      return compute(parseStoryData, data);
    } on DioError catch(e) {
      ShowSnackbar.snackbar(context, "${e.response!.statusCode} : Internal Server Error (${e.response!.data})", "", Colors.redAccent);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
    return [];
  } 

  Future<void> createStory(BuildContext context, {
    required String? caption,
    required String media,
    required String type
  }) async {
    try {
      Dio dio = Dio();
      await dio.post("${AppConstants.baseUrl}/story/store", data: {
        "uid": const Uuid().v4(),
        "caption": caption!.isEmpty 
        ? "" 
        : caption,
        "media": media,
        "type": type,
        "user_id": "93581cb6-42ff-47ba-a34c-b23528633e79"
      });
    } on DioError catch(e) {
      ShowSnackbar.snackbar(context, "${e.response!.statusCode} : Internal Server Error (${e.response!.data})", "", Colors.redAccent);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }

}

List<StoryData> parseStoryData(dynamic data) {
  StoryModel storyModel = StoryModel.fromJson(data);
  List<StoryData> storyData = storyModel.data!;
  return storyData;
}