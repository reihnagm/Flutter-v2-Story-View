import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view_app/custom/story_view/controller/story_controller.dart';

import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/custom/story_view/story_image.dart';
import 'package:story_view_app/custom/story_view/story_video.dart';
import 'package:story_view_app/data/models/story/story.dart';
import 'package:story_view_app/main.dart';
import 'package:story_view_app/providers/story/story.dart';
import 'package:story_view_app/services/navigation.dart';
import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';
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
  late NavigationService ns;

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
                StoryItem(
                  Container(
                    key: UniqueKey(),
                    decoration: const BoxDecoration(
                      color: ColorResources.black,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 45.0, 
                              left: 0.0
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                CachedNetworkImage(
                                  filterQuality: FilterQuality.medium,
                                  imageUrl: "${AppConstants.baseUrl}/images/${item.user!.pic}",
                                  imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                    return CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: imageProvider,
                                    );
                                  },
                                  placeholder: (BuildContext context, String val) {
                                    return const CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: ColorResources.grey,
                                      child: Icon(Icons.person,
                                        color: ColorResources.white,
                                      ),
                                    );
                                  },
                                  errorWidget: (BuildContext context, String url, dynamic error) {
                                    return const CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: ColorResources.grey,
                                      child: Icon(Icons.person,
                                        color: ColorResources.white,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 15.0),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${item.user!.fullname}",
                                      style: openSans.copyWith(
                                        color: ColorResources.white,
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text("${item.user!.created}",
                                      style: openSans.copyWith(
                                        color: ColorResources.white,
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        fontWeight: FontWeight.normal
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            imageUrl: "${AppConstants.baseUrl}/images/${item.media!}",
                            fit: BoxFit.fitWidth
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            child: Text("${item.caption}",
                              style: openSans.copyWith(
                                color: ColorResources.white,
                                fontSize: Dimensions.fontSizeExtraSmall,
                                fontWeight: FontWeight.normal
                              ),
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                  duration: const Duration(seconds: 3)
                )
              );
            });
          break;
          case "video":
            setState(() {
              _storyItem.add(
                StoryItem(
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        key: UniqueKey(),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: ColorResources.black,
                        ), 
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            StoryVideo.url("${AppConstants.baseUrl}/videos/${item.media!}",
                              controller: sc,
                            ),
                            SafeArea(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 27.0, 
                                    left: 0.0
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      CachedNetworkImage(
                                        filterQuality: FilterQuality.medium,
                                        imageUrl: "${AppConstants.baseUrl}/images/${item.user!.pic}",
                                        imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                          return CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: imageProvider,
                                          );
                                        },
                                        placeholder: (BuildContext context, String val) {
                                          return const CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: ColorResources.grey,
                                            child: Icon(Icons.person,
                                              color: ColorResources.white,
                                            ),
                                          );
                                        },
                                        errorWidget: (BuildContext context, String url, dynamic error) {
                                          return const CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: ColorResources.grey,
                                            child: Icon(Icons.person,
                                              color: ColorResources.white,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 15.0),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${item.user!.fullname}",
                                            style: openSans.copyWith(
                                              color: ColorResources.white,
                                              fontSize: Dimensions.fontSizeExtraSmall,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text("${item.user!.created}",
                                            style: openSans.copyWith(
                                              color: ColorResources.white,
                                              fontSize: Dimensions.fontSizeExtraSmall,
                                              fontWeight: FontWeight.normal
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ),
                              ),
                            ),
                            SafeArea(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 24.0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 8.0
                                  ),
                                  color: item.caption != null ? ColorResources.black : ColorResources.transparent,
                                  child: item.caption != null
                                  ? Text(
                                      item.caption!,
                                      style: openSans.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall, 
                                        color: ColorResources.white
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : const SizedBox(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  duration:  Duration(seconds: Helper.parseDuration(item.duration!).inSeconds)
                )
              );
            });
          break;
          case "text":
            setState(() {
              _storyItem.add(
                StoryItem(
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        key: UniqueKey(),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Helper.hexToColor(item.backgroundColor!),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [ 
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 45.0, 
                                  left: 0.0
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    CachedNetworkImage(
                                      filterQuality: FilterQuality.medium,
                                      imageUrl: "${AppConstants.baseUrl}/images/${item.user!.pic}",
                                      imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                        return CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: imageProvider,
                                        );
                                      },
                                      placeholder: (BuildContext context, String val) {
                                        return const CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor: ColorResources.grey,
                                          child: Icon(Icons.person,
                                            color: ColorResources.white,
                                          ),
                                        );
                                      },
                                      errorWidget: (BuildContext context, String url, dynamic error) {
                                        return const CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor: ColorResources.grey,
                                          child: Icon(Icons.person,
                                            color: ColorResources.white,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 15.0),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${item.user!.fullname}",
                                          style: openSans.copyWith(
                                            color: ColorResources.white,
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text("${item.user!.created}",
                                          style: openSans.copyWith(
                                            color: ColorResources.white,
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                            fontWeight: FontWeight.normal
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ),
                            ),  
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                item.caption!,
                                style: openSans.copyWith(
                                  color: Helper.hexToColor(item.textColor!),
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 3)
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
    ns.pushNav(context, HomeScreen(key: UniqueKey()));
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
        ns = NavigationService();
        
        return WillPopScope(
          onWillPop: willPopScope,
          child: storyItem.isEmpty 
          ? Container()
          : WillPopScope(
            onWillPop: willPopScope,
            child: Scaffold(
              key: globalKey,
              backgroundColor: Colors.black,
              body: GestureDetector(
                onTap: () {
                  setState(() {
                    sc.next();
                  });
                },
                onLongPress: () {
                  setState(() {
                    sc.pause();
                  });
                },
                onLongPressUp: () {
                  //  setState(() {
                  //   sc.play();
                  // });
                },
                child: StoryView(
                  controller: sc,
                  storyItems: storyItem,
                  onStoryShow: (s) {
                
                  },
                  onComplete: () {
                    Navigator.of(context).pop();
                  },
                  onVerticalSwipeComplete: (p) {
                    debugPrint("swipe up");
                  },
                  progressPosition: ProgressPosition.top,
                  repeat: false,
                  inline: true,
                ),
              ) 
            ),
          ),
        );
      },
    );
  }
}