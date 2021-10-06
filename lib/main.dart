import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:story_view_app/custom/story_view/controller/story_controller.dart';
import 'package:story_view_app/custom/story_view/story_image.dart';
import 'package:story_view_app/custom/story_view/index.dart';
import 'package:story_view_app/custom/story_view/story_video.dart';
import 'package:story_view_app/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int length = 100;

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text("Story View",
          style: TextStyle(
            color: Colors.black54
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3.0,
        mini: true,
        backgroundColor: const Color(0xffEEEEEE),
        foregroundColor: Colors.black,
        onPressed: () {
        },
        child: const Icon(
          Icons.edit,
          size: 18.0,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CachedNetworkImage(
                  filterQuality: FilterQuality.medium,
                  imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
                  errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
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
            title: const Text("Status saya",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0
              ),
            ),
            subtitle: const Text("Ketuk untuk menambahkan pembaruan status",
              style: TextStyle(
                fontSize: 12.0
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ListTile(
            dense: false,
            leading: CachedNetworkImage(
              filterQuality: FilterQuality.medium,
              imageUrl: "https://cdn.pixabay.com/photo/2013/07/13/12/07/avatar-159236_1280.png",
              errorWidget: (BuildContext context, String url, dynamic error) => const Text("error"),
              imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                return CustomPaint(
                  foregroundPainter: DashedCirclePainter(
                    dashes: 6,
                    gapSize: 4,
                    color: Colors.green[700]!,
                    strokeWidth: 2,
                  ),
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage: imageProvider,
                  ),
                );
              },
            ),
            title: const Text("Reihan Agam",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0
              ),
            ),
            subtitle: const Text("Kemarin 10:45",
              style: TextStyle(
                fontSize: 12.0
              ),
            ),
          ),
        ],
      )
    );
  }
}


class CustomRoundedPainter extends CustomPainter {
  Color buttonBorderColor;
  Color progressColor;
  double percentage;
  double width;

  CustomRoundedPainter({required this.buttonBorderColor,required this.progressColor, required this.percentage, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = buttonBorderColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete =  Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      radius,
      line
    );
    double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(
        center: center, 
        radius: radius
      ),
      -pi / 2,
      arcAngle,
      false,
      complete
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DashedCirclePainter extends CustomPainter {
  final int dashes;
  final Color color;
  final double gapSize;
  final double strokeWidth;

  DashedCirclePainter({
    this.dashes = 1,
    this.color = Colors.white,
    this.gapSize = 1,
    this.strokeWidth = 1
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double gap = pi / 180 * gapSize;
    final double singleAngle = (pi * 2) / dashes;

    for (int i = 0; i < dashes; i++) {
      final Paint paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(
          center:  Offset(size.width / 2, size.height / 2), 
          radius:  min(size.width / 2, size.height / 2),
        ), 
        gap + singleAngle * i, 
        singleAngle - gap * 2, false, paint
      );
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) {
    return true;
  }
}