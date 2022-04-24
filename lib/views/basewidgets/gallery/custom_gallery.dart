import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:story_view_app/services/navigation.dart';
import 'package:story_view_app/services/video.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:story_view_app/main.dart';
import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/basewidgets/gallery/ready_for_sent.dart';

import 'package:video_editor/video_editor.dart';

class TabCamera extends StatefulWidget {
  final bool needScaffold;

  const TabCamera({Key? key, this.needScaffold = true}) : super(key: key);

  @override
  _TabCameraState createState() => _TabCameraState();
}

class _TabCameraState extends State<TabCamera> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  Timer? timer;
  int sec = 0;

  List<Widget> mediaList = [];
  List<File?> files = [];
  List<Map<String, dynamic>> addFiles = [];
  List<String?> multipleFiles = [];
  int currentPage = 0;
  CameraController? cameraC;
  int cameraIndex = 0;

  bool isRecording = false;
  bool cameraNotAvailable = false;

  double containerHeight = 110.0;

  @override
  void initState() {
    super.initState();
    if (cameras == null || cameras!.isEmpty) {
      setState(() {
        if(mounted) {
          cameraNotAvailable = true;
        }
      });
    }
    getMediaAssets();
    initCamera(cameraIndex);
  }
  
  @override
  void dispose() {
    if (cameraC != null) {
      cameraC!.dispose();
    }
    super.dispose();
  }

  Future<void> getMediaAssets() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    List<AssetEntity> media = await albums[0].getAssetListPaged(currentPage, 60);
    List<Widget> temp = [];
    List<File?> tempFiles = [];
    for (AssetEntity asset in media) {
      tempFiles.add(await asset.file);
      temp.add(
        FutureBuilder(
          future: asset.thumbDataWithSize(200, 200), 
          builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (asset.type == AssetType.video)
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.0, bottom: 5.0),
                        child: Icon(
                          Icons.videocam,
                          color: ColorResources.white,
                        ),
                      ),
                    ),
                ],
              );
            }
            return Container();
          },
        ),
      );
    }
    setState(() {
      mediaList.addAll(temp);
      files.addAll(tempFiles);
      currentPage++;
    });
  }

  Future<void> initCamera(int index) async {
    if (cameraC != null) {
      await cameraC!.dispose();
    }
    cameraC = CameraController(cameras![index], ResolutionPreset.high);
    cameraC!.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraC!.initialize();
      cameraC!.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        cameraIndex = index;
      });
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (cameraC == null) {
      return;
    }
    try {
      await cameraC!.setFlashMode(mode);
    } on CameraException catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onSwitchCamera() {
    if (cameraC == null ||
      !cameraC!.value.isInitialized || cameraC!.value.isTakingPicture) {
      return;
    }
    final newIndex = cameraIndex + 1 == cameras!.length ? 0 : cameraIndex + 1;
    initCamera(newIndex);
  }

  Future<void> onTakePictureButtonPress() async {
    XFile? file = await takePicture();
    if (file != null) {
      File f = File(file.path);
      addFiles.add({
        "id": 0,
        "file": f,
        "thumbnail": "",
        "video": "",
        "duration": "",
        "type": lookupMimeType(file.path)!.split("/")[1],
        "text": TextEditingController()
      });
      NavigationService().pushNavReplacement(context,  ReadyForSentScreen(files: addFiles));
    }
  }

  Future<XFile?> takePicture() async {
    XFile? file;
    if (!cameraC!.value.isInitialized || cameraC!.value.isTakingPicture) {
      return null;
    }
    try {
      file = await cameraC!.takePicture();
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return file;
  }
 
  Widget buildGalleryBar() {
    double barHeight = 110.0;
    double vertPadding = 20.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      height: 130.0,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Icon(
              Icons.keyboard_arrow_up,
              color: ColorResources.white,
              size: 25.0,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: barHeight,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: vertPadding),
                scrollDirection: Axis.horizontal,
                itemCount: mediaList.length,
                itemBuilder: (BuildContext context, int i) {
                  return InkWell(
                    onLongPress: () async {
                      if(multipleFiles.length < 2) {
                        if(multipleFiles.isEmpty) {
                          if(multipleFiles.contains(files[i]!.path)) {
                            setState(() {
                              multipleFiles.remove(files[i]!.path);
                              addFiles.removeWhere((el) => el["id"] == i);
                            });
                          } else {
                            File? fileThumbnail;
                            String? duration;
                            String? ext = lookupMimeType(files[i]!.path)!.split("/")[1];
                            if(ext == "mp4") {
                              File ft = await VideoServices.generateFileThumbnail(files[i]!);
                              String? d =  await VideoServices.getDuration(files[i]!);
                              setState(() {
                                fileThumbnail = ft;
                                duration = d;
                              });
                            }
                            setState(() {
                              multipleFiles.add(files[i]!.path);
                              addFiles.add({
                                "id": i,
                                "file": files[i],
                                "thumbnail": fileThumbnail ?? "",
                                "video": VideoEditorController.file(files[i]!,
                                  maxDuration: const Duration(seconds: 30)
                                )..initialize(),
                                "duration": duration ?? "",
                                "type": ext,
                                "text": TextEditingController()
                              });
                            });
                          }
                        }
                      } else {
                        setState(() {
                          multipleFiles.remove(files[i]!.path);
                          addFiles.removeWhere((el) => el["id"] == i);
                        });
                        return;
                      }
                    },
                    onTap: () async {
                      if(multipleFiles.length < 2) {
                        if(multipleFiles.isNotEmpty) {
                          if(multipleFiles.contains(files[i]!.path)) {
                            setState(() {
                              multipleFiles.remove(files[i]!.path);
                              addFiles.removeWhere((el) => el["id"] == i);
                            });
                          } else {
                            File? fileThumbnail;
                            String? duration;
                            String? ext = lookupMimeType(files[i]!.path)!.split("/")[1];
                            if(ext == "mp4") {
                              File ft = await VideoServices.generateFileThumbnail(files[i]!);
                              String? d =  await VideoServices.getDuration(files[i]!);
                              setState(() {
                                fileThumbnail = ft;
                                duration = d;
                              });
                            }
                            setState(() {
                              multipleFiles.add(files[i]!.path);
                              addFiles.add({
                                "id": i,
                                "file": files[i],
                                "thumbnail": fileThumbnail ?? "",
                                "video": VideoEditorController.file(files[i]!,
                                  maxDuration: const Duration(seconds: 30)
                                )..initialize(),
                                "duration": duration ?? "",
                                "type": ext,
                                "text": TextEditingController()
                              });
                            });
                          }
                        } else {
                          if(multipleFiles.contains(files[i]!.path)) {
                            setState(() {
                              multipleFiles.remove(files[i]!.path);
                              addFiles.removeWhere((el) => el["id"] == i);
                            });
                          } else {
                            File? fileThumbnail;
                            String? duration;
                            String? ext = lookupMimeType(files[i]!.path)!.split("/")[1];
                            if(ext == "mp4") {
                              File ft = await VideoServices.generateFileThumbnail(files[i]!);
                              String? d = await VideoServices.getDuration(files[i]!);
                              setState(() {
                                fileThumbnail = ft;
                                duration = d;
                              });
                            }
                            setState(() {
                              multipleFiles.add(files[i]!.path);
                              addFiles.add({
                                "id": i,
                                "file": files[i],
                                "thumbnail": fileThumbnail ?? "",
                                "video": VideoEditorController.file(files[i]!,
                                  maxDuration: const Duration(seconds: 30)
                                )..initialize(),
                                "duration": duration ?? "",
                                "type": ext,
                                "text": TextEditingController()
                              });
                            });
                          }
                        }
                      } else {
                        setState(() {
                          multipleFiles.remove(files[i]!.path);
                          addFiles.removeWhere((el) => el["id"] == i);
                        });
                        return;
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 5.0),
                          width: 70.0,
                          height: barHeight - vertPadding * 2,
                          child: mediaList[i]
                        ),
                        multipleFiles.contains(files[i]!.path) 
                        ? Positioned(
                            top: 0.0,
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: ColorResources.success,
                                  shape: BoxShape.circle
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: ColorResources.white,
                                ),
                              ),
                            )
                          ) 
                        : Container()
                      ],
                    ) 
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ); 
  }

  Widget buildControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Material(
          color: ColorResources.transparent,
          child: IconButton(
            color: cameraC?.value.flashMode == FlashMode.off
            ? ColorResources.white
            : ColorResources.loaderBluePrimary,
            icon: const Icon(Icons.flash_auto),
            onPressed: cameraC != null
            ? () {
              if(cameraC!.value.flashMode == FlashMode.off) {
                onSetFlashModeButtonPressed(FlashMode.always);
              } else {
                onSetFlashModeButtonPressed(FlashMode.off);
              }
            }
            : null,
          ),
        ),
        GestureDetector(
          onTap: !isRecording ? onTakePictureButtonPress : () {},
          onLongPress: () async {
            await cameraC!.startVideoRecording();
            timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
              setState(() {
                sec++;
              });
            });
            setState(() {
              isRecording = true;
            });
          },
          onLongPressUp: () async {
            addFiles = [];
            XFile f = await cameraC!.stopVideoRecording();
            setState(() {
              isRecording = false;
            });
            timer?.cancel();
            File file = File(f.path);
            String? duration = await VideoServices.getDuration(file);
            addFiles.add({
              "id": 0,
              "file": file,
              "thumbnail": "",
              "video": VideoEditorController.file(file,
                maxDuration: const Duration(seconds: 30)
              )..initialize(),
              "duration": duration,
              "type": lookupMimeType(file.path)!.split("/")[1],
              "text": TextEditingController()
            });
            Future.delayed(const Duration(seconds: 3), () {
              NavigationService().pushNavReplacement(context, ReadyForSentScreen(
                files: addFiles,
              ));
            });
          },
          child: isRecording 
          ? Container(
              height: 80.0,
              width: 80.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorResources.error,
                  width: 5.0,
                ),
              ),
            )
          : Container(
            height: 80.0,
            width: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorResources.white,
                width: 5.0,
              ),
            ),
          ),
        ),
        Material(
          color: ColorResources.transparent,
          child: IconButton(
            color: ColorResources.white,
            icon: const Icon(Icons.switch_camera),
            onPressed: onSwitchCamera,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cameraNotAvailable) {
      const center = Center(
        child: Text('Camera not available /_\\'),
      );

      return center;
    }

    return buildUI();
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          key: globalKey,
          body: GestureDetector(
            onPanUpdate: (details) async {
              if (details.delta.dy < 0) {
                FilePickerResult? fpr = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  allowCompression: true,
                  type: FileType.custom,
                  allowedExtensions: ['mp4', 'jpeg', 'jpg', 'png'],
                );
                if(fpr != null) {
                  addFiles = [];
                  if(fpr.count > 1) {
                    for (int i = 0; i < fpr.files.length; i++) {
                      PlatformFile f = fpr.files[i];
                      File file = File(f.path!);
                      if(f.extension == "mp4") {
                        File ft = await VideoServices.generateFileThumbnail(file);
                        addFiles.add({
                          "id": i,
                          "file": file,
                          "thumbnail": ft,
                          "video": VideoEditorController.file(file,
                            maxDuration: const Duration(seconds: 30)
                          )..initialize(),
                          "duration": await VideoServices.getDuration(file),
                          "type": f.extension,
                          "text": TextEditingController()
                        });
                      } else {
                        addFiles.add({ 
                          "id": i,
                          "file": file,
                          "thumbnail": "",
                          "video": VideoEditorController.file(file,
                            maxDuration: const Duration(seconds: 30)
                          )..initialize(),
                          "duration": "",
                          "type": f.extension,
                          "text": TextEditingController()
                        });
                      }
                    }
                  } else {
                    PlatformFile f = fpr.files.single;
                    File file = File(f.path!);
                    if(f.extension == "mp4") {
                      addFiles.add({
                        "id": 0,
                        "file": file,
                        "thumbnail": "",
                        "video": VideoEditorController.file(file,
                          maxDuration: const Duration(seconds: 30)
                        )..initialize(),
                        "duration": await VideoServices.getDuration(file),
                        "type": f.extension,
                        "text": TextEditingController()
                      });
                    } else {
                      addFiles.add({
                        "id": 0,
                        "thumbnail": "",
                        "file": file,
                        "video": "",
                        "duration": "",
                        "type": f.extension,
                        "text": TextEditingController()
                      });
                    }
                  }
                  Future.delayed(const Duration(seconds: 3), () {
                    NavigationService().pushNavReplacement(context, ReadyForSentScreen(files: addFiles));
                  });
                }
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                cameraC!.value.isInitialized
                ? Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: cameraC!.value.aspectRatio,
                      child: CameraPreview(cameraC!),
                    ),
                  )
                : Container(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildGalleryBar(),
                      buildControlBar(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(sec == 0 ? 'Hold for Video, or Tap for photo' : sec.toString(),
                          style: openSans.copyWith(
                            color: ColorResources.white,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          )
                        ),
                      )
                    ],
                  ),
                ),
                multipleFiles.isEmpty 
                ? const SizedBox() 
                : Positioned(
                    bottom: 175.0,
                    right: 20.0,
                    child: Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorResources.success
                    ),
                    child: InkWell(
                      onTap: () { 
                        NavigationService().pushNavReplacement(context, ReadyForSentScreen(
                          files: addFiles,
                        ));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check,
                          color: ColorResources.white,
                          size: 30.0,
                        ),
                      ),
                    )
                  )
                ),
              ],
            ),
          )
        );
      },
    );
  }
}