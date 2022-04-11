import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/create_story.dart';
import 'package:story_view_app/providers.dart';
import 'package:story_view_app/story_view.dart';

import 'package:story_view_app/views/basewidgets/gallery/custom_gallery.dart';
import 'package:story_view_app/views/basewidgets/painter/wa_status.dart';

import 'package:story_view_app/container.dart' as core;

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await core.init();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint(e.code);
    debugPrint(e.description);
  }
  runApp(MultiProvider(
    providers: providers,
    child: MyApp(key: UniqueKey())
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override 
  void initState() {
    super.initState();
    if(mounted) {
      Future.delayed(Duration.zero, () async {
        await PhotoManager.requestPermission();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(key: UniqueKey()),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text("Story View",
          style: TextStyle(
            color: Colors.black
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3.0,
        mini: true,
        backgroundColor: const Color(0xffEEEEEE),
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateStoryScreen(
            type: "text",
          )));
        }, 
        child: const Icon(
          Icons.edit,
          size: 18.0,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TabCamera(key: UniqueKey())),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CachedNetworkImage(
                            filterQuality: FilterQuality.medium,
                            imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                            errorWidget: (BuildContext context, String url, dynamic error) => Container(),
                            imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                              return CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.transparent,
                                backgroundImage: imageProvider,
                              );
                            },
                          ),
                          Positioned(
                            top: 20.0,
                            right: -5.0,
                            bottom: 0.0,
                            child: Container(
                              width: 30.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 15.0,
                                color: Colors.white,
                              )
                            ),
                          )
                        ]
                      ),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Status saya",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text("Ketuk untuk menambahkan pembaruan status",
                              style: TextStyle(
                                fontSize: 12.0
                              ),
                            ),
                          ]
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 16.0, 
              right: 16.0
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Pembaruan Terkini",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StoryViewScreen(key: UniqueKey())),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CachedNetworkImage(
                        imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                        errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
                        imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                          return CustomPaint(
                            foregroundPainter: DashedCirclePainter(
                              dashes: 3,
                              gapSize: 4,
                              color: Colors.green[300]!,
                              strokeWidth: 2
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(3.0),
                              child: CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.transparent,
                                backgroundImage: imageProvider,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text("Reihan Agam",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text("Kemarin 10:45",
                              style: TextStyle(
                                fontSize: 12.0
                              ),
                            ),
                          ]
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
