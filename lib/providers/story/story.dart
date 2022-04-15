import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:story_view_app/data/models/story/story.dart';

import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/data/repository/story/story.dart';
import 'package:story_view_app/main.dart';
import 'package:story_view_app/services/navigation.dart';

enum GetStoryStatus { idle, loading, loaded, empty, error }
enum CreateStoryStatus { idle, loading, loaded, empty, error }

class StoryProvider with ChangeNotifier {
  final StoryRepo sr;
  final MediaRepo mr;
  final NavigationService ns;
  StoryProvider({
    required this.sr,
    required this.mr,
    required this.ns
  });

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
      List<StoryUser>? sd = await sr.getStory(context);
      List<StoryUser> sUAssign = [];
      for (StoryUser item in sd!) {
        sUAssign.add(StoryUser(
          user: UserItem(
            uid: item.user!.uid,
            created: item.user!.created,
            fullname: item.user!.fullname,
            itemCount: item.user!.itemCount,
            pic: item.user!.pic,
            items: item.user!.items
          )
        ));
      }
      _storyData = sUAssign;
      setStateGetCreateStoryStatus(GetStoryStatus.loaded);
      if(_storyData.isEmpty) {
        setStateGetCreateStoryStatus(GetStoryStatus.empty);
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
      setStateCreateStoryStatus(CreateStoryStatus.loaded);
      Future.delayed(Duration.zero, () {
        ns.pushNav(context, HomeScreen(key: UniqueKey()));
      });
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateCreateStoryStatus(CreateStoryStatus.error);
    }
  }

}