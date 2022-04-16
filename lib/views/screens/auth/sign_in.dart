import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/providers/auth/auth.dart';
import 'package:story_view_app/services/navigation.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/basewidgets/button/custom.dart';
import 'package:story_view_app/views/basewidgets/textfield/password.dart';
import 'package:story_view_app/views/basewidgets/textfield/textform.dart';
import 'package:story_view_app/views/screens/auth/sign_up.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({ Key? key }) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late double deviceHeight;
  late double deviceWidth;

  late NavigationService navigation;

  String? phone;
  String? pass;

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
        deviceHeight = MediaQuery.of(context).size.height;
        deviceWidth = MediaQuery.of(context).size.width;
        navigation = NavigationService();
        return Scaffold(
          key: globalKey,
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: deviceWidth * 0.03,
              vertical: deviceHeight * 0.02
            ),
            height: deviceHeight * 0.98,
            width: deviceWidth * 0.97,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 180.0),
                  pageTitle(),
                  const SizedBox(height: 20.0),
                  loginForm(),
                  const SizedBox(height: 20.0),
                  loginButton(),
                  const SizedBox(height: 10.0),
                  registerAccountLink()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget pageTitle() {
    return SizedBox(
      height: deviceHeight * 0.10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Story Status",
            style: openSans.copyWith(
              color: ColorResources.textBlackPrimary,
              fontSize: Dimensions.fontSizeSmall,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(width: 3.0),
          const Icon(
            Icons.chat_bubble_rounded,
            size: 20.0,  
          ),
        ],
      ) 
    );
  }

  Widget loginForm() {
    return Form(
      key: loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextFormField(
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(
              Icons.phone_android,
              size: 20.0,
              color: ColorResources.backgroundBlackPrimary,    
            ),
            onSaved: (val) {
              setState(() { 
                phone = val;
              });
            }, 
            onChanged: (val) {
              setState(() {
                phone = val;
              });
            },
            hintText: "", 
            label: Text("Phone",
              style: openSans.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: ColorResources.textBlackPrimary
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          CustomTextPasswordFormField(
            onSaved: (val) {
              setState(() {
                pass = val;
              });
            }, 
            regex: r".{8,}", 
            hintText: "", 
            label: Text("Password",
              style: openSans.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: ColorResources.textBlackPrimary
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget loginButton() {
    return CustomButton(
      onTap: () {
        if(loginFormKey.currentState!.validate()) {
          loginFormKey.currentState!.save();
          context.read<AuthProvider>().signIn(context, 
            phone: phone!, 
            pass: pass!
          );
        }
      },
      height: 40.0,
      isBorder: false,
      isBoxShadow: true,
      isLoading: context.watch<AuthProvider>().loginStatus == LoginStatus.loading ? true : false,
      btnColor: ColorResources.loaderBluePrimary,
      btnTxt: "Login"
    );
  } 

  Widget registerAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(),
        SizedBox(
          child: Material(
            color: ColorResources.transparent,
            child: InkWell(
              onTap: () {
                navigation.pushNav(context, const SignUpScreen());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Register",
                  style: openSans.copyWith(
                    color: ColorResources.textBlackPrimary,
                    fontSize: Dimensions.fontSizeExtraSmall,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

}