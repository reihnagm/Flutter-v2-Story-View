import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view_app/custom/story_view/controller/story_controller.dart';

import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/data/models/story/story.dart';
import 'package:story_view_app/providers/story/story.dart';
import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/utils/helper.dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryUserItem> storyUserItem;

  const StoryViewScreen({ 
    required this.storyUserItem,
    Key? key,
  }) : super(key: key);

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  late StoryController sc;
  late StoryProvider sp;

  List<StoryItem> _storyItem = [];
  List<StoryItem> get storyItem => [..._storyItem];

  @override 
  void initState() {
    super.initState();
    sc = StoryController();
    _storyItem = [];
    Future.delayed(Duration.zero, () {
      for (StoryUserItem item in widget.storyUserItem) {
        switch (item.type) {
          case "image":
            setState(() {
              _storyItem.add(
                StoryItem.pageImage(
                  url: "${AppConstants.baseUrl}/images/${item.media!}", 
                  controller: sc,
                  caption: item.caption
                )
              );
            });
          break;
          case "video":
            setState(() {
              _storyItem.add(
                StoryItem.pageVideo(
                  "${AppConstants.baseUrl}/videos/${item.media!}", 
                  duration: Duration(seconds: Helper.parseDuration(item.duration!).inSeconds),
                  controller: sc,
                  caption: item.caption,
                )
              );
            });
          break;
          default:
        }
      }
      if(mounted) {
        sp.getStory(context);
      }
    });
  }

  @override 
  void dispose() {
    sc.dispose();
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
            body:  StoryView(
              controller: sc,
              storyItems: storyItem,
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
            ) 
          ),
        );
      },
    );
  }
}