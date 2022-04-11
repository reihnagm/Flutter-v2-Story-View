import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:video_editor/video_editor.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:helpers/helpers.dart' show OpacityTransition;
import 'package:provider/provider.dart';

import 'package:story_view_app/providers/story/story.dart';


class ReadyForSentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> files;
  const ReadyForSentScreen({ 
    required this.files,
    Key? key 
  }) : super(key: key);

  @override
  State<ReadyForSentScreen> createState() => _ReadyForSentScreenState();
}

class _ReadyForSentScreenState extends State<ReadyForSentScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;
  late CarouselController carouselC;

  @override 
  void initState() {
    super.initState();
    carouselC = CarouselController();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  Future<bool> willPopScope() {
    Navigator.of(context).pop();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(); 
  }
  
  Widget buildUI() {
    return WillPopScope(
      onWillPop: willPopScope,
      child: Scaffold(
        key: globalKey,
        backgroundColor: const Color(0xFF252525),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: const Color(0xFF252525),
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: widget.files.isNotEmpty 
        ? widget.files.length > 1 
        ? viewFiles(context, widget.files)
        : viewFile(context, widget.files) 
        : Container()
      ),
    );
  }

  Widget viewFile(BuildContext context, List<Map<String, dynamic>> files) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: files.single["type"] == "mp4" 
            ? files.single["video"].initialized 
            ? ListView(
                padding: EdgeInsets.zero,
                children: [
                  AnimatedBuilder(
                    animation:  files.single["video"].video,
                    builder: (_, __) {
                      final duration =  files.single["video"].video.value.duration.inSeconds;
                      final pos =  files.single["video"].trimPosition * duration;
                      final start =  files.single["video"].minTrim * duration;
                      final end =  files.single["video"].maxTrim * duration;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60 / 4),
                        child: Row(
                          children: [
                            Text(formatter(Duration(seconds: pos.toInt())),
                              style: const TextStyle(
                                color: Colors.white
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            OpacityTransition(
                              visible:  files.single["video"].isTrimming,
                              child: Row(
                                mainAxisSize: MainAxisSize.min, 
                                children: [
                                  Text(formatter(Duration(seconds: start.toInt())),
                                    style: const TextStyle(
                                      color: Colors.white
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(formatter(Duration(seconds: end.toInt())),
                                    style: const TextStyle(
                                      color: Colors.white
                                    ),
                                  ),
                                ]
                              ),
                            )
                          ]
                        ),
                      );
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(vertical: 60.0 / 4),
                    child: TrimSlider(
                      child: TrimTimeline(
                        controller:  files.single["video"],
                        margin: const EdgeInsets.only(top: 10.0)
                      ),
                      controller:  files.single["video"],
                      height: 60.0,
                      horizontalMargin: 60.0 / 4
                    ),
                  ),
                  Stack( 
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      
                      CropGridViewer(
                        controller:  files.single["video"],
                        showGrid: false,
                      ),
                      AnimatedBuilder(
                        animation:  files.single["video"].video,
                        builder: (_, __) => OpacityTransition(
                          visible: ! files.single["video"].isPlaying,
                          child: GestureDetector(
                            onTap:  files.single["video"].video.play,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                color: Colors.black
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  )
                ],
              )
            : Container()
            : Image.file(
              File(files.single["file"].path),
              fit: BoxFit.fitHeight,
            )
          ),

          Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: files.single["text"],
                      textInputAction: TextInputAction.send,
                      cursorColor: Colors.black,
                      maxLines: null,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16.0),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30.0)
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30.0)
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30.0)
                        )
                      ),
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle
                    ),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () async {
                        TextEditingController? caption = files.single["text"];
                        File media = files.single["file"];
                        await context.read<StoryProvider>().createStory(context, 
                          caption: caption!.text, 
                          file: media
                        );
                      }, 
                      icon: context.watch<StoryProvider>().createStoryStatus == CreateStoryStatus.loading 
                      ? const SizedBox(
                          width: 14.0,
                          height: 14.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) 
                      : const Icon(
                        Icons.send,
                        size: 20.0,
                      )
                    ),
                  )
                )
              ],
            )
          )
          
        ],
      ),
    );
  }

  Widget viewFiles(BuildContext context, List<Map<String, dynamic>> files) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
    
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [

                CarouselSlider.builder(
                  options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    height: 420.0,
                    onPageChanged: (int i, CarouselPageChangedReason reason) {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                  ),
                  carouselController: carouselC,
                  itemCount: files.length,
                  itemBuilder: (BuildContext context, int i, int z) {
                    VideoEditorController vec = files[i]["video"];
                    return files[i]["type"] == "mp4" 
                    ? vec.initialized 
                    ? ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          AnimatedBuilder(
                            animation: vec.video,
                            builder: (_, __) {
                              final duration = vec.video.value.duration.inSeconds;
                              final pos = vec.trimPosition * duration;
                              final start = vec.minTrim * duration;
                              final end = vec.maxTrim * duration;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60 / 4),
                                child: Row(
                                  children: [
                                    Text(formatter(Duration(seconds: pos.toInt())),
                                      style: const TextStyle(
                                        color: Colors.white
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    OpacityTransition(
                                      visible: vec.isTrimming,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min, 
                                        children: [
                                          Text(formatter(Duration(seconds: start.toInt())),
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Text(formatter(Duration(seconds: end.toInt())),
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          ),
                                        ]
                                      ),
                                    )
                                  ]
                                ),
                              );
                            },
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 60.0 / 4),
                            child: TrimSlider(
                              child: TrimTimeline(
                                controller: vec,
                                margin: const EdgeInsets.only(top: 10.0)
                              ),
                              controller: vec,
                              height: 60.0,
                              horizontalMargin: 60.0 / 4
                            ),
                          ),
                          Stack( 
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              
                              SizedBox(
                                height: 300.0,
                                child: CropGridViewer(
                                  controller: vec,
                                  showGrid: false,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: vec.video,
                                builder: (_, __) => OpacityTransition(
                                  visible: !vec.isPlaying,
                                  child: GestureDetector(
                                    onTap: vec.video.play,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.play_arrow,
                                        color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            ]
                          )
                        ],
                      )
                    : Container()
                    : Image.file(
                      File(files[i]["type"] == "mp4" 
                      ? files[i]["thumbnail"].path 
                      : files[i]["file"].path),
                      fit: BoxFit.fitHeight,
                    );
                  },
                ), 
    
                Positioned(
                  left: 0.0, 
                  right: 0.0,
                  bottom: 0.0,
                  child: Center(
                    child: SizedBox(
                      height: 80.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: files.length,
                        itemBuilder: (context, int i) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                currentIndex = i;
                                carouselC.animateToPage(currentIndex);
                              });
                            },
                            child: Container(
                              width: 90.0,
                              margin: EdgeInsets.only(
                                left: i == 0 ? 16.0 : 0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: currentIndex == i 
                                  ? Colors.green 
                                  : Colors.white
                                )
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Image.file(File(files[i]["type"] == "mp4" 
                                  ? files[i]["thumbnail"].path 
                                  : files[i]["file"].path),
                                    fit: BoxFit.fill,
                                  ),
                                  files[i]["type"] == "mp4" 
                                  ? const Positioned(
                                      bottom: 5.0,
                                      right: 5.0,
                                      child: Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                      )
                                    ) 
                                  : Container()
                                ],
                              ) 
                            ),
                          );
                        },
                      ),
                    )
                  )
                )
    
              ]
            ),
          ),
    
          Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: files[currentIndex]["text"],
                      textInputAction: TextInputAction.send,
                      cursorColor: Colors.black,
                      maxLines: null,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16.0),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30.0)
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30.0)
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30.0)
                        )
                      ),
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle
                    ),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () async {
                        for (var file in files) {
                          TextEditingController caption = file["text"];
                          File media = file["file"];
                          await context.read<StoryProvider>().createStory(context, 
                            caption: caption.text, 
                            file: media
                          );
                        }
                      }, 
                      icon: context.watch<StoryProvider>().createStoryStatus == CreateStoryStatus.loading 
                      ? const SizedBox(
                          width: 14.0,
                          height: 14.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) 
                      : const Icon(
                        Icons.send,
                        size: 20.0,
                      )
                    ),
                  )
                )
              ],
            )
          )
        ],
      ),
    ); 
  }
}