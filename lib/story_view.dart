import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:story_view_app/custom/story_view/controller/story_controller.dart';
import 'package:story_view_app/custom/story_view/story_image.dart';
import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/custom/story_view/story_video.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({ Key? key }) : super(key: key);

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  final StoryController controller = StoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text("Story View"),
      ), 
      body: StoryView(
        controller: controller,
        storyItems: [
          StoryItem(
            Container(
              key: const Key("1"),
              color: Colors.black,
              child: Stack(
                children: [
                  StoryImage.url("https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
                    controller: controller,
                    fit: BoxFit.fitWidth,
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 24.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        color: Colors.black54,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            IconButton(
                              onPressed: () {
                                controller.pause();
                                showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0)
                                    ),
                                  ),
                                  context: context, 
                                  isDismissible: true,
                                  builder: (context) {
                                    return Container(
                                      margin: const EdgeInsets.only(top: 10.0),
                                      child: SizedBox(
                                        height: 300.0,
                                        child: ListView(
                                          children: [
                                            ListTile(
                                              dense: false,
                                              leading: CachedNetworkImage(
                                                filterQuality: FilterQuality.medium,
                                                imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                                                errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
                                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                  return CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: imageProvider,
                                                  );
                                                },
                                              ),
                                              title: const Text("Reihan Agam"),
                                              subtitle: const Text("10:45"),
                                            ),
                                            ListTile(
                                              dense: false,
                                              leading: CachedNetworkImage(
                                                filterQuality: FilterQuality.medium,
                                                imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                                                errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
                                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                  return CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: imageProvider,
                                                  );
                                                },
                                              ),
                                              title: const Text("Jecko"),
                                              subtitle: const Text("11:45"),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                ).whenComplete(() {
                                  controller.play();
                                });
                              }, 
                              icon: const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            )
                          ],
                        ) 
                      ),
                    ),
                  ),
                ],
              ),
            ), 
            duration: const Duration(seconds: 8),
          ),
          StoryItem(
            Container(
              key: const Key("1"),
              decoration: const BoxDecoration(
                color: Colors.orange,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: const Center(
                child: Text("Hello World!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            duration: const Duration(seconds: 8),
          ),
          StoryItem(
            Container(
              key: const Key("1"),
              color: Colors.black,
              child: Stack(
                children: [
                  StoryVideo.url("https://feedapi.connexist.id/d/f/community/715299187951/VID-20210922-WA0077.mp4",
                    controller: controller,
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        color: Colors.black54,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            IconButton(
                              onPressed: () {
                                controller.pause();
                                showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0)
                                    ),
                                  ),
                                  context: context, 
                                  isDismissible: true,
                                  builder: (context) {
                                    return Container(
                                      margin: const EdgeInsets.only(top: 10.0),
                                      child: SizedBox(
                                        height: 300.0,
                                        child: ListView(
                                          children: [
                                            ListTile(
                                              dense: false,
                                              leading: CachedNetworkImage(
                                                filterQuality: FilterQuality.medium,
                                                imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                                                errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
                                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                  return CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: imageProvider,
                                                  );
                                                },
                                              ),
                                              title: const Text("Reihan Agam"),
                                              subtitle: const Text("10:45"),
                                            ),
                                            ListTile(
                                              dense: false,
                                              leading: CachedNetworkImage(
                                                filterQuality: FilterQuality.medium,
                                                imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                                                errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
                                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                  return CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: imageProvider,
                                                  );
                                                },
                                              ),
                                              title: const Text("Jecko"),
                                              subtitle: const Text("11:45"),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                ).whenComplete(() {
                                  controller.play();
                                });
                              }, 
                              icon: const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            )
                          ],
                        ) 
                      ),
                    ),
                  )
                ],
              ),
            ),
            duration: const Duration(seconds: 10)
          )
          // StoryItem.pageVideo("https://feedapi.connexist.id/d/f/community/715299187951/VID-20210922-WA0077.mp4", 
          //   controller: controller,
          // )
          // StoryItem.text(
          //   title: "Hello world!",
          //   backgroundColor: Colors.orange,
          //   roundedTop: true,
          // ), 
          // StoryItem.pageImage(
          //   url: "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
          //   controller: controller,
          //   caption: "Hello world!",
          // ),
          // StoryItem.pageVideo(
          //   "https://feedapi.connexist.id/d/f/community/715299187951/VID-20210922-WA0077.mp4", 
          //   controller: controller
          // )
        ],
        onStoryShow: (s) {
        },
        onComplete: () {
        },
        onVerticalSwipeComplete: (p) {
        },
        progressPosition: ProgressPosition.top,
        repeat: true,
        inline: true,
      ),
    );
  }
}