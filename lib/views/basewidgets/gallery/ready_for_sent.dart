import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:story_view_app/services/video.dart';
import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

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
 
  late CarouselController carouselC;

  int currentIndex = 0;

  @override 
  void initState() {
    super.initState();   
    carouselC = CarouselController();
  }

  @override 
  void dispose() {
    for (Map<String, dynamic> item in widget.files) {
      item["video"].dispose();
    }
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
    return Builder(
      builder: (BuildContext context) {
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
      },
    );
  }

  Widget viewFile(BuildContext context, List<Map<String, dynamic>> files) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        files.single["type"] == "mp4" 
        ? files.single["video"].initialized
        ? ListView(
            padding: EdgeInsets.zero,
            children: [
              AnimatedBuilder(
                animation: files.single["video"].video,
                builder: (_, __) {
                  final duration =  files.single["video"].video.value.duration.inSeconds;
                  final pos =  files.single["video"].trimPosition * duration;
                  final start = files.single["video"].minTrim * duration;
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
                          visible: files.single["video"].isTrimming,
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
                    controller: files.single["video"],
                    margin: const EdgeInsets.only(top: 10.0)
                  ),
                  controller: files.single["video"],
                  height: 60.0,
                  horizontalMargin: 60.0 / 4
                ),
              ),
              Stack( 
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  CropGridViewer(
                    controller: files.single["video"],
                    showGrid: false,
                  ),
                  AnimatedBuilder(
                    animation: files.single["video"].video,
                    builder: (_, __) => OpacityTransition(
                      visible: !files.single["video"].isPlaying,
                      child: GestureDetector(
                        onTap: files.single["video"].video.play,
                        child: Container(
                          width: 40.0,
                          height: 40.0,
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
          : Center(
              child: Text("Video is not Initialize",
                style: openSans.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: ColorResources.white
                )
              ),
            )
          : Positioned.fill(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
            child: Image.file(
              File(files.single["file"].path),
              fit: BoxFit.contain,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.only(
                bottom: 20.0,
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
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      ),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () async {
                          // VideoEditorController vec = files.single["video"];
                          // double start = files.single["video"].minTrim;
                          // double end =  files.single["video"].maxTrim;
                          // String s = start.toStringAsFixed(2); 
                          // String e = end.toStringAsFixed(2);  
                          // setState(() {
                          //   vec.updateTrim(double.parse(s), double.parse(e));
                          // });
                          // vec.exportVideo(onCompleted: (File? f) async {
                          //   TextEditingController? caption = files.single["text"];
                          //   File media = f!;
                          //   String? duration = await VideoServices.getDuration(media);
                          //   await context.read<StoryProvider>().createStory(context, 
                          //     caption: caption!.text, 
                          //     file: media,
                          //     duration: duration!
                          //   );
                          // });
                          await context.read<StoryProvider>().createStory(context, 
                            // caption: caption.text, 
                            // file: media,
                            // duration: duration,
                            files: files
                          );
                        }, 
                        icon: context.watch<StoryProvider>().createStoryStatus == CreateStoryStatus.loading 
                        ? const SizedBox(
                            width: 12.0,
                            height: 12.0,
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
            ),
          )
        
        ],
      );
    }

  Widget viewFiles(BuildContext context, List<Map<String, dynamic>> files) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
    
        Stack(
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
                : Center(
                    child: Text("Video is not Initialize",
                      style: openSans.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: ColorResources.white
                      )
                    ),
                  )
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
              top: 0.0,
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
                          width: 80.0,
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
                            fit: StackFit.expand,
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
            ),

          ]
        ),
    
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.only(
              bottom: 20.0,
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
                        // context.read<StoryProvider>().setStateCreateStoryStatus(CreateStoryStatus.loading);
                     
                        //   for (Map<String, dynamic> file in files) {
                        //     TextEditingController caption = file["text"];
                        //     File media = file["file"];
                        //     String duration = file["duration"];
                        //     if(file["type"] == "mp4") {
                        //       VideoEditorController vec = file["video"];
                        //       double start = file["video"].minTrim;
                        //       double end =  file["video"].maxTrim;
                        //       String s = start.toStringAsFixed(2); 
                        //       String e = end.toStringAsFixed(2);  
                        //       setState(() {
                        //         vec.updateTrim(double.parse(s), double.parse(e));
                        //       });
                        //       vec.exportVideo(onCompleted: (File? file) async {
                        //         File m = file!;
                        //         String? d = await VideoServices.getDuration(m);
                        //         await context.read<StoryProvider>().createStory(context, 
                        //           caption: caption.text, 
                        //           file: m,
                        //           duration: d!
                        //         );
                        //       });
                        //     } else {
                        //       await context.read<StoryProvider>().createStory(context, 
                        //         caption: caption.text, 
                        //         file: media,
                        //         duration: duration
                        //       );
                        //     }
                        //   }
                       
                        await context.read<StoryProvider>().createStory(context, 
                          // caption: caption.text, 
                          // file: media,
                          // duration: duration,
                          files: files
                        );
                      }, 
                      icon: context.watch<StoryProvider>().createStoryStatus == CreateStoryStatus.loading 
                      ? const SizedBox(
                          width: 12.0,
                          height: 12.0,
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
          ),
        )
      ],
    ); 
  }
}