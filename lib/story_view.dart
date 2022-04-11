import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/custom/story_view/controller/story_controller.dart';
import 'package:story_view_app/custom/story_view/story_image.dart';
import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/custom/story_view/story_video.dart';
import 'package:story_view_app/custom/story_view/utils.dart';
import 'package:story_view_app/providers/story/story.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({ Key? key }) : super(key: key);

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  late StoryProvider sp;

  @override 
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if(mounted) {
        sp.sc = StoryController();
      }
      if(mounted) {
        sp.getStory(context);
      }
    });
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(); 
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
        sp = context.read<StoryProvider>();
        return Scaffold(
          key: globalKey,
          body: Consumer<StoryProvider>(
            builder: (BuildContext context, StoryProvider storyProvider, Widget? child) {
              if(storyProvider.getStoryStatus == GetStoryStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator()
                );
              }
              return StoryView(
                controller: storyProvider.sc,
                storyItems: storyProvider.storyItem,
                onStoryShow: (s) {
                },
                onComplete: () {
                  Navigator.pop(context);
                },
                onVerticalSwipeComplete: (p) {
                  storyProvider.swipeRight();
                },
                progressPosition: ProgressPosition.top,
                repeat: false,
                inline: true,
              ); 
            },
          ) 
        );
      },
    );
  }
}