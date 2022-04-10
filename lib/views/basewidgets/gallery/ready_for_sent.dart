import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:path/path.dart' as p;

import 'package:video_editor/video_editor.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  late VideoEditorController veC;
  late TextEditingController captionC;

  @override 
  void initState() {
    super.initState();
    carouselC = CarouselController();
    captionC = TextEditingController();
  }

  @override 
  void dispose() {
    captionC.dispose();
    veC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(); 
  }
  
  Widget buildUI() {
    return Scaffold(
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
      body: SafeArea(
        child: widget.files.isNotEmpty 
        ? widget.files.length > 1 
        ? viewFiles(context, widget.files)
        : viewFile(context, widget.files) 
        : Container(),
      )
    );
  }

  Widget viewFile(BuildContext context, List<Map<String, dynamic>> files) {
    return Align(
      alignment: Alignment.center,
      child: Image.file(File(files[0]["file"].path))
    );
  }

  Widget viewFiles(BuildContext context, List<Map<String, dynamic>> files) {
    

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
    
          Align(
            alignment: Alignment.center,
            child: SizedBox(
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
                      return Image.file(
                        File(files[i]["file"].path),
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
                                    color: currentIndex == i ? Colors.green : Colors.white
                                  )
                                ),
                                child: Image.file(
                                  File(files[i]["file"].path),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    )
                  )
    
                ]
              ),
            )
          ),
    
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                        onPressed: () {
                        
                        }, 
                        icon: const Icon(
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
      ),
    ); 
  }
}