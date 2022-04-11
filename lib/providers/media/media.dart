import 'dart:io';

import 'package:flutter/material.dart';

import 'package:story_view_app/data/repository/media/media.dart';

enum MediaStatus { idle, loading, loaded, empty, error }

class MediaProvider with ChangeNotifier {
  final MediaRepo mr;
  MediaProvider({
    required this.mr
  });

  MediaStatus _mediaStatus = MediaStatus.idle;
  MediaStatus get mediaStatus => _mediaStatus;

  void setStateMediaStatus(MediaStatus mediaStatus) {
    _mediaStatus = mediaStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  } 

  Future<void> media(BuildContext context, {required File file}) async {
    try {
      await mr.media(context, file: file);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }
}