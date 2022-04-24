import 'dart:async';
import 'package:cron/cron.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/providers.dart';
import 'package:story_view_app/providers/auth/auth.dart';
import 'package:story_view_app/providers/story/story.dart';
import 'package:story_view_app/services/navigation.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/basewidgets/drawer/drawer.dart';
import 'package:story_view_app/views/screens/story/create.dart';

import 'package:story_view_app/views/screens/story/list.dart';

import 'package:story_view_app/views/basewidgets/gallery/custom_gallery.dart';
import 'package:story_view_app/views/basewidgets/painter/wa_status.dart';

import 'package:story_view_app/container.dart' as core;

import 'package:story_view_app/views/screens/auth/sign_in.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await core.init();
  try {
    cameras = await availableCameras();
  } on CameraException catch(e) {
    debugPrint(e.code);
    debugPrint(e.description);
  } catch(e, stacktrace) {
    debugPrint(stacktrace.toString());
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
  
  Timer? timer;
  int value = 0;

  Future<void> checkUserStoryExpire() async  {
    await context.read<StoryProvider>().userStoryExpire(context);
  }

  @override 
  void initState() {
    super.initState();
    checkUserStoryExpire();
    Cron cron = Cron();
    cron.schedule(Schedule.parse('*/3 * * * *'), () async {
      await context.read<StoryProvider>().userStoryExpire(context);
    });
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        await PhotoManager.requestPermission();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360.0, 640.0),
      builder: (BuildContext context) {
        return  MaterialApp(
          title: 'Story Status',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: ColorResources.white,
          ),
          home: Consumer<AuthProvider>(
            builder: (BuildContext context, AuthProvider authProvider, Widget? child) {
              if(authProvider.isLogggedIn) {
                return const HomeScreen();
              } else {
                return const SignInScreen();
              }
            },
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StoryProvider sp;
  late NavigationService ns;

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
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
      sp = context.read<StoryProvider>();
      ns = NavigationService();
      return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: DrawerWidget(key: UniqueKey()),
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: ColorResources.black
          ),
          backgroundColor: ColorResources.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text("Story View",
            style: openSans.copyWith(
              color: ColorResources.black,
              fontSize: Dimensions.fontSizeExtraSmall
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 3.0,
          mini: true,
          backgroundColor: ColorResources.white,
          foregroundColor: ColorResources.black,
          onPressed: () {
            ns.pushNav(context, CreateStoryScreen(key: UniqueKey()));
          }, 
          child: const Icon(
            Icons.edit,
            size: 18.0,
          ),
        ),
        body: Consumer<StoryProvider>(
          builder: (BuildContext context, StoryProvider storyProvider, Widget? child) {
            if(storyProvider.getStoryStatus == GetStoryStatus.loading) {
              return const Center(
                child: SpinKitChasingDots(
                  color: ColorResources.loaderBluePrimary,
                  size: 20.0,
                ),
              );
            }
            if(storyProvider.getStoryStatus == GetStoryStatus.empty) {
              return RefreshIndicator(
                backgroundColor: ColorResources.white,
                color: ColorResources.loaderBluePrimary,
                onRefresh: () {
                  return Future.sync(() {
                    sp.getStory(context);
                  });
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    selfStatus(context)
                  ],
                ),
              );
            }
            if(storyProvider.getStoryStatus == GetStoryStatus.error) {
              return RefreshIndicator(
                backgroundColor: ColorResources.white,
                color: ColorResources.loaderBluePrimary,
                onRefresh: () {
                  return Future.sync(() {
                    sp.getStory(context);
                  });
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverFillRemaining(
                      child: Center(
                        child: Text("Oops! There was Problem",
                          style: TextStyle(
                            fontSize: Dimensions.fontSizeExtraSmall
                          ),
                        )
                      ),
                    )
                  ],
                ),
              );
            }
            if(storyProvider.getStoryStatus == GetStoryStatus.loaded) {
              return RefreshIndicator(
                backgroundColor: ColorResources.white,
                color: ColorResources.loaderBluePrimary,
                onRefresh: () {
                  return Future.sync(() {
                    sp.getStory(context);
                  });
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [

                   selfStatus(context),

                    SliverToBoxAdapter(
                      child: Container(
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
                    ),
                        
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(((BuildContext context, int i) {
                          return Container(
                            margin: const EdgeInsets.all(16.0),
                            child: Material(
                              color: ColorResources.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => StoryViewScreen(
                                      storyUserItem: storyProvider.storyData[i].user!.items!,
                                      key: UniqueKey()
                                    )),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: "${AppConstants.baseUrl}/images/${storyProvider.storyData[i].user!.pic}",
                                        imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                          return CustomPaint(
                                            foregroundPainter: DashedCirclePainter(
                                              dashes: storyProvider.storyData[i].user!.itemCount!,
                                              gapSize: 4,
                                              color: ColorResources.success,
                                              strokeWidth: 2
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(3.0),
                                              child: CircleAvatar(
                                                radius: 20.0,
                                                backgroundColor: ColorResources.grey,
                                                backgroundImage: imageProvider,
                                              ),
                                            ),
                                          );
                                        },
                                        placeholder: (BuildContext context, String url) {
                                          return CustomPaint(
                                            foregroundPainter: DashedCirclePainter(
                                              dashes: storyProvider.storyData[i].user!.itemCount!,
                                              gapSize: 4,
                                              color: ColorResources.success,
                                              strokeWidth: 2
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(3.0),
                                              child: const CircleAvatar(
                                                radius: 20.0,
                                                backgroundColor: ColorResources.grey,
                                                child: Icon(Icons.person,
                                                  color: ColorResources.white,
                                                ),
                                              ),
                                            ),
                                          ); 
                                        },
                                        errorWidget: (BuildContext context, String url, dynamic error) {
                                          return CustomPaint(
                                            foregroundPainter: DashedCirclePainter(
                                              dashes: storyProvider.storyData[i].user!.itemCount!,
                                              gapSize: 4,
                                              color: ColorResources.success,
                                              strokeWidth: 2
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(3.0),
                                              child: const CircleAvatar(
                                                radius: 20.0,
                                                backgroundColor: ColorResources.grey,
                                                child: Icon(Icons.person,
                                                  color: ColorResources.white,
                                                ),
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
                                          children: [
                                            Text(storyProvider.storyData[i].user!.fullname.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(storyProvider.storyData[i].user!.created!,
                                              style: const TextStyle(
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
                            );
                          }
                        ),
                        childCount: storyProvider.storyData.length
                      )
                    ),
                  )
                        
                  ],
                ),
              );
            }
            return Container();
          },
        )
      );
    });
  }

  Widget selfStatus(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(
          top: 5.0,
          left: 16.0, 
          right: 16.0,
          bottom: 5.0,
        ),
        child: Material(
          color: ColorResources.transparent,
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
                        imageUrl: "${AppConstants.baseUrl}/images/${context.read<AuthProvider>().getPic}",
                        imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                          return CircleAvatar(
                            radius: 20.0,
                            backgroundColor: ColorResources.transparent,
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
                      Positioned(
                        top: 20.0,
                        right: -5.0,
                        bottom: 0.0,
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: ColorResources.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorResources.white,
                              width: 2.0
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 15.0,
                            color: ColorResources.white,
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
                      children: const [
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
    );
  }
}
