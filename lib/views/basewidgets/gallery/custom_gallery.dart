import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:story_view_app/main.dart';

class TabCamera extends StatefulWidget {
  final bool needScaffold;

  const TabCamera({Key? key, this.needScaffold = true}) : super(key: key);

  @override
  _TabCameraState createState() => _TabCameraState();
}

class _TabCameraState extends State<TabCamera> {
  List<Widget> mediaList = [];
  List<File?> files = [];
  List<String?> multipleFiles = [];
  int currentPage = 0;
  CameraController? controller;
  int cameraIndex = 0;
  bool cameraNotAvailable = false;

  double containerHeight = 110.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showInSnackBar(String message) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
    
  }

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
                        padding: EdgeInsets.only(right: 5, bottom: 5),
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

  void initCamera(int index) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameras![index], ResolutionPreset.high);
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        _showInSnackBar('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
      controller!.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      _showCameraException(e);
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
      _showCameraException(e);
      rethrow;
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      _showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
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


  void _onTakePictureButtonPress() {
    _takePicture().then((filePath) {
      if (filePath != null) {
        // _showInSnackBar('Picture saved to $filePath');
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  icon: Icon(Icons.crop_rotate),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.insert_emoticon),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.text_fields),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {},
                ),
              ],
            ),
            body: Container(
              color: Colors.black,
              child: Center(
                child: Image.file(File(filePath)),
              ),
            ),
          );
        }));
      }
    });
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String?> _takePicture() async {
    if (!controller!.value.isInitialized || controller!.value.isTakingPicture) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/whatsapp_clone';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_timestamp()}.jpg';

    try {
      await controller!.takePicture();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    _showInSnackBar('Error: ${e.code}\n${e.description}');
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
                    onLongPress: () {
                      if(multipleFiles.isEmpty) {
                        if(multipleFiles.contains(files[i]!.path)) {
                          setState(() {
                            multipleFiles.remove(files[i]!.path);
                          });
                        } else {
                          setState(() {
                            multipleFiles.add(files[i]!.path);
                          });
                        }
                      }
                    },
                    onTap: () {
                      if(multipleFiles.isNotEmpty) {
                        if(multipleFiles.contains(files[i]!.path)) {
                          setState(() {
                            multipleFiles.remove(files[i]!.path);
                          });
                        } else {
                          setState(() {
                            multipleFiles.add(files[i]!.path);
                          });
                        }
                      } else {
                        if(multipleFiles.contains(files[i]!.path)) {
                          setState(() {
                            multipleFiles.remove(files[i]!.path);
                          });
                        } else {
                          setState(() {
                            multipleFiles.add(files[i]!.path);
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
          onTap: _onTakePictureButtonPress,
          child: Container(
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
  Widget build(BuildContext context) {
    if (cameraNotAvailable) {
      const center = Center(
        child: Text('Camera not available /_\\'),
      );

      return center;
    }

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) async {
          if (details.delta.dy < 0) {
            await FilePicker.platform.pickFiles(
              allowMultiple: true,
              allowCompression: true,
            );
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
            : const Text('Loading camera...'),
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
                    child: GestureDetector(
                      onLongPress: () {

                      },
                      onLongPressUp: () {

                      },
                      onTap: () {
                        
                      },
                      child: const Text('Hold for Video, or Tap for photo',
                        style: TextStyle(
                          color: Colors.white
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            multipleFiles.isEmpty 
            ? const SizedBox() 
            : Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3B833E)
                ),
                child: InkWell(
                  onTap: () {

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

  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller!.dispose();
    }
  }
}


  

// class GridGallery extends StatefulWidget {
//   final ScrollController? scrollCtr;

//   const GridGallery({
//     Key? key,
//     this.scrollCtr,
//   }) : super(key: key);

//   @override
//   _GridGalleryState createState() => _GridGalleryState();
// }

// class _GridGalleryState extends State<GridGallery> {
//   List<Widget> mediaList = [];
//   int currentPage = 0;
//   int? lastPage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchNewMedia();
//   }

//   _handleScrollEvent(ScrollNotification scroll) {
//     if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
//       if (currentPage != lastPage) {
//         _fetchNewMedia();
//       }
//     }
//   }

//   _fetchNewMedia() async {
//     lastPage = currentPage;
//     var result = await PhotoManager.requestPermission();
//     if (result) {
//       List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
//       List<AssetEntity> media = await albums[0].getAssetListPaged(currentPage, 60);
//       List<Widget> temp = [];
//       for (var asset in media) {
//         temp.add(
//           FutureBuilder(
//             future: asset.thumbDataWithSize(200, 200), 
//             builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Positioned.fill(
//                       child: Image.memory(
//                         snapshot.data!,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     if (asset.type == AssetType.video)
//                       const Align(
//                         alignment: Alignment.bottomRight,
//                         child: Padding(
//                           padding: EdgeInsets.only(right: 5, bottom: 5),
//                           child: Icon(
//                             Icons.videocam,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               }
//               return Container();
//             },
//           ),
//         );
//       }
//       setState(() {
//         mediaList.addAll(temp);
//         currentPage++;
//       });
//     } else {
//       PhotoManager.openSetting();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener<ScrollNotification>(
//       onNotification: (ScrollNotification scroll) {
//         _handleScrollEvent(scroll);
//         return false;
//       },
//       child: GridView.builder(
//         controller: widget.scrollCtr,
//         itemCount: mediaList.length,
//         gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//         itemBuilder: (BuildContext context, int index) {
//           return mediaList[index];
//         }
//       ),
//     );
//   }
// }