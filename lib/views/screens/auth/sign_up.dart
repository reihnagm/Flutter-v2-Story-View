import 'package:flutter/material.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({ Key? key }) : super(key: key);

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Builder(
      builder: (context) {
        return Scaffold(
          key: globalKey,
          backgroundColor: Colors.white,
        );
      },
    );
  }
}