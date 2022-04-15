import 'package:flutter/material.dart';

class CreateStoryScreen extends StatelessWidget {
  final String type;
  const CreateStoryScreen({ 
    Key? key,
    required this.type, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: Colors.blueAccent,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () {},
        child: const Icon(
          Icons.color_lens,
          size: 18.0,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                              child: TextField(
                                cursorColor: Colors.white,
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
                                style: const TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              )
                            )
                          )
                        ]
                      )
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15.0, right: 15.0),
                    width: 60.0,
                    height: 60.0,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Center(
                        child: Icon(
                          Icons.send, 
                          color: Colors.black
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        elevation: 0.0,
                        primary: Colors.white, 
                        onPrimary: Colors.red,
                      ),
                    ),
                  )
                )
              ],
            );            
          },
        )
      )
      // SingleChildScrollView(
        // children: [
        //    Expanded(
        //      child: Center(
        //       child: SingleChildScrollView(
        //         child: Container(
        //           margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        //           child: const TextField(
        //             cursorColor: Colors.white,
        //             maxLines: 8,
        //             style: TextStyle(
        //               fontSize: 30.0,
        //               color: Colors.white,
        //               height: 1.6
        //             ),
        //             decoration: InputDecoration(
        //               border: InputBorder.none
        //             )
        //           ),
        //         ),
        //       ),
        //     ),
        //   )
        // ],
      // )
    );
  }
}

