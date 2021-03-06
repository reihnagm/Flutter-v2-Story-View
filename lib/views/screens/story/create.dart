import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;

import 'package:story_view_app/providers/story/story.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({ 
    Key? key,
  }) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  Color backgroundC = Colors.blueAccent;
  Color textC = Colors.white;

  late TextEditingController captionC;

  List<Map<String, dynamic>> addFiles = [];

  @override 
  void initState() {
    super.initState();
    captionC = TextEditingController();
  }

  @override 
  void dispose() {
    captionC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: backgroundC,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          FloatingActionButton(
            elevation: 0.0,
            mini: true,
            backgroundColor: ColorResources.white,
            foregroundColor: ColorResources.black,
            onPressed: () {
              setState(() {
                backgroundC = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
              });
            },
            child: const Icon(
              Icons.color_lens,
              size: 18.0,
            ),
          ),
          FloatingActionButton(
            elevation: 0.0,
            mini: true,
            backgroundColor: ColorResources.white,
            foregroundColor: ColorResources.black,
            onPressed: () {
              setState(() {
                textC = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
              });
            },
            child: const Icon(
              Icons.text_fields,
              size: 18.0,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                      Container(
                        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: TextField(
                            controller: captionC,
                            cursorColor: ColorResources.white,
                            maxLines: 8,
                            autofocus: true,
                            focusNode: FocusNode(canRequestFocus: true),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none
                              ),
                            ),
                            style: openSans.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              fontWeight: FontWeight.bold,
                              color: textC
                            ),
                          )
                        )
                      )
                    ])
                  )],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                    width: 50.0,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: ColorResources.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)
                        )
                      ),
                      onPressed: () {
                        addFiles.add({
                          "id": 0,
                          "file": "",
                          "thumbnail": "",
                          "video": "",
                          "duration": "",
                          "backgroundColor": backgroundC.value.toRadixString(16),
                          "textColor": textC.value.toRadixString(16),
                          "type": "text",
                          "text": captionC
                        });
                        context.read<StoryProvider>().createStory(context, files: addFiles);
                      },
                      child: context.watch<StoryProvider>().createStoryStatus == CreateStoryStatus.loading 
                      ? const Center(
                          child: SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ColorResources.black),
                            ),
                          ),
                        ) 
                      : const Center(
                        child:  Icon(
                          Icons.send, 
                          color: Colors.black,
                          size: 20.0,
                        ),
                      ),
                    ),
                  )
                )
              ],
            );            
          },
        )
      )
    );
  }
}

