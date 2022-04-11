import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/custom/story_view/controller/story_controller.dart';

import 'package:story_view_app/custom/story_view/index.dart';
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
        sp.getStory(context);
      }
    });
  }

  @override 
  void dispose() {
    super.dispose();
  }

  Future<bool> willPopScope() {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(); 
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
        sp = context.read<StoryProvider>();
        return WillPopScope(
          onWillPop: willPopScope,
          child: Scaffold(
            key: globalKey,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Consumer<StoryProvider>(
              builder: (BuildContext context, StoryProvider storyProvider, Widget? child) {
                if(storyProvider.getStoryStatus == GetStoryStatus.loading) {
                  return Container();
                }
                if(storyProvider.getStoryStatus == GetStoryStatus.empty) {
                  return const SizedBox(
                    child: Center(
                      child: Text("There is no Data",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white
                        ),
                      )
                    ),
                  );
                }
                if(storyProvider.getStoryStatus == GetStoryStatus.error) {
                  return const SizedBox(
                    child: Center(
                      child: Text("Oops! There was a problem",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white
                        ),
                      )
                    ),
                  );
                }
                if(storyProvider.getStoryStatus == GetStoryStatus.loaded) {
                  return StoryView(
                    controller: storyProvider.sc,
                    storyItems: storyProvider.storyItem,
                    onStoryShow: (s) {
                  
                    },
                    onComplete: () {
                      Navigator.of(context).pop();
                    },
                    onVerticalSwipeComplete: (p) {
                       
                    },
                    progressPosition: ProgressPosition.top,
                    repeat: false,
                    inline: true,
                  ); 
                }
                return Container();
              }
            ) 
          ),
        );
      },
    );
  }
}