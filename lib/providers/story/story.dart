import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:story_view_app/data/models/story/story.dart';

import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/data/repository/story/story.dart';
import 'package:story_view_app/services/navigation.dart';
import 'package:story_view_app/services/video.dart';
import 'package:video_editor/video_editor.dart';

enum GetStoryStatus { idle, loading, loaded, empty, error }

enum CreateStoryStatus { idle, loading, loaded, empty, error }
enum CreateStoryVideoStatus { idle, loading, loaded, empty, error }
enum CreateStoryImageStatus { idle, loading, loaded, empty, error }

class StoryProvider with ChangeNotifier {
  final StoryRepo sr;
  final MediaRepo mr;
  final NavigationService ns;
  StoryProvider({
    required this.sr,
    required this.mr,
    required this.ns
  });

  String? duration = "";
  String? media = "";
  File? path;

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
    required List<Map<String, dynamic>> files,
  }) async {
    setStateCreateStoryStatus(CreateStoryStatus.loading);
    try {
      for (Map<String, dynamic> item in files) {
        if(item["type"] == "text") {
          TextEditingController caption = item["text"];
          await sr.createStory(context, 
            backgroundColor: item["backgroundColor"],
            textColor: item["textColor"],
            caption: caption.text,
            duration: "",
            type: "text",
            media: ""
          );
          setStateCreateStoryStatus(CreateStoryStatus.loaded);
        } else {
          TextEditingController caption = item["text"];
          File file = item["file"];    
          String? mimeType = lookupMimeType(file.path); 
          String type = mimeType!.split("/")[0];
          switch (type) {
            case "video":
              VideoEditorController vec = item["video"];
              double start = item["video"].minTrim;
              double end =  item["video"].maxTrim;
              String s = start.toStringAsFixed(2); 
              String e = end.toStringAsFixed(2);  
              vec.updateTrim(double.parse(s), double.parse(e));
              await vec.exportVideo(onCompleted: (File? f) async {
                duration = await VideoServices.getDuration(f!);
                media = await mr.media(context, 
                  file: f
                );
                Future.delayed(Duration.zero, () => notifyListeners());
                await sr.createStory(context, 
                  backgroundColor: "",
                  textColor: "",
                  caption: caption.text,
                  duration: duration!,
                  type: type,
                  media: media!
                );
                setStateCreateStoryStatus(CreateStoryStatus.loaded);
              });
            break;
            case "image":
              duration = "";
              media = await mr.media(context, 
                file: File(file.path)
              );
              Future.delayed(Duration.zero, () => notifyListeners());
              await sr.createStory(context, 
                backgroundColor: "",
                textColor: "",
                caption: caption.text,
                duration: duration!,
                type: type,
                media: media!
              );
              setStateCreateStoryStatus(CreateStoryStatus.loaded);
            break;
            default:
          }
        }
      }
      ns.goBack(context);
      Future.delayed(const Duration(seconds: 1), () {
        getStory(context);
      });
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setStateCreateStoryStatus(CreateStoryStatus.error);
    }
  }

  Future<void> userStoryExpire(BuildContext context) async {
    try {
      await sr.userStoryExpire(context);
      Future.delayed(Duration.zero, () {
        getStory(context);
      });
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }

}