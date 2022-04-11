import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:story_view_app/custom/story_view/controller/story_controller.dart';

import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/data/models/story/story.dart';

import 'package:story_view_app/data/repository/story/media.dart';
import 'package:story_view_app/data/repository/story/story.dart';
import 'package:story_view_app/utils/constant.dart';

enum GetStoryStatus { idle, loading, loaded, empty, error }
enum CreateStoryStatus { idle, loading, loaded, empty, error }

class StoryProvider with ChangeNotifier {
  final StoryRepo sr;
  final MediaRepo mr;
  StoryProvider({
    required this.sr,
    required this.mr
  });

  late StoryController sc;

  List<StoryItem> _storyItem = [];
  List<StoryItem> get storyItem => [..._storyItem];

  List<StoryData> _storyData = [];
  List<StoryData> get storyData => [..._storyData];

  GetStoryStatus _getStoryStatus = GetStoryStatus.loading;
  GetStoryStatus get getStoryStatus => _getStoryStatus;

  CreateStoryStatus _createStoryStatus = CreateStoryStatus.idle;
  CreateStoryStatus get createStoryStatus => _createStoryStatus;

  void swipeRight() {
    sc.next();
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateGetCreateStoryStatus(GetStoryStatus getStoryStatus) {
    _getStoryStatus = getStoryStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateCreateStoryStatus(CreateStoryStatus createStoryStatus) {
    _createStoryStatus = createStoryStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getStory(BuildContext context) async {
    try { 
      _storyItem = [];
      _storyData = [];
      List<StoryData>? sd = await sr.getStory(context);
      _storyData.addAll(sd!);
      setStateGetCreateStoryStatus(GetStoryStatus.loaded);
      if(_storyData.isEmpty) {
        setStateGetCreateStoryStatus(GetStoryStatus.empty);
      }
      for (StoryData story in storyData) {
        if(story.type == "image") {
          _storyItem.add(
            StoryItem.pageImage(
              controller: sc,
              imageFit: BoxFit.scaleDown,
              url: "${AppConstants.baseUrl}/images/${story.media}",
              caption: story.caption
            )
          );
        } else {
          _storyItem.add(
            StoryItem.pageVideo("${AppConstants.baseUrl}/videos/${story.media}",
              controller: sc,
              caption: story.caption
            )
          );
        }
      }
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateGetCreateStoryStatus(GetStoryStatus.error);
    }
  }

  Future<void> createStory(BuildContext context, {
    required String? caption,
    required File file,
  }) async {
    setStateCreateStoryStatus(CreateStoryStatus.loading);
    try {
      String? mimeType = lookupMimeType(file.path); 
      String fileType = mimeType!.split("/")[0];
      String? media = await mr.media(context, file: file);
      await sr.createStory(context, 
        caption: caption!,
        media: media!,
        type: fileType
      );
      Navigator.of(context).pop();
      setStateCreateStoryStatus(CreateStoryStatus.loaded);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateCreateStoryStatus(CreateStoryStatus.error);
    }
  }

}