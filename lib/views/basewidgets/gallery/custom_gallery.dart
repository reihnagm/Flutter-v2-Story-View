import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import 'package:video_compress/video_compress.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:story_view_app/main.dart';
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

  List<Widget> mediaList = [];
  List<File?> files = [];
  List<Map<String, dynamic>> addFiles = [];
  List<String?> multipleFiles = [];
  int currentPage = 0;
  CameraController? controller;
  int cameraIndex = 0;

  bool isRecording = false;
  bool cameraNotAvailable = false;

  double containerHeight = 110.0;

  Future<void> getNewMedia() async {
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
                          color: Colors.white,
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
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameras![index], ResolutionPreset.high);
    controller!.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller!.initialize();
      controller!.setFlashMode(FlashMode.off);
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
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      debugPrint(e.toString());
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

  void _onSwitchCamera() {
    if (controller == null ||
      !controller!.value.isInitialized || controller!.value.isTakingPicture) {
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
        "video": VideoEditorController.file(f,
          maxDuration: const Duration(seconds: 30))..initialize(),
        "type": lookupMimeType(file.path)!.split("/")[1],
        "text": TextEditingController()
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ReadyForSentScreen(files: addFiles);
      }));
    }
  }

  Future<XFile?> takePicture() async {
    XFile? file;
    if (!controller!.value.isInitialized || controller!.value.isTakingPicture) {
      return null;
    }
    try {
      file = await controller!.takePicture();
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
              color: Colors.white,
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
                      if(multipleFiles.isEmpty) {
                        if(multipleFiles.contains(files[i]!.path)) {
                          setState(() {
                            multipleFiles.remove(files[i]!.path);
                            addFiles.removeWhere((el) => el["id"] == i);
                          });
                        } else {
                          File? fileThumbnail;
                          String? ext = lookupMimeType(files[i]!.path)!.split("/")[1];
                          if(ext == "mp4") {
                            File ft = await VideoCompress.getFileThumbnail(files[i]!.path);
                            setState(() {
                              fileThumbnail = ft;
                            });
                          }
                          setState(() {
                            multipleFiles.add(files[i]!.path);
                            addFiles.add({
                              "id": i,
                              "file": files[i],
                              "thumbnail": fileThumbnail,
                              "video": VideoEditorController.file(files[i]!,
                                maxDuration: const Duration(seconds: 30))..initialize(),
                              "type": ext,
                              "text": TextEditingController()
                            });
                          });
                        }
                      }
                    },
                    onTap: () async {
                      if(multipleFiles.isNotEmpty) {
                        if(multipleFiles.contains(files[i]!.path)) {
                          setState(() {
                            multipleFiles.remove(files[i]!.path);
                            addFiles.removeWhere((el) => el["id"] == i);
                          });
                        } else {
                          File? fileThumbnail;
                          String? ext = lookupMimeType(files[i]!.path)!.split("/")[1];
                          if(ext == "mp4") {
                            File ft = await VideoCompress.getFileThumbnail(files[i]!.path);
                            setState(() {
                              fileThumbnail = ft;
                            });
                          }
                          setState(() {
                            multipleFiles.add(files[i]!.path);
                            addFiles.add({
                              "id": i,
                              "file": files[i],
                              "thumbnail": fileThumbnail,
                              "video": VideoEditorController.file(files[i]!,
                                maxDuration: const Duration(seconds: 30))..initialize(),
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
                          String? ext = lookupMimeType(files[i]!.path)!.split("/")[1];
                          if(ext == "mp4") {
                            File ft = await VideoCompress.getFileThumbnail(files[i]!.path);
                            setState(() {
                              fileThumbnail = ft;
                            });
                          }
                          setState(() {
                            multipleFiles.add(files[i]!.path);
                            addFiles.add({
                              "id": i,
                              "file": files[i],
                              "thumbnail": fileThumbnail,
                              "video": VideoEditorController.file(files[i]!,
                                maxDuration: const Duration(seconds: 30))..initialize(),
                              "type": ext,
                              "text": TextEditingController()
                            });
                          });
                        }
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
                                  color: Color(0xFF3B833E),
                                  shape: BoxShape.circle
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
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
          color: Colors.transparent,
          child: IconButton(
            color: controller?.value.flashMode == FlashMode.off
            ? Colors.white
            : Colors.blue,
            icon: const Icon(Icons.flash_auto),
            onPressed: controller != null
            ? () {
              if(controller!.value.flashMode == FlashMode.off) {
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
            await controller!.startVideoRecording();
            setState(() {
              isRecording = true;
            });
          },
          onLongPressUp: () async {
            addFiles = [];
            XFile f = await controller!.stopVideoRecording();
            File file = File(f.path);
            addFiles.add({
              "id": 0,
              "file": f,
              "thumbnail": "",
              "video": VideoEditorController.file(file)..initialize(),
              "type": lookupMimeType(file.path)!.split("/")[1],
              "text": TextEditingController()
            });
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ReadyForSentScreen(files: addFiles);
              }));
            });
            setState(() {
              isRecording = false;
            });
          },
          child: isRecording 
          ? Container(
              height: 80.0,
              width: 80.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red,
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
                color: Colors.white,
                width: 5.0,
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.switch_camera),
            onPressed: _onSwitchCamera,
          ),
        )
      ],
    );
  }

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
    getNewMedia();
    initCamera(cameraIndex);
  }
  
  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraNotAvailable) {
      const center = Center(
        child: Text('Camera not available /_\\'),
      );

      return center;
    }

    return Scaffold(
      key: globalKey,
      body: GestureDetector(
        onPanUpdate: (details) async {
          if (details.delta.dy < 0) {
            FilePickerResult? fpr = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              allowCompression: true,
            );
            if(fpr != null) {
              addFiles = [];
              for (int i = 0; i < fpr.files.length; i++) {
                PlatformFile f = fpr.files[i];
                File file = File(f.path!);
                if(f.extension == "mp4") {
                  File ft = await VideoCompress.getFileThumbnail(f.path!);
                  addFiles.add({
                    "id": i,
                    "file": file,
                    "thumbnail": ft,
                    "video": VideoEditorController.file(file,
                      maxDuration: const Duration(seconds: 30))..initialize(),
                    "type": f.extension,
                    "text": TextEditingController()
                  });
                } else {
                  addFiles.add({
                    "id": i,
                    "file": file,
                    "thumbnail": "",
                    "video": VideoEditorController.file(file,
                      maxDuration: const Duration(seconds: 30))..initialize(),
                    "type": f.extension,
                    "text": TextEditingController()
                  });
                }
              }
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ReadyForSentScreen(files: addFiles);
                }));
              });
            }
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            controller!.value.isInitialized
            ? Positioned.fill(
                child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: CameraPreview(controller!),
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
                    child: const Text('Hold for Video, or Tap for photo',
                      style: TextStyle(
                        color: Colors.white
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
                  color: Color(0xFF3B833E)
                ),
                child: InkWell(
                  onTap: () { 
                    Future.delayed(const  Duration(milliseconds: 1500), () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReadyForSentScreen(
                          files: addFiles,
                        )),
                      );
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
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
  }
}