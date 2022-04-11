import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:story_view_app/custom/story_view/controller/story_controller.dart';

import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/data/models/story/story.dart';

import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/data/repository/story/story.dart';
import 'package:story_view_app/main.dart';

enum GetStoryStatus { idle, loading, loaded, empty, error }
enum CreateStoryStatus { idle, loading, loaded, empty, error }

class StoryProvider with ChangeNotifier {
  late StoryController sc;

  final StoryRepo sr;
  final MediaRepo mr;
  StoryProvider({
    required this.sr,
    required this.mr
  }) {
    sc = StoryController();
  }

  @override 
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  List<StoryItem> _storyItem = [];
  List<StoryItem> get storyItem => [..._storyItem];

  List<StoryUser> _storyData = [];
  List<StoryUser> get storyData => [..._storyData];

  GetStoryStatus _getStoryStatus = GetStoryStatus.idle;
  GetStoryStatus get getStoryStatus => _getStoryStatus;

  CreateStoryStatus _createStoryStatus = CreateStoryStatus.idle;
  CreateStoryStatus get createStoryStatus => _createStoryStatus;

  void swipeRight() {
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
    setStateGetCreateStoryStatus(GetStoryStatus.loading);
    try { 
      _storyData = [];
      // _storyItem = [];
      List<StoryUser>? sd = await sr.getStory(context);
      _storyData.addAll(sd!);
      setStateGetCreateStoryStatus(GetStoryStatus.loaded);
      if(_storyData.isEmpty) {
        setStateGetCreateStoryStatus(GetStoryStatus.empty);
      }
      // for (StoryData story in storyData) {
      //   switch (story.type) {
      //     case "image":
      //       _storyItem.add(
      //         StoryItem.pageImage(
      //           controller: sc,
      //           imageFit: BoxFit.scaleDown,
      //           url: "${AppConstants.baseUrl}/images/${story.media}",
      //           caption: story.caption,
      //           shown: true
      //         )
      //       );
      //     break;
      //     case "video":
      //       _storyItem.add(
      //         StoryItem.pageVideo("${AppConstants.baseUrl}/videos/${story.media}",
      //           controller: sc,
      //           caption: story.caption,
      //           shown: true
      //         )
      //       );
      //     break;
      //     default:
      //   }
      // }
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
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen(key: UniqueKey());
      }));
      setStateCreateStoryStatus(CreateStoryStatus.loaded);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateCreateStoryStatus(CreateStoryStatus.error);
    }
  }

}