import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:story_view_app/data/models/story/story.dart';
import 'package:story_view_app/data/repository/auth/auth.dart';
import 'package:uuid/uuid.dart';

import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';

class StoryRepo {
  final AuthRepo ar;
  StoryRepo({
    required this.ar
  });

  Future<List<StoryUser>?> getStory(BuildContext context) async {
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
        "user_story_uid": const Uuid().v4(),
        "caption": caption,
        "media": media,
        "type": type,
        "user_id": "3e09dbde-b9d9-4d12-8a90-97990908301d"
      });
    } on DioError catch(e) {
      ShowSnackbar.snackbar(context, "${e.response?.statusCode} : Internal Server Error (${e.response?.data})", "", Colors.redAccent);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }

}

List<StoryUser> parseStoryData(dynamic data) {
  StoryModel storyModel = StoryModel.fromJson(data);
  List<StoryUser> storyData = storyModel.data!;
  return storyData;
}